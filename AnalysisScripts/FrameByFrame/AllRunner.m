% varsC = {cellDataBlebbistatin};
% varsP = {cellPerimsDataBlebbistatin};
% varsC = {cellDatad0wt_300fps_4psi, cellDatad0wt_600fps_4psi, cellDatad4wt_300fps_4psi, cellDatad4wt_600fps_4psi, cellDataBlebbistatin};
% varsP = {cellPerimsDatad0wt_300fps_4psi, cellPerimsDatad0wt_600fps_4psi, cellPerimsDatad4wt_300fps_4psi, cellPerimsDatad4wt_600fps_4psi, cellPerimsDataBlebbistatin};
% % varsC = {cellData_d0Ext};
% % varsP = {cellPerimsData_d0Ext};
% titles = {'WT d0 300fps', 'WT d0 600fps', 'WT d4 300fps', 'WT d4 600fps', 'HL60 Blebb'};
% frameRates = {300, 600, 300, 600, 200};
% % titles = {'WT d0 300fps'};
% % frameRates = {600};
varsC = {cellDataLBRctrl_4psi, cellDataLBRkd_4psi, cellDataMock_4psi, cellDataLama_4psi, cellDataLBRctrld4_all_300fps_4psi, cellDataLBRkdd4_all_300fps_4psi, cellDataLamad4_all_300fps_4psi, cellDataMockd4_all_300fps_4psi, cellDatad0lama_600fps_4psi, cellDatad0mock_600fps_4psi, cellDatad0wt_300fps_4psi, cellDatad0wt_600fps_4psi, cellDatad4wt_300fps_4psi, cellDatad4wt_600fps_4psi};
varsP = {cellPerimsDataLBRctrl_4psi, cellPerimsDataLBRkd_4psi, cellPerimsDataMock_4psi, cellPerimsDataLama_4psi, cellPerimsDataLBRctrld4_all_300fps_4psi, cellPerimsDataLBRkdd4_all_300fps_4psi, cellPerimsDataLamad4_all_300fps_4psi, cellPerimsDataMockd4_all_300fps_4psi, cellPerimsDatad0lama_600fps_4psi, cellPerimsDatad0mock_600fps_4psi, cellPerimsDatad0wt_300fps_4psi, cellPerimsDatad0wt_600fps_4psi, cellPerimsDatad4wt_300fps_4psi, cellPerimsDatad4wt_600fps_4psi};
titles = {'LBR ctrl_d4_4psi_300fps', 'LBR kd_d4_4psi_300fps', 'HL60 Mock_d4_4psi_300fps', 'HL60 LMNAoe_d4_4psi_300fps', 'HL60 LBRctrl_all_d4_4psi_300fps', 'HL60 LBRkd_all_d4_4psi_300fps', 'HL60 LMNAoe_all_d4_4psi_300fps', 'HL60 Mock_all_d4_4psi_300fps', 'HL60 LMNAoe_d0_4psi_600fps', 'HL60 Mock_d0_4psi_600fps', 'HL60 WT_d0_4psi_300fps', 'HL60 WT_d0_4psi_600fps', 'HL60 WT_d4_4psi_300fps', 'HL60 WT_d4_4psi_600fps'};
frameRates = {300, 300, 300, 300, 300, 300, 300, 300, 600, 600, 300, 600, 300, 600};
% varsC = {cellData_d0Ext, cellData_d4Ext};
% varsP = {cellPerimsData_d0Ext, cellPerimsData_d4Ext};
% titles = {'WT D0 6psi', 'WT D4 6psi'};
% frameRates = {600, 600};
figure;
for datNum = 1:length(varsC)
    consNum = 8;
    cData = varsC{datNum};
    pData = varsP{datNum};
    numSamples = 8;
    dats = zeros(1, numSamples);
    datsIt = 1;
    fps = frameRates{datNum};
    
    for laneNum = 1:16
        numCells = length(cData{laneNum});
        for cellNum = 1:numCells
            llane = laneNum; celll = cellNum;
            if isempty(cData{laneNum}{cellNum})
                continue;
            end
            
            FBF_Eccentricity
            datsIt = datsIt+1;
        end
    end
    1
    
     csvwrite(['D:\fbf\new\fbf_', num2str(titles{datNum}), '.csv'], dats);   
end