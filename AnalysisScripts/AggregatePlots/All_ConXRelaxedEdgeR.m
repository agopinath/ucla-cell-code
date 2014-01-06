consNum = 8;
cData = cellDataMock;

idx = 1;
xs = [];
ys = [];
extDists = zeros(1, 7);
extDistIt = 1;

for laneNum = 1:16
    numCells = length(cData{laneNum});
    for cellNum = 1:numCells
        llane = laneNum; celll = cellNum;
        
        ConXRelaxedEdgeR
        extDistIt = extDistIt+1;
        %i = 1;
    end
end

figure; boxplot(extDists);

hold off;
1+1