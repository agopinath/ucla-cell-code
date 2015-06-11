lowerLimit = 1;
upperLimit = 4;

src = {};
for i = lowerLimit:upperLimit
    src{i-lowerLimit+1} = ['cellData', num2str(i)];
end
% {'cellData7', 'cellData8', 'cellData9', 'cellData10', 'cellData11', 'cellData12'};

% {'cellData1', 'cellData2', 'cellData3', 'cellData4', 'cellData5'...
%     , 'cellData6', 'cellData7', 'cellData8', 'cellData9'};
srcPerims = {};
for i = lowerLimit:upperLimit
    srcPerims{i-lowerLimit+1} = ['cellPerimsData', num2str(i)];
end

% src{end+1} = 'f6';
% srcPerims{end+1} = 'f6p';
%{'cellPerimsData7', 'cellPerimsData8', 'cellPerimsData9', 'cellPerimsData10', 'cellPerimsData11', 'cellPerimsData12'};

% {'cellPerimsData1', 'cellPerimsData2',...
%     'cellPerimsData3', 'cellPerimsData4', 'cellPerimsData5'...
%     , 'cellPerimsData6', 'cellPerimsData7', 'cellPerimsData8', 'cellPerimsData9'};

destC = cell(1, 16);
destP = cell(1, 16);
for i = 1:16
    destC{i} = {};
    destP{i} = {};
    destP{i}{1} = [];
end

for srcI = 1:length(src)
    cellDataCurr = eval(src{srcI});
    cellPerimsDataCurr = eval(srcPerims{srcI});
    for r = 1:16
        numCells = length(cellDataCurr{r});
        if(numCells == 0)
            continue;
        end
        numCellsTotal = length(destC{r});
        offset = 0;
        for j = 1:numCells
            if(isempty(cellDataCurr{r}{j}))
                offset = offset - 1;
                continue;
            end
            destC{r}{numCellsTotal+offset+j} = cellDataCurr{r}{j};
            destP{r}{numCellsTotal+offset+j} = cellPerimsDataCurr{r}{j};
        end
    end
end