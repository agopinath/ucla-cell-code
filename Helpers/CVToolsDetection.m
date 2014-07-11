%% DefaultDetection.m

function processed = CVToolsDetection(cellVideo, startFrame, endFrame, folderName, videoName, mask, flags)
dbstop if error
%%% This code analyzes a video of cells passing through constrictions
%%% to produce and return a binary array of the video's frames which
%%% have been processed to yield only the cells.

progressbar([],0,[])

DEBUG_FLAG = flags(1); % flag for whether to show debug info
WRITEMOVIE_FLAG = flags(2); % flag for whether to write processed frames to movie on disk
USEMASK_FLAG = flags(3); % flag whether to binary AND the processed frames with the supplied mask
OVERLAYOUTLINE_FLAG = flags(4); % flag whether to overlay detected outlines of cells on original frames

if(OVERLAYOUTLINE_FLAG)
    disp('!!Warning: OVERLAYOUTLINE_FLAG is set, frames cannnot be processed!!');
end

startTime1 = tic;

isVideoGrayscale = (strcmp(cellVideo.VideoFormat, 'Grayscale') == 1);

disp(sprintf(['\nStarting cell detection for ', videoName, '...']));

%% Calculate initial background image
sampleWindow = 350;

% if the sampling window is larger than the number of frames present,
% the number is set to all the frames present instead
if((sampleWindow+startFrame) > endFrame)
    sampleWindow = effectiveFrameCount-1;
end

%endFrame = 900;
effectiveFrameCount = (endFrame-startFrame+1) ;

%% Prepare for Cell Detection
% create structuring elements used in cleanup of grayscale image
forClose = strel('disk', 6);
forErr = strel('disk', 1);

% automatic calculation of threshold value for conversion from grayscale to binary image
%threshold = graythresh(backgroundImg) / 20;

% preallocate memory for marix for speed
if(OVERLAYOUTLINE_FLAG)
    processed = zeros(304, 544, effectiveFrameCount, 'uint8');
else
    processed = false(304, 544, effectiveFrameCount);
end


bgProcessTime = toc(startTime1);
startTime2 = tic;

foregroundDetector = vision.ForegroundDetector('NumGaussians',3, 'NumTrainingFrames', sampleWindow,...
                                                'MinimumBackgroundRatio', .32);
videoReader = vision.VideoFileReader(fullfile(folderName, videoName));

for nn = 1:(startFrame-1)
    step(videoReader); % step until startFrame is reached
end

%% Step through video
% iterates through each video frame in the range [startFrame, endFrame]
for frameIdx = startFrame:endFrame
    currFrame = step(videoReader); % read the next video frame
    %currFrame = step(videoReader);
    %currFrame = currFrame(:,:,1);
    cleanImg = step(foregroundDetector, currFrame);
    %cleanImg = uint8(cleanImg);
    %cleanImg = bwareaopen(cleanImg, 10);
    cleanImg = bwareaopen(cleanImg, 7);
    %cleanImg = imdilate(cleanImg, forDil);
    cleanImg = imclose(cleanImg, forClose);
    cleanImg = medfilt2(cleanImg, [9, 9]);
    cleanImg = bwareaopen(cleanImg, 75);
    cleanImg = imfill(cleanImg, 'holes');
    cleanImg = imerode(cleanImg, forErr);
%     
%     cleanImg = im2bw(imsubtract(backgroundImg, currFrame), threshold);
    
    %% Cleanup 
    % clean the grayscale image of the cells to improve detection
%     cleanImg = bwareaopen(cleanImg, 20);
%     cleanImg = imbothat(cleanImg, forClose);
%     cleanImg = medfilt2(cleanImg, [5, 5]);
%     cleanImg = bwareaopen(cleanImg, 35);
%     cleanImg = bwmorph(cleanImg, 'bridge');
%     cleanImg = imfill(cleanImg, 'holes');
    
    if(USEMASK_FLAG)
        % binary 'AND' to find the intersection of the cleaned image and the mask
        % to prevent the detected cell boundaries from being outside the microfluidic device
        cleanImg = cleanImg & mask; 
    end
    
    if OVERLAYOUTLINE_FLAG == 1
        currFrame = uint8(currFrame(:,:,1));
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