function [cellData, cellPerimsData] = CellTrackingEveryFrame(numFrames, framerate, template, processedFrames, xOffset)
currFrameIdx = 1;
%dbstop in CellTrackingEveryFrame at 68 if (currFrameIdx == 78)
dbstop if error
%progressbar([],[],0)
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
    %for j = 1:length(temp)
    %    temp{j} = zeros(1, 6);
    %end
    cellData{i} = {};
    cellPerimsData{i} = {};
    cellPerimsData{i}{1} = {};
end

% % Initialize vector cellID to store the current ID to use to label
% % each new cell which intersects tripWireStart in every lane. Every time
% % a cell is labeled with an ID, the corresponding lane entry in cellID is
% % incremented
% cellID = zeros(1, 16);

% passageStatus = cell(1, 16);
% for i = 1:16
%     passageStatus{i} = [false];
% end

newCells = false(1, 16);
checkingArray = false(1, 16);
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
for currFrameIdx = 1:1064
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
%         potentialMatches = cell(1,16);
        
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
            
%             % Find the indices of all "open" cells - those which have
%             % already hit the "start" tripwire but have not yet hit the
%             % "end" tripwire (i.e. those which are still passing)
%             cellPassingIndices = find(passageStatus{cellLane});
            
            % If the cell centroid X coord is more than 12 pixels from the
            % nearest hardcoded lane X coord, it's too early to do any
            % tracking, so skip it. Also, skip it if the cell's centroid Y
            % coord is greater than the "end" tripwrie Y coord, indicating
            % that it has finished passing through the region of interest
            if(offCenter > 12 || currCell.Centroid(2) > tripWireEnd)
                continue;
            end
            
%             matchFound = false;
%             for i = 1:length(cellPassingIndices)
%                 checkCell = cellData{cellLane}{cellPassingIndices(i)}(end, :);
%                 if(currCell.Centroid(2) - (checkCell(3)-5) > 0 &&...
%                    (currFrameIdx > checkCell(1)))
% %                    ((abs(checkCell(4) - currCell.Area)) < 0.5*checkCell(4)) &&
%                     disp(['Found match in lane ', num2str(cellLane), ': ']);
%                     checkCell
%                     [currFrameIdx, currCell.Centroid(1), currCell.Centroid(2), currCell.Area...
%                      currCell.MajorAxisLength, currCell.MinorAxisLength]
%                     matchFound = true;
%                     len = length(potentialMatches{cellLane})+1;
%                     potentialMatches{cellLane}(len, 1) = checkCell(1);
%                     potentialMatches{cellLane}(len, 2) = currCellIdx;
%                 end
%             end
            
            forIntersection = ismember(labeledFrame, currCellIdx);
            % If the cell intersects the "start" tripwire
            if(checkingArray(cellLane) == 0)
                if(any(forIntersection(tripWireStart,:)))
                    % cellID(cellLane) = cellID(cellLane) + 1;
                    newCellIdx = length(cellData{cellLane}) + 1;
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
                    
                    cellPerimsData{cellLane}{newCellIdx}{1} = currCell.BoundaryPoints;
                    
                    checkingArray(cellLane) = 1;
                    newCells(cellLane) = 1;
                end
            elseif(abs(currCell.Centroid(2) - tripWireCheck) < 10 && currCell.Centroid(2) > tripWireCheck)
                checkingArray(cellLane) = 0;
            end
        end
        clear cellLane;
        
        for currLane = 1:16
            % numTrackedCells = length(cellfun(@isempty, cellData{currLane}));
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
                %numPotMatches = 2;
                %potentialMatches = cell(2, 1);
                for m = 1:numCells
                    currPassingCell = cellsPassing{currLane}{m};
                    if(currPassingCell.Centroid(2) < (lastFrameCell(3)-10))
                        continue;
                    end
                    
                    currDist = sqrt(currPassingCell.Centroid(1)-lastFrameCell(2) +...
                                    currPassingCell.Centroid(2)-lastFrameCell(3));
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
                
                cellPerimsData{currLane}{i}{newEntryIdx} = bestCell.BoundaryPoints;
                
                if(bestCell.Centroid(2) > tripWireEnd)
                    newEntryIdx = newEntryIdx + 1;
                    cellData{currLane}{i}(newEntryIdx, 1) = -1;
                end
            end
        end
%         for currLane = 1:16
%             cellsPassing = find(passageStatus{currLane});
%             for m = 1:length(cellsPassing)
%                 cellIdx = cellsPassing(m);
%                 if(size(cellData{currLane}{cellIdx}, 1) == 0)
%                     continue;
%                 end
%                 
%                 lastEntry = cellData{currLane}{cellIdx}(end, :);
%                 % If the last entry's frame is the current frame, then
%                 % the entry is for a new cell, so skip matching it
%                 if(lastEntry(1) == currFrameIdx) 
%                     continue;
%                 end
%                 
%                 bestCellIdx = -1;
%                 matchScores = [];
%                 matchScoreIdx = 1;
%                 if(~isempty(potentialMatches{currLane}))
%                     toCheck = potentialMatches{currLane}(potentialMatches{currLane}(:, 1) == lastEntry(1), :);
%                     if(isempty(toCheck)) 
%                         continue;
%                     end
%                     for matchIdx = 1:size(toCheck, 1)
%                         currCell = cellProps(toCheck(matchIdx, 2));
%                         distScore = norm(currCell.Centroid(1)-lastEntry(2), currCell.Centroid(2)-lastEntry(3));
%                         areaScore = abs(currCell.Area - lastEntry(4));
%                         matchScores(matchScoreIdx, 1) = toCheck(matchIdx, 2);
%                         matchScores(matchScoreIdx, 2) = distScore;%0.75*distScore + 0.25*areaScore;
%                     end
%                     
%                     lowestScoreIdx = find(min(matchScores));
%                     bestCellIdx = matchScores(lowestScoreIdx, 1);
%                 end
%                 
%                 if(bestCellIdx ~= -1)
%                     bestCell = cellProps(bestCellIdx);
%                     forIntersection = ismember(labeledFrame, bestCellIdx);
%                     % If the cell intersects the "end" tripwire, "cap" the
%                     % cell frame entries so no more are appended for that
%                     % particular cell
%                     intersectsEndTripwire = any(forIntersection(tripWireEnd,:));
%                     if(intersectsEndTripwire ||...
%                        (~intersectsEndTripwire && bestCell.Centroid(2) > tripWireEnd))
%                         toCap = find(passageStatus{currLane}, 1);
%                         passageStatus{currLane}(toCap) = false;
%                     end
%                     
%                     % Store the cell data for the frame regardless of whether
%                     % it intersects the "end" tripwire
%                     newEntryIdx = size(cellData{currLane}{cellID(currLane)}, 1) + 1;
%                     cellData{currLane}{cellIdx}(newEntryIdx, 1) = currFrameIdx;
%                     cellData{currLane}{cellIdx}(newEntryIdx, 2) = bestCell.Centroid(1);
%                     cellData{currLane}{cellIdx}(newEntryIdx, 3) = bestCell.Centroid(2);
%                     cellData{currLane}{cellIdx}(newEntryIdx, 4) = bestCell.Area(1);
%                     cellData{currLane}{cellIdx}(newEntryIdx, 5) = bestCell.MajorAxisLength;
%                     cellData{currLane}{cellIdx}(newEntryIdx, 6) = bestCell.MinorAxisLength;
%                     cellData{currLane}{cellIdx}(newEntryIdx, 7) = bestCell.BoundingBox(3);
%                     cellData{currLane}{cellIdx}(newEntryIdx, 8) = bestCell.BoundingBox(4);
%                 end
%             end  
%         end 
        
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
