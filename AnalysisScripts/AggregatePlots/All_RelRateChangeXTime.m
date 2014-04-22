relCDats = []; % stores constriction, time in con, and rel. rate
consNum = 8;

idx = 1;
xs = [];
ys = [];

for laneNum = 1:16
    numCells = length(cData{laneNum});
    for cellNum = 1:numCells
        llane = laneNum; celll = cellNum;
        
        RelRateChangeXTime
    end
end

figure; scatter3(relCDats(:, 1), relCDats(:, 2), relCDats(:, 3));
%boxplot(relDats);

hold off;
1+1