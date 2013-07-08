%% Cell Segmentation Algorithm (Modified as of 10/05/2011) by Bino Abel Varghese
% Automation and efficiency changes made 03/11/2013 by Dave Hoelzle
% Adding comments, commenting the output figure on 6/25/13 by Mike Scott
% Huge boost in program efficiency (~4x as fast) + improved cell segmentation on 7/6/13 by Ajay G.

% function Portion_segment(video_name, folder_name, start_frame, end_frame, position, seg_number)

%% The aim of this code is to segment a binary image of the cells from a stack of grayscale images

clc;

% 6/25/13 Commented out the code which generated the 'overlap' diagram.  It
% was unused and slowed down the user during execution.  Also added
% comments to clarify the code. (Mike Scott)

folderName = 'G:\CellVideos\';
videoName = 'unconstricted_test_1200.avi';%'dev9x10_20X_1200fps_0.6ms_2psi_p9_324_1.avi'; 
            %'unconstricted_test_800.avi';
segmentNum = 1;

%% Computing an average image
% loads the video and initialize range of frames to process
cellVideo = VideoReader([folderName, videoName]);
startFrame = 1;
endFrame = cellVideo.NumberOfFrames;

% stores the number of frames that will be processed
effectiveFrameCount = (endFrame-startFrame+1) ;

% generates a sample array of the indices of 100 evenly spaced frames in the video
bgSample = 1:ceil(cellVideo.NumberOfFrames/100):cellVideo.NumberOfFrames;

% store the height/width of the cell video for clarity
height = cellVideo.Height;
width = cellVideo.Width;

% bgFrames holds the video frames specified by the indices stored in bgSample
bgFrames = zeros(height, width, length(bgSample), 'uint8');
for i = 1:length(bgSample)
    bgFrames(:,:,i) = uint8(mean(read(cellVideo, bgSample(i)), 3));
end

% finds the 'background'. Goes pixel by pixel and averages that pixel
% value over the 100 selected frames.  backgroundImg is the image 
% whose pixels values are the average of these 100 sample frames.

backgroundImg = zeros(height, width, 'uint8');
for i = 1:height
    for j = 1:width
        backgroundImg(i,j) = uint8(mean(bgFrames(i,j,:)));
    end
end

% clear variables for better memory management
clear bgSampleFrame; clear bgSample; clear bgFrames;

% create structuring elements used in cleanup of grayscale image
forErode = strel('disk', 1);
forClose = strel('disk', 4);

% preallocate memory for marix for speed
processed = false(height, width, effectiveFrameCount);

startTime = tic;
for frameIdx = startFrame:endFrame
    %% Steps through the video frame by frame in the range [startFrame, endFrame]
    % reads in the movie file frame at frameIdx
    currFrame = read(cellVideo, frameIdx); 

    % converts currFrame from a structure format to a 3D array (In future versions, speed can be improved of the code is altered to work on cell strct instead of 3D array.
    currFrame = uint8(mean(currFrame,3));
    
    %% Do cell detection
    % subtracts the background (backgroundImg) from each frame, hopefully leaving
    % just the cells
    cleanImg = imsubtract(backgroundImg, currFrame);
    
    %% Cleanup the grayscale image of the cells to improve detection
    cleanImg = imadjust(cleanImg);
    
    cleanImg = imerode(cleanImg, forErode);
    cleanImg = bwareaopen(cleanImg, 30);
    
    cleanImg = imclose(cleanImg, forClose);
    
    %% Store cleaned image of segmented cells in processed
    processed(:,:,frameIdx) = cleanImg;
end

% output debugging information
totalTime = toc(startTime)
averageTimePerFrame = totalTime/effectiveFrameCount

% open GUI to display image
display = figure('Name', videoName);

% declare, initialize and show the current frame to be displayed
frameToShow = startFrame;
imshow(processed(:,:,startFrame));

% map key events to function to change frame displayed
set(display, 'KeyPressFcn', @(h_obj,evt) debug_processed(evt.Key, processed));