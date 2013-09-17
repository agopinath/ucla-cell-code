function fftData = PostprocessPerimData(cellVideo, cellData, cellPerimsData)

fftData = cell(1, 16);

for i = 1:16
    fftData{i} = {};
    fftData{i}{1} = {};
end

for currLane = 9:16
    numCells = length(cellData{currLane});
    for currCellIdx = 1:numCells
        currCell = cellData{currLane}{currCellIdx};
        currCellPerim = cellPerimsData{currLane}{currCellIdx};
        
        numFrames = size(currCell, 1);
        for currFrameIdx = 1:numFrames
            frameData = currCell(currFrameIdx, :);
            framePerim = currCellPerim{currFrameIdx};
            
            numPoints = size(framePerim, 1);
            frequency = 1 / numPoints;
            centrX = frameData(2);
            centrY = frameData(3);
            
            dists = [];
            for currPointIdx = 1:numPoints
                dists(currPointIdx) = sqrt((centrX-framePerim(currPointIdx, 1))^2 +...
                                           (centrY-framePerim(currPointIdx, 2))^2);
            end
            
            times = (0:numPoints-1)*frequency;
            fftData{currLane}{currCellIdx}{currFrameIdx} = dists;
            if currFrameIdx == 1
                figure; plot(times, dists);
            else
                hold on; plot(times, dists);
            end
            qq=1+1;
        end
    end
end

qq=1+1;