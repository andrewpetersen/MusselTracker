function  [normalizedAccVector,normalizedProjectedMagVector,transformationMatrix, vectorAngles]=IMUCalculations(accVector,magVector)

    %Correct for offset introduced by gape sensor magnet, enter manually
    [accVector, magVector] = magnetOffset(accVector,magVector);

    %Find magnetic vector's projection onto plane orthogonal to acc vector
    projectedMagVector = projectMag(accVector,magVector);

    %test orthogonality
    i;
    if (dot(accVector,projectedMagVector)>0.005 || dot(accVector,projectedMagVector)<-0.005)
        disp('Error: Projected Mag Vector is not orthogonal to AccV.')
        disp(i)
    end

    %Normalize Acc and Mag Vectors
    normalizedAccVector = accVector./norm(accVector);
    normalizedProjectedMagVector = projectedMagVector./norm(projectedMagVector);
    
%     physOffMat =[
%    -0.4023    0.8373    0.3702
%    -0.0711    0.3746   -0.9245
%    -0.9128   -0.3982   -0.0911];
% 
%     normalizedAccVector = normalizedAccVector*physOffMat;
%     normalizedProjectedMagVector = normalizedProjectedMagVector*physOffMat;
    
    %Calculate the Transformation Matrix
    crossProduct = cross(normalizedAccVector, normalizedProjectedMagVector);
    b = [normalizedAccVector; normalizedProjectedMagVector; crossProduct]';
    accEnd = [0,0,-1]; %Earth's Gravitational Field, pointing down
    magEnd = [1,0,0]; %Earth's Magnetic Field, pointing magnetic north
    fixedCross = cross(accEnd,magEnd);
    fixed = [ accEnd; magEnd; fixedCross ]';
    transformationMatrix = fixed/b;
    
    
    %Pitch for Acc and Mag
    pitchAcc = acosd(normalizedAccVector(1,3));
    pitchMag = acosd(normalizedProjectedMagVector(1,3));
    
    %Azimuth for Acc and Mag
    azimuthAcc = atand( normalizedAccVector(1,2) / normalizedAccVector(1,1));
    if (normalizedAccVector(1,3) > 0 && azimuthAcc < 0) ||  (normalizedAccVector(1,3) < 0 && azimuthAcc > 0)
       azimuthAcc = azimuthAcc + 180;
    end
    if azimuthAcc < 0
       azimuthAcc = azimuthAcc + 360;
    end
    
    azimuthMag = atand( normalizedProjectedMagVector(1,2) / normalizedProjectedMagVector(1,1));
    if (normalizedProjectedMagVector(1,3) > 0 && azimuthMag < 0) ||  (normalizedProjectedMagVector(1,3) < 0 && azimuthMag > 0)
       azimuthMag = azimuthMag + 180;
    end
    if azimuthMag < 0
       azimuthMag = azimuthMag + 360;
    end
    vectorAngles = [pitchAcc pitchMag azimuthAcc azimuthMag];

    
end