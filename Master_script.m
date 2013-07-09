%% Data Compilation file; runs sequential segmentations and analyses; objective is minimal user input
% Updated 6/25/2013 by Mike
%       -Cut out the preprocessing 50 frames (required editing indicies of
%       the call for Portion_segment
%       - Rearranged and commented the code to make it clearer
clear
clc

% Header to test different files, commented when running actual code.
% folder_name = 'D:\120220 hl60\MOCK 5um 4psi 600fps';
% videos = ['MOCK 5um 4psi 600fps Dev1-41'];
% frame_rate = 600;           % frames per second

% Initializations
% make sure to delimit path and video names below by semicolons, NOT commas
paths = {'G:\CellVideos\'};
videos = {'device01_20X_800fps_0.6ms_6psi_p4_15_3.avi'}; 
            %'Dev3x10_20x_200fps_4,8ms_72_1.avi';
            %'device01_20X_800fps_0.6ms_6psi_p4_15_3.avi';
            %'dev9x10_20X_1200fps_0.6ms_2psi_p9_324_1.avi'; 
            %'unconstricted_test_800.avi';
            %'unconstricted_test_1200.avi';

for i = 1: length(videos)
    cellVideos(i) = VideoReader([paths{i}, videos{i}]);
end

% % Opens a GUI to select videos, user can select a single file at a time and
% % ends selection by clicking 'cancel'
% while (filename ~= 0)
%     [filename, filePath] = uigetfile('.avi', 'Please select the next video file, if done select cancel.', filePath);
%     if (filename ~= 0)
%         videos{i} = filename;
%         paths{i} = filePath;
%         [frame_rate(i)] = input (['Please enter the frame rate for video ', filename, ':']);
%         i = i+1;
%     end
% end

startTime = tic;
% % Calculates the length of each segment.  If no_of_seg = 0, then break_size
% % is the length of each video
% for i = 1:size(videos,1)
%     temp_mov = VideoReader([paths{i}, videos{i}]);
%     break_size(i) = floor(temp_mov.NumberOfFrames/no_of_seg); 
% end

% % Places the data in the folder of the first video slected.  If the data
% % file already exists, the data is loaded.
% if (exist([paths{i}, 'compiled_data\data_comp.mat']) == 2)   
%     load ([paths{i}, 'compiled_data\data_comp.mat'])
% end
% 
% % Creates a directory for each video, followed by another set of folders
% % inside these for each segment of the video
% for i = 1:size(videos,1)
%     mkdir (paths{i}, ['compiled_data\'])
%     for j = 1:no_of_seg
%         % make folders
%         mkdir (paths{i}, [videos{i}, '_', num2str(j)])
%         [msg, msgid] = lastwarn;
% %         warning ('off', msgid);
%     end
%     
%     % Calls the Make_waypoints function to define the constriction region.
%     % This function draws a template with a line across each constriction;
%     % these lines are used in calculating the transit time
%     %[position(i,:)] = Make_waypoints(videos{i}, paths{i}, i, no_of_seg);
%     
%     % This preprocessing of the first 50 frames was cut out, and was seen
%     % as unnecessary.  Other minor edits were required to keep the same
%     % functionality: the indicies of the call for portion_segment have
%     % changed to include the first video.
% %     % Process first 50 frames of each to assess segmenation quality
% %     Portion_segment(videos{i}, paths{i}, 1, 50, position(i,:), 1);
%     
% end

% data_comp_ = zeros(1,8);
for i = 1:length(cellVideos)
%     for j = 1:no_of_seg
%        Portion_segment(videos{i}, paths{i}, max([50 (j-1)*break_size(i)])+1, j*break_size(i), position(i,:), j);
         currVideo = cellVideos(i);
         startFrame = 1;
         endFrame = currVideo.NumberOfFrames;
         Portion_segment(currVideo, paths{i}, videos{i}, startFrame, endFrame);
%          [data_] = AnalysisCodeBAV(paths{i}, videos{i}, break_size(i), j, frame_rate(i));
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
%              xlswrite ([paths{1}, 'compiled_data\data_xlscomp'], data_comp_)
%              save ([paths{1}, 'compiled_data\data_comp'],'data_comp_', 'frame_rate')
%              
%          end
         
%     end    
end

totalTime = toc(startTime);
disp(sprintf('\n\n======'));
disp(['Total time to analyze ', num2str(length(videos)), ' video(s): ', num2str(totalTime), ' secs']);
disp(['Average time per video: ', num2str(totalTime/length(videos)), ' secs']);