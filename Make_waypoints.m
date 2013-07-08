%% Image Template Maker (Modified as of 10/05/2011) by Bino Abel Varghese
% Latest update by David Hoelzle (2013/01/07)

function [ImageTemplate] = Make_waypoints(videoName, folderName)

% The aim of the code is to write a TEMPLATE file that marks the contriction locations.

%% Clearing variables
% clear all;
close all;
% clc;

%% ------------------------- Header Strip -------------------------------%
% used in troubleshooting code, this is a legacy in streamlined code, but
% it is still valuable to have in case of code redesign
% folder_name = 'D:\120220 hl60\MOCK 5um 4psi 600fps';
% video_name = ['MOCK 5um 4psi 600fps Dev1-41'];
% video_num = 1;
% no_of_breaks = 1;

%% Main Body

% Specify region of interest
% Reads in the specified movie
temp_mov = VideoReader([folderName, videoName]);

% Shows the first frame, and asks for a cropping rectangle to be drawn
% figure (1)
% imshow(read(temp_mov,1))
% text (150,100, ['File:', videoName], 'EdgeColor', [0 0 0], 'BackgroundColor', [1 1 1])
% text (150,150, 'Draw and Drag Cropping Rectangle then Double-Click Inside', 'EdgeColor', [0 0 0], 'BackgroundColor', [1 1 1])

% Allows the user to draw a rectangle and waits until they double click
% inside it.  Then it stores in position [Xmin, Ymin, width, height]
% h = imrect;
% position = uint16(wait(h));
    
% Crops the image to the specified rectangle.  The min/max ensure the
% indicies of the matrix are nonnegative
A = read(temp_mov,1); 
A = A(:,:,:);

% Preallocates an array for storing the template
ImageTemplate = zeros(size(A,1), size(A,2));

% Shows the cropped frame, and asks the user to specify the constriction
% region
fig1 = figure (1)
imshow(A)
text (150,150, 'Specify Constriction Region then Double-Click Inside', 'EdgeColor', [0 0 0], 'BackgroundColor', [1 1 1])

% Used to show a rectangle, has been updated to show a polygon that better
% shows the constriction region features.
% h = imrect(gca, [10 45 524 224]);
% setResizable(h,false);
% constrict = uint16(wait(h));

% Overlays a dragable region on the screen to align with the constrictions
% on the device.  Stores the position vector [Xmin, Ymin, width, height]
% after the user double clicks.
h = impoly(gca, [10,49; 10,81; 534,81; 534,113; 10,113; 10,145; 534,145; 534,177; 10,177; 10,209; 534,209; 534,241; 10,241; 10,273; 534,273; 534,49; 10,49; 10,273]);
setVerticesDraggable(h,false);
setColor(h,'yellow')
pos = uint16(wait(h));
constrict = [pos(1,1), pos(1,2), pos(3,1)-pos(1,1), pos(13,2)-pos(17,2)];
clear pos;

% Calculates the spacing (fixed due to the new constriction region, default
% value = 32 pixels)
spacing = constrict(4)/6;       

% This loop writes the horizontal lines defining each constriction to the
% template
for i = 1:8                      
    ImageTemplate(floor(constrict(2)+(i-1)*spacing),:) = ones(1,size(A,2));
end

%% Checking: Displays the template overlaid on the background image
% Stores the value of every white point (line on template) in a vector
[Xcoords,Ycoords]= find(ImageTemplate);

% Draws the lines in the template on the cropped frame (A), then shows the
% figure
for counter=1:length(Xcoords)
    A(Xcoords(counter),Ycoords(counter),1:3)= ones(1,3)*255;
end
figure(11);
imshow(A);

delete(fig1);
%imwrite(ImageTemplate, [folderName, videoName, '_', num2str(videoNum), '\', 'FinalTemplate.tif']);%% Change filename .tif

