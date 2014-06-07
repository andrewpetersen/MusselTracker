%Converts seconds to X axis 
function x_axis = secondsToXAxis(timestamp)
x_axis = [];
for i = 1:length(timestamp)
    singleDateTime = timestamp(i,1:13);    
    
    hours = str2num(singleDateTime(6:7));
    minutes = str2num(singleDateTime(9:10));
    seconds = str2num(singleDateTime(12:13));

    totalSeconds = hours*3600 + minutes*60 + seconds;
    x_axis = [x_axis totalSeconds];
end


