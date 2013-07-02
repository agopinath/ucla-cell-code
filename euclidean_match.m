
function [scramble_matrix, unmatched] = euclidean_match(projection, new_centers, euc_thresh);

%% Prototyping region
% clear
% projection = [50 100; 50 150; 300 50; 200 75];
% new_centers = [52 102; 300 56; 300 52; 52 157; 201 74];
% euc_thresh = 7;

%% Code body

% scramble_matrix = zeros(size(projection,1),1);      % initialize as no matches
avail_cells = 1:size(new_centers,1);
scramble_matrix = [];

for i = 1:size(projection,1)
    
    j = 1;        
    while(j <= size(new_centers,1) & avail_cells(j) ~= 0)
        euc_dist(i,j) = norm([projection(i,1)-new_centers(j,1), projection(i,2)-new_centers(j,2)],2);     % calculate euclidean distances
        j = j+1;
    end
    
%     if (min(euc_dist(i,:)) < euc_thresh)        % ensure threshold is met
%         scamble_matrix(i) = find(euc_dist(i,:) == min(euc_dist(i,:)), 1, 'first');
    if (isempty(find(euc_dist(i,:) == min(euc_dist(i,:)) & euc_dist(i,:) < euc_thresh, 1, 'first')) ~= 1)
        scramble_matrix(i) = find(euc_dist(i,:) == min(euc_dist(i,:)) & euc_dist(i,:) < euc_thresh, 1, 'first');
    end
%     end
        
end

if isempty(scramble_matrix) ~= 1
    unmatched = sort(find(scramble_matrix == 0));
else
    unmatched = avail_cells;
end