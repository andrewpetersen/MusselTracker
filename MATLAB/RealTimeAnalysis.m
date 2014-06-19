clear; clc; close all;
figure(100); grid on;
xlabel('x');
ylabel('y');
zlabel('z');

%%%%%%%%%%%%%%%%%%%%
delete(instrfind);%%   DELETE BEFORE RUNNING ARDUINO
%%%%%%%%%%%%%%%%%%%%

s = serial('COM5','BaudRate',57600); %Declare serial port stuff
fopen(s);%open the stream (connect to ardiuno)
% fileHandle = fopen('April21LiveMusselTest02.txt');

for i = 1:3
    fgetl(s);
%     fgetl(fileHandle);
end;


%wait until user is ready
%input('Press enter to start samples without magnet');
%gather samples without magnet


%prompt user, wait until user has placed magnet
%input('Press enter, with magnet');

%gather samples with magnet

%calculations

%continue

initializeDisplay();
handles = zeros(1,2*38+2); %number of triangles in mussel model, plus two for reference vectors

i = 1;
while 1
   
%    while s.BytesAvailable < 6
%        pause(.001)
%     end
   
%     holder = (fscanf(s,'%f, %f, %f, %f, %f, %f, %f, %f;'))';
    line = fgetl(s);
%     line = fgetl(fileHandle);
    holder = str2num(line(15:end));
 
    %Thermistor Calculations
    thermistorResistanceData = holder(7);
    thermistorTemp = resistanceToTemp(thermistorResistanceData, 10000)
   
    %Hall Effect Calculations
    hallEffectData = holder(8);
    hallEffectDistance = hallVoltsToDist(hallEffectData)
   
    %---IMU Calculations---
    accVector = holder(1:3)
    magVector = holder(4:6)
    
    
    [normalizedAccVector,          ...
     normalizedProjectedMagVector, ...
     transformationMatrix,         ...
     vectorAngles]   =   IMUCalculations(accVector,magVector);
    
    %disp('pitchAcc pitchMag azimuthAcc azimuthMag')
    %vectorAngles
    handles = updateDisplay(accVector, magVector, normalizedAccVector,         ...
                  normalizedProjectedMagVector,...
                  transformationMatrix,        ...
                  thermistorTemp,           ...
                  hallEffectDistance,       ...
                  i,                           ...
                  handles);
    i = i+1;
end

fclose(s);
