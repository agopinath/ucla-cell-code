%% Cell Detection Algorithm - original (10/05/2011) by Bino Abel Varghese
% Automation and efficiency changes made 03/11/2013 by Dave Hoelzle Adding
% comments, commenting the output figure on 6/25/13 by Mike Scott 
% Increase in speed (~3 - 4x faster) + removed disk output unless debugging made on 7/5/13 by Ajay G.

% 6/25/13 Commented out the code which generated the 'overlap' diagram.  It
% was unused and slowed down the user during execution.  Also added
% comments to clarify the code. (Mike Scott)

function processed = Portion_segment(cellVideo, folderName, videoName, startFrame, endFrame)

%%% This code analyzes a video of cells passing through constrictions
%%% to produce and return a binary array of the video's frames which
%%% have been processed to yield only the cells.

DEBUG_FLAG = 1; % flag for whether to show debug info
WRITEMOVIE_FLAG = 0; % flag for whether to write processed frames to movie on disk
OVERLAYTEMPLATE_FLAG = 0; % flag whether to overlay template lines on processed frames
OVERLAYOUTLINE_FLAG = 1; % flag whether to overlay detected outlines of cells on original frames

startTime1 = tic;

% %% Initialization
% folderName = 'G:\CellVideos\';
% videoName = 'dev9x10_20X_1200fps_0.6ms_2psi_p9_324_1.avi';
%             %'Dev3x10_20x_200fps_4,8ms_72_1.avi';
%             %'device01_20X_800fps_0.6ms_6psi_p4_15_3.avi';
%             %'dev9x10_20X_1200fps_0.6ms_2psi_p9_324_1.avi'; 
%             %'unconstricted_test_1200.avi';
%             
% cellVideo = VideoReader([folderName, videoName]);
% startFrame = 1;
% endFrame = cellVideo.NumberOfFrames;

isVideoGrayscale = (strcmp(cellVideo.VideoFormat, 'Grayscale') == 1);

%clc;
disp(sprintf(['\nStarting cell detection for ', videoName, '...']));

% empirical threshold value for conversion from grayscale to binary image
threshold = 0.02;

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
        if(isVideoGrayscale)
            bgFrames(:,:,j) = read(cellVideo, frameIdxs(j)); % store the frame that was read in bgFrames
        else
            temp = read(cellVideo, frameIdxs(j));
            bgFrames(:,:,j) = temp(:,:,1);
        end
    end
    
    % calculate the 'background' frame for the current section by
    % storing the corresponding pixel value as the mean value of
    % each corresponding pixel of the background frames in bgFrames
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

%% Prepare for Cell Detection
% create structuring elements used in cleanup of grayscale image
forClose = strel('disk', 10);

% preallocate memory for marix for speed
if OVERLAYOUTLINE_FLAG == 1
    processed = zeros(height, width, effectiveFrameCount, 'uint8');
else
    processed = false(height, width, effectiveFrameCount);
end

% temporarily stop and record the time taken so far
bgCalcTime = toc(startTime1);

if OVERLAYTEMPLATE_FLAG == 1
    template = logical(Make_waypoints(videoName, folderName));
end

% continue recording the time taken
startTime2 = tic;

%% Step through video
% iterates through each video frame in the range [startFrame, endFrame]
for frameIdx = startFrame:endFrame
    % reads in the movie file frame at frameIdx
    if(isVideoGrayscale)
        currFrame = read(cellVideo, frameIdx);
    else
        temp = read(cellVideo, frameIdx);
        currFrame = temp(:,:,1);
    end
    
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
    cleanImg = im2bw(imsubtract(bgImgs(:,:,imgIdx), currFrame), threshold);
    
    %% Cleanup 
    % clean the grayscale image of the cells to improve detection
    %cleanImg = logical(imadjust(cleanImg));
    cleanImg = bwareaopen(cleanImg, 40);
    cleanImg = imclose(cleanImg, forClose);
    cleanImg = bwareaopen(cleanImg, 60);
    cleanImg = imfill(cleanImg, 'holes');
    
%     cleanImg = imerode(cleanImg, forErode1);
%     cleanImg = medfilt2(cleanImg, [2, 2]);
%     cleanImg = bwareaopen(cleanImg, 25);
%     cleanImg = imdilate(cleanImg, forDilate);
%     cleanImg = imclose(cleanImg, forClose);
%     cleanImg = imerode(cleanImg, forErode2);
%     cleanImg = bwareaopen(cleanImg, 50);
    
    if OVERLAYTEMPLATE_FLAG == 1
        cleanImg = cleanImg | template; % binary 'OR' to find the union of the two imgs
    end
    
    if OVERLAYOUTLINE_FLAG == 1
        cleanImg = imadd(currFrame, uint8(bwperim(cleanImg)*255));
    end
    
    %% Store cleaned image of segmented cells in processed
    processed(:,:,frameIdx-startFrame+1) = cleanImg;
end

% stop recording the time and output debugging information
processTime = toc(startTime2);
totalTime = processTime + bgCalcTime;
disp(['Time taken for cell detection: ', num2str(totalTime), ' secs']);
disp(['Average time to detect cells per frame: ', num2str(processTime/effectiveFrameCount), ' secs']);

%% Set up frame viewer and write to file if debugging is on
if DEBUG_FLAG == 1
    implay(processed);
    
    % if video file is set
    if WRITEMOVIE_FLAG == 1
        writer = VideoWriter([folderName, 'cellsdetected_', videoName]);
        open(writer);
        
        if(islogical(processed))
            processed = uint8(processed); % convert to uint8 for use with writeVideo

            % make binary '1's into '255's so all resulting pixels will be
            % either black or white
            for idx = 1:effectiveFrameCount
                processed(:,:,idx) = processed(:,:,idx)*255;
            end
        end
        
        % write processed frames to disk
        for currFrame = startFrame:endFrame
            writeVideo(writer, processed(:,:,currFrame-startFrame+1));
        end
        
        close(writer);
    end
end
