%% Cell Segmentation Algorithm (Modified as of 10/05/2011) by Bino Abel Varghese
% Automation and efficiency changes made 03/11/2013 by Dave Hoelzle
% Adding comments, commenting the output figure on 6/25/13 by Mike Scott
% Adding comments, commenting the output figure on 6/25/13 by Mike Scott

% function Portion_segment(video_name, folder_name, start_frame, end_frame, position, seg_number)

%% The aim of this code is to segment a binary image of the cells from a stack of grayscale images

clc;

% 6/25/13 Commented out the code which generated the 'overlap' diagram.  It
% was unused and slowed down the user during execution.  Also added
% comments to clarify the code. (Mike Scott)

folderName = 'C:\Users\agopinath\Desktop\CellVideos\';
videoName = 'unconstricted_test.avi';%'unconstricted_test.avi';
segmentNum = 1;

% create the folder to write to
writeFolder = [folderName, videoName, '_', num2str(segmentNum)];
mkdir(writeFolder);

%% Computing an average image
% loads the video and initialize range of frames to process
cellVideo = VideoReader([folderName, videoName]);
startFrame = 4;
endFrame = cellVideo.NumberOfFrames;

% generates a sample array of the indices of 100 evenly spaced frames in the video
bgSample = 1:ceil(cellVideo.NumberOfFrames/100):cellVideo.NumberOfFrames;

% read cell video 
bgFrames = read(cellVideo, 1);
height = size(bgFrames, 1);
width = size(bgFrames, 2);

% bgFrames holds the video frames specified by the indices stored in bgSample
bgFrames = zeros(height, width, 'uint8');
for i = 1:length(bgSample)
    bgSampleFrame = read(cellVideo, bgSample(i));
    bgFrames(:,:,i) = uint8(mean(bgSampleFrame,3));
end

% finds the 'background'.  Goes pixel by pixel and averages that pixel
% value over the 100 selected frames.  Amean is the average of these 100
% frames

movi = zeros(height, width, 'uint8');
for i = 1:height
    for j = 1:width
        backgroundImg(i,j) = uint8(mean(bgFrames(i,j,:)));
    end
end

clear bgSampleFrame; clear bgSample;

%% Steps through the video frame by frame in the range [startFrame, endFrame]
for frameIdx = startFrame:endFrame
    % reads in the movie file 
    bgSampleFrame = read(cellVideo, frameIdx); 

    % converts the Avi from a structure format to a 3D array (In future versions, speed can be improved of the code is altered to work on cell strct instead of 3D array.
    bgFrames(:,:) = uint8(mean(bgSampleFrame,3));
    
    %% Perform Change detection
    % subtracts the background (Amean) from each frame, hopefully leaving
    % just the cells.  Again, the min/max statements ensure the indicies
    % are nonzero.
    Aaviconverted2 = imsubtract(backgroundImg, bgFrames(:,:));
    Aaviconverted2 = imadjust(Aaviconverted2);

    Aaviconverted2 = bwareaopen(Aaviconverted2, 40);
    seD = strel('disk', 1);
    Aaviconverted2 = imerode(Aaviconverted2, seD);
    Aaviconverted2 = bwareaopen(Aaviconverted2, 40);
    seD = strel('disk', 2);
    Aaviconverted2 = imclose(Aaviconverted2, seD);
    
    %% Save edge-detected image file
    % the following code saves image sequence and the image template with
    % the demarcation lines for the transit time analysis
    filename = [writeFolder, '\','BWstill_', num2str(frameIdx),'.tif'];
    imwrite(Aaviconverted2(:,:),filename,'Compression','none');
end