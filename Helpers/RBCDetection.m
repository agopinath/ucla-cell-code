%% RBCDetection.m

function processed = RBCDetection(cellVideo, startFrame, endFrame, folderName, videoName, mask, flags)

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

disp(sprintf(['\nStarting cell detection for ', videoName, '...']));

% stores the number of frames that will be processed
effectiveFrameCount = (endFrame-startFrame+1) ;

% store the height/width of the cell video for clarity
height = cellVideo.Height;
width = cellVideo.Width;

%% Calculate initial background image
sampleWindow = 100;

% if the sampling window is larger than the number of frames present,
% the number is set to all the frames present instead
if((sampleWindow+startFrame) > endFrame)
    sampleWindow = effectiveFrameCount-1;
end

% Store the first sampleWindow frames into bgFrames
bgFrames = zeros(height, width, sampleWindow, 'uint8');
for j = startFrame:(startFrame+sampleWindow-1)
    if(isVideoGrayscale)
        bgFrames(:,:,j) = read(cellVideo, j); % store the frame that was read in bgFrames
    else
        temp = read(cellVideo, j);
        bgFrames(:,:,j) = temp(:,:,1);
    end
end

% calculate the initial 'background' frame for the first sampleWindow
% frames by storing the corresponding pixel value as the mean value of each 
% corresponding pixel of the background frames in bgFrames
backgroundImg = uint8(mean(bgFrames, 3));

% clear variables for better memory management
clear frameIdxs;

%% Prepare for Cell Detection
% create structuring elements used in cleanup of grayscale image
forClose = strel('disk', 8);

% automatic calculation of threshold value for conversion from grayscale to binary image
threshold = graythresh(backgroundImg) / 30;

% preallocate memory for marix for speed
if(OVERLAYOUTLINE_FLAG)
    processed = zeros(height, width, effectiveFrameCount, 'uint8');
else
    processed = false(height, width, effectiveFrameCount);
end

bgProcessTime = toc(startTime1);
startTime2 = tic;
lastBackgroundImg = double(backgroundImg);
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
    
    % if the current frame is after the first sampleWindow frames,
    % start adjusting the backgroundImage so that it represents a 'moving'
    % average of the pixel values of the frames in the interval
    % [frameIdx-sampleWindow, frameIdx]. This better localizes the background 
    % imageso it 'adapts' to the local frames and appears to better segment 
    % the cells. bgFrames is used to store the previous sampleWindow frames
    % so that memory is recycled.
    if(frameIdx >= sampleWindow+startFrame)
        bgImgDbl = lastBackgroundImg - double(bgFrames(:,:,(mod(frameIdx-1,sampleWindow)+1)))/sampleWindow + double(currFrame)/sampleWindow;
        backgroundImg = uint8(bgImgDbl);
        lastBackgroundImg = bgImgDbl;
        bgFrames(:,:,mod(frameIdx-1,sampleWindow)+1) = currFrame;
    end
    
    %% Do cell detection
    % subtracts the background in bgImgs from each frame, hopefully leaving
    % just the cells
    cleanImg = im2bw(imsubtract(backgroundImg, currFrame), threshold);
    
    %% Cleanup 
    % clean the grayscale image of the cells to improve detection
%     cleanImg = bwareaopen(cleanImg, 20);
%     cleanImg = imbothat(cleanImg, forClose);
%     cleanImg = medfilt2(cleanImg, [5, 5]);
%     cleanImg = bwareaopen(cleanImg, 35);
%     cleanImg = bwmorph(cleanImg, 'bridge');
%     cleanImg = imfill(cleanImg, 'holes');
    cleanImg = bwareaopen(cleanImg, 10);
    cleanImg = imclose(cleanImg, forClose);
    cleanImg = imfill(cleanImg, 'holes');
    cleanImg = bwareaopen(cleanImg, 20);
    cleanImg = medfilt2(cleanImg, [3, 3]);
    cleanImg = bwareaopen(cleanImg, 20);
    
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
