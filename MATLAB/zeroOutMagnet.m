clear, clc 

fileName1 = 'withOutMagnetData.m';
fid1 = fopen(fileName1);
fileName2 = 'withMagnetData.m';
fid2 = fopen(fileName2);

for i = 1:3
    fgetl(fid1);
    fgetl(fid2);
%     fgetl(fileHandle);
end

i = 1;
while i<24
    i
    line = fgetl(fid1)
    withMagnet(i,:) = str2num(line(14:end));
    line = fgetl(fid2)
    withOutMagnet(i,:) = str2num(line(14:end));
    i = i + 1;
end



difference = mean(withOutMagnet(:,1:6)) - mean(withMagnet(:,1:6))



