%% Image Template Maker (Modified as of 10/05/2011) by Bino Abel Varghese
% Latest update by David Hoelzle (2013/01/07)

function [position] = Make_waypoints(video_name, folder_name, video_num, no_of_breaks)

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
temp_mov = VideoReader([folder_name, video_name]);

figure (1)
imshow(read(temp_mov,1))
text (150,100, ['File:', video_name], 'EdgeColor', [0 0 0], 'BackgroundColor', [1 1 1])
text (150,150, 'Draw and Drag Cropping Rectangle then Double-Click Inside', 'EdgeColor', [0 0 0], 'BackgroundColor', [1 1 1])
h = imrect;
position = uint16(wait(h));
    
% Read the masked image
A =                                      read(temp_mov,1); %%%% 3% (normal)
A =                                      A(max([1 position(2)]):min([size(A,1) position(2)+position(4)]), max([1 position(1)]):min([size(A,2) position(1)+position(3)]),:);

ImageTemplate =                          zeros(size(A,1), size(A,2));

% Manually set extents of waypoints
figure (1)
imshow(A)
text (150,150, 'Specify Constriction Region then Double-Click Inside', 'EdgeColor', [0 0 0], 'BackgroundColor', [1 1 1])
h = imrect;
constrict = uint16(wait(h));

spacing = constrict(4)/6;       % decimel value spacing between constrictions

for i = 1:8                     % write waypoints
    
    ImageTemplate(floor(constrict(2)+(i-1)*spacing),:) = ones(1,size(A,2));
  
end

%%% Checking
[Xcoords,Ycoords]=                                                         find(ImageTemplate);
for counter=1:length(Xcoords)
    A(Xcoords(counter),Ycoords(counter),1:3)= ones(1,3)*255;%% 100
end
figure(11);
imshow(A);

for write_count = 1:no_of_breaks
imwrite(ImageTemplate, [folder_name, video_name, '_', num2str(write_count), '\', 'FinalTemplate.tif']);%% Change filename .tif
end

