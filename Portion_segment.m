%% Cell Segmentation Algorithm (Modified as of 10/05/2011) by Bino Abel Varghese
% Automation and efficiency changes made 03/11/2013 by Dave Hoelzle
% Adding comments, commenting the output figure on 6/25/13 by Mike Scott
% Huge boost in program efficiency (~4x as fast) + improved cell segmentation on 7/6/13 by Ajay G.

% function Portion_segment(video_name, folder_name, start_frame, end_frame, position, seg_number)

%% The aim of this code is to segment a binary image of the cells from a stack of grayscale images

%%clc;

% 6/25/13 Commented out the code which generated the 'overlap' diagram.  It
% was unused and slowed down the user during execution.  Also added
% comments to clarify the code. (Mike Scott)
startTime = tic;
folderName = 'G:\CellVideos\';
videoName = 'dev9x10_20X_1200fps_0.6ms_2psi_p9_324_1.avi'; 
            %'unconstricted_test_800.avi';
            %'unconstricted_test_1200.avi';
segmentNum = 1;

%% Computing an average image
% loads the video and initialize range of frames to process
cellVideo = VideoReader([folderName, videoName]);
startFrame = 1;
endFrame = cellVideo.NumberOfFrames;

% stores the number of frames that will be processed
effectiveFrameCount = (endFrame-startFrame+1) ;

% generates a sample array of the indices of 100 evenly spaced frames in the video
% bgSample = 1:ceil(cellVideo.NumberOfFrames/100):cellVideo.NumberOfFrames;

% store the height/width of the cell video for clarity
height = cellVideo.Height;
width = cellVideo.Width;

numSections = 2; % the number of sections to "divide" the video into
numSamples = 100; % the number of samples to take from each section

bgSections = 1:ceil(cellVideo.NumberOfFrames/numSections):cellVideo.NumberOfFrames; % indices of the frames which separate the sections
bgSections(numSections+1) = cellVideo.NumberOfFrames;  % add on the last frame to signal the end of the last section
bgImgs = zeros(height, width, length(bgSections)-1, 'uint8'); % 3D array to store the background image for each section

bgImgIdx = 1;
backgroundImg = zeros(height, width, 'uint8');
bgFrames = zeros(height, width, length(frameIdxs), 'uint8');
% loop through each 'section'
for i = 2:length(bgSections)
    sectionStart = bgSections(i-1); % the starting frame of each section
    sectionEnd = bgSections(i); % the ending frame of each section
    sampleInterval = ceil((sectionEnd-sectionStart)/numSamples); % the interval using which the samples are taken
    frameIdxs = sectionStart:sampleInterval:sectionEnd; % stores the indices of the frames to sample in each section
       
    for j = 1:length(frameIdxs)
        bgFrames(:,:,j) = uint8(read(cellVideo, frameIdxs(j))); % store the frame in bgImgs
    end
    
    for col = 1:height
        for row = 1:width
            backgroundImg(col, row) = mean(bgFrames(col, row,:));
        end
    end
    
    bgImgs(:,:,bgImgIdx) = backgroundImg;
    bgImgIdx = bgImgIdx + 1;
end

% clear variables for better memory management
clear bgSampleFrame; clear bgSample; clear bgFrames;

% create structuring elements used in cleanup of grayscale image
forErode = strel('disk', 1);

% preallocate memory for marix for speed
processed = false(height, width, effectiveFrameCount);

for frameIdx = startFrame:endFrame
    %% Steps through the video frame by frame in the range [startFrame, endFrame]
    % reads in the movie file frame at frameIdx
    currFrame = read(cellVideo, frameIdx);
    
    %% Determine which background image to use
    imgIdx = 0;
    for idx = 2:length(bgSections)
        if (frameIdx - bgSections(idx)) <= 0
            imgIdx = idx-1;
            break;
        end
    end
    
    %% Do cell detection
    % subtracts the background (backgroundImg) from each frame, hopefully leaving
    % just the cells
    cleanImg = imsubtract(bgImgs(:,:,imgIdx), currFrame);
    
    %% Cleanup the grayscale image of the cells to improve detection
    cleanImg = logical(imadjust(cleanImg));
    
    cleanImg = imerode(cleanImg, forErode);
    cleanImg = medfilt2(cleanImg, [2, 2]);
    cleanImg = bwareaopen(cleanImg, 20);
    
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