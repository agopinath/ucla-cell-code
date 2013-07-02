%% Data Compilation file; runs sequential segmentations and analyses; objective is minimal user input
clear
clc

% Header to test different files, commented when running actual code.
% folder_name = 'D:\120220 hl60\MOCK 5um 4psi 600fps';
% video_names = ['MOCK 5um 4psi 600fps Dev1-41'];
% frame_rate = 600;           % frames per second

name_length = [32, 32, 32, 32, 32, 32, 32, 32];
path_length = 28*ones(1,8);

video_names(1,1:name_length(1)) = ['hl60 d0 10psi 5um 600fps Dev1-67'];
video_names(2,1:name_length(2)) = ['hl60 d0 10psi 5um 600fps Dev1-68'];
video_names(3,1:name_length(3)) = ['hl60 d0 10psi 5um 600fps Dev1-69'];
video_names(4,1:name_length(4)) = ['hl60 d0 10psi 5um 600fps Dev1-70'];
video_names(5,1:name_length(5)) = ['HL60 wt 10psi 5um 600fps Dev2-08'];
video_names(6,1:name_length(6)) = ['HL60 wt 10psi 5um 600fps Dev2-09'];
video_names(7,1:name_length(7)) = ['HL60 wt 10psi 5um 600fps Dev2-10'];
video_names(8,1:name_length(8)) = ['HL60 wt 10psi 5um 600fps Dev2-11'];

path_names(1,1:path_length(1)) = ['D:\Data Verification Folder\'];
path_names(2,1:path_length(1)) = ['D:\Data Verification Folder\'];
path_names(3,1:path_length(1)) = ['D:\Data Verification Folder\'];
path_names(4,1:path_length(1)) = ['D:\Data Verification Folder\'];
path_names(5,1:path_length(1)) = ['D:\Data Verification Folder\'];
path_names(6,1:path_length(1)) = ['D:\Data Verification Folder\'];
path_names(7,1:path_length(1)) = ['D:\Data Verification Folder\'];
path_names(8,1:path_length(1)) = ['D:\Data Verification Folder\'];

filename = 1; i = 1; no_of_seg = 1; filePath = 'C:\';   %initializations

% while (filename ~= 0)
%     [filename, filePath] = uigetfile('.avi', 'Please select the next video file, if done select cancel.', filePath);
%     if (filename ~= 0)
%         name_length(i) = length(filename);
%         path_length(i) = length(filePath);
%         video_names(i,1:name_length(i)) = filename;
%         path_names(i,1:path_length(i)) = filePath;
%         [frame_rate(i)] = input (['Please enter the frame rate for video ', filename, ':']);
%         i = i+1;
%     end
% end
% tStart = tic;
% for i = 1:size(video_names,1)
%     temp_mov = VideoReader([path_names(i,1:path_length(i)), video_names(i,1:name_length(i))]);
    break_size = [3192 3192 2679 3192 3000 3000 3000 3000]; 
    frame_rate = 600*ones(8,1);
% end
% position = [14     19    529    285];

if (exist([path_names(1,1:path_length(1)), 'compiled_data\data_comp.mat']) == 2)   % place data in folder of first video
    load ([path_names(1,1:path_length(1)), 'compiled_data\data_comp.mat'])
end

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
data_comp_ = zeros(1,8);
for i = 1:size(video_names,1)
    for j = 1:no_of_seg
%          Portion_segment(video_names(i,1:name_length(i)), path_names(i,1:path_length(i)), max([50 (j-1)*break_size(i)])+1, j*break_size(i), position(i,:), j);
         [data_] = AnalysisCodeBAV_temp(path_names(i,1:path_length(i)), video_names(i,1:name_length(i)), break_size(i), j, frame_rate(i));
         if (isempty(data_) ~= 1)
             if (data_comp_(1,1:8) == zeros(1,8))
                 data_comp_ = data_;
             else
             data_comp_(end+1:end+size(data_,1),1:8) = data_;
             end
             
             [n,xout] = hist(data_comp_(:,8), 100);
             % plot histogram of compiled data
                           
             d = {'Constriction 1', 'Constriction 2', 'Constriction 3', 'Constriction 4', 'Constriction 5', 'Constriction 6', 'Constriction 7', 'Total'}; {num2str(data_comp_)};
             xlswrite ([path_names(1,1:path_length(1)), 'compiled_data\data_xlscomp'], data_comp_)
             save ([path_names(1,1:path_length(1)), 'compiled_data\data_comp'],'data_comp_', 'frame_rate')
             
         end
         
    end    
end

total_time = toc(tStart)
average_time = total_time/size(video_names,1)/temp_mov.NumberOfFrames