function [cellData, cellPerimsData] = CellTrackingEveryFrame(numFrames, framerate, template, processedFrames, xOffset)
currFrameIdx = 1;
%dbstop in CellTrackingEveryFrame at 68 if (currFrameIdx == 78)
dbstop if error

% Change WRITEVIDEO_FLAG to true in order to print a video of the output,
% defaults to false.
WRITEVIDEO_FLAG = false;

%% Initializations

% Initialize cell array cellData to store the cell data
% of each cell at every frame between the start and end lines
% The data for the stored cells are referenced as: 
%   cellData{lane#}{cellID}
cellData = cell(1, 16);

cellPerimsData = cell(1, 16);

for i = 1:16
    cellData{i} = {};
    cellPerimsData{i} = {};
    cellPerimsData{i}{1} = {};
end

newCells = false(1, 16);
checkingArray = false(1, 16);
numPassing = zeros(1, 16);
cellsPassing = cell(1, 16);

% HARD CODED x coordinates for the center of each lane (1-16), shifted by
% the offset found in 'MakeWaypoints'
laneCoords = [16 48 81 113 146 178 210 243 276 308 341 373 406 438 471 503] + xOffset;

% Labels each grid line in the template from 1-8 starting at the top
[tempmask, ~] = bwlabel(template);

% Uses the labeled template to find the y coordinate of the start and
% ending tripwires, tripWireStart and tripWireEnd, respectively
q = regionprops(ismember(tempmask, 1), 'PixelList');
tripWireStart = q(1,1).PixelList(1,2);
q = regionprops(ismember(tempmask, 9), 'PixelList');
tripWireEnd = q(1,1).PixelList(1,2);
q = regionprops(ismember(tempmask, 2), 'PixelList');
tripWireCheck = q(1,1).PixelList(1,2);
clear tempmask;

%% Opens a videowriter object if needed
if(WRITEVIDEO_FLAG)
    outputVideo = VideoWriter('G:\CellVideos\compiled_data\output_video.avi');
    outputVideo.FrameRate = cellVideo.FrameRate;
    open(outputVideo)
end

%% Cell Labeling
for currFrameIdx = 120:1273
    currentFrame = processedFrames(:,:,currFrameIdx);
    
    % If the current frame has any objects in it.  Skips any empty frames.
    if any(currentFrame(:) ~= 0)
        %% Label the current frame
        % Count number of cells in the frame and label them
        % (numLabels gives the number of cells found in that frame)
        [labeledFrame, numLabels] = bwlabel(currentFrame);
        % Compute their centroids
        cellProps = regionprops(labeledFrame, 'centroid', 'area', 'BoundingBox',...
                                              'MajorAxisLength', 'MinorAxisLength');
        
        newCells = false(1, 16);
        cellsPassing = cell(1, 16);
        perimPoints = bwboundaries(currentFrame, 'noholes');
        %% Check which line the object intersects with
        for currCellIdx = 1:numLabels
            currCell = cellProps(currCellIdx);
            [offCenter, cellLane] = min(abs(laneCoords-currCell.Centroid(1)));
            
            cellPoints = perimPoints{currCellIdx};
            cellPoints(:,[1,2]) = cellPoints(:,[2,1]);
            currCell.BoundaryPoints = cellPoints; % store points of cell boundary
            
            cellsPassing{cellLane}{length(cellsPassing{cellLane})+1} = currCell;
            
            % If the cell centroid X coord is more than 12 pixels from the
            % nearest hardcoded lane X coord, it's too early to do any
            % tracking, so skip it. Also, skip it if the cell's centroid Y
            % coord is greater than the "end" tripwrie Y coord, indicating
            % that it has finished passing through the region of interest
            if(offCenter > 12 || currCell.Centroid(2) > tripWireEnd)
                continue;
            end
            
            forIntersection = ismember(labeledFrame, currCellIdx);
            % If the cell intersects the "start" tripwire
            if(checkingArray(cellLane) == 0)
                if(any(forIntersection(tripWireStart,:)))
                    % cellID(cellLane) = cellID(cellLane) + 1;
                    newCellIdx = length(cellData{cellLane}) + 1;
                    numPassing(cellLane) = numPassing(cellLane)+1;
                    % passageStatus{cellLane}(cellID(cellLane)) = true;
                    % newEntryIdx = size(cellData{cellLane}{cellID(cellLane)}, 1) + 1;
                    cellData{cellLane}{newCellIdx}(1, 1) = currFrameIdx;
                    cellData{cellLane}{newCellIdx}(1, 2) = currCell.Centroid(1);
                    cellData{cellLane}{newCellIdx}(1, 3) = currCell.Centroid(2);
                    cellData{cellLane}{newCellIdx}(1, 4) = currCell.Area;
                    cellData{cellLane}{newCellIdx}(1, 5) = currCell.MajorAxisLength;
                    cellData{cellLane}{newCellIdx}(1, 6) = currCell.MinorAxisLength;
                    cellData{cellLane}{newCellIdx}(1, 7) = currCell.BoundingBox(3);
                    cellData{cellLane}{newCellIdx}(1, 8) = currCell.BoundingBox(4);
                    
                    if(numPassing(cellLane) > 1)
                        cellData{cellLane}{newCellIdx}(1, 9) = 1;
                    else
                        cellData{cellLane}{newCellIdx}(1, 9) = 0;
                    end
                    
                    if(length(currCell.BoundaryPoints) > 5)
                        pcoords = PreprocessPerimData(currCell);
                        cellPerimsData{cellLane}{newCellIdx}{1} = pcoords;
                    end
                    
                    checkingArray(cellLane) = 1;
                    newCells(cellLane) = 1;
                end
            elseif(abs(currCell.Centroid(2) - tripWireCheck) < 10 && currCell.Centroid(2) > tripWireCheck)
                checkingArray(cellLane) = 0;
            end
        end
        clear cellLane;
        
        for currLane = 1:16
            for i = 1:length(cellData{currLane})
                if(isempty(cellData{currLane}))
                    continue;
                end
                currTrackedCell = cellData{currLane}{i};
                if(~any(currTrackedCell)) % if tracked cell is empty, skip it
                    continue;
                elseif(size(currTrackedCell, 1) == 1 && newCells(currLane) == 1) % if this is a new cell
                    continue;
                elseif(currTrackedCell(end, 1) == -1) % if tracking has been 'capped' for this cell, skip it
                    continue;
                end
                
                lastFrameCell = currTrackedCell(end, :);
                numCells = length(cellsPassing{currLane});
                lowestDist = 100000;
                bestCellIdx = -1;
                for m = 1:numCells
                    currPassingCell = cellsPassing{currLane}{m};
                    if(currPassingCell.Centroid(2) < (lastFrameCell(3)-10))
                        continue;
                    end
                    
                    currDist = sqrt((currPassingCell.Centroid(1)-lastFrameCell(2))^2 +...
                                    (currPassingCell.Centroid(2)-lastFrameCell(3))^2);
                    if(currDist < lowestDist)
                        bestCellIdx = m;
                        lowestDist = currDist;
                    end
                end
                % if no match was found (like in the case of buggy cell detection)
                % or if the lowest distance is greater than a certain amount (meaning
                % that the cell has disappeared and has been matched with another one
                % instead), skip
                if(bestCellIdx == -1 || lowestDist > 20)
                    continue;         
                end
                
                bestCell = cellsPassing{currLane}{bestCellIdx};
                newEntryIdx = size(cellData{currLane}{i}, 1) + 1;
                cellData{currLane}{i}(newEntryIdx, 1) = currFrameIdx;
                cellData{currLane}{i}(newEntryIdx, 2) = bestCell.Centroid(1);
                cellData{currLane}{i}(newEntryIdx, 3) = bestCell.Centroid(2);
                cellData{currLane}{i}(newEntryIdx, 4) = bestCell.Area(1);
                cellData{currLane}{i}(newEntryIdx, 5) = bestCell.MajorAxisLength;
                cellData{currLane}{i}(newEntryIdx, 6) = bestCell.MinorAxisLength;
                cellData{currLane}{i}(newEntryIdx, 7) = bestCell.BoundingBox(3);
                cellData{currLane}{i}(newEntryIdx, 8) = bestCell.BoundingBox(4);
                
                if(numPassing(currLane) > 1)
                    cellData{currLane}{i}(newEntryIdx, 9) = 1;
                else
                    cellData{currLane}{i}(newEntryIdx, 9) = 0;
                end
                
                if(length(bestCell.BoundaryPoints) > 5)
                    pcoords = PreprocessPerimData(bestCell);
                    cellPerimsData{currLane}{i}{newEntryIdx} = pcoords;
                end
                
                %cellPerimsData{currLane}{i}{newEntryIdx} = bestCell.BoundaryPoints;
                
                if(bestCell.Centroid(2) > tripWireEnd)
                    newEntryIdx = newEntryIdx + 1;
                    cellData{currLane}{i}(newEntryIdx, 1) = -1;
                    numPassing(currLane) = numPassing(currLane)-1;
                    if(numPassing(currLane) <= 0)
                        numPassing(currLane) = 0;
                    end
                end
            end
        end
    end
    
    if(WRITEVIDEO_FLAG)
        tempFrame = imoverlay(read(cellVideo,currFrameIdx), bwperim(logical(workingFrame)), [1 1 0]);
        writeVideo(outputVideo, tempFrame);
    end
    % Progress bar update
    if mod(currFrameIdx, floor((numFrames)/100)) == 0
        progressbar([],[], (currFrameIdx/(numFrames)))
    end
end

%% Do post-processing of cell data
% remove the "cap" entry (row of -1's) at the end of every tracked cell
for r = 1:16
    numCells = length(cellData{r});
    for j = 1:numCells
        if(cellData{r}{j}(end, 1) == -1)
            cellData{r}{j}(end, :) = [];
        end
    end
end

% Closes the video if it is open
if(WRITEVIDEO_FLAG)
    close(outputVideo);
end

