%% Data Compilation file; runs sequential segmentations and analyses; objective is minimal user input
clear
clc

addpath('C:\Users\agopinath\Documents\ucla-cell-code\lib'); % Add any relevant libraries to the path

% Header to test different files, commented when running actual code.
% folder_name = 'D:\120220 hl60\MOCK 5um 4psi 600fps';
% video_names = ['MOCK 5um 4psi 600fps Dev1-41'];
% frame_rate = 600;           % frames per second

numFilesSelected = 1; no_of_seg = 1; filePath = 'C:\Users\agopinath\Documents', count = 1, lastCount = 1;   %initializations

while (numFilesSelected > 0) % while at least one file is selected, continue prompting
    files = uipickfiles('FilterSpec', '*.avi'); % prompt user to select files, filtering by file type
    numFilesSelected = size(files, 2); % number of files the user selects (can be 0, 1, or >1)
    if (numFilesSelected > 0) % if the user selects at least one file
        for i = 1:numFilesSelected
            [pathname, filename, ext] = fileparts(files{i}); % split up the full file name into its respective path, filename, and file extension

            video_names{lastCount+i-1} = [filename, ext]; % concatenate filename with its respective file extension and store it
            path_names{lastCount+i-1} = [pathname, '\']; % concatenate pathname with a trailing backslash and store it
        end
        count = lastCount+i-1;
        
        % Inform the user of which files were selected - this is just for convenience
        fprintf('============ SELECTED ==============\n');
        for j = lastCount:count
            fprintf('Selected: %s.\n', [path_names{j}, video_names{j}]);
        end
        fprintf('====================================\n');
        
        % Prompts user for a common frame rate to assign to the selected video(s), and store them in frame_rate
        frate = input (['Please enter the common frame rate for the selected video(s): ']); %prompt for frame rate
        for k = lastCount:count
            [frame_rate(k)] = frate; %store inputted number value for frame rate
        end
        lastCount = count+1;
    end
end

% After user has selected all the videos he/she wants processed, display their names before continuing ahead
fprintf('\n========= TO BE PROCESSED =========\n');
for i = 1:size(video_names, 2)
    fprintf('Videos: %s.\n', [path_names{i}, video_names{i}, ' at', ' ', num2str(frame_rate(i)), ' FPS']);
end
fprintf('===================================\n');

% tStart = tic;
% for i = 1:size(video_names,1)
%     temp_mov = VideoReader([path_names(i,1:path_length(i)), video_names(i,1:name_length(i))]);
%     break_size(i) = floor(temp_mov.NumberOfFrames/no_of_seg); 
% end
% position = [14     19    529    285];
% 
% if (exist([path_names(1,1:path_length(1)), 'compiled_data\data_comp.mat']) == 2)   % place data in folder of first video
%     load ([path_names(1,1:path_length(1)), 'compiled_data\data_comp.mat'])
% end
% 
% for i = 1:size(video_names,1)
%     mkdir (path_names(i,1:path_length(i)), ['compiled_data\'])
%     for j = 1:no_of_seg
%         % make folders
%         mkdir (path_names(i,1:path_length(i)), [video_names(i,1:name_length(i)), '_', num2str(j)])
%         [msg msgid] = lastwarn;
% %         warning ('off', msgid);
%     end
%     % construct template
%     [position(i,:)] = Make_waypoints(video_names(i,1:name_length(i)), path_names(i,1:path_length(i)), i, no_of_seg);
%     
%     % Process first 50 frames of each to assess segmenation quality
%     Portion_segment(video_names(i,1:name_length(i)), path_names(i,1:path_length(i)), 1, 50, position(i,:), 1);
%     
% end
% data_comp_ = zeros(1,8);
% for i = 1:size(video_names,1)
%     for j = 1:no_of_seg
%          Portion_segment(video_names(i,1:name_length(i)), path_names(i,1:path_length(i)), max([50 (j-1)*break_size(i)])+1, j*break_size(i), position(i,:), j);
%          [data_] = AnalysisCodeBAV(path_names(i,1:path_length(i)), video_names(i,1:name_length(i)), break_size(i), j, frame_rate(i));
%          if (isempty(data_) ~= 1)
%              if (data_comp_(1,1:8) == zeros(1,8))
%                  data_comp_ = data_;
%              else
%              data_comp_(end+1:end+size(data_,1),1:8) = data_;
%              end
%              
%              [n,xout] = hist(data_comp_(:,8), 100);
%              % plot histogram of compiled data
%                            
%              d = {'Constriction 1', 'Constriction 2', 'Constriction 3', 'Constriction 4', 'Constriction 5', 'Constriction 6', 'Constriction 7', 'Total'}; {num2str(data_comp_)};
%              xlswrite ([path_names(1,1:path_length(1)), 'compiled_data\data_xlscomp'], data_comp_)
%              save ([path_names(1,1:path_length(1)), 'compiled_data\data_comp'],'data_comp_', 'frame_rate')
%              
%          end
%          
%     end    
% end
% 
% total_time = toc(tStart)
% average_time = total_time/size(video_names,1)/temp_mov.NumberOfFrames
