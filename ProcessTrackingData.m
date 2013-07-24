%% ProcessTrackingData.m
% function [transitData] = ProcessTrackingData(checkingArray, framerate, cellInfo)
% This function inputs the raw data about the cell objects found in
% cellTracking and fills an output data array with transit information for
% cells.  To be counted, a cell must begin at line 1 and touch every line
% from 1-8.  This function is designed to run quickly, and replaces an
% older version where nested 'for' loops searched through the code.  

% Code from Dr. Amy Rowat's Lab, UCLA Department of Integrative Biology and
% Physiology
% Written by Mike Scott (July 2013)

% Inputs
%   - checkingArray: an array that stores the frame that a cell last hit 
%       each constriction generated in CellTracking 
%   - framerate: an integer that stores the framerate, used to calculate
%       the transit times
%   - cellInfo: a 16 entry cell structure that stores information about
%       cells from each of the 16 lanes. 

% Outputs
%   - transitData: one for unpaired cells, another for paired cells
%       - transitData(:,:,1) is the transit time data
%       - transitData(:,:,2) is the area data
%       - transitData(:,:,3) is the equivalent diameter data
%       - transitData(:,:,4) is the eccentricity data

function [unpairedTransitData, pairedTransitData] = ProcessTrackingData(checkingArray, framerate, cellInfo)

% Tracks the cells
% contactCount stores how many cells have touched a particular line in the
% lane.  The behavior is a little complicated to avoid issues when two
% cells independently enter the lane, but later 'merge' and are detected as
% only one cell.  
%   -It is initialized to zero.
%   -The first row (corresponding to line 1) is incremented by 1 each time 
%   a new cell object touches the first line.
%   - Later rows are incremented by copying the value from the row above
%   them.  For example, if a cell hits line 3, the value for line 3 becomes
%   the value currently in line 2.  Will only be counted as a cell if the
%   current value is less than the element above it, hopefully eliminating
%   blips that are found on lower lines.
%   - Line 1 is never incremented to be 2 larger than line 2.  This will
%   alleviate the issue that we have where line 1 has many blips.
% Each element stores the row where the data should be stored in the data 
% array.  Later filtering will eliminate any 'cell' that does not transit
% all the way through the device.

% laneData is an array containing the frame at which each cell is found
% at each line.  It is a (n x 7) array, where n is the number of cells.
% laneData contains data on every cell found, but will later be pared
% down to eliminate cells that didn't make it all the way through the
% device.  Each column corresponds to a line (1-7), and each row is a new 
% cell.  The numerical entry is the frame in which the cell hit the line,
% and will later be converted to times based on the framerate.
% dim1 = transit time data
% dim2 = area data
% dim3 = diameter data
% dim4 = eccentrity data
laneData = zeros(30,9,4);

% trackingData is a cell that contains the lane data for each lane
trackingData = cell(2,16);

% Goes through the data for each lane (1-16)
for lane = 1:16
    contactCount = zeros(8,1);
    if(any(checkingArray(:,lane) == 0))
        % Does not store any data for the lane if no cells fully transited through the lane
        laneData = zeros(30,9,2);
        continue;
    else
        % For each cell in this lane's data
        for cellIndex = 1:size(cellInfo{lane},1)
            currentLine = cellInfo{lane}(cellIndex,3);
            
            % Once all the cells are evaluated (current line is zero),
            if(currentLine == 0)
               break; 
            end
            
            if(currentLine == 1 && contactCount(1) == contactCount(2))
                % Increment the contact count
                contactCount(1) = contactCount(1) + 1;
                % Write the frame number to trackingData for that cell at
                % line 1
                laneData(contactCount(1), 1, 1) = cellInfo{lane}(cellIndex,1);
                % Write the cell's area to the entry "behind" the frame
                laneData(contactCount(1), 1, 2) = cellInfo{lane}(cellIndex,4);
                % Diameter (from axis lengths)
                laneData(contactCount(1), 1, 3) = (cellInfo{lane}(cellIndex,5) + cellInfo{lane}(cellIndex,6))/2;
                % Eccentricity
                laneData(contactCount(1), 1, 4) = sqrt(1 - (((cellInfo{lane}(cellIndex,6))^2) / ((cellInfo{lane}(cellIndex,5))^2)));
            % If the cell is below line 1, and the contact count for the
            % previous line is greater than the current line (ie the cell
            % moved from the previous line), change the contactCount and
            % write the frame number to laneData 
            elseif(currentLine ~= 1 && contactCount(currentLine) < contactCount(currentLine-1))
                contactCount(currentLine) = contactCount(currentLine-1);
                % Frame number
                laneData(contactCount(currentLine), currentLine, 1) = cellInfo{lane}(cellIndex,1);
                % Area
                laneData(contactCount(currentLine), currentLine, 2) = cellInfo{lane}(cellIndex,4);
                % Diameter
                laneData(contactCount(currentLine), currentLine, 3) = (cellInfo{lane}(cellIndex,5) + cellInfo{lane}(cellIndex,6))/2;
                % Eccentricity
                laneData(contactCount(currentLine), currentLine, 4) = sqrt(1 - (((cellInfo{lane}(cellIndex,6))^2) / ((cellInfo{lane}(cellIndex,5))^2)));
            end
            
            % Checks to make sure that the array is not full, adds more
            % space if necessary
            if(size(laneData,1) <= (contactCount(1) + 2))
               laneData = vertcat(laneData, zeros(10,9,4)); 
            end
        end
 
        % Sets laneData(:,9,2) to the current lane (useful in debugging)
        laneData(:,9,2) = lane;
        
        % Eliminate any rows with zeros in the 8th column (did not transit)
        [row, ~] = find(laneData(:,8,1) ~= 0);
        laneData = laneData(row,:,:);
        
        % Make sure the first cells were not paired (with cells already in
        % the device that are not counted because they did not touch every
        % line).  Basic principle:  Frame where the first cell hits
        % constriction 8 is known.  Look back for the previous cell at
        % frame 8, and see if this frame is greater than the frame where
        % the first cell hits line 1.  If so, pair.
        
        % Looks back from the frame the first cell is at line 8
        index = 1;
        lastEight = 0;
        while (~isempty(laneData) && (index < size(cellInfo{1,lane}, 1)) && (cellInfo{1,lane}(index,1) < laneData(1,8,1)))
            % If there is a cell at line 8 (other than the first counted
            % cell), store the frame at which it hit line 8.
            if(cellInfo{1,lane}(index,3) == 8)
               lastEight = cellInfo{1,lane}(index,1);
            end
            index = index + 1;
        end
        
        % Pair the first cell if it coincides with another (uncounted) cell
        if(~isempty(laneData) && laneData(1,2,1) <= lastEight)
           laneData(1,9,1) = 2;
        end
        
        % Paired cells after the initial cells
        for index = 2:size(laneData,1)
            % If not already paired, set to 1
            if(laneData(index,9,1) == 0)
                laneData(index,9,1) = 1;
            end
            % If the current cell hits line 2 before the previous clears
            % line 8
            if(laneData(index,2,1) < laneData(index-1,8,1))
                laneData(index,9,1) = 2;
                laneData(index-1,9,1) = 2;
            end
        end
        
        % Writes the lonely cells to the first row of trackingData
        [row, ~] = find(laneData(:,9,1) == 1);
        trackingData{1,lane} = laneData(row,:,:);
        
        % Writes paired cells to the second row of trackingData
        [row, ~] = find(laneData(:,9,1) == 2);
        trackingData{2,lane} = laneData(row,:,:);
        
        laneData = zeros(30,9,4);
    end
end

unpairedTransitData = double(vertcat(trackingData{1, 1:16}));
pairedTransitData = double(vertcat(trackingData{2, 1:16}));

% If no cells are in video, fill unpaired and paired transit data with
% zeros to indicate as such
if (isempty(unpairedTransitData))
    unpairedTransitData = zeros(0,9,4);
end
if (isempty(pairedTransitData))
    pairedTransitData = zeros(0,9,4);
end

% Convert the data from frames into delta time values.  After this loop,
% column 1 will store the time at which the cell reached the line, and
% columns 2-7 will store the length of time the cell took to pass between
% the lines. For example, column 2 stores the amount of time it took for
% the cell to go from line 1 to line 2.

unpairedTransitData(:,1:8,1) = 1 / (framerate*10^-3) * unpairedTransitData(:,1:8,1);
pairedTransitData(:,1:8,1) = 1 / (framerate*10^-3) * pairedTransitData(:,1:8,1);

for ii = 1:6
   for jj = 1:size(unpairedTransitData,1)
        unpairedTransitData(jj,9-ii,1) = unpairedTransitData(jj,9-ii,1) - unpairedTransitData(jj,8-ii,1);
   end
end

for ii = 1:6
   for jj = 1:size(pairedTransitData,1)
        pairedTransitData(jj,9-ii,1) = pairedTransitData(jj,9-ii,1) - pairedTransitData(jj,8-ii,1);
   end
end

% Overwrites first column of 1st dimension with the total time
for ii = 1:size(unpairedTransitData,1)
   unpairedTransitData(ii,1,1) = sum(unpairedTransitData(ii,3:8,1));
end

% Overwrites first column of 1st dimension with the total time
for ii = 1:size(pairedTransitData,1)
   pairedTransitData(ii,1,1) = sum(pairedTransitData(ii,3:8,1));
end

% Overwrites second column of 1st dimension with areas at each constriction
unpairedTransitData(:,2,1) = unpairedTransitData(:,1,2);
pairedTransitData(:,2,1) = pairedTransitData(:,1,2);