varsC = {cellDataMock, cellDataLama};
varsP = {cellPerimsDataMock, cellPerimsDataLama};
titles = {'HL60 Mock', 'HL60 LamA OE', '10 cSt Silicone Droplets'};
% varsC = {cellData0uMMock, cellData50uMMock, cellData0uMLama}%,, cellData50uMLama}; %, dropDataSilicone100kcSt};
% varsP = {cellPerimsData0uMsMock, cellPerimsData50uMMock, cellPerimsData0uMLama}%, cellPerimsData50uMLama};%, dropPerimsDataSilicone100kcSt};
% titles = {'HL60 Mock',  'HL60 Mock 50uM', 'HL60 LamA', 'HL60 LamA 50uM'};
frameRates = {800, 800, 500};
% varsC = {cellData0uMMock, dropDataSilicone10cSt, cellDataHEYA8Mock} %, dropDataSilicone100kcSt};
% varsP = {cellPerimsData0uMMock, dropPerimsDataSilicone10cSt, cellPerimsDataHEYA8Mock }%, dropPerimsDataSilicone100kcSt};
% titles = {'HL60 Mock',  '100k cSt Silicone', 'HEYA8 MOCK'};
% frameRates = {800, 500, 800};
% varsC = {cellData0uMMock, dropDataSilicone10cSt, dropDataSilicone100kcSt};
% varsP = {cellPerimsData0uMMock, dropPerimsDataSilicone10cSt, dropPerimsDataSilicone100kcSt};
% titles = {'HL60 Mock', '10 cSt Silicone Droplets', '100k cSt Silicone Droplets'};
% frameRates = {800, 500, 500};
figure;
axes('position', [0 0 1 1]);
% varsC = {cellData10cSt_2psi, cellData10cSt_4psi, cellData10cSt_6psi, cellData10cSt_8psi};
% varsP = {cellPerimsData10cSt_2psi, cellPerimsData10cSt_4psi, cellPerimsData10cSt_6psi, cellPerimsData10cSt_8psi};
% titles = {'Silicone 10 cSt @ 2psi', 'Silicone 10 cSt @ 4psi', 'Silicone 10 cSt @ 6psi', 'Silicone 10 cSt @ 8psi'};
% frameRates = {500, 500, 500, 500};
% figure;
colors = {['r'];['g'];['m'];};
% for jjj = 1:2
for nn = 1:length(varsC)
    relDats = []; % stores constriction, time in con, and rel. rate
    consNum = 8;
    cData = varsC{nn};%cellDataHEYA8_5093p; %%CHANGE
    pData = varsP{nn};%cellPerimsDataHEYA8_5093p; %%CHANGE
    idx = 1;
    xs = [];
    ys = [];

    for laneNum = 1:16
        numCells = size(cData{laneNum}, 2);
        for cellNum = 1:numCells
            llane = laneNum; celll = cellNum;
            fps = frameRates{nn};
            RelRateVsDefTime
        end
    end

    %figure;  %%CHANGE
%     if(jjj == 2)
%         offf = 3 + nn;
%     else
%         offf = nn;
%     end
    subplot(1,2,nn); %%CHANGE
%     if (jjj == 2 && nn == 3)
%         maxX = 45;
%     else
        maxX = 2000;
%     end
    %maxY = -.4;
    mmm = relDats(relDats(:,1)==1 & relDats(:,2) <= maxX, :); 
%     if(jjj == 2)
%         %negs = -1./mmm(:, 3);
%         if(nn ~= 3)
%             scatter(mmm(-1./mmm(:,3) < -.1, 2), -1./mmm(-1./mmm(:,3) < -.1, 3));
%         else
%             scatter(mmm(-1./mmm(:,3)>-.3, 2), -1./mmm(-1./mmm(:,3)>-.3, 3));
%         end
%     else
        %loglog(mmm(:,2)', mmm(:,3)');
%     end
    scatter((mmm(:,2)), (mmm(:,3)));
    xlim([0 200]);
    ylim([0 20]);
    % xlim([0 10]);
%     if(jjj == 2)
%         h = lsline;
%         set(h, 'color', colors{nn});
%         set(h, 'LineWidth', 2);
%         ylim([-.8 0]);
%     else
        %ylim([0 10]);
        title(titles{nn});
%     end
     %%CHANGE
%     title('Silicon Oil Droplets @ 10 cSt');
    %title(['0uM Mock - Con #' num2str(nn)]);
    %xlabel('Time in constriction (ms)');
    %ylabel('Relaxation Rate (%/ms)');
    %scatter3(relDats(:, 1), relDats(:, 2), relDats(:, 3));
    %boxplot(relDats);
    
    
    
    hold off;
    1+1
    
    %csvwrite(['D:\fullLength_', num2str(nn), '.csv'], mmm);   
end
% end