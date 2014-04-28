%% CellsDetectedCleaner.m
% Cleans files processed by CellTrackingEveryFrame to remove duplicate
% entries due to some issues with cell tracking code
nCdata = cell(1, 16);
nPdata = cell(1, 16);
for jj = 1:16
    nCdata{jj} = {};
    nPdata{jj} = {};
    nPdata{jj}{1} = {};
end

cData = cellDataMock2;
pData = cellPerimsDataMock2;

for r = 1:16
    numCells = length(cData{r});
    lastX = 0;
    lastY = 0;
    for j = 1:numCells
        if(size(cData{r}{j}, 1) < 5 ||...
           (cData{r}{j}(end, 2) == lastX && cData{r}{j}(end, 3) == lastY))
            cData{r}{j} = [];
            pData{r}{j} = [];
        end
        if(~isempty(cData{r}{j}))
            lastX = cData{r}{j}(end, 2);
            lastY = cData{r}{j}(end, 3);
        end
    end
end

for r = 1:16
    numCells = length(cData{r});
    numCellsTotal = length(nCdata{r});
    offset = 0;
    for j = 1:numCells
        if(isempty(cData{r}{j}))
            offset = offset - 1;
            continue;
        end
        nCdata{r}{numCellsTotal+offset+j} = cData{r}{j};
        nPdata{r}{numCellsTotal+offset+j} = pData{r}{j};
    end
end

cellDataMock2 = nCdata;
cellPerimsDataMock2 = nPdata;