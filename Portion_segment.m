%% Cell Segmentation Algorithm (Modified as of 10/05/2011) by Bino Abel Varghese
% Automation and efficiency changes made 03/11/2013 by Dave Hoelzle
% Adding comments, commenting the output figure on 6/25/13 by Mike Scott

function Portion_segment(video_name, folder_name, start_frame, end_frame, position, seg_number)

%% The aim of this code is to segment a binary image of the cells from a stack of grayscale images

%% Clears the screen
% clear;
% close all;
clc;

%% ------------------------- Header Strip -------------------------------%
% all major code design changes made here
% 6/25/13 Commented out the code which generated the 'overlap' diagram.  It
% was unused and slowed down the user during execution.  Also added
% comments to clarify the code. (Mike Scott)

% Median filter size in pixels, must be an odd number; 11 is nice
med_size = 11;          
BH_size = 7;
% Threshold to filter out small cells, specifies the minimum AREA in pixels
% of a cell
smallest_cell = 5;      
% Emperical threshold value for binarizing images (default 4)
threshold = 4;          
% folder_name = '';
% video_name = ['MOCK 5um 4psi 600fps Dev1-41'];
% no_of_seg = 1;
% start_frame = 1;
% end_frame = 1000;
% position = [14     19    529    285];
% seg_number = 1;


%% Computing an average image
% Loads the video
temp_mov = VideoReader([folder_name, video_name]);

% Generates a vector of to select 100 evenly spaced frames in the video
select_range = 1:ceil(temp_mov.NumberOfFrames/100):temp_mov.NumberOfFrames; % change back to range_wide later

% Compiles Aavi, an array of 100 evenly spaced frames specified by
% select_range, and then averages over RGB to get Aaviconverted (uint8 type
% uses less memory)
for i=1:length(select_range)
    Aavi =                  read(temp_mov, select_range(i));
    Aaviconverted(:,:,i)=   uint8(mean(Aavi,3));
end

% Finds the 'background'.  Goes pixel by pixel and averages that pixel
% value over the 100 selected frames.  Amean is the average of these 100
% frames.  The 'max' and 'min' statements ensure the box (specified by the
% user) are nonnegative and within the video size.
for i = max([1 position(2)]):min([size(Aaviconverted,1) position(2)+position(4)])
    for j = max([1 position(1)]):min([size(Aaviconverted,2) position(1)+position(3)])
        Amean(i-max([1 position(2)])+1,j-max([1 position(1)])+1) = uint8(mean(Aaviconverted(i,j,:)));
    end
end

%% Steps through the video one frame at a time to segment out cells
% Clears variables to conserve memory 
clear Aaviconverted; clear select_range;

for rep = start_frame:end_frame
    %% Reads in the movie file frame by frame
    Aavi = read(temp_mov, rep); 

    % Converts the Avi from a structure format to a 3D array (In future versions, speed can be improved of the code is altered to work on cell strct instead of 3D array.
    Aaviconverted(:,:) = uint8((mean(Aavi,3)));
    %     Aaviconvertedplacehold(:,:,i)= Aaviconverted(:,:,i);
    %     figure(11);
    %     imshow(Aaviconverted(:,:));

    % Clears Aavi to save memory, add more variables if you landup with 
    % Java heap or out of memory error. 
    clear Aavi;  

    %% Perform Change detection
    % Subtracts the background (Amean) from each frame, hopefully leaving
    % just the cells.  Again, the min/max statements ensure the indicies
    % are nonzero.
    Aaviconverted2(:,:) = (imsubtract(Amean,Aaviconverted(max([1 position(2)]):min([size(Aaviconverted,1) position(2)+position(4)]), max([1 position(1)]):min([size(Aaviconverted,2) position(1)+position(3)]))));   

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
%     if (rep<=50)
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
%     end

    %% Save
    % The following code saves image sequence and the image template with
    % the demarcation lines for the transit time analysis.
    filename = [folder_name, video_name, '_', num2str(seg_number), '\','BWstill_', num2str(rep),'.tif']; %% Change filename .tif
    imwrite(Clean(:,:),filename,'Compression','none');

end