%% MakeWaypoints.m
% function [mask, lineTemplate, xOffset] = MakeWaypoints(cellVideo, templateSize)
% This code uses the first frame of the video to make a template that is
% used to calculate transit time.  The template has 8 horizontal lines to
% define a preconstriction area (where unconstricted area is calculated) as
% well as the 7 constriction areas.  Automatically detects the regions
% using a template and numerical correlation.  Outputs a figure to enable
% quick determination of whether or not the correlation was successful.

% Code from Dr. Amy Rowat's Lab, UCLA Department of Integrative Biology and
% Physiology
% Code originally by Bino Varghese (October 2011)
% Updated by David Hoelzle (January 2013)
% Updated by Sam Bruce, Ajay Gopinath, and Mike Scott (July 2013)

% Inputs
%   - cellVideo: a videoReader object for the video specified by the user
%   - templateSize: an integer that specifies the constriction size of the
%       template to be used.  Options are 3, 5, 7, or 9 microns.

% Outputs
%   - mask: a logical array that defines the lanes, and is loaded as a .tif 
%       file from the specified filepath
%   - lineTemplate: a logical array with the same size as the input video, 
%        with horizontal lines defining the constriction regions
%   - xOffset: an integer specifying the number of pixels the template must
%        be offset horizontally in order to match with the video.

% Updated by David Hoelzle (2013/01/07)
% Updated 7/2/13 by Mike Scott.  Made the code more automatic, so no
% regions need to be selected for cropping or defining the constriction
% region.  Also, replaced the 'video_num input' (which was unused) with a
% 'templateSize' variable to decide which template is to be used (5, 7, or
% 9 micron).

function [mask, lineTemplate, xOffset] = MakeWaypoints(cellVideo, templateSize)

%% Loading
templateFolder = 'C:\Users\Ajay\Documents\ucla-cell-code\Masks';%'Y:\072213 Cell Deformer V2 (Stable Release)\Masks';

% Reads in the specified template
template = imread(fullfile(templateFolder, [num2str(templateSize), 'micron_thin.tif']));
loadedMask = logical(imread(fullfile(templateFolder, [num2str(templateSize), 'micron.tif'])));

% Load the input image and the template
frame = read(cellVideo,1);

% Copies the frame to another variable, to be overlaid with the lines later
% for verification (not strictly necessary, but nice to check if the lines
% have been placed correctly)
originalFrame = frame;


%% Filtering
% Defines a sharpening filter hSharp (sum of the entries == 1, so the
% brightness of the frame overall will be unchanged).
% Filtering scheme:
%   1) Sharpen
%   2) Detect edges
%   3) Enhance contrast
%   4) Convert to grayscale with automatic thresholding
%   5) Perform a median filter (gets rid of noise)
%   6) Inverts binary image

hSharp = [-1 -1 -1; -1 12 -1; -1 -1 -1]/4;
frame = imfilter(frame, hSharp);
h = fspecial('prewitt');
frame = imfilter(frame, h');
frame = imadjust(frame,stretchlim(frame, [0.05 0.99]), []);
frame = im2bw(frame, graythresh(frame));
frame = medfilt2(frame);
frame = ~frame;


%% Image Registration
%Registers the processed first frame to the template and
%translates the frame to match the template.
[optimizer, metric] = imregconfig('multimodal');

    optimizer.GrowthFactor = 1.0000001;
    optimizer.Epsilon = 1.5e-7;
    optimizer.MaximumIterations = 200;
    optimizer.InitialRadius = 6.25e-4;
    
registeredFrame = imregister(double(frame), double(template),'translation',optimizer,metric);


%% Cross Correlation
% Computes the 2D normal cross correlation between the first frame and the
% template.  This gives x and y values for how much offset the template
% needs to match the video.  This allows automatic cropping and
% determination of the constriction region, hopefully leading to
% reproducibility.
% Perform the cross correlation to determine offset.
% This code is from the matlab documentation for normxcorr2.
% corrOffset contains [yOffset, xOffset].
cc = normxcorr2(template, frame);
[~, imax] = max(abs(cc(:)));
[ypeak, xpeak] = ind2sub(size(cc),imax(1));
corrOffset = [ (ypeak-size(template,1)) (xpeak-size(template,2)) ];

% Defines the position vector [Xmin Ymin width height]
% Max functions are there to prevent negative numbers which will become
% indicies 
position = [max(0,corrOffset(2)), max(0,corrOffset(1)), size(template,2), size(template,1)];
xOffset = corrOffset(2);

% Shows how well the correlation worked by overlaying the image template in
% green over the processed frame.
figure(2)
imshow(originalFrame(max([1 position(2)]):min([size(frame,1) position(2)+position(4)-1]), max([1 position(1)]):min([size(frame,2) position(1)+position(3)-1]),:), 'InitialMag', 'fit')
g = imgcf;
set(g,'name','Template Correlation Verification')
% Makes an all green image, then by using 'AlphaData', only shows green
% pixels where the template was black (since the template was binary).
green = cat(3, zeros(size(template)), ones(size(template)), zeros(size(template)));
hold on
h = imshow(green);
hold off
set(h, 'AlphaData', imcomplement(template))
title(regexprep(cellVideo.Name,'_',' '))

%% Line template generation
% Preallocates an array for storing the template
lineTemplate = uint8(zeros(size(frame)));

% The variable 'firstLinePos' stores the y-value in pixels of the top line,
% default value = 22 pixels for 5, 7, and 9 micron templates, and 19 pixels 
% for the 3 micron template. 'secondLinePos' stores the y-value of the second
% line (the line that should on the first constriction and where the tracking starts). 
% The position(2) offset is due to the different size of the template and frame.  
% The variable 'spacing' gives the spacing between constrictions, default 
% value = 32 pixels for 5, 7, and 9 micron templates, and 28 for the 3 micron template.  
if templateSize == 3
    %constrict = 47 + position(2);
    firstLinePos = 21 + position(2);
    secondLinePos = 47 + position(2);
    spacing = 28;
else
    %constrict = 46 + position(2);
    firstLinePos = 33 + position(2);
    secondLinePos = 46 + position(2);
    spacing = 32;
end

% Resizes the mask to be the same size as the frame, but shifted
% appropriately
mask = false(size(frame));
mask(position(2)+1:size(loadedMask,1)+position(2), position(1)+1:size(loadedMask,2)+position(1)) = loadedMask; 

% Verifies the mask and frame are the same size
% If mask is too large it is cropped down to size of frame
if size(mask,1) ~= size(frame,1) || size(mask,2) ~= size(frame,2)
    mask = mask (max(1,abs(size(mask,1)-size(frame,1))+1):size(mask,1),max(1,abs(size(mask,2)-size(frame,2))+1):size(mask,2));
end

% This loop writes the horizontal lines defining each constriction to the
% template
for i = 1:8
    if(i ~= 1)
        lineTemplate(floor(secondLinePos+(i-2)*spacing),:) = uint8(ones(1,size(frame,2)));
    else
        lineTemplate(floor(firstLinePos),:) = uint8(ones(1,size(frame,2)));
    end
end

%% Check: Displays the template overlaid on the background image 
% Stores the value of every white point (line on template) in a vector
[Xcoords, Ycoords]= find(lineTemplate);

% Draws the lines in the template on the originalFrame, shows the figure
for counter=1:length(Xcoords)
    originalFrame(Xcoords(counter),Ycoords(counter),1:3)= ones(1,3)*255;
end

figure(3);
imshow(originalFrame);
h = imgcf;
set(h,'name','Line Template Verification')
title(regexprep(cellVideo.Name,'_',' '))
