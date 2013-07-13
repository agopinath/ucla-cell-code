%% Data Compilation file; runs sequential segmentations and analyses; objective is minimal user input
% Updated 6/25/2013 by Mike
%       -Cut out the preprocessing 50 frames (required editing indicies of
%       the call for Portion_segment
%       - Rearranged and commented the code to make it clearer
clear
clc

% if you want to process all videos in a set of folders, uncomment the
% following lines and specify the folders of the videos you want to process
% searchPaths = {'Y:\Kendra\Microfluidics\Raw Data\130618\Mock\7x10um\2psi\';
%                'Y:\Kendra\Microfluidics\Raw Data\130628\Mock\7x10\2psi\'};

if exist('searchPaths', 'var') == 0 
    % make sure to delimit path and video names below by semicolons, NOT commas
    paths = {'G:\CellVideos'};
    videos = {'dev9x10_20X_1200fps_0.6ms_2psi_p9_324_1.avi'};%; 'device01_20X_800fps_0.6ms_6psi_p4_15_2.avi';
          %'device01_20X_800fps_0.6ms_6psi_p4_15_3.avi'; 'Dev3x10_20x_200fps_4,8ms_72_1.avi';
          %'dev9x10_20X_1200fps_0.6ms_2psi_p9_324_1.avi'; 'dev9x10_20X_1200fps_0.6ms_2psi_p9_324_1.avi'}; 
            %'Dev3x10_20x_200fps_4,8ms_72_1.avi';
            %'device01_20X_800fps_0.6ms_6psi_p4_15_3.avi';
            %'dev9x10_20X_1200fps_0.6ms_2psi_p9_324_1.avi'; 
            %'unconstricted_test_800.avi';
            %'unconstricted_test_1200.avi'; 
    for i = 1:length(videos)
        if ~(exist(fullfile(paths{i}, videos{i}), 'file') == 2)
            disp(['Error: ', fullfile(paths{i}, videos{i}), ' doesnt exist']);
            return;
        end
   end
else
    idx = 0;
    for i = 1:length(searchPaths)
        pathToSearch = searchPaths{i};
        if ~(exist(fullfile(pathToSearch), 'file') == 7)
            disp(['Error: ', pathToSearch, ' doesnt exist']);
            return;
        end
        files = dir(fullfile(pathToSearch, '*.avi'));
        for j = 1:length(files)
            paths{j+idx} = pathToSearch;
            videos{j+idx} = files(j).name;
        end
        idx = idx + length(files);
    end
end

for i = 1: length(videos)
    cellVideos(i) = VideoReader(fullfile(paths{i}, videos{i}));
end

startTime = tic;

allUnconSizes = [];
for i = 1:length(cellVideos)
    currVideo = cellVideos(i);
    startFrame = 1;
    endFrame = currVideo.NumberOfFrames;
    disp(['==Video ', num2str(i), '==']);
    processed = Portion_segment(currVideo, paths{i}, videos{i}, startFrame, endFrame);
    %unconSizes = AnalysisCodeBAV(processed, videos{i});
    %allUnconSizes = [allUnconSizes, unconSizes];
end

totalTime = toc(startTime);
% outputFilename = [datestr(now, 'mm-dd-YY_HH-MM-SS'), '.txt'];
% dlmwrite(outputFilename, allUnconSizes);
% hist(allUnconSizes);

disp(sprintf('\n\n======'));
disp(['Total time to analyze ', num2str(length(videos)), ' video(s): ', num2str(totalTime), ' secs']);
disp(['Average time per video: ', num2str(totalTime/length(videos)), ' secs']);
disp('');
