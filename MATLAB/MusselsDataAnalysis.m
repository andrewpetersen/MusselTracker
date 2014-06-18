clear
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
%Get date of collection from last timestamp
fid = fopen(strcat('WorkingRawSD\' , dataFileNames(end,:)));
while ~feof(fid)
  line = fgetl(fid);
end
fclose(fid);
try 
    numbers = [line(1:2),line(4:5),line(7:8)];
    slashes = [line(3),line(6)];
    slashesGood = strcmp(slashes,'//');
    isNotDigit = sum((numbers<48) + (numbers>57));
    if slashesGood && isNotDigit==0
        dateCollected = strcat(line(1:2),'-',line(4:5),'-',line(7:8));
        fprintf('Date SD card collected (YY-MM-DD): %s\n',dateCollected)
    else 
        error()
    end
catch
    error('Last line of last data file does not have a timestamp.')
end

%Create file for concatenated data
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
concatFid = fopen(strcat(subFolder,concatFileName),'w');
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

%Input Data into Matlab
dataToProcessFileName = strcat(subFolder,concatFileName);
fid = fopen(dataToProcessFileName);
if fid == -1
    error('Failed to opened file: %s \n',dataToProcessFileName);
end
nFileLines = numel(textread(dataToProcessFileName,'%1c%*[^\n]'));
fclose(fid);
fid = fopen(dataToProcessFileName);
fprintf('Opened file: %s \n',dataToProcessFileName);
error('work in progress')
%Remove Resets - more thorough processing with timestamps to be added later
maxLineLength = 400;
dataNoReset = zeros(nFileLines,maxLineLength);  %
resetTimeStamps = zeros(1,100);
k=1;
p=1;
for i=1:nFileLines
    line = fgetl(fid);
    if ~strcmp(line(1:6),'Mussel') %if there is not a reset line
        trailingZeros = maxLineLength-length(line);
        padding = zeros(1,trailingZeros);
        for j=1:length(padding)
            padding(j) = ' ';
        end
        try 
            dataNoReset(k,:) = [line, padding];
        catch
            warning('Removing Resets Failed')
            i
            k
            trailingZeros
            padding
            line
        end
        k=k+1;
    else
        resetTimeStamps(p) = 1;
        
        p=p+1;
    end
end
numberOfResets = nFileLines - k + 1;
%Separate and Parse lines from file into timestamps and data
numberOfRows = nFileLines - numberOfResets;
timestamps = zeros(numberOfRows,14);
musselData = zeros(numberOfRows,9);
for i=1:numberOfRows
    timestamps(i,:) = dataNoReset(i,1:14);
    try
        musselData(i,:) = str2num(char(dataNoReset(i,15:end)));
    catch
        warning('str2num failed')
        i
        stringThing = char(dataNoReset(i,15:end))
        errorThing = str2num(char(dataNoReset(i,15:end)))
    end
end
% musselData = fscanf(fid,'%*s%*s\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d',[8,nRows]);
fclose(fid);
x_axis = 1:length(musselData);

disp('Done reading.')
%error('Stop Point')%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
imuMatrix = musselData(:,1:6);
thermistorResistanceData = musselData(:,7:8);
hallEffectData = musselData(:,9);

%Calculating Thermistor Resistance
disp('Thermistor calculations started')
Rk = 9800;
I = (thermistorResistanceData(:,1)-thermistorResistanceData(:,2))./(Rk);
thermistorResistances = thermistorResistanceData(:,2)./I;
thermistorTemp = resistanceToTemp(thermistorResistances, 10000);
disp('Thermistor calculations finished')

%Calculating Distance from Hall Effect Sensor
disp('Hall effect calculations started')
hallEffectDistance = hallVoltsToDist(hallEffectData);
disp('Hall effect calculations finished')

disp('Plotting')
set(figure, 'color', [1 1 1])
subplot(3,1,1)
hold on
plot(x_axis, thermistorTemp,'o','MarkerSize',1)
title('Thermistor','FontWeight','bold','FontSize',15);ylabel('Temperature, C');
axis([-inf, inf, 5, 45])

subplot(3,1,2)
hold on;
plot(x_axis, hallEffectDistance,'r')
title('Hall Effect','FontWeight','bold','FontSize',15);ylabel('Gape, mm');
axis([-inf, inf, -1,3])

subplot(3,1,3)
hold on
title('IMU Data: Red-Acc, Blue-Mag','FontWeight','bold','FontSize',15);xlabel('Data Points');
axis([-inf, inf, -2000, 2000])
for i=1:3
    plot(x_axis,imuMatrix(:,i),'r')
end
for i=4:6
    plot(x_axis,imuMatrix(:,i),'b')
end


