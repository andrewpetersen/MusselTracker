%Returns the projection of magVector on the plane orthogonal to accVector
function projectedMagVector = projectMag(accVector,magVector)
    point1 = [-1*accVector(2)+accVector(3), accVector(1), -1*accVector(1)];
    point2 = cross(point1, accVector);
    projectedMagVector = (dot(magVector,point1)*point1)./(norm(point1)^2) + (dot(magVector,point2)*point2)./(norm(point2)^2); 
end