
%% In this function, the grid line with which a legitimate cell intersects
%% is computed and given back to the main code.
function  [mat_app] = call_inter(bw_frameno, nolabes, tempmask, temlab)


[m n]=size(bw_frameno);
bw_frameno2=zeros([m n]);
mat_app=0;
idx = ismember(bw_frameno, nolabes); %% image dataset of all the legitimate cells

%% a legitimate cell must intersect at least 1 of the 8 grid lines in the
%% template image
for j=1:1:8
    idx1 = ismember (tempmask,j); %% pull out the labels of lines 1 to 8 sequentially
    idx2=(idx1.*idx); %% Find their intersection
    if sum(sum(idx2))>0 %% if there is an intersection
%% if intersection of the legitimate cell with one of the grid lines is
%% found (counter starts from grid line 1 to 8), then we can check for the
%% next labelled cell.
        mat_app=j; %% the grid line intersecting with a given cell is send to the main code
        break;    
        
    end    
    
end











