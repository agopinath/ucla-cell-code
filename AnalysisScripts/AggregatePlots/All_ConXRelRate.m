consNum = 8;
cData = cellDataMock;

idx = 1;
xs = [];
ys = [];
relRates = zeros(1, 7);
relRateIt = 1;

for laneNum = 1:16
    numCells = length(cData{laneNum});
    for cellNum = 1:numCells
        llane = laneNum; celll = cellNum;
        
        ConXRelRate
        relRateIt = relRateIt+1;
        %i = 1;
    end
end

figure; boxplot(relRates);

hold off;
1+1