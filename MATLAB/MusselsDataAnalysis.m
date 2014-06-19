clear
format compact
%clc, close all
%Mussel Data Analysis

disp('Started')

%Finding Necessary Files
workingDirectory = 'WorkingRawSD\';
files = dir(workingDirectory);
[countSD,fileSDName] = checkForFile(files,'SD',false);
[countERR,fileErrorLogName] = checkForFile(files,'ERRORLOG.TXT',false);
[countMAG,fileMagnetLogName] = checkForFile(files,'MAGNETLG.TXT',false);
[countDATA,fileMusselName] = checkForFile(files,'MT',true);


%Get Data File Names
dataFileNames = zeros(countDATA,length('MTXXXXXX.TXT'));
k=1;
for i=1:length(files)
    if length(files(i).name)>=length('MT') && strcmp(files(i).name(1:2),'MT')
        dataFileNames(k,:)=files(i).name;
        k=k+1;
    end
end

%Get Rk and Rt@25 from SDXX.TXT file
fid = fopen(strcat(workingDirectory,fileSDName));
if fid == -1
    error('Could not open %s',fileSDName)
end
fgetl(fid); %skip first line
RtFromFile = fgetl(fid);
RkFromFile = fgetl(fid);
fclose(fid);
if ~((length(RtFromFile)>2 && strcmp(RtFromFile(1:2),'Rt')) && length(RkFromFile)>2 && strcmp(RkFromFile(1:2),'Rk'))
    warning('SDXX file in wrong format.')
    fprintf('Proper format is: \nSDXX\nRt xxxxx\nRk xxxxx\n')
    error('SDXX file in wrong format')
end    
Rt = str2num(char(RtFromFile(3:end)));
Rk = str2num(char(RkFromFile(3:end)));

fprintf('Rt@25 = %d   (at 25 degrees Celsius)\n',Rt);
fprintf('Rk    = %d   (known resistance)\n',Rk);

%Getting Timestamps of Resets, 
fid = fopen([workingDirectory,fileErrorLogName]);
if fid == -1
    warning('Could not open %s',fileErrorLogName)
end
fgetl(fid); %ignore start time 
resets = [];
while ~feof(fid)
    resets = [resets; fgetl(fid)];
end
fclose(fid);

%Get Calibration data from MAGNETLG.TXT
fid = fopen([workingDirectory,fileMagnetLogName]);
if fid == -1
    error('Could not open %s',fileMagnetLogName)
end
magLogDataLength = 0;
while ~feof(fid)  %count the number of lines
    line = fgetl(fid);
    magLogDataLength = magLogDataLength + 1;
end
magLogDataLength = magLogDataLength - 2; %ignore last two lines of file
fclose(fid);
magnetLogData = zeros(magLogDataLength,9);
fid = fopen([workingDirectory,fileMagnetLogName]);
timestampLength = length('14/06/17 14:00:01');
for i=1:magLogDataLength
    line = fgetl(fid);
    try
        magnetLogData(i,:) = str2num(char(line(timestampLength+1:end)));
    catch
        error('Reading Line %d of %s failed',i,fileMagnetLogName)
        line
    end
end
fclose(fid);

%Get date of collection from last timestamp
fid = fopen(strcat(workingDirectory , dataFileNames(end,:))); %open last data file
while ~feof(fid)
  line = fgetl(fid);        %get last line of data file
end
fclose(fid);
try                         
    %verify that date is in correct format:
    %14/06/17 14:01:15
    numbers = [line(1:2),line(4:5),line(7:8)];
    slashes = [line(3),line(6)];
    slashesGood = strcmp(slashes,'//');
    isNotDigit = sum((numbers<48) + (numbers>57));%will be zero if characters are digits (ASCII characters)
    if slashesGood && isNotDigit==0
        dateCollected = strcat(line(1:2),'-',line(4:5),'-',line(7:8));
        fprintf('Date SD card collected (YY-MM-DD): %s\n',dateCollected)
    else 
        error()
    end
catch
    error('Last line of last data file does not have a timestamp.')
end

%Create folder for processed data
processedFolder = 'C:\Users\Student\Documents\EE Monterey 2014 MATLAB\ProcessedData\';
dateSDNum = strcat(dateCollected,'-',fileSDName(1:4));
concatFileName = strcat(dateSDNum,'.m');
subFolder = strcat(processedFolder,dateSDNum,'\');
checkFiles = dir(subFolder);
if ~isempty(checkFiles)
    error('Folder %s already exists',subFolder)
end 
if mkdir(subFolder) ~=1
    error('Folder %s could not be created',subFolder)
end
fprintf('Created folder %s\n',subFolder)

%Create concatenated data file
concatFid = fopen(strcat(subFolder,concatFileName),'w');
%%%%check if file already exists/has data in it
if concatFid == -1
    error('Failed to create file %s in %s', concatFileName,subFolder)
end
fprintf('Created file %s\n',concatFileName)

%Concatenate data from each file and write to new file
for i=1:length(dataFileNames(:,1))
    dataFile = strcat(workingDirectory,(dataFileNames(i,:)));
    fid = fopen(dataFile);
    if fid ~= -1
        fprintf('Opened %s\n',dataFile)
    else
        error('Could not open %s',dataFile)
    end
    %Read from file
    while ~feof(fid)
        line = fgets(fid);
        fprintf(concatFid,line);
    end
    fprintf('Wrote %s to %s\n',dataFile,concatFileName)
    fclose(fid);
end
fclose(concatFid);
fprintf('Finished writing concatenated data\n')

%Read and Parse Data into Matlab
dataToProcessFileName = strcat(subFolder,concatFileName);
fid = fopen(dataToProcessFileName);
if fid == -1
    error('Failed to opened file: %s \n',dataToProcessFileName);
end
numberOfRows = numel(textread(dataToProcessFileName,'%1c%*[^\n]')); %count the number of lines in the file
fclose(fid);
fid = fopen(dataToProcessFileName);
fprintf('Opened file: %s \n',dataToProcessFileName);
timestamps = zeros(numberOfRows,timestampLength);
musselData = zeros(numberOfRows,9);
for i=1:numberOfRows
    line = fgetl(fid);
    try
        timestamps(i,:) = line(1:timestampLength);
        musselData(i,:) = str2num(char(line(timestampLength+1:end)));
    catch
        warning('Reading Line %d failed',i)
        line
    end
end
fclose(fid);
fprintf('Finished reading data from %s \n',concatFileName); %dataToProcessFileName);


%Separate data into parts
imuMatrix = musselData(:,1:6);
thermistorResistanceData = musselData(:,7:8);
hallEffectData = musselData(:,9);

%Calculating Thermistor Resistance
disp('Thermistor calculations started')
I = (thermistorResistanceData(:,1)-thermistorResistanceData(:,2))./(Rk);
thermistorResistances = thermistorResistanceData(:,2)./I;
thermistorTemp = resistanceToTemp(thermistorResistances, Rt);
disp('Thermistor calculations finished')

%Calculating Distance from Hall Effect Sensor
disp('Hall effect calculations started')
zeroPoint = mean(magnetLogData(end-60:end,9));
hallEffectDistance = hallVoltsToDist(hallEffectData,zeroPoint);
disp('Hall effect calculations finished')

%IMU Calcs
%%%%Calculating magnet offset for IMU
%%%%Calculating shift offset - make matrix to be inputted into other
%%%%program

%Convert Timestamps to proper format for datenum and datetick
timeTicks = zeros(length(timestamps(:,1)),21);
timeTicks(:,1:17) = timestamps;
for i=1:length(timeTicks(:,1))
    timeTicks(i,18:21) = '.000';
end
a = timeTicks(1,:);
for i=2:length(timeTicks(:,1))
    b = timeTicks(i,:);
    if strcmp(char(a),char(b))
        timeTicks(i,19)='5';
    end
    a = b;
end
% x_axis = datenum(char(timeTicks),'yy/mm/dd HH:MM:SS.FFF');
x_axis = datenum(datevec(char(timeTicks)));

disp('Plotting')
fHandle = figure('units','normalized','outerposition',[0.1 0.1 0.9 0.9]);%makes figure fullscreen (not 'Maximized')
%set(fHandle, 'color', [1 1 1])
%Plotting Thermistor, temperature data
subplot(3,1,1)
hold on
plot(x_axis, thermistorTemp,'o','MarkerSize',1)
title('Thermistor','FontWeight','bold','FontSize',15);ylabel('Temperature, C');
axis([-inf, inf, 5, 45])

%Plotting Hall Effect, Gape data
subplot(3,1,2)
hold on;
plot(x_axis, hallEffectDistance,'ro','MarkerSize',1)
title('Hall Effect','FontWeight','bold','FontSize',15);ylabel('Gape, mm');
axis([-inf, inf, -1,6])

%Plotting IMU, orientation data
subplot(3,1,3)
hold on
title('IMU Data: Red-Acc, Blue-Mag','FontWeight','bold','FontSize',15);xlabel(['Timestamps, Date: ',dateCollected(1:5)]);
axis([-inf, inf, -5000, 5000])
for i=1:3
    plot(x_axis,imuMatrix(:,i),'ro','MarkerSize',1)
end
for i=4:6
    plot(x_axis,imuMatrix(:,i),'bo','MarkerSize',1)
end

%Plotting Resets, Format from file: 'Reset pressed at 14/06/17 13:40:54'
for i=1:length(resets(:,1))
    time = [resets(i,18:end),'.000'];%this code could be better, resets might be off by 0.5 seconds
    xtime = datenum(datevec(char(time)));
    x = [xtime, xtime];
    y = [-20000,20000];
    subplot(3,1,1)
    plot(x,y,'g-')
    subplot(3,1,2)
    plot(x,y,'g-')
    subplot(3,1,3)
    plot(x,y,'g-')
end

%DateTickZoom
subplot(3,1,1)
datetickzoom('x','HH:MM:SS.FFF')
subplot(3,1,2)
datetickzoom('x','HH:MM:SS.FFF')
subplot(3,1,3)
datetickzoom('x','HH:MM:SS.FFF')

%Save the plot alongside the concatenated data file
savefig(fHandle,[subFolder,dateSDNum])
