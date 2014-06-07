function rsq = rsqCalc(thermocouple, thermistor)

yresid = thermocouple - thermistor;
%Square the residuals and total them obtain the residual sum of squares:
SSresid = sum(yresid.^2);
%Compute the total sum of squares of Thermocouple by multiplying the variance of Thermocouple by the number of observations minus 1:
SStotal = (length(thermocouple)-1) * var(thermocouple);
%Compute R2 using the formula given in the introduction of this topic:
rsq = 1 - SSresid/SStotal;
