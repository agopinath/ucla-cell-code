%% Cell Detection Algorithm  - rewriten on 7/7/2013 by Ajay Gopinath; original (Modified as of 10/05/2011) by Bino Abel Varghese, 
% Automation and efficiency changes made 03/11/2013 by Dave Hoelzle
% Adding comments, commenting the output figure on 6/25/13 by Mike Scott
% Increase in speed (~5x faster) + better cell detection quality on 7/6/13 by Ajay G.

% 6/25/13 Commented out the code which generated the 'overlap' diagram.  It
% was unused and slowed down the user during execution.  Also added
% comments to clarify the code. (Mike Scott)

function processed = Portion_segment(cellVideo, videoName, startFrame, endFrame)

%%% This code analyzes a video of cells passing through constrictions
%%% to produce and return a binary array of the video's frames which
%%% have been processed to yield only the cells.

DEBUG_FLAG = 1; % boolean flag to indicate whether to show debug info

startTime = tic;

%% Initialization
% loads the video and initialize range of frames to process

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
forClose = strel('disk', 6);

% preallocate memory for marix for speed
processed = false(height, width, effectiveFrameCount);

%% Steps through the video frame by frame in the range [startFrame, endFrame]
for frameIdx = startFrame:endFrame
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
    cleanImg = bwareaopen(cleanImg, 20);
    cleanImg = imdilate(cleanImg, forDilate);
    cleanImg = imclose(cleanImg, forClose);
    cleanImg = imerode(cleanImg, forErode2);
    
    %% Store cleaned image of segmented cells in processed
    processed(:,:,frameIdx) = cleanImg;
end

% output debugging information
totalTime = toc(startTime)
averageTimePerFrame = totalTime/effectiveFrameCount

%% Set up crude frame viewer if debugging is on
if DEBUG_FLAG == 1
    % open GUI to display image 
    display = figure('Name', videoName);

    % declare, initialize and show the current frame to be displayed
    frameToShow = startFrame;
    imshow(processed(:,:,startFrame), 'Border', 'tight');

    % map key events to function to change frame displayed
    set(display, 'KeyPressFcn', @(h_obj,evt) debug_processed(evt.Key, processed));
end

end