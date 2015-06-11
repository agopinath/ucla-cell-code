cData = cellData_d0Ext;
pData = cellPerimsData_d0Ext;

ln = 1;
cn = 7;
clear mmm;

allDegs = (1:361)*pi/180;
[delta, thetaLengthIdx1] = min(abs(allDegs-0));
[delta, thetaLengthIdx2] = min(abs(allDegs-pi));
[delta, thetaWidthIdx1] = min(abs(allDegs-pi/2));
[delta, thetaWidthIdx2] = min(abs(allDegs-3*pi/2));

for nn = 1:length(cData{ln}{cn})
    len = pData{ln}{cn}(nn, thetaLengthIdx1) +  pData{ln}{cn}(nn, thetaLengthIdx2);
    wid = pData{ln}{cn}(nn, thetaWidthIdx1) +  pData{ln}{cn}(nn, thetaWidthIdx2);
    mmm(nn) = axes2ecc(max([len wid]), min([len wid]));
end 
mmm = mmm / mmm(1);
figure; plot(1:length(cData{ln}{cn}), mmm);
title('Ecc');
% figure; plot(1:length(cData{ln}{cn}), cData{ln}{cn}(:,5));