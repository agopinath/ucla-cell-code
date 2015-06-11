% varsC = {cellDataMockExt, cellDataLamaExt, cellData_d0Ext, cellData_d4Ext};
% varsP = {cellPerimsDataMockExt, cellPerimsDataLamaExt, cellPerimsData_d0Ext, cellPerimsData_d4Ext};
% titles = {'HL60 Mock Ext', 'HL60 LMNA OE Ext', 'HL60 d0 Ext', 'HL60 d4 Ext'};
% frameRates = {600, 600, 600, 600};

% varsC = {cellDataMockExt, cellDataLamaExt};
% varsP = {cellPerimsDataMockExt, cellPerimsDataLamaExt};
% titles = {'HL60 Mock Ext', 'HL60 LMNA OE Ext', 'HL60 d0 Ext', 'HL60 d4 Ext'};
% frameRates = {600, 600, 600, 600};

% varsC = {cellDataLBRctrl_4psi, cellDataLBRkd_4psi, cellDataMock_4psi, cellDataLama_4psi, cellDataLBRctrld4_all_300fps_4psi, cellDataLBRkdd4_all_300fps_4psi, cellDataLamad4_all_300fps_4psi, cellDataMockd4_all_300fps_4psi, cellDatad0lama_600fps_4psi, cellDatad0mock_600fps_4psi, cellDatad0wt_300fps_4psi, cellDatad0wt_600fps_4psi, cellDatad4wt_300fps_4psi, cellDatad4wt_600fps_4psi};
% varsP = {cellPerimsDataLBRctrl_4psi, cellPerimsDataLBRkd_4psi, cellPerimsDataMock_4psi, cellPerimsDataLama_4psi, cellPerimsDataLBRctrld4_all_300fps_4psi, cellPerimsDataLBRkdd4_all_300fps_4psi, cellPerimsDataLamad4_all_300fps_4psi, cellPerimsDataMockd4_all_300fps_4psi, cellPerimsDatad0lama_600fps_4psi, cellPerimsDatad0mock_600fps_4psi, cellPerimsDatad0wt_300fps_4psi, cellPerimsDatad0wt_600fps_4psi, cellPerimsDatad4wt_300fps_4psi, cellPerimsDatad4wt_600fps_4psi};
% titles = {'LBR ctrl_d4_4psi_300fps', 'LBR kd_d4_4psi_300fps', 'HL60 Mock_d4_4psi_300fps', 'HL60 LMNAoe_d4_4psi_300fps', 'HL60 LBRctrl_all_d4_4psi_300fps', 'HL60 LBRkd_all_d4_4psi_300fps', 'HL60 LMNAoe_all_d4_4psi_300fps', 'HL60 Mock_all_d4_4psi_300fps', 'HL60 LMNAoe_d0_4psi_600fps', 'HL60 Mock_d0_4psi_600fps', 'HL60 WT_d0_4psi_300fps', 'HL60 WT_d0_4psi_600fps', 'HL60 WT_d4_4psi_300fps', 'HL60 WT_d4_4psi_600fps'};
% frameRates = {300, 300, 300, 300, 300, 300, 300, 300, 600, 600, 300, 600, 300, 600};

% varsC = {cellDataMock, cellDataLama, cellData_d0_6psi, cellData_d4_6psi};
% varsP = {cellPerimsDataMock, cellPerimsDataLama, cellPerimsData_d0_6psi, cellPerimsData_d4_6psi};
% titles = {'HL60 Mock', 'HL60 LMNA OE', 'HL60 d0', 'HL60 d4'};
% frameRates = {800, 800, 300, 300};

varsC = {cellDataWTd0_6psi, cellDataWTd4_6psi};
varsP = {cellPerimsDataWTd0_6psi, cellPerimsDataWTd4_6psi};
titles = {'WT D0 6psi', 'WT D4 6psi'};
frameRates = {600, 600};

% varsC = {dropData10cSt, dropData1000cSt, dropData10000cSt};
% varsP = {dropPerimsData10cSt, dropPerimsData1000cSt, dropPerimsData10000cSt};
% titles = {'10 cSt Silicone Droplets', '1k cSt Silicone Droplets', '10k cSt Silicone Droplets'};
% frameRates = {800, 800, 800};

% varsC = {dropDataSilicone100kcSt};
% varsP = {dropPerimsDataSilicone100kcSt};
% titles = {'100k cSt Silicone Droplets'};
% frameRates = {500};

% varsC = {cellDataMock, cellDataLama};
% varsP = {cellPerimsDataMock, cellPerimsDataLama};
% titles = {'hl60_MOCK', 'hl60_LMNAoe'};
% frameRates = {800, 800};

% COL 1 - unconstricted length
% COL 2 - unconstricted width
% COL 3 - unconstricted cell area
% COL 4 - 1st con transit time
% COL 5 - total transit time
% COL 6 - max length (%)
% COL 7 - length relaxation rate
% COL 8 - width relaxation rate
% COL 9 - minimum length convergence
% COL 10 - leading edge creep extent
% COL 11 - leading edge creep time
% COL 12 - leading edge creep rate (extent/time)
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