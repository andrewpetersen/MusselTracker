%Shifts the magnetometer data by offset introduced by the gape sensor magnet
% differe
function [accVectorOut, magVectorOut] = magnetOffset(accVector,magVector)
    %difference =  [-4.1739    0.6957   -1.9130   10.3043  -60.0435 -842.5652];
    %difference = [.8    5.9   -3.3   -39.6    240.5    1230.2];
    % shift = [ accX     accY       accZ    magX      magY      magZ ];
     shift = [ 0, 0, 0, 0, 0, 0];
    % shift = [ -32.5128   43.0776    1.7964  -58.1130  133.4861  624.4049];
%     shift = [  -0.2609    6.6087   10.4348   -3.8261 -325.8696 -162.3478];
    accVectorOut = accVector - 0; %shift(1:3);
    %the change in acc shows that the mussel moved slightly 
    magVectorOut = magVector - shift(4:6);
end