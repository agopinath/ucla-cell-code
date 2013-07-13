%% Cell Tacking

function [transit_time_data] = Process_Tracking_Data(checking_array, framerate, cell_info)

% Tracks the cells
% Preallocation
% Occupied_row stores which of the lines in the current lane are currently
% occupied by a cell (for the frame being processed)
% occupied_lines = zeros(7,1);

% Contact_count stores how many cells have touched a particular line in the
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
% contact_count = zeros(7,1);

% Lane_data is an array containing the frame at which each cell is found
% at each line.  It is a (n x 7) array, where n is the number of cells.
% Lane_data contains data on every cell found, but will later be pared
% down to eliminate cells that didn't make it all the way through the
% device.  Each column corresponds to a line (1-7), and each row is a new 
% cell.  The numerical entry is the frame in which the cell hit the line,
% and will later be converted to times based on the framerate.
lane_data = uint16(zeros(30,7));

% Tracking_data is a cell that contains the lane data for each lane
tracking_data = cell(1,16);

% Goes through the data for each lane (1-16)
for lane = 1:16
    contact_count = zeros(7,1);
    if(any(checking_array(:,lane) == 0))
        % Stores this lane's tracking data
        lane_data = uint16(zeros(30,7));
        % tracking_data{lane} = zeros(1,7);
        continue;
    else
        % For each cell in this lane's data
        for cell_number = 1:size(cell_info{lane},1)
            % If the cell is touching line 1, and the previous cell already
            % reached line 2
            current_line = cell_info{lane}(cell_number,3);
            
            % Once all the cells are evaluated (current line is zero),
            if(current_line == 0)
               break; 
            end
            
            if(current_line == 1 && contact_count(1) == contact_count(2))
                % Increment the contact count
                contact_count(1) = contact_count(1) + 1;
                % Write the frame number to tracking_data for that cell at
                % line 1
                lane_data(contact_count(1), 1) = cell_info{lane}(cell_number,1);
            % If the cell is below line 1, and the contact count for the
            % previous line is greater than the current line (ie the cell
            % moved from the previous line), change the contact_count and
            % write the frame number to lane_data 
            elseif(current_line ~= 1 && contact_count(current_line) < contact_count(current_line-1))
                contact_count(current_line) = contact_count(current_line-1);
                lane_data(contact_count(current_line), current_line) = cell_info{lane}(cell_number,1);
            end
            
            % Checks to make sure that the array is not full, adds more
            % space if necessary
            if(size(lane_data,1) <= (contact_count(1) + 2))
               lane_data = vertcat(lane_data, uint16(zeros(10,7))); 
            end
        end
 
        % Stores this lane's tracking data, eliminating any cells that
        % didn't fully transit through the device.
        tracking_data{lane} = lane_data(all(lane_data,2),:);
        lane_data = uint16(zeros(30,7));
    end
end

transit_time_data = double(vertcat(tracking_data{1:16}));

% Convert the data from frames into delta time values.  After this loop,
% column 1 will store the time at which the cell reached the line, and
% columns 2-7 will store the length of time the cell took to pass between
% the lines. For example, column 2 stores the amount of time it took for
% the cell to go from line 1 to line 2.

transit_time_data = 1 / (framerate*10^-3) * transit_time_data;

for ii = 1:6
   for jj = 1:size(transit_time_data,1)
        transit_time_data(jj,8-ii) = transit_time_data(jj,8-ii) - transit_time_data(jj,7-ii);
   end
end

% Overwrites the first column with the total time
for ii = 1:size(transit_time_data,1)
   transit_time_data(ii,1) = sum(transit_time_data(ii,2:7)); 
end