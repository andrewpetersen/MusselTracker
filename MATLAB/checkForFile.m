function  [count, fileName] = checkForFile(files,leadingChars,moreThan1Expected)
    count = 0;
    for i=1:length(files)
        if length(files(i).name)>=length(leadingChars) ...
           && strcmp(files(i).name(1:length(leadingChars)),leadingChars)
            count=count+1;
            fileName = files(i).name;
        end
    end
    if count>1
        if ~moreThan1Expected
            error('More than one %s file found',leadingChars)
        else
            fprintf('%d %s files found\n',count,leadingChars)
        end
    elseif count==0
        error('No %s file found',leadingChars)
    else 
        fprintf('%s found\n',fileName)
    end
    
end