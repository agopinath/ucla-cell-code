% varsC = {cellData4psi5um_d0, cellData4psi5um_d4};
% varsP = {cellPerimsData4psi5um_d0, cellPerimsData4psi5um_d4};
% titles = {'HL60 Mock', '10 cSt Silicone Droplets', '100k cSt Silicone Droplets'};
% frameRates = {300, 300, 500};
varsC = {cellData0uMMock, cellDataLama, dropDataSilicone10cSt};
varsP = {cellPerimsData0uMMock, cellPerimsDataLama, dropPerimsDataSilicone10cSt};
titles = {'HL60 Mock', 'HL60 LamA OE', 'Silicone Oil (10 cSt)'};
frameRates = {800, 800, 500};
hFig = figure;
haxes = axes;
colors = {['r'];['b'];['g'];};

for nn = 1:length(varsC)
    consNum = 8;
    cData = varsC{nn};
    pData = varsP{nn};%cellPerimsDataHSF1_NPC;

    idx = 1;
    xs = [];
    ys = [];
    maxExt = zeros(1, 7);
    maxExtIt = 1;
    fps = frameRates{nn};

    for laneNum = 1:16
        numCells = length(cData{laneNum});
        for cellNum = 1:numCells
            llane = laneNum; celll = cellNum;

            ConXMaxEdge
            maxExtIt = maxExtIt+1;
            hold off;
            %i = 1;
        end
    end
    maxExt(all(isnan(maxExt), 2), :) = [];
    size(maxExt, 1)
    %figure; 
    hFig = subplot(1,3,nn);
    haxes = axes;
    boxplot(maxExt, 'colors', colors{nn}, 'plotstyle', 'compact');
    
    title(titles{nn}, 'FontSize', 28);
    xlabel('Constriction #', 'FontSize', 18);
    %ylabel('% Maximum Length Extension');
    ylim([0,200]);
    
    hold off;
    1+1
end