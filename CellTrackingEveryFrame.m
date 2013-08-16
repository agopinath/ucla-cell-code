function CellTrackingEveryFrame(numFrames, framerate, template, processedFrames, xOffset)
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

for i = 1:16
    temp = cell(1, 50);
    %for j = 1:length(temp)
    %    temp{j} = zeros(1, 6);
    %end
    cellData{i} = temp;
end

% Initialize vector cellID to store the current ID to use to label
% each new cell which intersects tripWireStart in every lane. Every time
% a cell is labeled with an ID, the corresponding lane entry in cellID is
% incremented
cellID = zeros(1, 16);

passageStatus = cell(1, 16);
for i = 1:16
    passageStatus{i} = [false];
end

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
        
        %% Check which line the object intersects with
        for currCellIdx = 1:numLabels
            currCell = cellProps(currCellIdx);
            [offCenter, currLane] = min(abs(laneCoords-currCell.Centroid(1)));
            
            % Find the indices of all "open" cells - those which have
            % already hit the "start" tripwire but have not yet hit the
            % "end" tripwire (i.e. those which are still passing)
            cellPassingIndices = find(passageStatus{currLane});
            
            % If the cell centroid X coord is more than 12 pixels from the
            % nearest hardcoded lane X coord, it's too early to do any
            % tracking, so skip it. Also, skip it if the cell's centroid Y
            % coord is greater than the "end" tripwrie Y coord, indicating
            % that it has finished passing through the region of interest
            if(offCenter > 12 || currCell.Centroid(2) > tripWireEnd)
                continue;
            end
            
            matchFound = false;
            foundIndex = -1;
            for i = 1:length(cellPassingIndices)
                checkCell = cellData{currLane}{cellPassingIndices(i)}(end, :);
                if(currCell.Centroid(2) - (checkCell(3)-3) > 0 &&...
                   ((abs(checkCell(4) - currCell.Area)) < 0.5*currCell.Area) &&...
                   (currFrameIdx > checkCell(1)))
                    disp(['Found match in lane ', num2str(currLane), ': ']);
                    checkCell
                    [currFrameIdx, currCell.Centroid(1), currCell.Centroid(2), currCell.Area...
                     currCell.MajorAxisLength, currCell.MinorAxisLength]
                    matchFound = true;
                    foundIndex = cellPassingIndices(i);
                    break;
                end
            end
            
            forIntersection = ismember(labeledFrame, currCellIdx);
            % If the cell intersects the "start" tripwire
            if(~matchFound && any(forIntersection(tripWireStart,:)))
                cellID(currLane) = cellID(currLane) + 1;
                passageStatus{currLane}(cellID(currLane)) = true;
                newEntryIdx = size(cellData{currLane}{cellID(currLane)}, 1) + 1;
                cellData{currLane}{cellID(currLane)}(newEntryIdx, 1) = currFrameIdx;
                cellData{currLane}{cellID(currLane)}(newEntryIdx, 2) = currCell.Centroid(1);
                cellData{currLane}{cellID(currLane)}(newEntryIdx, 3) = currCell.Centroid(2);
                cellData{currLane}{cellID(currLane)}(newEntryIdx, 4) = currCell.Area;
                cellData{currLane}{cellID(currLane)}(newEntryIdx, 5) = currCell.MajorAxisLength;
                cellData{currLane}{cellID(currLane)}(newEntryIdx, 6) = currCell.MinorAxisLength;
                cellData{currLane}{cellID(currLane)}(newEntryIdx, 7) = currCell.BoundingBox(3);
                cellData{currLane}{cellID(currLane)}(newEntryIdx, 8) = currCell.BoundingBox(4);
            % Else if a match was found
            elseif(matchFound)
                % If the cell intersects the "end" tripwire, "cap" the
                % cell frame entries so no more are appended for that
                % particular cell
                if(any(forIntersection(tripWireEnd,:)))
                    toCap = find(passageStatus{currLane}, 1);
                    passageStatus{currLane}(toCap) = false;
                end
                % Store the cell data for the frame regardless of whether
                % it intersects the "end" tripwire
                newEntryIdx = size(cellData{currLane}{cellID(currLane)}, 1) + 1;
                cellData{currLane}{cellID(currLane)}(newEntryIdx, 1) = currFrameIdx;
                cellData{currLane}{cellID(currLane)}(newEntryIdx, 2) = currCell.Centroid(1);
                cellData{currLane}{cellID(currLane)}(newEntryIdx, 3) = currCell.Centroid(2);
                cellData{currLane}{cellID(currLane)}(newEntryIdx, 4) = currCell.Area(1);
                cellData{currLane}{cellID(currLane)}(newEntryIdx, 5) = currCell.MajorAxisLength;
                cellData{currLane}{cellID(currLane)}(newEntryIdx, 6) = currCell.MinorAxisLength;
                cellData{currLane}{cellID(currLane)}(newEntryIdx, 7) = currCell.BoundingBox(3);
                cellData{currLane}{cellID(currLane)}(newEntryIdx, 8) = currCell.BoundingBox(4);
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

% Closes the video if it is open
if(WRITEVIDEO_FLAG)
    close(outputVideo);
end
