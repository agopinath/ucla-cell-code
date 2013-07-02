% Code to catalog cell positions, areas, and eccentricities



%% Prototyping region, comment out when running as a function
clear
folder_name = 'C:\Users\dhoelzle\Documents\Research\Post-Doc Research\Cell Deformer Studies\Processing Code\Most Recent\';
video_name = 'MOCK 5um 4psi 600fps Dev1-41.avi';
no_of_images = 3000;
seg_number = 1;
frame_rate = 600;
vetting = 5;        % Requires three contiguous frames for a cell to be vetted
pixel_norm = 10;

%% Main Code
% Find template waypoints, this part can be deleted from process if we redo
% waypoint calculation.  No need to be an image, must a vector of y values
% of the waypoints
indexIntoResults = @(t, ind) t(ind);
template=imread([folder_name, video_name, '_', num2str(seg_number), '\', 'FinalTemplate.tif']);

j = 1;
for i = 1:size(template,1)
    if template(i,1) == 255
        waypoints(j) = i;
        j = j+1;
    end
end

% Establishes cell tracks
tracks = zeros(no_of_images,1,4);       % structure: length = length of video, width = number of cells, height = [centroid.x, centroid.y, area, eccentricity]
active_tracks = 0;
minor_league_tracks = zeros(vetting,30);       % 30 possible minor league tracks
active_m_tracks = 0;
j_it = 1;
projection = [];

% Main loop to extract cell data
for i = 1:15; %no_of_images
    
    [blabs labs] =  bwlabel(imread([folder_name, video_name, '_', num2str(seg_number), '\','BWstill_', num2str(no_of_images*(seg_number-1)+i),'.tif']));
    
    s                                       = regionprops(blabs, 'centroid', 'area','eccentricity');
    centroids                               = cat(1, s.Centroid);
    areas                                   = cat(1, s.Area);
    eccentricities                          = cat(1, s.Eccentricity);
    avail_cells = 1:length(areas);
    
    while j_it <= length(nonzeros(active_tracks))       % needs thought
          j = indexIntoResults(nonzeros(active_tracks), [j_int]);
%         j =  nonzeros(active_tracks)'*[zeros(j_it-1,1); 1; zeros(length(nonzeros(active_tracks))-j_it,1)];  % extract correct track
%         if active_tracks(j) ~= 0
            projection(j,2) = mean(diff(tracks(max([i-vetting,1]):max([i-1,1]), j,2))) + tracks(i,j,2);     % project in x direction
            projection(j,1) = mean(diff(tracks(max([i-vetting,1]):max([i-1,1]), j,1))) + tracks(i,j,1);    % project in y direction
            j_it = j_it + 1;    % increment
    end
    j_it = 1;       % reset j_int
            
    [scramble_matrix, unmatched] = euclidean_match(projection, centroids, pixel_norm);

    
%             for k = nonzeros(avail_cells)
%                 min_dist = find(norm(
            
            
%         end
%     end
    
    


    
    figure(1)
    imshow(label2rgb(blabs,'hsv','k'))
    pause(.1)
    
end