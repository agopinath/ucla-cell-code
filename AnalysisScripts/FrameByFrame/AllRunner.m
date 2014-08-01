varsC = {cellData_d0Ext};
varsP = {cellPerimsData_d0Ext};
titles = {'HL60 d0'};
frameRates = {600};

figure;
for nn = 1:length(varsC)
    consNum = 8;
    cData = varsC{nn};
    pData = varsP{nn};
    numSamples = 5;
    dats = zeros(1, numSamples);
    datsIt = 1;
    fps = frameRates{nn};
    
    for laneNum = 1:16
        numCells = length(cData{laneNum});
        for cellNum = 1:numCells
            llane = laneNum; celll = cellNum;
            if isempty(cData{laneNum}{cellNum})
                continue;
            end
            
            FBF_CreepRate
            datsIt = datsIt+1;
        end
    end
    figure; boxplot(dats);
%     dats(all(isnan(dats), 2), :) = [];
%     subplot(1,length(varsC),nn);
%     maxX = 2000;
%     mmm = dats(dats(:,1) <= maxX, :); 
% 
%     csvwrite(['D:\firstCon_', num2str(nn), '.csv'], mmm);   
end