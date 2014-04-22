varsC = {cellData0uMMock, dropDataSilicone10cSt, cellData0uMLama, dropDataSilicone100kcSt};
varsP = {cellPerimsData0uMMock, dropPerimsDataSilicone10cSt, cellPerimsData0uMLama, dropPerimsDataSilicone100kcSt};
titles = {'0uM Blebbistatin Mock', '10 cSt Silicone Droplets', '0uM Blebbistatin LamA OE', '100k cSt Silicone Droplets'};
frameRates = {1000, 500, 1000, 500};
figure;
for nn = 1:length(varsC)

    dats = []; % stores constriction, time in con, and rel. rate
    consNum = 8;
    cData = varsC{nn};
    pData = varsP{nn};
    fps = frameRates{nn};
    idx = 1;
    xs = [];
    ys = [];

    for laneNum = 1:16
        numCells = size(cData{laneNum}, 2);
        for cellNum = 1:numCells
            llane = laneNum; celll = cellNum;

            RelRateXDefIdx
        end
    end

    mmm = dats(dats(:,1)==3, :); scatter(mmm(:, 2), (mmm(:, 3)));
    subplot(2,2,nn);
    title(titles{nn});
end

hold off;
1+1