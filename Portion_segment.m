%% Cell Segmentation Algorithm (Modified as of 10/05/2011) by Bino Abel Varghese
% Automation and efficiency changes made 03/11/2013 by Dave Hoelzle
% Adding comments, commenting the output figure on 6/25/13 by Mike Scott

% function Portion_segment(video_name, folder_name, start_frame, end_frame, position, seg_number)

%% The aim of this code is to segment a binary image of the cells from a stack of grayscale images

%% Clears the screen
% clear;
% close all;
clc;

%% ------------------------- Header Strip -------------------------------%
% all major code design changes made here
% 6/25/13 Commented out the code which generated the 'overlap' diagram.  It
% was unused and slowed down the user during execution.  Also added
% comments to clarify the code. (Mike Scott)

% Median filter size in pixels, must be an odd number; 11 is nice
med_size = 11;          
BH_size = 7;
% Threshold to filter out small cells, specifies the minimum AREA in pixels
% of a cell
smallest_cell = 5;      
% Emperical threshold value for binarizing images (default 4)
threshold = 4;          
folder_name = 'C:\Users\agopinath\Desktop\CellVideos\';
video_name = 'compressed.avi';%'unconstricted_test.avi';
% position = [5     5    540    300];
seg_number = 1;

% create the folder to write to
writeFolder = [folder_name, video_name, '_', num2str(seg_number)];
mkdir(writeFolder);

%% Computing an average image
% Loads the video
temp_mov = VideoReader([folder_name, video_name]);
start_frame = 1;
end_frame = temp_mov.NumberOfFrames;

% Generates a vector of to select 100 evenly spaced frames in the video
select_range = 1:ceil(temp_mov.NumberOfFrames/100):temp_mov.NumberOfFrames; % change back to range_wide later
% Compiles Aavi, an array of 100 evenly spaced frames specified by
% select_range, and then averages over RGB to get Aaviconverted (uint8 type
% uses less memory)
temp = read(temp_mov, 1);
height = size(temp, 1);
width = size(temp, 2);

Aaviconverted = zeros(height, width, 'uint8');
for i = 1:length(select_range)
    Aavi = read(temp_mov, select_range(i));
    Aaviconverted(:,:,i) = uint8(mean(Aavi,3));
end

% Finds the 'background'.  Goes pixel by pixel and averages that pixel
% value over the 100 selected frames.  Amean is the average of these 100
% frames.  The 'max' and 'min' statements ensure the box (specified by the
% user) are nonnegative and within the video size.

Amean = zeros(height, width, 'uint8');
for i = 1:height
    for j = 1:width
        Amean(i,j) = uint8(mean(Aaviconverted(i,j,:)));
    end
end

%% Steps through the video one frame at a time to segment out cells
% Clears variables to conserve memory 
clear Aaviconverted; clear select_range; clear temp;

for rep = start_frame:end_frame
    %% Reads in the movie file frame by frame
    Aavi = read(temp_mov, rep); 

    % Converts the Avi from a structure format to a 3D array (In future versions, speed can be improved of the code is altered to work on cell strct instead of 3D array.
    Aaviconverted(:,:) = uint8(mean(Aavi,3));

    % Clears Aavi to save memory, add more variables if you landup with 
    % Java heap or out of memory error. 
    clear Aavi;  

    %% Perform Change detection
    % Subtracts the background (Amean) from each frame, hopefully leaving
    % just the cells.  Again, the min/max statements ensure the indicies
    % are nonzero.
    Aaviconverted2 = imsubtract(Amean, Aaviconverted(:,:));
    Aaviconverted2 = imadjust(Aaviconverted2);
    seD = strel('disk', 1);
    Aaviconverted2 = imerode(Aaviconverted2, seD);
    %Aaviconverted2 = medfilt2(Aaviconverted2,[4, 4]);%imerode(Aaviconverted2, seD);
    Aaviconverted2 = bwareaopen(Aaviconverted2, 40);
    seD = strel('disk', 10);
    Aaviconverted2 = imclose(Aaviconverted2, seD);
    %myfilter = fspecial('gaussian',[3, 3], 4);
    %Aaviconverted2 = imfilter(Aaviconverted2, myfilter, 'replicate');
    % Performs a bottom hat filter using the strel 'se'
    %se = strel('disk',BH_size);
    %BH(:,:) = imbothat(Aaviconverted2,se);
    
    % Performs a median filter using the pixel size specified in the
    % header
    %med_bhat(:,:) = medfilt2(BH(:,:),[med_size med_size]);

    % Gets rid of small 'cells'.  This function gets rid of any connected
    % region which is less that smallest_cell pixels connected.  Each frame
    % is converted to black and white before the small cells are filled in
    % with black.
    %Clean(:,:) = bwareaopen(im2bw(double(med_bhat(:,:))/256, threshold/256),smallest_cell);

    %% Save
    % The following code saves image sequence and the image template with
    % the demarcation lines for the transit time analysis.
    filename = [writeFolder, '\','BWstill_', num2str(rep),'.tif']; %% Change filename .tif
    imwrite(Aaviconverted2(:,:),filename,'Compression','none');
end