consNum = 8;
cData = cellDataMock;

idx = 1;
xs = [];
ys = [];
maxExt = zeros(1, 7);
maxExtIt = 1;

for laneNum = 1:16
    numCells = length(cData{laneNum});
    for cellNum = 1:numCells
        llane = laneNum; celll = cellNum;
        
        ConXMaxEdge
        maxExtIt = maxExtIt+1;
        hold off;
        %i = 1;
    end
end

figure; boxplot(maxExt);

hold off;
1+1