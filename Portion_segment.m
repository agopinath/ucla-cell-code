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
videoName = 'dev9x10_20X_1200fps_0.6ms_2psi_p9_324_1.avi';%'unconstricted_test.avi';
segmentNum = 1;

% create the folder to write to
writeFolder = [folderName, videoName, '_', num2str(segmentNum)];
mkdir(writeFolder);

%% Computing an average image
% loads the video and initialize range of frames to process
cellVideo = VideoReader([folderName, videoName]);
startFrame = 1;
endFrame = cellVideo.NumberOfFrames;

% generates a sample array of the indices of 100 evenly spaced frames in the video
bgSample = 1:ceil(cellVideo.NumberOfFrames/100):cellVideo.NumberOfFrames;

% store the height/width of the cell video for clarity
height = cellVideo.Height;
width = cellVideo.Width;

% bgFrames holds the video frames specified by the indices stored in bgSample
bgFrames = zeros(height, width, 'uint8');
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

forErode = strel('disk', 1);
forClose = strel('disk', 11);

startTime = tic;
for frameIdx = startFrame:endFrame
    %% Steps through the video frame by frame in the range [startFrame, endFrame]
    % reads in the movie file 
    currFrame = read(cellVideo, frameIdx); 

    % converts currFrame from a structure format to a 3D array (In future versions, speed can be improved of the code is altered to work on cell strct instead of 3D array.
    currFrame = uint8(mean(currFrame,3));
    
    %% Do cell detection
    % subtracts the background (backgroundImg) from each frame, hopefully leaving
    % just the cells
    cleanImg = imsubtract(backgroundImg, currFrame);
    
    %% Cleanup the grayscale image of the cells
    cleanImg = imadjust(cleanImg);
    
    cleanImg = imerode(cleanImg, forErode);
    cleanImg = bwareaopen(cleanImg, 40);
    
    cleanImg = imclose(cleanImg, forClose);
    
    %% Save edge-detected image file
    % the following code saves image sequence and the image template with
    % the demarcation lines for the transit time analysis
    filename = [writeFolder, '\','BWstill_', num2str(frameIdx), '.tif'];
    imwrite(cleanImg, filename, 'Compression', 'none');
end

totalTime = toc(startTime)
averageTimePerFrame = totalTime/(endFrame-startFrame)