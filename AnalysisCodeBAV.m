%%% Bino Abel Varghese
%%% Code to track cells
%%% First part of the code
%%% Output variable 'diff_int' is the final variable.

function [diffint] = AnalysisCodeBAV(folder_name, video_name, no_of_images, seg_number, frame_rate)

% Temporary to run as a script, not a function
% folder_name = 'C:\Users\agopinath\Desktop\CellVideos\';
% video_name = 'device01_20X_800fps_0.6ms_6psi_p4_15.avi';
% no_of_images = 1500;
% seg_number = 1;
% frame_rate = 400;
counter = 1;

% clear all;
close all;
clc;

%% ------------------------------- Header Strip ------------------------%%
% template_name = 'F:\Pilot Study UHouston Cells\12-7-11\cell line 2 Hey A8 130b p3\7 micron\dev2\Video_11\FinalTemplateNorm3.tif';
% folder_loc = 'F:\Pilot Study UHouston Cells\12-7-11\cell line 2 Hey A8 130b p3\7 micron\dev2\Video_11\';
% no_of_images = 3000;
% frame_rate = 300;

% Loads the template file from the folder where the first video was
template = imread([folder_name, video_name, '_', num2str(seg_number), '\', 'FinalTemplate.tif']);

%% Labels each grid line in the template from 1-8 starting at the top
[tempmask, temlab] = bwlabel(template); 
clear template;

% This loop begins at the first frame and finds the first frame that is not
% empty
for id=1:no_of_images
    img = imread([folder_name, video_name, '_', num2str(seg_number), '\','BWstill_', num2str(no_of_images*(seg_number-1)+id),'.tif']);
    % If image matrix is not empty then
    if isempty(img) == 0
        % Count number of cells in the frame and label them (nolabes gives
        % the number of cells found in that frame)
        [bw_frameno, nolabes] = bwlabel(img);
        
        % Converts the frame to a black and white logical frame (every
        % pixel is either 1 or zero)
        bw_frameno2 = im2bw(bw_frameno);
        
        % For each cell found in the frame, check if it intersects with the
        % first (top) constriction line
        for i = 1:nolabes
            % If the cell does not intersect the top template line, then
            % set the cell labels to zero for that cell
            if (ismember(tempmask,1).*ismember(bw_frameno,i)) == 0 
                bw_frameno2 = (bw_frameno2)-ismember(bw_frameno,i) == 0;  
            else
                % Counts the number of legitimate cells in the first image
                % counter = counter + 1;
            end  
        end
        
        % Finds and stores the specifications of the first legitimate 
        % starting frame.  Legitimate = non-blank and with at least one
        % cell touching the top template line.
        
        % If the image is not blank save the labelled image and total 
        % number of labels for cells intersecting line 1
        if bw_frameno2 ~= 0 
            [bw_framenonew, nolabesnew] = bwlabel(bw_frameno2); 
        % If the image is blank, save the  labelled image and set the total 
        % number of labels to zero
        else
            bw_framenonew = bw_frameno2; 
            nolabesnew = 0; 
        end
        
        % These lines of code record the starting legitimate image and start
        % numbering cells which need to be tracked in this image
        
        % if the image is not blank, save the following:
        %   'id', the image number
        %   'bw_framenonew', the image with labeled cells
        %   'nolabesnew', the label numbers of the cells
        if sum(sum(bw_framenonew)) > 0 
            start_image_ind = id; 
            start_image = bw_framenonew; 
            start_label = nolabesnew; 
            break;
        end
    end
end

% Initializes a new array 'image_3d' to store all subsequent legitimate 
% frames.  Legitimate frames are stored, and non-legitimate frames are zero
image_3d(:,:,start_image_ind) = im2bw(bw_framenonew); 

%% These lines of code select "legitimate cells" within each image, and 
% stores their label numbers and their centroid locations (x-coordinate and
% y-coordinate).  Runs from the first frame after the legitimate frame
% above until the last image
for id = start_image_ind+1:no_of_images
    img = imread([folder_name, video_name, '_', num2str(seg_number), '\','BWstill_', num2str(no_of_images*(seg_number-1)+id),'.tif']);
    % If there is at least one cell in the frame
    if isempty(img) == 0;
        % Label cells in the image
        [blabs, labs] = bwlabel(img);
        % The function 'SecondCheckForCellValidity' eliminates cells
        % which do not intersect with any of the grid lines in the
        % template image.
        [bw_frameno2, counter] = SecondCheckForCellValidity(blabs, labs, tempmask, counter);
        % Stores the frame with only legitimate cells in the image_3d array
        image_3d(:,:,id) = bw_frameno2;   
    % If no cells are detected in the frame, store the frame as is
    else
        image_3d(:,:,id) = img; 
    end    
end

% The matrix 'mat_label' is an important matrix that stores information 
% about each legitimate cell.  The columns are: 
%   1) Image number 
%   2) cell label number 
%   3) Centroid X Coordinate 
%   4) Centroid Y Coordinate
%   5) Grid line that the cell intersects
% mat_label = 0;
mat_label = zeros(counter, 5);

% once again label the cells of the starting legitimate image
[blabs_start, labs_start] = bwlabel(image_3d(:,:,start_image_ind));

% compute centroid of each cell in the starting image
s = regionprops(blabs_start, 'centroid');
centroids = cat(1, s.Centroid);
id = start_image_ind;

% Recording each cell in the legitimate image in variable mat_label
for idd=1:labs_start
    mat_label(idd,1) = id; % cell's corresponding image number
    mat_label(idd,2) = idd; % cell's label number
    mat_label(idd,3) = centroids(idd,1);  % x-cordinate of its centroid
    mat_label(idd,4) = centroids(idd,2);% y-cordinate of its centroid
    
    % This function 'call_inter' is evoked to record the grid line with
    % which the given cell intersects
    map_ints = call_inter(blabs_start,idd, tempmask, temlab);
    mat_label(idd,5) = map_ints; % recording the intersecting grid line
end

% Recording each cell in the subsequent images in variable mat_label
for id = start_image_ind+1:no_of_images
    if isempty(image_3d(:,:,id)) == 0;
        % label the cells of the subsequent images
        [blabs, labs] = bwlabel(image_3d(:,:,id));
        % compute centroid of each cell in the subsequent image
        s = regionprops(blabs, 'centroid');
        centroids = cat(1, s.Centroid);
        
        % Note: we increment the label number of cells in corresponding
        % images depending on the last cell's label number in the previous
        % image
        labsnew = labs+labs_start;
        
        for idd=1:labs
            mat_label(idd+labs_start,1) = id; % cell's corresponding image number
            mat_label(idd+labs_start,2) = idd+labs_start;  % cell's label number
            mat_label(idd+labs_start,3) = centroids(idd,1); % x-cordinate of its centroid
            mat_label(idd+labs_start,4) = centroids(idd,2); % y-cordinate of its centroid
            
            % This function 'call_inter' is evoked to record the grid line with
            % which the given cell intersects
            map_ints = call_inter(blabs,idd, tempmask, temlab);
            mat_label(idd+labs_start,5)= map_ints;       % recording the intersecting grid line
        end
        
        % updating variable labs_start  before cells in the following image
        % are counted
        labs_start = labsnew;
    end
end

%% The other code has been merged here onwards!!!!
s = round(mat_label);
% variable mat_pair will contain pairs of labels corresponding to a given
% cell tracked in images

% example of the matrix mat_pair: [1 7; 7 10; 10 13; 13 16];
% as you can see here label 1 is tracked by label 7, label 7 is tracked by
% label 10, label 10 is tracked by label 13 and so forth.
mat_pair = zeros(1,length(s(:,2)));

% Creates cell pairs
for k = 1:length(s(:,2))
    count = 1;
    for k1 = (k+1):length(s(:,2))
        % The criteria to create cell pairs are as follows:
        %   -Pairs of cells must lie in different images, 
        %   -The centroid of the cells must be vary by than 4 pixels in the 
        %       x-direction.
        %   Note: the cell with label number S can only be paired with cell 
        %       which has a higher label number (> S).
        if (s(k1,5) == (s(k,5)+1)) && (abs(s(k,3)-s(k1,3))<4) && (s(k,1)<s(k1,1));
            % If a pair is found for a given label number S, then break 
            mat_pair(k) = k1;
            break;
        end
    end
end

%% Here, we use variable 'mat_pair' to create a matrix 'make_list' which
% connects all continous pair of cells and puts them in one row
% for example: pairs [7 10], [10 14], [14 17], [17 20] will be sorted from
% mat_pair to form a row = [7 10 14 17 20]

make_list = 0;

% computing matrix 'make_list' below
for i = 1:length(mat_pair)
    make_list(i,1) = i;
    c = mat_pair(i);
    % the number of connections cannot exceed more than 8 (as there are 8
    % grid lines in the template image)
    for count = 2:8
        if c > 0
            make_list(i,count) = c;
            c = mat_pair(c);
        else
            break;
        end
    end
end

%% These lines of code will eliminate redundant connections in matrix
% 'make_list'
% example if make_list = [first row: 7 10 14 17 20
%                         second row: 14 17 20     ]
% then following codes should eliminate second row in make_list

make_list1 = make_list; % make_list1 is a copy of make_list
for i = 1:size(make_list,1)
    for j = 1:size(make_list,1)
        if make_list(i,1) < make_list(j,1)
            if (size(make_list,2) > 7)         % prevent accessing unaccessable space when there are no cells
                c(1:7) = make_list(i,2:8);
                d(1:7) = make_list(j,2:8);
            else
                c(1:7) = 0;
                d(1:7) = 0;
            end
            if c == d
                make_list(j,:) = 0; % set repeptitive row equals to zero
            end
        end
    end
end

%% variable make_list3 will contain only unique rows in make_list
% function unique will help eliminate rows with zero values

make_list3 = unique(make_list,'rows');

% %variable make_list4 is the processed variable from

if (size(make_list3,1) > 1)
    if sum(make_list3(1,:)) > 0 && (size(make_list3,1) > 1)
        make_list4 = make_list3;
    else
        make_list4 = make_list3(2:length(make_list3),:);
    end
else
    diffint = [];
    return
end

make_list5 = make_list4;
% % eliminating any repeated cell numbers and maintaining only refined connections
for i = 1:size(make_list4,1)
    for j = 1:size(make_list4,2)
        c = make_list4(i,j);
        [x1, y1] = find(make_list4(:,:) == c);
        [x2, ico] = sort(x1);
        y2 = y1(ico);
        if length(x2) > 1
            for i2 = 2:length(x2)
                make_list5(x2(i2),y2(i2)) = 0;
            end
        end
    end
end

% % refining connections further to obtain make_list7 which has the final connections
make_list6 = unique(make_list5,'rows');

if sum(make_list6(1,:)) > 0 && (size(make_list6,1) > 1)
    make_list7 = make_list6;
else
    make_list7 = make_list6(2:size(make_list6,1),:);
end

% % Here, we compute the image numbers corresponding to tracked cells in a
% % given row to obtain matrix list
list = 0;
for i = 1:size(make_list7,1)
    for j = 1:size(make_list7,2)
        c = make_list7(i,j);
        if c > 0
            list(i,j) = mat_label(c,1);
        end
    end
end

% % Refining matrix list to form list1
list1 = 0;
count = 1;
for i = 1:size(list,1)
    if list(i,8) ~= 0
        list1(count,1:8) = list(i,1:8);
        count = count+1;
    end
end
%
% % This is the final variable you need
diffint = 0;
% % the variable 'diffint' will store the transit time of a cell as it
% % passes consecutive grid lines.
% % the last column of diffint will contain the total transit time as the
% % cell hits the first grid line and leaves the image after exceeding the
% % last grid line
for i = 1:size(list1,1)
    for j = 1:size(list1,2)-1
        diffint(i,j) = ((abs(list1(i,j+1)-list1(i,j)))/frame_rate)*100;
    end
    diffint(i,8) = ((abs(list1(i,1)-list1(i,8)))/frame_rate)*100;
end

save ([folder_name, video_name, '_', num2str(seg_number), 'data_', video_name, '_seg', num2str(seg_number)], 'diffint')


