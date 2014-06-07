%Converts Hall Effect digital voltage to gape distance 
function distances = hallVoltsToDist(hallDigitalVoltages)
%polynomial model from dry mussel test data
p = [11.910638022389092 -23.561862461178915  10.056370472024383];  %polynomial coefficients: p(1)*x^2 + p(2)*x + p(3)
voltages = hallDigitalVoltages*3.3/1024; %3.3V reference voltage with 10-bit ADC resolution (1024 = 2^10)
distances = polyval(p,voltages); %evalulate polynomial