%% Image Template Maker (Modified as of 10/05/2011) by Bino Abel Varghese
% Updated by David Hoelzle (2013/01/07)
% Updated 7/2/13 by Mike Scott.  Made the code more automatic, so no
% regions need to be selected for cropping or defining the constriction
% region.  Also, replaced the 'video_num input' (which was unused) with a
% 'template_size' variable to decide which template is to be used (5, 7, or
% 9 micron).

% This code uses the first frame of the video and a template file to
% automatically crop the frame and make a template for the lines that are
% used to calculate transit time.  This generated template is saved in the
% video's folder as a .tif

% The variable 'original_frame' is, strictly speaking', unecessary.  It is
% only used to display the original image with the lines superimposed in a
% figure at the end of this function.  However, this is a great way to
% verify this function is working correctly and the lines placed in the
% right places.  Once this code is confirmed to work well, it can be
% deleted (and it must be deleted in the event the code were to be used on
% the cluster!)

function [mask, line_template, x_offset] = MakeWaypoints(video_name, folder_name, template_size)
close all;

%% Loading
% Reads in the specified movie
temp_mov = VideoReader([folder_name, video_name]);

templateFolder = 'C:\Users\agopinath\Documents\ucla-cell-code\Masks';

% Reads in the specified template
template = imread(fullfile(templateFolder, [num2str(template_size), 'micron_thin.tif']));
loaded_mask = logical(imread(fullfile(templateFolder, [num2str(template_size), 'micron.tif'])));

% Load the input image and the template
frame = read(temp_mov,1);

% Copies the frame to another variable, to be overlaid with the lines later
% for verification (not strictly necessary, but nice to check if the lines
% have been placed correctly)
original_frame = frame;

%% Filtering
% Defines a sharpening filter h_sharp (sum of the entries == 1, so the
% brightness of the frame overall will be unchanged).
% Filtering scheme:
%   1) Sharpen
%   2) Enhance contrast
%   3) Convert to grayscale with automatic thresholding
%   4) Perform a median filter (gets rid of noise)
h_sharp = [-1 -1 -1; -1 12 -1; -1 -1 -1]/4;
frame = imfilter(frame, h_sharp);
frame = imadjust(frame,stretchlim(frame, [0.05 0.99]), []);
frame = im2bw(frame, graythresh(frame));
frame = medfilt2(frame);

%% Cross Correlation
% Computes the 2D normal cross correlation between the first frame and the
% template.  This gives x and y values for how much offset the template
% needs to match the video.  This allows automatic cropping and
% determination of the constriction region, hopefully leading to
% reproducibility.
% Perform the cross correlation to determine offset.
% This code is from the matlab documentation for normxcorr2.
% corr_offset contains [y_offset, x_offset].
cc = normxcorr2(template,frame);
[~, imax] = max(abs(cc(:)));
[ypeak, xpeak] = ind2sub(size(cc),imax(1));
corr_offset = [ (ypeak-size(template,1)) (xpeak-size(template,2)) ];

% Defines the position vector [Xmin Ymin width height]
% Max functions are there to prevent negative numbers which will become
% indicies 
position = [max(0,corr_offset(2)), max(0,corr_offset(1)), size(template,2), size(template,1)];
x_offset = corr_offset(2);

% Shows how well the correlation worked by overlaying the image template in
% green over the processed frame.
figure(52)
imshow(original_frame(max([1 position(2)]):min([size(frame,1) position(2)+position(4)-1]), max([1 position(1)]):min([size(frame,2) position(1)+position(3)-1]),:), 'InitialMag', 'fit')
% Makes an all green image, then by using 'AlphaData', only shows green
% pixels where the template was black (since the template was binary).
green = cat(3, zeros(size(template)), ones(size(template)), zeros(size(template)));
hold on
h = imshow(green);
hold off
set(h, 'AlphaData', imcomplement(template))

%% Line template generation
% Preallocates an array for storing the template
line_template = uint8(zeros(size(frame)));

% The variable 'zerothLinePos' stores the y-value in pixels of the top line,
% default value = 22 pixels for 5, 7, and 9 micron templates, and 19 pixels 
% for the 3 micron template. 'firstLinePos' stores the y-value of the second
% line (the line that should on the first constriction). The position(2) offset 
% is due to the different size of the template and frame.  The variable 
% 'spacing' gives the spacing between constrictions, default value = 32 pixels
% for 5, 7, and 9 micron templates, and 28 for the 3 micron template.  
if template_size == 3
    %constrict = 47 + position(2);
    zerothLinePos = 19 + position(2);
    firstLinePos = 47 + position(2);
    spacing = 28;
else
    %constrict = 46 + position(2);
    zerothLinePos = 26 + position(2);
    firstLinePos = 46 + position(2);
    spacing = 32;
end

% Resizes the mask to be the same size as the frame, but shifted
% appropriately
mask = false(size(frame));
mask(position(2)+1:size(loaded_mask,1)+position(2), position(1)+1:size(loaded_mask,2)+position(1)) = loaded_mask; 

% Verifies the mask and frame are the same size
% If mask is too large it is cropped down to size of frame
if size(mask,1) ~= size(frame,1) || size(mask,2) ~= size(frame,2)
    mask = mask (max(1,abs(size(mask,1)-size(frame,1))+1):size(mask,1),max(1,abs(size(mask,2)-size(frame,2))+1):size(mask,2));
end

% This loop writes the horizontal lines defining each constriction to the
% template
for i = 1:8
    if(i ~= 1)
        line_template(floor(firstLinePos+(i-2)*spacing),:) = uint8(ones(1,size(frame,2)));
    else
        line_template(floor(zerothLinePos),:) = uint8(ones(1,size(frame,2)));
    end
end

%% Check: Displays the template overlaid on the background image 
% Stores the value of every white point (line on template) in a vector
[Xcoords,Ycoords]= find(line_template);

% Draws the lines in the template on the original_frame, shows the figure
for counter=1:length(Xcoords)
    original_frame(Xcoords(counter),Ycoords(counter),1:3)= ones(1,3)*255;
end
figure(11);
imshow(original_frame);
