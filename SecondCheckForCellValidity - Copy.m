%% Invoking 'SecondCheckForCellValidity' function to identify only
%% legitimate cells in subsequent frames after starting frame (image) has
%% been determined.


function  [bw_frameno2, counter] = SecondCheckForCellValidity(bw_frameno, nolabes, tempmask, counter)

[m, n]=size(bw_frameno);

bw_frameno2=zeros([m n]);

% Here a legitimate cell is a cell which touches at least 1 of the eight
% grid lines in the template image. If this condition is not satisfied
% that given cell is set to zero or in other words eliminated from the image.

for i=1:nolabes
    % Pull out cells labelled 1 2 3 etc....
    idx = ismember(bw_frameno, i);
    for j = 1:1:8
        % Pull line 1 to 8 sequentially
        idx1 = ismember(tempmask,j);
        % Find their intersection
        idx2 =(idx1.*idx);
        
        if sum(sum(idx2)) > 0 %% If there is an intersection
            bw_frameno2 = bw_frameno2+idx; %% Images with only legitimate cells are sent back to main code.
            counter = counter + 1;
            break;
        end
    end
end







