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

DEBUG_FLAG = 0; % flag for whether to show debug info
WRITEMOVIE_FLAG = 0; % flag for whether to write processed frames to disk
OVERLAYTEMPLATE_FLAG = 0; % flag whether to overlay template lines on processed frames

startTime1 = tic;

folderName = 'G:\CellVideos\';
videoName = 'dev9x10_20X_1200fps_0.6ms_2psi_p9_324_1.avi';
            %'Dev3x10_20x_200fps_4,8ms_72_1.avi';
            %'device01_20X_800fps_0.6ms_6psi_p4_15_3.avi';
            %'dev9x10_20X_1200fps_0.6ms_2psi_p9_324_1.avi'; 
            %'unconstricted_test_800.avi';
            %'unconstricted_test_1200.avi';

%% Initialization
% loads the video and initialize range of frames to process
cellVideo = VideoReader([folderName, videoName]);
startFrame = 1;
endFrame = cellVideo.NumberOfFrames;

% stores the number of frames that will be processed
effectiveFrameCount = (endFrame-startFrame+1) ;

% store the height/width of the cell video for clarity
height = cellVideo.Height;
width = cellVideo.Width;

%% Calculate background image(s)
numSections = 2; % the number of sections to "divide" the video into
numSamples = 100; % the number of samples to take from each section

bgSections = 1:ceil(cellVideo.NumberOfFrames/numSections):cellVideo.NumberOfFrames; % indices of the frames which separate the sections
bgSections(numSections+1) = cellVideo.NumberOfFrames;  % add on the last frame to signal the end of the last section
bgImgs = zeros(height, width, length(bgSections)-1, 'uint8'); % 3D array to store the background image for each section

bgImgIdx = 1;
backgroundImg = zeros(height, width, 'uint8');

% loop through each 'section'
for i = 2:length(bgSections)
    sectionStart = bgSections(i-1); % the starting frame of each section
    sectionEnd = bgSections(i); % the ending frame of each section
    sampleInterval = ceil((sectionEnd-sectionStart)/numSamples); % the interval using which the samples are taken
    frameIdxs = sectionStart:sampleInterval:sectionEnd; % stores the indices of the frames to sample in each section
    
    bgFrames = zeros(height, width, length(frameIdxs), 'uint8');
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
clear frameIdxs; clear backgroundImg; clear bgFrames; clear bgImgIdx; clear sampleInterval;

% create structuring elements used in cleanup of grayscale image
forErode1 = strel('disk', 1);
forErode2 = strel('disk', 4);
forDilate = strel('disk', 2);
forClose = strel('disk', 10);

% preallocate memory for marix for speed
processed = false(height, width, effectiveFrameCount);
tempTime = toc(startTime1);

if OVERLAYTEMPLATE_FLAG == 1
    template = logical(Make_waypoints(videoName, folderName));
end

startTime2 = tic;
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
    
    cleanImg = imerode(cleanImg, forErode1);
    cleanImg = medfilt2(cleanImg, [2, 2]);
    cleanImg = bwareaopen(cleanImg, 25);
    cleanImg = imdilate(cleanImg, forDilate);
    cleanImg = imclose(cleanImg, forClose);
    cleanImg = imerode(cleanImg, forErode2);
    cleanImg = bwareaopen(cleanImg, 60);
    
    if OVERLAYTEMPLATE_FLAG == 1
        cleanImg = cleanImg | template; % binary 'OR' to find the union of the two imgs
    end
    
    %% Store cleaned image of segmented cells in processed
    processed(:,:,frameIdx) = cleanImg;
end

% output debugging information
totalTime = toc(startTime2) + tempTime
averageTimePerFrame = totalTime/effectiveFrameCount

%% Set up built-in frame viewer and write to file if debugging is on
if DEBUG_FLAG == 1
    implay(processed);
    if WRITEMOVIE_FLAG == 1
        writer = VideoWriter([folderName, 'proc_new_', videoName]);
        open(writer);
        
        processed = uint8(processed); % convert to uint8 for use with writeVideo
        
        % make binary '1's into '255's so all resulting pixels will be
        % either black or white
        for idx = 1:effectiveFrameCount
            processed(:,:,idx) = processed(:,:,idx)*255;
        end
        
        % write processed frames to disk
        for currFrame = startFrame:endFrame
            writeVideo(writer, processed(:,:,currFrame));
        end
        
        close(writer);
    end
end