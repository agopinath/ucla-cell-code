cData = cellDatad0wt_600fps_4psi;
pData = cellPerimsDatad0wt_600fps_4psi;

ln = 4;
cn = 4;
frame = 1;
clear mmm;

allDegs = (1:361)*pi/180;
[delta, thetaLengthIdx1] = min(abs(allDegs-0));
[delta, thetaLengthIdx2] = min(abs(allDegs-pi));
[delta, thetaWidthIdx1] = min(abs(allDegs-pi/2));
[delta, thetaWidthIdx2] = min(abs(allDegs-3*pi/2));
figure;
title('R Vs Theta');
plot(1:361, smooth(pData{ln}{cn}(1, :), 3));
pause(15);
for nn = frame:length(cData{ln}{cn})
    plot(1:361, smooth(pData{ln}{cn}(nn, :), 3));
    title(['frame #', num2str(nn)]);
    ylim([0 50]);
    pause(.08);
end 