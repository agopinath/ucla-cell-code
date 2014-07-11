% varsC = {cellDataMock, cellDataLama};
% varsP = {cellPerimsDataMock, cellPerimsDataLama};
% titles = {'HL60 Mock', 'HL60 LMNA OE', 'Silicone Oil (10 cSt)'};
% frameRates = {800, 800, 500};

% varsC = {cellDataMock, cellDataLama, cellData_d0_6psi, cellData_d4_6psi};
% varsP = {cellPerimsDataMock, cellPerimsDataLama, cellPerimsData_d0_6psi, cellPerimsData_d4_6psi};
% titles = {'HL60 Mock', 'HL60 LMNA OE', 'HL60 d0', 'HL60 d4'};
% frameRates = {800, 800, 300, 300}

varsC = {cellData_d0Ext};
varsP = {cellPerimsData_d0Ext};
titles = {'HL60 d0'};
frameRates = {600};

figure;
for nn = 1:length(varsC)
    consNum = 8;
    cData = varsC{nn};
    pData = varsP{nn};

    dats = zeros(1, 7);
    datsIt = 1;
    fps = frameRates{nn};

    for laneNum = 1:16
        numCells = length(cData{laneNum});
        for cellNum = 1:numCells
            llane = laneNum; celll = cellNum;
            if isempty(cData{laneNum}{cellNum})
                continue;
            end
            
            Multi_MaxLen
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