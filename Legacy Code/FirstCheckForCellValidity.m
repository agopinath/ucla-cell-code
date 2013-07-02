%% Invoking 'FirstCheckForCellValidity' function to identify the first
%% legitimate image to start the cell tracking

function  [bw_framenonew, nolabesnew] = FirstCheckForCellValidity(bw_frameno, nolabes, tempmask, temlab)

%% here, we classify an image as a legitimate starting image, if at least
%% one of its cell is at grid line 1. All other cells in that image will be
%% set to zero (i.e., eliminated) to avoid inaccurate tracking of cells
bw_frameno2=im2bw(bw_frameno);
for i=1:nolabes
    idx = ismember(bw_frameno, i) %% Pulling out cell labelled 1 2 3 etc...
     for j=1        
        idx1 = ismember (tempmask,j) %% Pulling out line 
        idx2=(idx1.*idx) %% Looking at the intersection
       if idx2==0 %% if no intersection                    
            bw_frameno2=(bw_frameno2)-im2bw(idx);  %% then set those cell labels to zero
        end
       
    end
  
end

%% Specifications of the legitimate starting image (i.e., its corresponding labeled image) is given to main
%% function

if bw_frameno2~=0 %% if the image is not blank
[bw_framenonew, nolabesnew]=bwlabel(bw_frameno2); %%  save the labelled image and total number of labels %% all cells that intersect with line 1
else bw_framenonew=bw_frameno2; %% if the image is blank, save the  labelled image
    nolabesnew=0; %% set the total number of labels to zero
end








