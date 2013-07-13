%% Cell Segmentation Algorithm (Modified as of 10/05/2011) by Bino Abel Varghese
% Automation and efficiency changes made 03/11/2013 by Dave Hoelzle
% Adding comments, commenting the output figure on 6/25/13 by Mike Scott

%% ------------------------- Header Strip -------------------------------%
% all major code design changes made here
% 6/25/13 Commented out the code which generated the 'overlap' diagram.  It
% was unused and slowed down the user during execution.  Also added
% comments to clarify the code. (Mike Scott)

function [processed_frames] = Image_filtering(video_name, folder_name, number_of_frames, mask)

%% The aim of this code is to segment a binary image of the cells from a stack of grayscale images

%% Clears the screen
clc;
progressbar([],0,[])

%% Initializations
% Median filter size in pixels, must be an odd number (default 11)
med_size = 11;          
% Size of the bottom hat filter (default 7)
BH_size = 7;
% Threshold to filter out small cells, specifies the minimum AREA in pixels
% of a cell 
smallest_cell = 35;
se = strel('disk',BH_size);

%% Computing an average image to use for background subtraction
% Loads the video
temp_mov = VideoReader([folder_name, video_name]);
% Allocates an array for the processed frames
processed_frames = false(temp_mov.height, temp_mov.width, temp_mov.NumberOfFrames);

% Generates a vector of to select 100 evenly spaced frames in the video
select_range = 1:ceil(temp_mov.NumberOfFrames/100):temp_mov.NumberOfFrames; 

% Alocates an array for converted frames and average frame
converted_frames = uint8(zeros(temp_mov.height, temp_mov.width, 100));

% Compiles converted_frames, an array of 100 evenly spaced frames specified by
% select_range, and then averages over RGB to get converted_frames (uint8 type
% uses less memory)
for i=1:length(select_range)
    current_frame = read(temp_mov, select_range(i));
    converted_frames(:,:,i) = uint8(mean(current_frame,3));
end

% Finds the 'background'.  Goes pixel by pixel and averages that pixel
% value over the 100 selected frames.  Amean is the average of these 100
% frames.  The 'max' and 'min' statements ensure the box (specified by the
% user) are nonnegative and within the video size.
average_frame = uint8(mean(converted_frames,3));
% Finds a threshold value based on the first frame in average_frame
threshold = 10 * graythresh(average_frame); 
 
% Clears variables to conserve memory 
clear converted_frames; clear select_range;

%% Steps through the video one frame at a time to segment out cells
for ii = 1:number_of_frames
    %% Reads in the movie file frame by frame
    current_frame = uint8(read(temp_mov, ii)); 
    
%     %  For MATLAB pre-2013: Converts the frame to uint8 rather than an RGB 
%     % array
%     current_frame(:,:) = uint8((mean((read(temp_mov, ii)),3)));

    %% Perform Change detection
    % Subtracts the background (average_frame) from each frame, hopefully 
    % leaving just the cells.  
    subtracted_frame(:,:) = imsubtract(average_frame,current_frame);   
    % Performs a bottom hat filter using the strel 'se'
    BH(:,:) = imbothat(subtracted_frame,se);

    % Performs a median filter using the pixel size specified in the
    % header
    med_bhat(:,:) = medfilt2(BH(:,:),[med_size med_size]);

    % Gets rid of small 'cells'.  This function gets rid of any connected
    % region which is less that smallest_cell pixels connected.  Each frame
    % is converted to black and white before the small cells are filled in
    % with black.
    % Clean(:,:) = bwareaopen(im2bw(double(med_bhat(:,:))/256, threshold/256),smallest_cell);
    PreClean(:,:) = bwareaopen(im2bw(double(med_bhat(:,:))/256, threshold/256),smallest_cell);
    
    % template = logical(template);
    Clean = PreClean & mask;
    
    % Saves the 'Clean' image in processed_frames.  This array will store a
    % copy of the entire video, with each frame cleaned
    processed_frames(:,:,ii) = Clean;
    
    % Increments the progress bar, each time 1% of the frames are finished
    if mod(ii, floor(number_of_frames/100)) == 0
        progressbar([], ii/number_of_frames, [])
    end
end