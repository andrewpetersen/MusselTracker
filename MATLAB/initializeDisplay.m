function initializeDisplay()

    %Figure Initialization for IMU Graphics
    figure(100), grid on
    xlabel('x');
    ylabel('y');
    zlabel('z');
    gravity = line([0, 0],[0, 0],[0, -12]);
    north = line([0, 12],[0, 0],[0, 0]);
    view([-40,26]);
%     axis([-1.1 1.1 -1.1 1.1 -1.1 1.1])
    text(0,0,-12,'g')
    text(12,0,0,'N')
    set(gravity,'Color',[1 0 0 ])
    set(north,'Color',[0 0 1])
    

end