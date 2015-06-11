cData = cellData_d0Ext;
pData = cellPerimsData_d0Ext;

ln = 1;
cn = 7;
clear mmm;
for nn = 1:length(cData{ln}{cn})
    A = cData{ln}{cn}(nn,4);
    P = 0;
    for kk = 1:360
        d1 = pData{ln}{cn}(nn, kk);
        d2 = pData{ln}{cn}(nn, kk+1);
        dist = sqrt(d1^2 + d2^2 - 2*d1*d2*cos(1));
        P = P + dist;
    end

    mmm(nn) = (4*pi*A)/(P^2);
end 
mmm = mmm / mmm(1);
figure; plot(1:length(cData{ln}{cn}), mmm);
title('(4*pi*A)/(P^2)');
% figure; plot(1:length(cData{ln}{cn}), cData{ln}{cn}(:,5));