% varsC = {cellDataMockExt, cellDataLamaExt, cellData_d0Ext, cellData_d4Ext};
% varsP = {cellPerimsDataMockExt, cellPerimsDataLamaExt, cellPerimsData_d0Ext, cellPerimsData_d4Ext};
% titles = {'HL60 Mock Ext', 'HL60 LMNA OE Ext', 'HL60 d0 Ext', 'HL60 d4 Ext'};
% frameRates = {600, 600, 600, 600};

varsC = {cellDataMockExt, cellDataLamaExt};
varsP = {cellPerimsDataMockExt, cellPerimsDataLamaExt};
titles = {'HL60 Mock Ext', 'HL60 LMNA OE Ext', 'HL60 d0 Ext', 'HL60 d4 Ext'};
frameRates = {600, 600, 600, 600};

% varsC = {cellDataMock, cellDataLama, cellData_d0_6psi, cellData_d4_6psi};
% varsP = {cellPerimsDataMock, cellPerimsDataLama, cellPerimsData_d0_6psi, cellPerimsData_d4_6psi};
% titles = {'HL60 Mock', 'HL60 LMNA OE', 'HL60 d0', 'HL60 d4'};
% frameRates = {800, 800, 300, 300};

% varsC = {cellData_d0, cellData_d4};
% varsP = {cellPerimsData_d0, cellPerimsData_d4};
% titles = {'HL60 d0', 'HL60 d4'};
% frameRates = {300, 300};

% varsC = {dropDataSilicone10cSt};
% varsP = {dropPerimsDataSilicone10cSt};
% titles = {'10 cSt Silicone Droplets', '100k cSt Silicone Droplets'};
% frameRates = {500, 500};

% varsC = {dropDataSilicone100kcSt};
% varsP = {dropPerimsDataSilicone100kcSt};
% titles = {'100k cSt Silicone Droplets'};
% frameRates = {500};

% varsC = {cellDataMock, cellDataLama};
% varsP = {cellPerimsDataMock, cellPerimsDataLama};
% titles = {'hl60_MOCK', 'hl60_LMNAoe'};
% frameRates = {800, 800};

% COL 1 - 1st con transit time
% COL 2 - total transit time
% COL 3 - unconstricted length
% COL 4 - max length (%)
% COL 5 - length relaxation rate
% COL 6 - minimum length convergence
% COL 7 - unconstricted cell area
% COL 8 - leading edge creep extent
% COL 9 - leading edge creep time
% COL 10 - leading edge creep rate (extent/time)
figure;
for nnn = 1:length(varsC)
    consNum = 8;
    cData = varsC{nnn};
    pData = varsP{nnn};

    idx = 1;
    xs = [];
    ys = [];
    dats = zeros(1, 10);
    datsIt = 1;
    fps = frameRates{nnn};

    for laneNum = 1:16
        numCells = length(cData{laneNum});
        for cellNum = 1:numCells
            llane = laneNum; celll = cellNum;
            if isempty(cData{llane}{celll}) || cData{llane}{celll}(1, 4) > 450
                continue;
            end
            
            Firstcon
            datsIt = datsIt+1;
        end
    end
    dats(all(isnan(dats), 2), :) = [];
%     maxX = 2000;
%     mmm = dats(dats(:,1) <= maxX, :); 
    subplot(1,length(varsC),nnn);
    scatter((dats(:,1)), (dats(:,5)));
    title(titles{nnn}, 'FontSize', 22);
    xlim([0 200]);
    ylim([0 20]);
%     xlabel('Max length (%)', 'FontSize', 14);
%     ylabel('Transit Time 1st Con (ms)', 'FontSize', 14);
    csvwrite(['D:\firstCon_', titles{nnn}, '.csv'], dats);   
end