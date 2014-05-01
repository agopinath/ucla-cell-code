varsC = {cellDataMock, cellDataLama};
varsP = {cellPerimsDataMock, cellPerimsDataLama};
titles = {'HL60 Mock', 'HL60 LMNA OE', 'Silicone Oil (10 cSt)'};
frameRates = {800, 800, 500};

figure;
for nn = 1:length(varsC)
    consNum = 8;
    cData = varsC{nn};
    pData = varsP{nn};
    clear datsIt; clear dats;
    
    xs = [];
    ys = [];
    datsVels = zeros(1, 9);
    datsLen = zeros(1, 9);
    datsIt = 1;
    fps = frameRates{nn};
    for laneNum = 1:16
        numCells = length(cData{laneNum});
        for cellNum = 1:numCells
            llane = laneNum; celll = cellNum;
            if isempty(cData{llane}{celll})
                continue;
            end
            
            AllConsTask
            datsIt = datsIt+1;
        end
    end
    datsVels(all(isnan(datsVels), 2), :) = [];
    datsLen(all(isnan(datsLen), 2), :) = [];
    subplot(1,2,nn);
    boxplot(datsVels(:,1:7))
%     maxX = 2000;
%     mmm = dats(dats(:,1) <= maxX, :); 
%     %mmm = mmm(log10(mmm(:,3)) > 1 & log10(mmm(:,3)) < 1.35, :);
%     scatter((dats(:,1)), (dats(:,6)));
%     %scatter(log(dats(:,3)), log(dats(:,1)));
% 
%     title(titles{nn}, 'FontSize', 22);
% %     xlabel('Max length (%)', 'FontSize', 14);
% %     ylabel('Transit Time 1st Con (ms)', 'FontSize', 14);
%     xlim([0 200]);
%     ylim([0 20]);
%     csvwrite(['D:\allCons_vel_', titles{nn}, '.csv'], datsVels);   
%     csvwrite(['D:\allCons_len_', titles{nn}, '.csv'], datsLen); 
end