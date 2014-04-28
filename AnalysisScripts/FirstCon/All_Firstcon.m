% varsC = {cellDataMock, cellDataLama};
% varsP = {cellPerimsDataMock, cellPerimsDataLama};
% titles = {'HL60 Mock', 'HL60 LMNA OE', 'Silicone Oil (10 cSt)'};
% frameRates = {800, 800, 500};

% varsC = {cellDataMock, cellDataLama, cellData_d0_6psi, cellData_d4_6psi};
% varsP = {cellPerimsDataMock, cellPerimsDataLama, cellPerimsData_d0_6psi, cellPerimsData_d4_6psi};
% titles = {'HL60 Mock', 'HL60 LMNA OE', 'HL60 d0', 'HL60 d4'};
% frameRates = {800, 800, 300, 300};

% varsC = {cellData_d0_6psi, cellData_d4_6psi};
% varsP = {cellPerimsData_d0_6psi, cellPerimsData_d4_6psi};
% titles = {'HL60 d0', 'HL60 d4'};
% frameRates = {300, 300};

% varsC = {dropDataSilicone10cSt, dropDataSilicone100kcSt};
% varsP = {dropPerimsDataSilicone10cSt, dropPerimsDataSilicone100kcSt};
% titles = {'10 cSt Silicone Droplets', '100k cSt Silicone Droplets'};
% frameRates = {500, 500};

varsC = {cellDataMock, cellDataLama};
varsP = {cellPerimsDataMock,cellPerimsDataLama};
titles = {'hl60_MOCK', 'hl60_LMNAoe'};
frameRates = {800, 800};

% COL 1 - 1st con transit time
% COL 2 - total transit time
% COL 3 - unconstricted length
% COL 4 - max length (%)
% COL 5 - max length (um)
% COL 6 - length relaxation rate
% COL 7 - minimum length convergence
% COL 8 - unconstricted cell area
% % % COL 7 - unconstricted width
% % % COL 8 - width relaxation rate
figure;
for nn = 1:length(varsC)
    consNum = 8;
    cData = varsC{nn};
    pData = varsP{nn};

    idx = 1;
    xs = [];
    ys = [];
    dats = zeros(1, 6);
    datsIt = 1;
    fps = frameRates{nn};

    for laneNum = 1:16
        numCells = length(cData{laneNum});
        for cellNum = 1:numCells
            llane = laneNum; celll = cellNum;
            if isempty(cData{llane}{celll})
                continue;
            end
            
            Firstcon
            datsIt = datsIt+1;
        end
    end
    dats(all(isnan(dats), 2), :) = [];
    subplot(1,length(varsC),nn);
    maxX = 2000;
    mmm = dats(dats(:,1) <= maxX, :); 
    %mmm = mmm(log10(mmm(:,3)) > 1 & log10(mmm(:,3)) < 1.35, :);
    scatter((dats(:,1)), (dats(:,6)));
    %scatter(log(dats(:,3)), log(dats(:,1)));

    title(titles{nn}, 'FontSize', 22);
%     xlabel('Max length (%)', 'FontSize', 14);
%     ylabel('Transit Time 1st Con (ms)', 'FontSize', 14);
    xlim([0 200]);
    ylim([0 20]);
    csvwrite(['D:\firstCon_', titles{nn}, '.csv'], mmm);   
end