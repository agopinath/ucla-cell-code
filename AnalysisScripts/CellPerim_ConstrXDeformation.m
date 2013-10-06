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
            if(currCon ~= 1)
                conEnd = find(currCell(:,9) == currCon, 1, 'last');
            else
                conEnd = find(currCell(:,9) == currCon, 1, 'first');
            end
            
            if(isempty(conEnd))
                defDeltas(currCon) = NaN;
                deltas{currCon}(end+1) = NaN;
                continue;
            end
            
            if(currCon ~= 1)
                postCon = find(cellData{currLane}{currCellIdx}(:, 9) == i+0.5, 1, 'last');
            else
                postCon = find(cellData{currLane}{currCellIdx}(:, 9) == i, 1, 'last');
            end
            
            if(isempty(postCon) || postCon > numFrames || numFrames < 2 )
                defDeltas(currCon) = NaN;
                deltas{currCon}(end+1) = NaN;
                continue;
            end
            
            postConStart = conEnd+1;
            if(postCon - postConStart > 3)
                postConEnd = postConStart+3;
            else
                postConEnd = postCon;
            end
            
            postConWave = 0;
            for postConIdx = postConStart:postConEnd
                currYs = cellPerimsData{currLane}{currCellIdx}{:, postConIdx};
                if(isempty(currYs))
                    continue;
                end
                postConWave = postConWave + currYs(:, 2);
            end
            postConWave = postConWave/(postConEnd-postConStart+1);
            postConWave = postConWave/cellData{currLane}{currCellIdx}(1, 4); % normalize by dividing by uncon. cell area
            conEndWave = cellPerimsData{currLane}{currCellIdx}{:, conEnd}(:, 2);
            conEndWave = conEndWave/cellData{currLane}{currCellIdx}(1, 4); % normalize by dividing by uncon. cell area
            
            defDeltas(currCon) = sum(abs(postConWave - conEndWave));
            deltas{currCon}(end+1) = defDeltas(currCon)';
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