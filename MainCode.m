%% Data Compilation file; runs sequential segmentations and analyses; objective is minimal user input
% Updated 7/09/2013 by Mike
%       -Cut out the preprocessing 50 frames (required editing indicies of
%       the call for Portion_segment
%       - Rearranged and commented the code to make it clearer
%       - Added the template.  Now Make_Waypoints is automatic and no
%       longer requires defining the cropping and constriction regions
%       - Eliminated redundant inputs and outputs from functions
%       - Eliminated 'segments', nobody used them
clear
clc

%% Initializations
filename = 1;
filePath = 'G:\CellVideos\';
% Allocates an array for the data
compiled_data = zeros(1,7);
% Initializes a progress bar
progressbar('Overall', 'Cell detection', 'Cell tracking');

%% Loading GUI
% Opens a GUI to select videos, user can select a single file at a time and
% ends selection by clicking 'cancel'
i = 1;
j = 1;
while (filename ~= 0)
    [filename, filePath] = uigetfile('.avi', 'Please select the next video file, if done select cancel.', filePath, 'multiselect','on');
    if size(filename,2) ~= 1
        filename = cellstr(filename);
        while j <= size(filename,2)
            filename1 = filename{j};
            name_length(i) = length(filename1);
            path_length(i) = length(filePath);
            video_names(i,1:name_length(i)) = filename1;
            path_names(i,1:path_length(i)) = filePath;
            i = i+1;
            j = j+1;
        end
        j = 1;
        filename = filename1;
        clear filename1
    end
end

% Reads title of fps from title of file
% Important that fps come after first underscore
% Title format to follow
% 'dev5x10_1200fps_48hrppb_glass_4psi_20x_0.6ms_p12_041'
for i = 1:size(name_length,2)
    j = 1; ii = 1;
    while video_names(i,j) ~= 'f'
        while video_names(i,j) == '_'
            if video_names(i,k) == 'f'
                break
            end
            frame_rates(ii) = video_names(i,k);
            k = k+1;
            ii = ii+1;
        end
        j = j+1;
        k = j+1;
    end
    frame_rate(i) = str2double(frame_rates);
end

%Reads template size from title
%only works if one follows titling fomrat shown above
for ii = 1:size(name_length,2)
    if size(name_length,2) == 1
        template_size = str2double(video_names(4));
    else
        template_size(ii) = str2double(video_names(ii,4));
    end
end

tStart = tic;

% Creates a directory for each video, followed by another set of folders
% inside these for each segment of the video
for i = 1:size(video_names,1)
    mkdir (path_names(i,1:path_length(i)), 'compiled_data\')
    
    % Makes folders
    mkdir(path_names(i,1:path_length(i)), [video_names(i,1:name_length(i))])
    [msg, msgid] = lastwarn;
    
end

for i = 1:size(video_names,1)
    % Calls the Make_waypoints function to define the constriction region.
    % This function draws a template with a line across each constriction;
    % these lines are used in calculating the transit time
    currVideo = VideoReader([path_names(i,1:path_length(i)), video_names(i,1:name_length(i))]);
    startFrame = 1;
    endFrame = currVideo.NumberOfFrames;
    [mask, line_template, x_offset] = MakeWaypoints(currVideo, template_size(i));
    
    % Calls CellDetection to filter the images and store them in
    % 'processed_frames'.  These stored image are binary and should
    % (hopefully) only have the cells in them
    [processedFrames] = CellDetection(currVideo, startFrame, endFrame, path_names(i,1:path_length(i)), video_names(i,1:name_length(i)), mask);
    progressbar((i/(2*size(video_names,1))), [], [])
    
    % Calls CellTracking to track the located cells.
    [data] = CellTracking((endFrame-startFrame+1), frame_rate(i), line_template, processedFrames, x_offset, currVideo);
    progressbar((i/(size(video_names,1))), 0, 0)
    
    % If data is generated (cells are found and tracked through the device)
    if (~isempty(data))
        % If the first row is zeros (has not been written to yet)
        if (compiled_data(1,1:7) == zeros(1,7))
            compiled_data = data;
        % Otherwise add the new data
        else
            compiled_data(end+1:end+size(data,1),1:7) = data;
        end
        
        % plot histogram of compiled data
        figure(99)
        [n,xout] = hist(compiled_data(:,7), 100);
        bar(xout,n)
        
        % Writes out the transit time data in an excel file
        col_header = {'Total Time (ms)', 'Constriction 1 to 2', 'Constriction 2 to 3', 'Constriction 3 to 4', 'Constriction 4 to 5', 'Constriction 5 to 6', 'Constriction 6 to 7'};
        % xlswrite ([path_names(1,1:path_length(1)), 'compiled_data\data_xlscomp'], data_comp_)
        xlswrite([path_names(1,1:path_length(1)), 'compiled_data\data_xlscomp'],col_header,'Sheet1','A1');
        xlswrite([path_names(1,1:path_length(1)), 'compiled_data\data_xlscomp'],compiled_data,'Sheet1','A2');
        % save ([path_names(1,1:path_length(1)), 'compiled_data\data_comp'],'data_comp', 'frame_rate')
    end
end

total_time = toc(tStart)
average_time = total_time/size(video_names,1);