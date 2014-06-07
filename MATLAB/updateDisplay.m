function handles = updateDisplay(accVector, magVector, normalizedAccVector, normalizedProjectedMagVector, transformationMatrix, temp, gape, i, handles)
    figure(100)
    
    %could add frequency/period stuff here to make elapsed time always accurate
    hours = floor(i/3600);
    minutes = floor((i-hours*3600)/60);
    seconds = i-minutes*60-hours*3600;
    
    title(sprintf('Elapsed Time %d:%d:%d, Temp %f, Gape %f ',hours,minutes,seconds,temp,gape));
    
   
%     physicalOffsetMatrix = [
%    -0.2317   -0.1011   -0.9675
%     0.0521   -0.9944    0.0914
%    -0.9714   -0.0293    0.2357];

    
%     normalizedAccVector = normalizedAccVector*physicalOffsetMatrix;
%     normalizedProjectedMagVector = normalizedProjectedMagVector*physicalOffsetMatrix;

    accVectorDemo = transformationMatrix*(normalizedAccVector');
    magVectorDemo = transformationMatrix*(normalizedProjectedMagVector');

    %Check if Demo is in the correct position   
    if(pdist([accVectorDemo';0,0,-1])>0.00001)
       fprintf('Error at index %d: acceleration vector not properly transformed.',i) 
    end
    if(pdist([magVectorDemo';1,0,0])>0.00001)
       fprintf('Error at index %d: magnetic vector not properly transformed.',i) 
    end
    
    %Display Results
    figure(100)
    handles = displayMusselModel(transformationMatrix,temp,gape,handles);
    try
    delete ( handles(1) );
    delete ( handles(2) );
    catch
    end
    accID = line([0, normalizedAccVector(1)*12],[0, normalizedAccVector(2)*12],[0, normalizedAccVector(3)*12]);
    magID = line([0, normalizedProjectedMagVector(1)*12],[0, normalizedProjectedMagVector(2)*12],[0, normalizedProjectedMagVector(3)*12]);
%     accVector = accVector./norm(accVector);
%     magVector = magVector./norm(magVector);
%  
%     accID = line([0, accVector(1)*12],[0, accVector(2)*12],[0, accVector(3)*12]);
%     magID = line([0, magVector(1)*12],[0, magVector(2)*12],[0, magVector(3)*12]);
    handles(1) = accID;
    handles(2) = magID;
    set(accID,'Color',[1 0 0])
    set(magID,'Color',[0 0 1])
    
end