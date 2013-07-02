%% Filter testing code
% Designed to input a video, perform filtering operations, and then output
% the video with the filtered video below it for easy comparison and
% evaluation of effectiveness.  Written 6/28/13 by Mike Scott

% Clear the workspace and close any open figures
clear
clc
close all
tic


%% Input parameters
% Median filter size in pixels, must be an odd number; 11 is nice
med_size = 11;          
BH_size = 7;
% Threshold to filter out small cells, specifies the minimum AREA in pixels
% of a cell
smallest_cell = 50;      
% Emperical threshold value for binarizing images (default 4)
threshold = 4;  


%% Loading Sequence
% Loads the video specified and reads in the number of frames and the width
% and height of the frames.
filename = 'C:\Users\Mike\Desktop\TwoStacks\video.avi';
video = VideoReader(filename);
% The two lines to find the number of frames are necessary on some
% computers (different versions of windows!)
lastFrame = read(video, inf);
numFrames = video.NumberOfFrames;
videoWidth = video.width;  
videoHeight = video.height;

%% Computing an average background image
% Generates a vector of to select 100 evenly spaced frames in the video
selectRange = 1:ceil(numFrames/100):numFrames; 

% Reads in vid to form vidConverted,an array of 100 evenly spaced frames 
% specified by select_range.  On versions of MATLAB previous to 2013, the 
% comment should be removed, so that it averages over RGB to get 
% vidConverted (uint8 type uses less memory)
vidConverted = uint8(zeros(videoHeight, videoWidth, length(selectRange)));
for i=1:length(selectRange)
    vid = read(video, selectRange(i));
    vidConverted(:,:,i) = vid;    
    % Needed on older version to convert Vid to a uint8 type
    % Vid_Converted(:,:,i)=   uint8(mean(Vid,3));
end

% Finds the 'background'.  Goes pixel by pixel and averages that pixel
% value over the 100 selected frames.  The array averageFrame stores the
% computed background image
averageFrame = uint8(zeros(videoHeight, videoWidth));
for i = 1:videoHeight
    for j = 1:videoWidth
        averageFrame(i,j) = uint8(mode(vidConverted(i,j,:)));
    end
end

% %Displays the average image
% figure(1)
% imshow(averageFrame)

%% Steps through the video one frame at a time to segment out cells
% Clears variables to conserve memory 
clear vidConverted; clear selectRange;

for ii = 1:numFrames
    % Reads in the movie file frame by frame
    vid = read(video, ii); 

    %% Perform Change detection
    % Subtracts the background (averageFrame) from each frame, hopefully leaving
    % just the cells.  Again, the min/max statements ensure the indicies
    % are nonzero.
    Aaviconverted2(:,:) = (imsubtract(averageFrame,vid));   
    figure(1)
    imshow(averageFrame);
    figure(2)
    imshow(vid);
    
    % Performs a bottom hat filter using the strel 'se'
    se = strel('disk',BH_size);
    BH(:,:) = imbothat(Aaviconverted2,se);

    % Performs a median filter using the pixel size specified in the
    % header
    med_bhat(:,:) = medfilt2(BH(:,:),[med_size med_size]);

    % Gets rid of small 'cells'.  This function gets rid of any connected
    % region which is less that smallest_cell pixels connected.  Each frame
    % is converted to black and white before the small cells are filled in
    % with black.
    Clean(:,:) = bwareaopen(im2bw(double(med_bhat(:,:))/256, threshold/256),smallest_cell);
    figure(3)
    imshow(16*Aaviconverted2);
    figure(4)
    imshow(16*BH)
    figure(5)
    imshow(16*med_bhat)
    figure(6)
    imshow(Clean);
    ii
   
   
 
%     %% Overlapping the boundaries on the original image to check validity
%     % This section can be uncommented to display a plot that shows each
%     % of the filtered images as well as the composite ('Clean') image as it
%     % is filtered.  It can be used to verify that the code detects the
%     % cells, but if it is not being used for verification it slows down the
%     % usage of the code.
%      
%     % Gives the X (AB) and Y (CD) indicies of every white pixel in the
%     % image.  This is hopefully every pixel of every cell.
%     [AB CD] = find(logical(Clean(:,:))); 
%     
%     OVERLAP(:,:) = Aaviconverted(max([1 position(2)]):min([size(Aaviconverted,1) position(2)+position(4)]), max([1 position(1)]):min([size(Aaviconverted,2) position(1)+position(3)]));
%     for integ=1:length(AB)
%         OVERLAP(AB(integ),CD(integ))=255;
%     end
%  
%     
%     figure(100)
%     subplot(2,2,1)
%     imagesc(OVERLAP(:,:));
%     title (['Final; Frame ', int2str(rep)])
%     subplot(2,2,2)
%     imagesc(Aaviconverted2(:,:));
%     title (['Difference Image; Frame ', int2str(rep)])
%     colorbar;impixelinfo;
%     subplot(2,2,3)
%     imagesc(BH(:,:));
%     title (['Bottom Hat Filtered; Frame ', int2str(rep)])
%     colorbar;impixelinfo;
%     subplot(2,2,4)
%     imagesc(med_bhat(:,:));
%     title (['Median Filtered; Frame ', int2str(rep)])
%     colorbar;impixelinfo;
%     

%     %% Save
%     % The following code saves image sequence and the image template with
%     % the demarcation lines for the transit time analysis.
%     filename = [folder_name, video_name, '_', num2str(seg_number), '\','BWstill_', num2str(ii),'.tif']; %% Change filename .tif
%     imwrite(Clean(:,:),filename,'Compression','none');

end
