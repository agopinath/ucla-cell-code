figure; hold on;
xCon = 1:8;
deltas = cell(1, 8);
for currLane = 1:16
    numCells = length(cellData{currLane});
    for currCellIdx = 1:numCells
        currCell = cellData{currLane}{currCellIdx};
        currCellPerim = cellPerimsData{currLane}{currCellIdx};
        
        numFrames = size(currCell, 1);
        for currCon = 1:8
            conEnd = find(currCell(:,9) == currCon, 1, 'last');
            if(isempty(conEnd))
                defDeltas(currCon) = NaN;
                deltas{currCon}(end+1) = NaN;
                continue;
            end
            postCon = conEnd + 1;
            if(postCon > numFrames || numFrames < 2)
                continue;
            end
            if(currCon ~= 1)
                conEnd = currCellPerim{conEnd}(:, 2);
                postCon = currCellPerim{postCon}(:, 2);
            else
                conEnd = currCellPerim{1}(:, 2);
                postCon = currCellPerim{2}(:, 2);
            end
            defDeltas(currCon) = sum(abs(postCon - conEnd));
            deltas{currCon}(end+1) = defDeltas(currCon);
        end
        
    end
end
hold off;
mn = ceil(mean(arrayfun(@(x) length(deltas{x}), xCon)));
for uu = 1:length(xCon)
    while(length(deltas{uu}) < mn)
        deltas{uu}(end+1) = NaN;
    end
end
deltas = horzcat(deltas{1}', deltas{2}', deltas{3}', deltas{4}', deltas{5}',...
                 deltas{6}', deltas{7}', deltas{8}');
boxplot(deltas);
%scatter(xCon, deltas, 36, 'blue');