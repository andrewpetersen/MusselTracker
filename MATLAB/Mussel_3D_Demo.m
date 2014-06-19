%Mussles Senior Project
%Thermistor Calculations 
clear; clc; close all;
%points that make up shape of a mussel

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


% 
% points = [ 
% %   x            y            z
%     1            2            0
%     1            4            0
%   1.5            5            0
%   2.5          1.5            0
%     3            3            1
%  2.75          4.5            1
%     3            6            0
%     4          1.5            0
%  5.25         2.25            1
%   4.5            4          1.5
%  4.25            5            1
%     5         6.25            0
%  6.25         3.25          1.5
%     7          4.5            1.75
%     6            5            1.25
%     7         6.25            0
%     8            2            0
%     8          3.5          1.5
%   9.5          2.5            1
%     9            5          1.5
%     9         5.75            0
%    10            4          1.5
% 10.75          4.5            0
%    11            3            1
%    12            2            0
%    12         2.75            0
% 11.75          3.5            0];
% 
% %testing with simple transformations
% %rotate all points around the +y axis by 270 degrees:
% Ry = [cos(3*pi/2),0,sin(3*pi/2);0,1,0;-sin(3*pi/2),0,cos(3*pi/2)];
% points = points*Ry;
% %shift up by 12, z axis
% points(:,3) = points(:,3) + 12;
% %rotate all points around the +z axis by 270 degrees:
% Rz = [cos(3*pi/2),-sin(3*pi/2),0;sin(3*pi/2),cos(3*pi/2),0;0,0,1];
% points = points*Rz;
% %shift up by 2, x axis
% points(:,1) = points(:,1) + 2;

%points = pointsR;

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
%p2 = num2str(pointsL)
%groups2 = triangleGroups + length(points(:,1));
%triangleGroups = [triangleGroups;groups2];
%points = [points; pointsL];


%label points for debugging
% points = [pointsR;pointsL];
% x = points(:,1);
% y = points(:,2);
% z = points(:,3);
% for i = 1:length(x)  
%     text(x(i),y(i),z(i),num2str(i))
% end

%draw
figure('units','normalized','outerposition',[0 0 1 1])
num = 500;
handles = zeros(1,2*length(triangleGroups));
for w=1:num
    
    hold on;
    groupR = zeros(3,3);
    groupL = zeros(3,3);
    view([45,20])
    grid on;
    axis([-12,12,-12,12,-12,12])
    
    %convert gape distance to half angle
    gapeR = [1,0,0;0,cos((pi/4)*(w/num)),-sin((pi/4)*(w/num));0, sin((pi/4)*(w/num)),cos((pi/4)*(w/num))];
    gapeL = [1,0,0;0,cos((pi/4)*(w/num)), sin((pi/4)*(w/num));0,-sin((pi/4)*(w/num)),cos((pi/4)*(w/num))];
    
    pointsRdisp = pointsR*gapeR;
    pointsLdisp = pointsL*gapeL;
    
    %transform with given matrix
    Ry = [cos((2*pi)*(w/num)),0,sin((2*pi)*(w/num));0,1,0;-sin((2*pi)*(w/num)),0,cos((2*pi)*(w/num))];
    pointsRdisp = pointsRdisp*Ry;
    pointsLdisp = pointsLdisp*Ry;
    
    
    
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
        mixColor = [w/num 0 1-w/num];
        triColor = (triColor+6*mixColor)./7;
        
        if(w~=1)
            delete(handles(2*i-1))
            delete(handles(2*i))
        end
        handles(2*i-1) = fill3(xR,yR,zR,triColor);
        handles(2*i) = fill3(xL,yL,zL,triColor);
    end
    daspect([1 1 1]);
    pbaspect([1 1 1]);
    xlabel('x')
    ylabel('y')
    zlabel('z')
    pause(0.0001)
end





