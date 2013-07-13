%%% Bino Abel Varghese
%%% Code to track cells
%%% First part of the code
%%% Output variable 'diff_int' is the final variable.

function [transit_time_data] = CellTracking(no_of_frames, framerate, template, processed_frames, x_offset, input_video)

% % Temporary to run as a script, not a function
% folder_name = 'C:\Users\Mike\Desktop\Microfluidic Code Testing\video\';
% video_name = 'dev5x10_20X_400fps_2400us_hESC-FF1_H9+Blebb_76.avi';
% no_of_images = 1500;
% seg_number = 1;
% frame_rate = 400;
% counter = 1;

close all;
clc;
progressbar([],[],0)
% Change write_video to true in order to print a video of the output,
% defaults to false.
write_video = false;

%% Initializations
first_frame = true;
counter = 0;
line = 0;
write = true;

% HARD CODED x coordinates for the center of each lane (1-16), shifted by
% the offset found in 'MakeWaypoints'
lane_coordinates = [16 48 81 113 146 178 210 243 276 308 341 373 406 438 471 503] + x_offset;

% The cell structure 'cell_info' is an important structure that stores 
% information about each cell.  It contains 16 arrays, one for each lane in
% the device.  Each array is initialized to a default length 
% of 1,500 rows, and the code checks that the array is not full at the end 
% of each loop.  If the array is full, it is enlarged. The columns are:
%   1) Frame number
%   2) cell label number
%   3) Grid line that the cell intersects
%   4) Cell area (in pixels)
cell_info = cell(1,16);
for ii = 1:16
   cell_info{ii} = zeros(300,4);
end

% In order to remember which index to write to in each of the arrays in
% cell_info, a counter variable is needed.  Lane_index gives the index for
% each lane.
lane_index = ones(1,16);

% The array checking_array is 'number of horizontal lines' x 'number of
% lanes'.  Each time a cell is found, the position (lane and line) is
% known.  These are used as indicies (for instance, a cell at line 2 in
% lane 4 will check checking_array(2,4)).  At each position, the last frame
% at which a cell was previously found in that position is stored.  The
% cell is only stored as a cell if no cell was found in sequential previous
% frames.  If the frame stored at that position is 0 or 2 less than the
% current frame, the cell is counted (write is turned true)
checking_array = zeros(7,16);

%% Labels each grid line in the template from 1-7 starting at the top
[tempmask, ~] = bwlabel(template);

% Preallocates an array to store the y coordinate of each line
line_coordinate = zeros(1,7);

% Uses the labeled template to find the y coordinate of each line
for jj = 1:7
    q = regionprops(ismember(tempmask, jj), 'PixelList');
    line_coordinate(jj) = q(1,1).PixelList(1,2);
end
clear tempmask;

%% Opens a videowriter object if needed
if(write_video)
   output_video = VideoWriter('C:\Users\Mike\Desktop\output_video.avi','Uncompressed AVI');
   output_video.FrameRate = input_video.FrameRate;
   open(output_video) 
end

%% Cell Labeling
% This loop goes through the video frame by frame and labels all of the
% cells.  It stores (in cell_info), the centroids and line intersection of
% each cell.
for ii = 1:no_of_frames
    % current_frame stores the frame that is currently being processed
    current_frame = processed_frames(:,:,ii);
    % Allocates a working frame (all black).  Any cell in the current
    % frame that is valid (touching a line and of a certain size) will be
    % added into working frame.
    working_frame = false(size(current_frame));
    
    % If the current frame has any objects in it.  Skips any empty frames.
    if any(current_frame(:) ~= 0)
        %% Label the current frame
        % Count number of cells in the frame and label them
        % (number_of_labels gives the number of cells found in that frame)
        [labeled_frame, number_of_labels] = bwlabel(current_frame);
        % Compute their centroids
        cell_centroid = regionprops(labeled_frame, 'centroid', 'area');
        
        %% Check which line the object intersects with
        % If first_frame is true (meaning this is the first frame), looks
        % for the first frame with an object intersecting the top line.
        for jj = 1:number_of_labels
            current_region = ismember(labeled_frame, jj);
            
            % For the first frame
            if first_frame
                % If the cell intersects line 1, add it to working_frame,
                % and set first_frame = false.
                if(sum(current_region(line_coordinate(1),:)) ~= 0)
                    % working_frame = working_frame | current_region;
                    counter = counter + 1;
                    % Indicates that the cell intersects the top line
                    line = 1;
                end
                
                % If any cells were found in the first frame, set first_frame false
                % so future frames are checked for cells that intersect any line,
                % not just the top line
                if(jj == number_of_labels && counter > 0)
                    first_frame = false;
                end
                
            % For frames other than the first frame (same as first frame,
            % but looks at every line, not just the top line.    
            else
                % Goes through each labeled region in the current frame, and finds
                % the line that the object intersects with 
                for line = 1:7
                    % Find their intersection
                    if(sum(current_region(line_coordinate(line),:)) ~= 0)
                        % working_frame = working_frame | current_region;
                        counter = counter + 1;
                        % Breaks to preserve line, the line intersection
                        write = true;
                        break;
                    end
                    % If the cell is not touching any of the lines, set
                    % line = 0, so it is not included in the array
                    % cell_info
                    if(line == 7)
                        write = false;
                        break;
                    end
                end
            end
            
            % To implement: check if the last cell is already touching the line
            % the current cell is touching (ie same cell touching same
            % line), if so, change write to false
            
            if(counter > 0 && write == true && line ~= 0)
                % Determines which lane the current cell is in
                [~, lane] = min(abs(lane_coordinates-cell_centroid(jj,1).Centroid(1)));
                
                % Now that line and lane are both known, checks the array
                % 'checking_array' to see if the cell should be stored.  
                % There are two possibilities:
                %       1) The element of 'checking array' contains the 
                %       previous frame number. In this case, the frame 
                %       value in 'checking_array' is updated, but the cell 
                %       is not stored.
                %       2) The element of 'checking array' does not contain 
                %       the previous frame number, or contains zero.  In 
                %       this case, the frame value is stored in 'checking
                %       array' and the cell is stored in the appropriate
                %       array in cell_info.
                % In case 1:
                if(checking_array(line,lane) == ii - 1 && (checking_array(line,lane) ~= 0 || ii ~= 1))
                    % If the cell was in the same place as the line before
                    % And a cell was previously found at this line
                    % ~=0 since if the cell is the first to be found on
                    % line 1 in that lane, it will be zero (if in frame 1)
                    checking_array(line,lane) = ii;
                else
                    % Also checks that the cell is not from the same frame
                    % as the previously found cell (cells should not be
                    % large enough to touch two lines simultaneously)
                    if(line ~=1)
                       if(checking_array(line,lane) == checking_array(line-1,lane)) 
                            continue;
                       end
                    end
                    % Save data about the cell:
                    % Frame number
                    cell_info{lane}(lane_index(lane),1) = ii;
                    % Cell number
                    cell_info{lane}(lane_index(lane),2) = counter;
                    % Line intersection
                    cell_info{lane}(lane_index(lane),3) = line;
                    % Saves the area of the cell in pixels
                    cell_info{lane}(lane_index(lane),4) = cell_centroid(jj,1).Area(1);
                    % Updates the checking array and lane index
                    checking_array(line,lane) = ii;
                    lane_index(lane) = lane_index(lane) + 1;
                    % Update working_frame
                    working_frame = working_frame | current_region;
                end
            end
            % Sets line = 0 so if the cell is not on a line, it is not
            % counted next loop
            line = 0;        
        end   
    end
    
    %% Frame postprocessing
    % Save the labeled image
    processed_frames(:,:,ii) = logical(working_frame);
    
    if(write_video == true)
        temporary_frame = imoverlay(read(input_video,ii), bwperim(processed_frames(:,:,ii)), [1 1 0]);
        writeVideo(output_video, temporary_frame);
    end
    
    % Check to see if the arrays in 'cell_info' are filling.  If there are 
    % less than 10 more empty rows in any given array, estimate the number
    % of additional rows needed, based on the current filling and the 
    % number of frames remaining.  
    for jj = 1:16
        if((size(cell_info{jj},2) - lane_index(jj)) <= 10)
            vertcat(cell_info{jj}, zeros(floor(((no_of_frames/ii-1)*size(cell_info{jj},2))*1.1), 4));
        end
    end
    
    % Progress bar update
    if mod(ii, floor((no_of_frames)/100)) == 0
        progressbar([],[], (ii/(no_of_frames)))
    end
end

% Closes the video if it is open
if(write_video)
    close(output_video);
end

%% Calls Process_Tracking_Data to process the raw data and return
% transit_time_data, an nx7 array where n is the number of cells that
% transited completely through the device.  The first column is the total
% transit time, while columns 2-7 give the time taken to transit from
% constriction 1-2, 2-3, etc.
[transit_time_data] = Process_Tracking_Data(checking_array, framerate, cell_info);