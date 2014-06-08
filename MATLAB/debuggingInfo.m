clear, clc, close all
disp('Started')
fileName = 'B02-06-06-2014.m';
fid = fopen(fileName);
nRows = numel(textread(fileName,'%1c%*[^\n]'));
fprintf('Opened file: %s \n',fileName);


%Debugging Info Code 
maxLineLength = 0;
lineLengthsHist = zeros(1,2000);
k = 1;
m = 1;
for i=1:nRows 
    line = fgetl(fid);
    lineLength = length(line);
    lineLengthsHist(lineLength) = lineLengthsHist(lineLength) + 1;
    if maxLineLength<lineLength
        maxLineLength = lineLength;
    end
end
maxLineLength
relevantLines = [];
for i=1:length(lineLengthsHist)
    if lineLengthsHist(i)~=0
        relevantLines = [relevantLines, [lineLengthsHist(i);i]];
    end
end
relevantLines
fclose(fid);
fid = fopen(fileName);
allFileLines = zeros(nRows,maxLineLength);
for i=1:nRows
    line = fgetl(fid);
    trailingZeros = maxLineLength-length(line);
    padding = zeros(1,trailingZeros);
    for j=1:length(padding)
        padding(j) = ' ';
    end
    allFileLines(i) = [line;padding];
end
fclose(fid);
fid = fopen(fileName);

i=1;
line = fgetl(fid);
while line~=-1
     lineLength = length(line);
     if ~(lineLength==62 || lineLength==63)
         line
     end
     i=i+1;
     line = fgetl(fid);
end
i=i-1
error('the end')
fclose(fid)
  