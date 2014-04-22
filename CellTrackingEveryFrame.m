function [cellData, cellPerimsData] = CellTrackingEveryFrame(numFrames, template, processedFrames, xOffset, cellData, cellPerimsData)
currFrameIdx = 1;
%dbstop in CellTrackingEveryFrame at 68 if (currFrameIdx == 78)
dbstop if error

% Change WRITEVIDEO_FLAG to true in order to print a video of the output,
% defaults to false.
WRITEVIDEO_FLAG = false;
CONV_FACTOR = 1.06; % conversion factor in um per pixel.
% MAX_NUM = 20; % maximum number of cells in any lane before it turns out to be an error, and we clear the lane;

%% Initializations
%% Initialize cell data containers
% Initialize cell array cellData to store the cell data
% of each cell at every frame between the start and end lines
% The data for the stored cells are referenced as: 
%   cellData{lane#}{cellID}
cellDataCurr = cell(1, 16);

cellPerimsDataCurr = cell(1, 16);

for i = 1:16
    cellDataCurr{i} = {};
    cellPerimsDataCurr{i} = {};
    cellPerimsDataCurr{i}{1} = {};
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

for jj = 1:8
    q = regionprops(ismember(tempmask, jj), 'PixelList');
    conLines(jj) = q(1,1).PixelList(1,2);
end
clear tempmask;

%% Opens a videowriter object if needed
if(WRITEVIDEO_FLAG)
    outputVideo = VideoWriter('G:\CellVideos\compiled_data\output_video.avi');
    outputVideo.FrameRate = cellVideo.FrameRate;
    open(outputVideo)
end

%% Cell Labeling
for currFrameIdx = 1:numFrames
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
            currCell.LocalIndex = currCellIdx;
            
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
                    newCellIdx = length(cellDataCurr{cellLane}) + 1;
                    numPassing(cellLane) = numPassing(cellLane)+1;
                    % passageStatus{cellLane}(cellID(cellLane)) = true;
                    % newEntryIdx = size(cellData{cellLane}{cellID(cellLane)}, 1) + 1;
                    cellDataCurr{cellLane}{newCellIdx}(1, 1) = currFrameIdx;
                    cellDataCurr{cellLane}{newCellIdx}(1, 2) = currCell.Centroid(1);
                    cellDataCurr{cellLane}{newCellIdx}(1, 3) = currCell.Centroid(2);
                    cellDataCurr{cellLane}{newCellIdx}(1, 4) = currCell.Area*CONV_FACTOR^2;
                    cellDataCurr{cellLane}{newCellIdx}(1, 5) = currCell.MajorAxisLength*CONV_FACTOR;
                    cellDataCurr{cellLane}{newCellIdx}(1, 6) = currCell.MinorAxisLength*CONV_FACTOR;
                    cellDataCurr{cellLane}{newCellIdx}(1, 7) = currCell.BoundingBox(3)*CONV_FACTOR;
                    cellDataCurr{cellLane}{newCellIdx}(1, 8) = currCell.BoundingBox(4)*CONV_FACTOR;
                    cellDataCurr{cellLane}{newCellIdx}(1, 9) = 1;
                    
                    if(numPassing(cellLane) > 1)
                        cellDataCurr{cellLane}{newCellIdx}(1, 10) = 1;
                    else
                        cellDataCurr{cellLane}{newCellIdx}(1, 10) = 0;
                    end
                    
                    if(length(currCell.BoundaryPoints) > 5)
                        pcoords = PreprocessPerimData(currCell, CONV_FACTOR);
                        cellPerimsDataCurr{cellLane}{newCellIdx}{1} = pcoords;
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
            for i = 1:length(cellDataCurr{currLane})
                if(isempty(cellDataCurr{currLane}))
                    continue;
                end
                currTrackedCell = cellDataCurr{currLane}{i};
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
                if(bestCellIdx == -1 || lowestDist > 30)
                    continue;         
                end
                
                bestCell = cellsPassing{currLane}{bestCellIdx};
                newEntryIdx = size(cellDataCurr{currLane}{i}, 1) + 1;
                cellDataCurr{currLane}{i}(newEntryIdx, 1) = currFrameIdx;
                cellDataCurr{currLane}{i}(newEntryIdx, 2) = bestCell.Centroid(1);
                cellDataCurr{currLane}{i}(newEntryIdx, 3) = bestCell.Centroid(2);
                cellDataCurr{currLane}{i}(newEntryIdx, 4) = bestCell.Area*CONV_FACTOR^2;
                cellDataCurr{currLane}{i}(newEntryIdx, 5) = bestCell.MajorAxisLength*CONV_FACTOR;
                cellDataCurr{currLane}{i}(newEntryIdx, 6) = bestCell.MinorAxisLength*CONV_FACTOR;
                cellDataCurr{currLane}{i}(newEntryIdx, 7) = bestCell.BoundingBox(3)*CONV_FACTOR;
                cellDataCurr{currLane}{i}(newEntryIdx, 8) = bestCell.BoundingBox(4)*CONV_FACTOR;
                
                intersectCons = ismember(labeledFrame, bestCell.LocalIndex);
                consIdx = 0;
                for currConIdx = length(conLines):-1:1
                    if(any(intersectCons(conLines(currConIdx), :)))
                        consIdx = currConIdx;
                        break;
                    end
                end
                if consIdx == 0
                    if(mod(cellDataCurr{currLane}{i}(end-1, 9), 0.2) == 0)
                        consIdx = cellDataCurr{currLane}{i}(end-1, 9) + 0.5;
                    else
                        consIdx = cellDataCurr{currLane}{i}(end-1, 9);
                    end
                end
                cellDataCurr{currLane}{i}(newEntryIdx, 9) = consIdx;
                
                if(numPassing(currLane) > 1)
                    cellDataCurr{currLane}{i}(newEntryIdx, 10) = 1;
                else
                    cellDataCurr{currLane}{i}(newEntryIdx, 10) = 0;
                end
                
                if(length(bestCell.BoundaryPoints) > 5)
                    pcoords = PreprocessPerimData(bestCell, CONV_FACTOR);
                    cellPerimsDataCurr{currLane}{i}{newEntryIdx} = pcoords;
                end
                
                %cellPerimsData{currLane}{i}{newEntryIdx} = bestCell.BoundaryPoints;
                
                if(bestCell.Centroid(2) > tripWireEnd)
                    newEntryIdx = newEntryIdx + 1;
                    cellDataCurr{currLane}{i}(newEntryIdx, 1) = -1;
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
    numCells = length(cellDataCurr{r});
    for j = 1:numCells
        if(cellDataCurr{r}{j}(end, 1) == -1)
            cellDataCurr{r}{j}(end, :) = [];
        else
            cellDataCurr{r}{j} = [];
        end
    end
end


for r = 1:16
    numCells = length(cellDataCurr{r});
    for j = 1:numCells
        if(size(cellDataCurr{r}{j}, 1) < 5)
            cellDataCurr{r}{j} = [];
        elseif(cellDataCurr{r}{j}(end, 3) < tripWireEnd)
            cellDataCurr{r}{j} = [];
        end
    end
end

for r = 1:16
    numCells = length(cellDataCurr{r});
%     if(numCells > MAX_NUM)
%         continue;
%     end
    numCellsTotal = length(cellData{r});
    offset = 0;
    for j = 1:numCells
        if(isempty(cellDataCurr{r}{j}))
            offset = offset - 1;
            continue;
        end
        cellData{r}{numCellsTotal+offset+j} = cellDataCurr{r}{j};
        cellPerimsData{r}{numCellsTotal+offset+j} = cellPerimsDataCurr{r}{j};
    end
end

% Closes the video if it is open
if(WRITEVIDEO_FLAG)
    close(outputVideo);
end

