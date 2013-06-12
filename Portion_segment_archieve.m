%% Cell Segmentation Algorithm (Modified as of 10/05/2011) by Bino Abel Varghese
% Small automation changes made 12/29/2011 by Dave Hoelzle

% function Portion_segment(video_name, folder_name, start_frame, end_frame, position, seg_number)

%% The aim of the code to segment a binary image of the cells from a stack of grayscale images

%% Clearing screen
clear;
% close all;
clc;

%% ------------------------- Header Strip -------------------------------%
% all major code design changes made here
f_size = 13;                % pixels, median filter size, must be an odd number; 15 is nice
smallest_cell = 15;         % pixels, threshold to filter out small cells
threshold = 2;              % Emperical threshold value for binarizing images
corr_filt_size = 5;         % Correlation filter size
folder_name = 'D:\120220 hl60\MOCK 5um 4psi 600fps';
video_name = ['MOCK 5um 4psi 600fps Dev1-41'];
no_of_seg = 1;
start_frame = 1;
end_frame = 1000;
position = [14     19    529    285];
seg_number = 1;


%% Computing an average image
temp_mov = VideoReader([folder_name, '\', video_name, '.avi']);

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

% Correlation Filter
    h = fspecial ('gaussian'); %ones(corr_filt_size,corr_filt_size) / corr_filt_size^2;
    Correlated = imfilter(Aaviconverted2,h, 'corr');
%     figure (194)
%     imagesc(Correlated(:,:));
%     title (['Correlated Image - Frame ' int2str(rep)])
%     colorbar;impixelinfo;
    

    %% Suppressing very small changes (here less than 15 (based on optimization of various avis') and binarizing the images
    
%     for l=1:size(Aaviconverted2,1)
%         for m=1:size(Aaviconverted2,2)
%             if Aaviconverted2(l,m)<5;%%15 
%                 Aaviconverted2(l,m)=0;
%             end
%         end
%     end
%             figure (20);
%             imagesc(Aaviconverted2(:,:));
%             title (['Noise Suppression - Frame ' int2str(rep)])
%             colorbar;
%             impixelinfo;
%     
    %% Dilating to improve connectivity
    
    SE =                                                                    strel('disk',1, 8);
%     DilateCell(:,:)=                                                      imdilate(Aaviconverted2(:,:),SE);
%             figure(21);
%             imagesc(DilateCell(:,:));
%             colorbar;
%             impixelinfo;
            
            DilateCell(:,:)=                                                      imdilate(Correlated(:,:),SE);
%             figure(215);
%             imagesc(DilateCell(:,:));
%             title ('Dilated')
%             colorbar;
%             impixelinfo;
            
   
    %% Finding the neighbourhood of the strel element for the standard deviation filter
    
%     NHOOD3 =                                                                getnhood(SE);
%     
%     %% Findgin the standard deviation (STD) along a neighbourhood across the whole image
%     
%     S(:,:) =                                                              stdfilt(Correlated(:,:),NHOOD3); %% STD filter
%     S(:,:)=                                                               mat2gray(S(:,:));
%     S(S(:,:)<0.15)=                                                       0; %% zeroing the the very small values (based on optimization)
%     S(:,:)=                                                               S(:,:)*450; %% was 500, Increasing the contribution from the STD filter
% %             figure(22);
% %             imagesc(S(:,:));
% %             colorbar;
% %             impixelinfo;
%     
% %% Weighted sum of Dilated Cell and STD filter  
%     CellClean(:,:)=                                                       double(0*Correlated(:,:))+(S(:,:))./2;
%             figure(23);
%             imagesc(CellClean(:,:));
%             title (['Weighted Sum ' int2str(rep)])
%             colormap(hsv);
%             colorbar;
%             impixelinfo;
    
    %% Removing small values below 20 (noise)
%     for l=1:size(Aaviconverted2,1)
%         for m=1:size(Aaviconverted2,2)
%             if CellClean(l,m)<20;%% was 25, was 50
%                 CellClean(l,m)=0;
%             end
%         end
%     end
%         figure (24);
%         imagesc(CellClean(:,:));
%         colormap(hsv);
%         colorbar;
%         impixelinfo;

 %% Imdilating for connectivity
%     SE1 =                                                                   strel('rectangle', [7 1]) ; %%2 original
%     CellClean1(:,:)=                                                      imdilate(CellClean(:,:),SE1);
%     
%     %% Computing the euclidean distances of each cell
%     
%     % Compute the distance transform of the complement of the binary image.
%     
%     D(:,:) =                                                              bwdist(~CellClean(:,:));
%     
%     %% Converting the matrix to a grayscale image
%     
%     D(:,:)=                                                               mat2gray(D(:,:));
% %     figure(25), imagesc(D(:,:));
% %     colorbar;
% %     title('Distance transform of ~bw');
%     
%     %% Combine distance information with standard deviation based cell intensities
%     %% At this stage if require the profile intensity based segmentation code can be invoked, but the results are comparable, but faster this way.
%     
%     L(:,:)=                                                               D(:,:).*CellClean(:,:);
%         for ia=1:size(L(:,:),1)
%             for ib=1:size(L(:,:),2)
%         if L(ia,ib)<5
%             L(ia,ib)=0;
%         end
%         end
%         end
    
%         figure(26), imagesc(L(:,:));
%         colorbar;
%         title('Check');
    
    Medfiltimage(:,:) = medfilt2(DilateCell(:,:), [f_size f_size]);      %L(:,:), [f_size f_size]);      % Filter size, must be odd numbers
%     if (rep<=50)
%     figure(40), imagesc(Medfiltimage(:,:));
%     colorbar;
%     title(['Medfiltimage - Frame ' int2str(rep)]);
%     impixelinfo
%     end
    
    
    %% Binarizing to peform morphological operations
    
    % Finding the coordinates of the target cells
%     [xcoord,ycoord]=                                                        find(Medfiltimage(:,:));
%     
%     %% Initialization
%     BinarizedImage(:,:)=                                                  zeros(size(CellClean(:,:)));
    
    %% Capturing the target cells in above matrix
%     for inc=1:length(xcoord)
%         BinarizedImage(xcoord(inc),ycoord(inc))=255;
%     end
%     clear xcoord ycoord;
    
%     figure (27);
%     imagesc(BinarizedImage(:,:));
%     colormap(jet);
%     colorbar;
%     impixelinfo;
%     
    %% Removing small particles anything below 'smallest_cell' pixels (based on optimization)
%     Cleaning(:,:)  =                                                      bwareaopen(BinarizedImage(:,:),smallest_cell);
%     figure(28);
%     imshow(Cleaning(:,:));
%     colormap(jet);
%     impixelinfo;
%     
    % % % % %     Additional morphological operations, incase of case of poor quality images
    % % % %
%                 Closing(:,:)=bwmorph(Cleaning(:,:),'bridge',30);
%                     figure(29);
%                     imagesc(Closing(:,:));
%                     colormap(jet);
%                     colorbar;
%                     impixelinfo;
    
%                 Imfillcell(:,:) = imfill(Cleaning(:,:),'holes');
%                     figure(30);
%                     imagesc(Imfillcell(:,:));
%                     colormap(jet);
%                     colorbar;
%                     impixelinfo;
%     % % % %
    %                Merging labels if close
%                      [label_label, label_num]=bwlabel(Imfillcell(:,:));
%                      s = regionprops(label_label, 'Centroid');
%                      centroids = cat(1, s.Centroid);
%                      for inte=1:label_num-1
%                      if abs(centroids(inte,2)-centroids(inte+1,2))<20
%                          Imfillcell(centroids(inte,2):centroids(inte+1,2),centroids(inte,1):centroids(inte,1)+1)=1;
%                      end
%                      end
%                      clear centroids label_label label_num s;
%                      figure(31);
%                      imshow(Imfillcell(:,:));
    
    %                Multiply with Binary mask
%                      Imageset(:,:)=Imfillcell(:,:).*BinaryMask;
%                      figure(32);
%                      imshow(Imageset(:,:));
    
%                     CleanCellOne(:,:)  = bwareaopen(Imfillcell(:,:),300);
%                     figure(33);
%                     imagesc(CleanCellOne(:,:));
%                     colormap(jet);
%                     colorbar;
%                     impixelinfo;
    
%                       CleanCellBoundary1(:,:)  = bwmorph(CleanCellOne(:,:),'bridge',10);
%     % % % %
%     SizeCorrectedCleanCellOne(:,:)=                                       bwmorph(Cleaning(:,:),'erode',2);
%     figure(34);
%     imshow(SizeCorrectedCleanCellOne(:,:));
%     colormap(jet);
%     impixelinfo;
%     % % % %
%     % % % % %             Multiplying by the mask
%     % % % %
%     % % % %
%     % % % %                 BW2(:,:) = bwperim(Cleaning(:,:), 8);
%     % % % %
%     % % % %                     figure(35);
%     % % % %                     imagesc(BW2(:,:));
%     % % % %                     colormap(jet);
%     % % % %                     colorbar;
%     % % % %                     impixelinfo;
%     % % % %
%     % % % %                 BW6(:,:) = edge(BW2(:,:),'canny',0.01,2);
%     % % % %
%     % % % %                 BW7(:,:)=bwmorph(BW6(:,:),'dilate',1);
%     % % % %                 BW8(:,:)=bwmorph(BW7(:,:),'bridge',100);
%     % % % %                 BW9(:,:)=bwmorph(BW8(:,:),'erode',1);
%     % % % %                 CELL(:,:) = imfill(BW9(:,:),'holes');
%     % % % %                 figure(36);
%     % % % %                 imagesc(CELL(:,:));
%     % % % %                 colormap(jet);
%     % % % %                 colorbar;
%     % % % %                 impixelinfo;
%     
%     % Getting the cell edges using canny with a low intensity threshold and sigma of 2
%     CELLWALL(:,:) =                                                      edge(Cleaning(:,:),'canny',0.01,2);
%     %             figure(37);
%     %             imshow(CELLWALL(:,:));
%     
%     %% Finding the coordinates of the cell boundaries
% %     
% %     [AB CD]=                                                                    find(logical(CELLWALL(:,:))); %%% If you want only cell boundaries
BW = im2bw(double(Medfiltimage)/256, threshold/256);
%             figure(300);
%             imagesc(BW(:,:));
%             title ('Thresholded')
%             colorbar;
%             impixelinfo;   
Clean(:,:)  =                                                      bwareaopen(BW(:,:),smallest_cell);

[AB CD]=                                                               find(logical(Clean(:,:))); %%% If you want whole cell
%   

 
    %% Overlapping the boundaries on the original image to check validity
    
    OVERLAP(:,:)=                                                        Aaviconverted(max([1 position(2)]):min([size(Aaviconverted,1) position(2)+position(4)]), max([1 position(1)]):min([size(Aaviconverted,2) position(1)+position(3)]));
    for integ=1:length(AB)
        OVERLAP(AB(integ),CD(integ))=255;
    end
%     if (rep<=50)
%         figure(38);
%         imshow(OVERLAP(:,:));
%         title (['Final - Frame ' int2str(rep)])
%     end
    if (rep<=50)
    figure(100)
    title (['Frame ', int2str(rep)])
    subplot(2,2,1)
    imagesc(OVERLAP(:,:));
    title ('Final')
    subplot(2,2,2)
    imagesc(Aaviconverted2(:,:));
    title ('Difference Image')
    colorbar;impixelinfo;
    subplot(2,2,3)
    imagesc(Correlated(:,:));
    title ('Correlated Image')
    colorbar;impixelinfo;
    subplot(2,2,4)
    imagesc(Medfiltimage(:,:));
    title ('Median Filtered')
    colorbar;impixelinfo;
    end


%%%% The following code saves image sequence and the image template with
%%%% the demarcation lines for the transit time analysis.

filename=[folder_name, '\', video_name, '_', num2str(seg_number), '\','BWstill_', num2str(rep),'.tif']; %% Change filename .tif
imwrite(Clean(:,:),filename,'Compression','none');

end