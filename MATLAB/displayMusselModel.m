function handles = displayMusselModel(transformationMatrix,temperature,gape,handles)
    
    pointsR = [
    0            0           11
   -2            0           11
   -3            0         10.5
  0.5            0          9.5
   -1            1            9
 -2.5            1         9.25
   -4            0            9
  0.5            0            8
-0.25            1         6.75
   -2          1.5          7.5
   -3            1         7.75
-4.25            0            7
-1.25          1.5         5.75
 -2.5         1.75            5
   -3         1.25            6
-4.25            0            5
    0            0            4
 -1.5          1.5            4
 -0.5            1          2.5
   -3          1.5            3
-3.75            0            3
   -2          1.5            2
 -2.5            0         1.25
   -1            1            1
    0            0            0
-0.75            0            0
 -1.5            0         0.25];

%put points into groups of 3 to draw triangles
triangleGroups = [
    1 2 5
    1 4 5
    4 5 8
    5 8 9
    5 10 9
    5 6 10
    2 5 6
    2 3 6
    3 6 7
    6 7 11
    6 11 10
    7 11 12
    11 12 15
    11 15 10
    10 15 14
    10 9 13
    8 9 17
    9 13 17
    12 15 16
    15 16 14
    10 14 13
    13 14 18
    13 18 17
    17 18 19
    17 19 25
    19 24 25
    24 26 25
    24 26 27
    16 14 21
    14 20 21
    14 18 20
    18 22 20
    18 19 22
    20 22 23
    20 23 21
    22 23 27
    19 22 24
    22 24 27];

%make other half of mussel
pointsL = pointsR;
pointsL(:,2) = -pointsL(:,2);

figure(100)

hold on;
    groupR = zeros(3,3);
    groupL = zeros(3,3);
    %view([45,20])
    grid on;
    axis([-12,12,-12,12,-12,12])
    daspect([1 1 1]);
    pbaspect([1 1 1]);

    
    %convert gape distance to half angle
    lengthOfMussel = 63.5; %in milimeters (mm)
    openAngle = atan(gape/(2*lengthOfMussel));
    gapeR = [1,0,0;0,cos(openAngle),-sin(openAngle);0, sin(openAngle),cos(openAngle)];
    gapeL = [1,0,0;0,cos(openAngle), sin(openAngle);0,-sin(openAngle),cos(openAngle)];
    %open halves of mussel
    pointsRdisp = pointsR*gapeR;
    pointsLdisp = pointsL*gapeL;
    
    %transform with given matrix
%     Ry = [cos((2*pi)*(w/num)),0,sin((2*pi)*(w/num));0,1,0;-sin((2*pi)*(w/num)),0,cos((2*pi)*(w/num))];
    
%     physicalOffsetMatrix = [
%    -0.2317   -0.1011   -0.9675
%     0.0521   -0.9944    0.0914
%    -0.9714   -0.0293    0.2357];
% 
% %    physicalOffsetMatrix = inv(physicalOffsetMatrix);
% 
%      pointsRdisp = pointsRdisp*physicalOffsetMatrix;
%      pointsLdisp = pointsLdisp*physicalOffsetMatrix;
    
    pointsRdisp = pointsRdisp*transformationMatrix;
    pointsLdisp = pointsLdisp*transformationMatrix;
    
    
    
    for i=1:length(triangleGroups)
        for k=1:3
            groupR(k,:) = pointsRdisp(triangleGroups(i,k),:);
            groupL(k,:) = pointsLdisp(triangleGroups(i,k),:);
        end
        xR = groupR(:,1);
        yR = groupR(:,2);
        zR = groupR(:,3);    
        xL = groupL(:,1);
        yL = groupL(:,2);
        zL = groupL(:,3);

        %choose a random color
        triColor = [rand,rand,rand]; 
        %make mix color based on temperature
        tempRange = [5,45];
        if(temperature > 45)
            warning('Temperature hit color max')
            temperature = 45;
        elseif(temperature < 5)
            warning('Temperature hit color min')
            temperature = 5;
        end
        amountRed = (temperature-tempRange(1))/(tempRange(2)-tempRange(1));
        mixColor = [amountRed 0 1-amountRed];
        triColor = (triColor+6*mixColor)./7;
        
        try
            delete(handles(2*i+1))
            delete(handles(2*i+2))
        catch 
        end
        handles(2*i+1) = fill3(xR,yR,zR,triColor);
        handles(2*i+2) = fill3(xL,yL,zL,triColor);
    end
 
%     pause(0.01)
end