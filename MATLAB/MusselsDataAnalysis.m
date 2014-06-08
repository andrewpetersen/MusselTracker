clear, clc, close all
%Mussel Data Analysis

disp('Started')
%Reading Text File and Inputing the Data into Matlab
fileName = 'B02-06-06-2014.m';
fid = fopen(fileName);
nRows = numel(textread(fileName,'%1c%*[^\n]'));
fprintf('Opened file: %s \n',fileName);

%Remove Resets - more thorough processing with timestamps to be added later
dataNoReset = zeros(nRows,maxLineLength);  %
resetTimeStamps = zeros(1,100);
k=1;
p=1;
for i=1:nRows
    line = fgetl(fid);
    if ~strcmp(line(1:6),'Mussel') %if there is not a reset line
        trailingZeros = maxLineLength              -length(line);
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
numberOfResets = nRows - k + 1;
%Separate and Parse lines from file into timestamps and data
numberOfRows = nRows - numberOfResets;
timestamps = zeros(numberOfRows,14);
musselData = zeros(numberOfRows,8);
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
thermistorResistanceData = musselData(:,7);
hallEffectData = musselData(:,8);

%Calculating Thermistor Resistance
disp('Thermistor calculations started')
thermistorTemp = resistanceToTemp(thermistorResistanceData, 10000);
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
axis([-inf, inf, 0, 20])

subplot(3,1,2)
hold on;
plot(x_axis, hallEffectDistance - 1.5,'r')
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


