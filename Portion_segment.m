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
videoName = 'unconstricted_test_1200.avi';%'dev9x10_20X_1200fps_0.6ms_2psi_p9_324_1.avi'; 
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

% % bgFrames holds the video frames specified by the indices stored in bgSample
% bgFrames = zeros(height, width, length(bgSample), 'uint8');
% for i = 1:length(bgSample)
%     bgFrames(:,:,i) = uint8(mean(read(cellVideo, bgSample(i)), 3));
% end
% 
% % finds the 'background'. Goes pixel by pixel and averages that pixel
% % value over the 100 selected frames.  backgroundImg is the image 
% % whose pixels values are the average of these 100 sample frames.
% 
% backgroundImg = zeros(height, width, 'uint8');
% for i = 1:height
%     for j = 1:width
%         backgroundImg(i,j) = mean(bgFrames(i,j,:));
%     end
% end

%==
numSections = 2; % the number of sections to "divide" the video into
%meanFramesPerVideo = 3000;
numSamples = 120;

bgSections = 1:ceil(cellVideo.NumberOfFrames/numSections):cellVideo.NumberOfFrames;
bgSections(numSections+1) = cellVideo.NumberOfFrames;  % add on the last frame to signal the end of the last section
bgImgs = zeros(304, width, length(bgSections)-1, 'uint8'); % 3D array to store the background image for each section

frameIdxs = zeros(numSamples);
bgImgIdx = 1;

backgroundImg = zeros(height, width, 'uint8');

% loop through each 'section'
for i = 2:length(bgSections)
    sectionStart = bgSections(i-1);
    sectionEnd = bgSections(i);
    sampleInterval = ceil((sectionEnd-sectionStart)/numSamples);
    frameIdxs = sectionStart:sampleInterval:sectionEnd;
    
    bgFrames = zeros(height, width, length(frameIdxs), 'uint8');
    for j = 1:length(frameIdxs)
        bgFrames(:,:,j) = uint8(mean(read(cellVideo, frameIdxs(j)), 3));
    end
    
    
    for col = 1:height
        for row = 1:width
            backgroundImg(col, row) = mean(bgFrames(col, row,:));
        end
    end
    
    bgImgs(:,:,bgImgIdx) = backgroundImg;
    bgImgIdx = bgImgIdx + 1;
end

%==


% clear variables for better memory management
clear bgSampleFrame; clear bgSample; clear bgFrames;

% create structuring elements used in cleanup of grayscale image
forErode = strel('disk', 1);
forClose1 = strel('disk', 3);
forClose2 = strel('disk', 4);
forDilate = strel('disk', 2);
% preallocate memory for marix for speed
processed = false(height, width, effectiveFrameCount);


for frameIdx = startFrame:endFrame
    %% Steps through the video frame by frame in the range [startFrame, endFrame]
    % reads in the movie file frame at frameIdx
    currFrame = read(cellVideo, frameIdx);
    
    % converts currFrame from a structure format to a 3D array (In future versions, speed can be improved of the code is altered to work on cell strct instead of 3D array.
    currFrame = uint8(mean(currFrame, 3));
    
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
    %cleanImg = imsubtract(backgroundImg, currFrame);
    
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