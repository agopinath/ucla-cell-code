varsC = {cellDataNPC_HMGA2kd};%, cellDataNPC_MECP2, cellDataNPC_NegCntrl};
varsP = {cellPerimsDataNPC_HMGA2kd}%, cellPerimsDataNPC_MECP2, cellPerimsDataNPC_NegCntrl};
titles = {'NPC HMGA2 KD', 'NPC MEPC2', 'NPC Negative Control'};
frameRates = {150, 150, 150};
% figure;
for nn = 1:length(varsC)
    dats = []; % stores constriction, time in con, and rel. rate
    consNum = 8;
    cData = varsC{nn};
    pData = varsP{nn};
    idx = 1;
    xs = [];
    ys = [];
    defIdxs = [];%zeros(1, 7);
    defIdxIt = 1;
    
%     sizeMat = [];
%     for cLane = 1:16
%         numCells = length(cData{cLane});
%         for currCell = 1:numCells
%             sizeMat(end+1) = cData{cLane}{currCell}(1, 4);
%         end
%     end
%     
%     prctt = prctile(sizeMat, [30, 70]);
    
    for laneNum = 1:16
        numCells = length(cData{laneNum});
        for cellNum = 1:numCells
            llane = laneNum; celll = cellNum;
%             if(cData{llane}{celll}(1, 4) < prctt(1) || cData{llane}{celll}(1, 4) > prctt(2))
%                 continue;
%             end
              numSamples = 4;
%             if(nn == 1 || nn == 3)
%                 numSamples = 19;
%             else
%                 numSamples = 9;
%             end
            
            DefIdxRelaxation
            
            defIdxIt = defIdxIt+1;
            %i = 1;
        end
    end
    defIdxs = defIdxs(~any(isnan(defIdxs),2),:);
    defIdxs = defIdxs(defIdxs(:,1)~=0, :);
    subplot(1,3,3);
%     if(nn == 2 || nn == 4)
%         boxplot(defIdxs, 'labels',{'2','4','6','8','10','12','14','16','18','20'});
%     else
%         boxplot(defIdxs);
%     end
    boxplot(defIdxs);
    title(titles{nn});
    xlabel('Time (ms)');
    ylabel('Deformation Index (length/width)');
    ylim([0, 5]);
end

hold off;
1+1