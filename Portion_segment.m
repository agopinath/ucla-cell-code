%% Cell Segmentation Algorithm (Modified as of 10/05/2011) by Bino Abel Varghese
% Automation and efficiency changes made 03/11/2013 by Dave Hoelzle

function Portion_segment(video_name, folder_name, start_frame, end_frame, position, seg_number)

%% The aim of the code to segment a binary image of the cells from a stack of grayscale images

%% Clearing screen
% clear;
% close all;
clc;

%% ------------------------- Header Strip -------------------------------%
% all major code design changes made here
med_size = 11;                % pixels, median filter size, must be an odd number; 11 is nice
BH_size = 7;
smallest_cell = 5;         % pixels, threshold to filter out small cells
threshold = 4;              % Emperical threshold value for binarizing images
% folder_name = '';
% video_name = ['MOCK 5um 4psi 600fps Dev1-41'];
% no_of_seg = 1;
% start_frame = 1;
% end_frame = 1000;
% position = [14     19    529    285];
% seg_number = 1;


%% Computing an average image
temp_mov = VideoReader([folder_name, video_name]);

select_range = 1:ceil(temp_mov.NumberOfFrames/100):temp_mov.NumberOfFrames; % change back to range_wide later

% Compile image stack first
for i=1:length(select_range)
    Aavi =                  read(temp_mov, select_range(i));
    Aaviconverted(:,:,i)=   uint8((mean(Aavi,3)));
end

    % find image baseline
for i = max([1 position(2)]):min([size(Aaviconverted,1) position(2)+position(4)])
    for j = max([1 position(1)]):min([size(Aaviconverted,2) position(1)+position(3)])
        Amean(i-max([1 position(2)])+1,j-max([1 position(1)])+1) = uint8(mean(Aaviconverted(i,j,:)));
    end
end

%% Stepping through one frame at a time to segment out cells
 clear Aaviconverted; clear select_range;

for rep = start_frame:end_frame
%% Reading the movie file frame by frame
Aavi=                                                                       read(temp_mov, rep); %%%% 3

% Convert the Avi from a structure format to a 3D array (In future versions, speed can be improved of the code is altered to work on cell strct instead of 3D array.
Aaviconverted(:,:) = uint8((mean(Aavi,3)));
%     Aaviconvertedplacehold(:,:,i)= Aaviconverted(:,:,i);
%     figure(11);
%     imshow(Aaviconverted(:,:));

clear Aavi; %% Saving memory %% Add more variables if you landup with Java heap or out of memory error.

%% Perform Change detection
    
    Aaviconverted2(:,:)=                                                  (imsubtract(Amean,Aaviconverted(max([1 position(2)]):min([size(Aaviconverted,1) position(2)+position(4)]), max([1 position(1)]):min([size(Aaviconverted,2) position(1)+position(3)]))));   

%bottom hat filter and median filter
se = strel('disk',BH_size);
BH(:,:) = imbothat(Aaviconverted2,se);

med_bhat(:,:) = medfilt2(BH(:,:),[med_size med_size]);

Clean(:,:)  =                                                      bwareaopen(im2bw(double(med_bhat(:,:))/256, threshold/256),smallest_cell);

[AB CD]=                                                               find(logical(Clean(:,:))); %%% If you want whole cell
%   

 
    %% Overlapping the boundaries on the original image to check validity
    
    OVERLAP(:,:)=                                                        Aaviconverted(max([1 position(2)]):min([size(Aaviconverted,1) position(2)+position(4)]), max([1 position(1)]):min([size(Aaviconverted,2) position(1)+position(3)]));
    for integ=1:length(AB)
        OVERLAP(AB(integ),CD(integ))=255;
    end
 
    if (rep<=50)
    figure(100)
    subplot(2,2,1)
    imagesc(OVERLAP(:,:));
    title (['Final; Frame ', int2str(rep)])
    subplot(2,2,2)
    imagesc(Aaviconverted2(:,:));
    title (['Difference Image; Frame ', int2str(rep)])
    colorbar;impixelinfo;
    subplot(2,2,3)
    imagesc(BH(:,:));
    title (['Bottom Hat Filtered; Frame ', int2str(rep)])
    colorbar;impixelinfo;
    subplot(2,2,4)
    imagesc(med_bhat(:,:));
    title (['Median Filtered; Frame ', int2str(rep)])
    colorbar;impixelinfo;
    end


%%%% The following code saves image sequence and the image template with
%%%% the demarcation lines for the transit time analysis.

filename=[folder_name, video_name, '_', num2str(seg_number), '\','BWstill_', num2str(rep),'.tif']; %% Change filename .tif
imwrite(Clean(:,:),filename,'Compression','none');

end