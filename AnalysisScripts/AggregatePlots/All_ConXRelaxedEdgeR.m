varsC = {cellDataMock, cellDataLama};
varsP = {cellPerimsDataMock, cellPerimsDataLama};
titles = {'HL60 Mock', 'HL60 LMNA OE', 'Silicone Oil (10 cSt)'};
frameRates = {800, 800, 500};
figure;
colors = {['r'];['b'];['g'];};

for nn = 1:length(varsC)
    idx = 1;
    xs = [];
    ys = [];
    extDists = zeros(1, 7);
    extDistIt = 1;
    cData = varsC{nn};
    pData = varsP{nn};
    fps = frameRates{nn};
    
    for laneNum = 1:16
        numCells = length(cData{laneNum});
        for cellNum = 1:numCells
            llane = laneNum; celll = cellNum;

            ConXRelaxedEdgeR
            extDistIt = extDistIt+1;
            %i = 1;
        end
    end
    subplot(1,2,nn)
    extDists = extDists(~any(isnan(extDists),2),:);
    
    h = boxplot(extDists, 'colors', colors{nn}, 'plotstyle', 'traditional');
    %set(h(6,:),'Visible','off')
    set(h(7,:),'Visible','off')
    if(nn == 1)
        asdf = extDists;
    end
    
    title(titles{nn}, 'FontSize', 20);
    ylim([-50 75]);
    xlim([1.5, 2.5]);
    
    xlabel('Constriction #', 'FontSize', 14);
    ylabel('% Difference From Uncon. Length', 'FontSize', 14);
end

% ti = get(gca,'TightInset')
% set(gca,'Position',[ti(1) ti(2)+.02 1-ti(3)-ti(1) 1-ti(4)-ti(2)]);

hold off;
1+1