%% CellDetection.m
% function processed = CellDetection(cellVideo, startFrame, endFrame, folderName, videoName, mask)
% CellDetection loads the videos selected earlier and processes each frame
% to isolate the cells.  When debugging, the processed frames can be
% written to a video, or the outlines of the detected cells can be overlaid
% on the video.

% Code from Dr. Amy Rowat's Lab, UCLA Department of Integrative Biology and
% Physiology
% Code originally by Bino Varghese (October 2011)
% Updated by David Hoelzle (January 2013)
% Updated by Mike Scott (July 2013)
% Rewritten by Ajay Gopinath (July 2013)

% Inputs
%   - cellVideo: a videoReader object specifying a video to load
%   - startFrame: an integer specifying the frame to start analysis at
%   - endFrame: an integer specifying the frame to end analysis at
%   - folderName: a string specifying the filepath
%   - videoName: a string specifying the video's name
%   - mask: a logical array that was loaded in makeWaypoints and is used to
%       erase objects found outside of the lanes of the cell deformer.

% Outputs
%   - processed: An array of dimensions (height x width x frames) that
%       stores the processed frames.  Is of binary type.

% Changes
% Automation and efficiency changes made 03/11/2013 by Dave Hoelzle 
% Commenting and minor edits on 6/25/13 by Mike Scott 
% Increase in speed (~3 - 4x faster) + removed disk output unless debugging made on 7/5/13 by Ajay G.

function processed = CellDetection(cellVideo, startFrame, endFrame, folderName, videoName, mask)

%%% This code analyzes a video of cells passing through constrictions
%%% to produce and return a binary array of the video's frames which
%%% have been processed to yield only the cells.

progressbar([],0,[])

DEBUG_FLAG = false; % flag for whether to show debug info
WRITEMOVIE_FLAG = false; % flag for whether to write processed frames to movie on disk
USEMASK_FLAG = true; % flag whether to binary AND the processed frames with the supplied mask
OVERLAYOUTLINE_FLAG = false; % flag whether to overlay detected outlines of cells on original frames

if(OVERLAYOUTLINE_FLAG)
    disp('!!Warning: OVERLAYOUTLINE_FLAG is set, frames cannnot be processed!!');
end

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
    backgroundImg = mean(bgFrames, 3);
    
    bgImgs(:,:,bgImgIdx) = backgroundImg;
    bgImgIdx = bgImgIdx + 1;
end

% clear variables for better memory management
clear frameIdxs; clear backgroundImg; clear bgFrames; clear bgImgIdx; clear sampleInterval;

%% Prepare for Cell Detection
% create structuring elements used in cleanup of grayscale image
forClose = strel('disk', 10);

% automatic calculation of threshold value for conversion from grayscale to binary image
threshold = graythresh(uint8(mean(bgImgs, 3))) / 20;

% preallocate memory for marix for speed
if(OVERLAYOUTLINE_FLAG)
    processed = zeros(height, width, effectiveFrameCount, 'uint8');
else
    processed = false(height, width, effectiveFrameCount);
end

bgProcessTime = toc(startTime1);
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
    % subtracts the background in bgImgs from each frame, hopefully leaving
    % just the cells
    cleanImg = im2bw(imsubtract(bgImgs(:,:,imgIdx), currFrame), threshold);
    
    %% Cleanup 
    % clean the grayscale image of the cells to improve detection
    
    cleanImg = bwareaopen(cleanImg, 20);
    cleanImg = imclose(cleanImg, forClose);
    cleanImg = bwareaopen(cleanImg, 35);
    cleanImg = medfilt2(cleanImg, [7, 7]);
    cleanImg = bwareaopen(cleanImg, 35);
    
    if(USEMASK_FLAG)
        % binary 'AND' to find the intersection of the cleaned image and the mask
        % to prevent the detected cell boundaries from being outside the microfluidic device
        cleanImg = cleanImg & mask; 
    end
    
    if OVERLAYOUTLINE_FLAG == 1
        cleanImg = imadd(currFrame, uint8(bwperim(cleanImg)*255));
    end
    
    %% Store cleaned image of segmented cells in processed
    processed(:,:,frameIdx-startFrame+1) = cleanImg;
    
    % Increments the progress bar, each time 1% of the frames are finished
    if mod(frameIdx, floor(effectiveFrameCount/100)) == 0
        progressbar([], frameIdx/effectiveFrameCount, [])
    end
end

% stop recording the time and output debugging information
framesTime = toc(startTime2);
totalTime = bgProcessTime + framesTime;
disp(['Time taken for cell detection: ', num2str(totalTime), ' secs']);
disp(['Average time to detect cells per frame: ', num2str(framesTime/effectiveFrameCount), ' secs']);

%% Set up frame viewer and write to file if debugging is on
if(DEBUG_FLAG)
    implay(processed);
    
    % if video file is set
    if(WRITEMOVIE_FLAG)
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
