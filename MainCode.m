%% MainCode.m
% Main loop of the cell deformer tracking code.  Designed to input .avi 
% video files and track cells through the cell deformer device.  Designed
% to run multiple videos with minimal user interaction.

% Code from Dr. Amy Rowat's Lab, UCLA Department of Integrative Biology and
% Physiology
% Code originally by Bino Varghese (October 2011)
% Updated by David Hoelzle (January 2013)
% Updated by Sam Bruce, Ajay Gopinath, and Mike Scott (July 2013)

% Inputs
%   - .avi files are selected using a GUI
%   - The video names should include, anywhere in the name, the following:
%   1) "devNx10" where N is constriction width / template size to use
%       ex. "dev5x10..."
%   2) "Mfps", where M is the frame rate in frames per second
%       ex. "1200fps..."
%       Example of a properly formatted video name:
%       'dev5x10_1200fps_48hrppb_glass_4psi_20x_0.6ms_p12_041'

% Outputs
%   - An excel file with 5 sheets at the specified compiledDataPath
%       1) Total transit time (ms) and unconstricted area (pixels)
%       2) Transit time data (ms)
%       3) Area information at each constriction (pixels)
%       4) Approximate diameter at each constriction (pixels), calculated
%       as the average of major and minor axis of the cell
%       5) Eccentricity of each cell at each constriction

% Functions called
%   - PromptForVideos   (opens a GUI to load videos)
%   - MakeWaypoints     (Determines the constriction regions)
%   - CellDetection     (Filters the video frames to isolate the cells)
%   - CellTracking      (Labels and tracks cells through the device)
%   - progressbar       (Gives an indication of how much time is left)

% Updated 7/2013 by Mike
%       -Cut out the preprocessing 50 frames (required editing indicies of
%       the call for CellDetection
%       - Rearranged and commented the code to make it clearer
%       - Added the template.  Now MakeWaypoints is automatic and no
%       longer requires defining the cropping and constriction regions
%       - Eliminated redundant inputs and outputs from functions
%       - Eliminated 'segments', nobody used them
% Updated 7/16/2013 by Ajay
%       - separated all logic for prompting/selection of video files to
%       process into function PromptForVideos
%       - improved extraction of frame rates and template sizes from video
%       names by using regular expressions instead of ad-hoc parsing
%       - cleaned up any remaining legacy code and comments
%       - added better output of debugging information

close all
clear variables
clc

addpath(genpath(fullfile(pwd, '/Helpers')));

%% Initializations
% Allocates an array for the data
numDataCols = 8;
lonelyCompiledData = zeros(1, numDataCols);
pairedCompiledData = zeros(1, numDataCols);
compiledDataPath = 'C:\Users\Mike\Desktop\';
% Initializes a progress bar
progressbar('Overall', 'Cell detection', 'Cell tracking');

%% Load video files and prepare any metadata
[pathNames, videoNames] = PromptForVideos('G:\CellVideos\');

% Checks to make sure at least one video was selected for processing
if(isempty(videoNames{1}))
    disp('No videos selected.');
    close all;
    return;
end

% Extracts the template size and frame rates from the video name.
%   The video names should include, anywhere in the name, the following:
%   1) "devNx10" where N is constriction width / template size to use
%       ex. "dev5x10..."
%   2) "Mfps", where M is the frame rate in frames per second
%       ex. "1200fps..."
% Example of properly formatted video names:
% 'dev5x10_1200fps_48hrppb_glass_4psi_20x_0.6ms_p12_041'
for i = 1:length(videoNames)
    videoName = videoNames{i};
    [j,k] = regexp(videoName, 'dev\d*x'); % store start/end indices of template size
    [m, n] = regexp(videoName, '\d*fps'); % store start/end indices of frame rate
    templateSize = videoName((j+3):(k-1)); % removes 'dev' at the start, and 'x' at the end
    frameRate = videoName(m:(n-3)); % removes 'fps'  at the end
    
    templateSizes(i) = str2double(templateSize);
    frameRates(i) = str2double(frameRate);
end

tStart = tic;

% Create the folder in which to store the output data
% The output folder name is a subfolder in the folder where the first videos
% were selected. The folder name contains the time at which processing is
% started.
outputFolderName = fullfile(pathNames{1}, ['processed_', datestr(now, 'mm-dd-YY_HH-MM')]);
if ~(exist(outputFolderName, 'file') == 7)
    mkdir(outputFolderName);
end

lastPathName = pathNames{i};
%% Iterates through videos to filter, analyze, and output the compiled data
for i = 1:length(videoNames)
    % Initializations
    currPathName = pathNames{i};
    outputFilename = fullfile(outputFolderName, regexprep(currPathName, '[^a-zA-Z_0-9-]', '~'));
    currVideoName = videoNames{i};
    currVideo = VideoReader(fullfile(currPathName, currVideoName));
    startFrame = 1;
    endFrame = currVideo.NumberOfFrames;
    
    disp(['==Video ', num2str(i), '==']);
    
    % Calls the MakeWaypoints function to define the constriction region.
    % This function draws a template with a line across each constriction;
    % these lines are used in calculating the transit time
    [mask, lineTemplate, xOffset] = MakeWaypoints(currVideo, templateSizes(i));
    
    % Calls CellDetection to filter the images and store them in
    % 'processedFrames'.  These stored image are binary and should
    % (hopefully) only have the cells in them
    [processedFrames] = CellDetection(currVideo, startFrame, endFrame, currPathName, currVideoName, mask);
    
    % Calls CellTracking to track the detected cells.
    [lonelyData, pairedData] = CellTrackingNoFirst((endFrame-startFrame+1), frameRates(i), lineTemplate, processedFrames, xOffset);
    progressbar((i/(size(videoNames,2))), 0, 0)
    
    % If data is generated (cells are found and tracked through the device)
    if (~isempty(lonelyData))
        % If the first row is zeros (has not been written to yet)
        if ((strcmpi(lastPathName, currPathName) == 0) | lonelyCompiledData(1,1:numDataCols) == zeros(1,numDataCols))
            lonelyCompiledData = lonelyData;
        % Otherwise add the new data
        else
            lonelyCompiledData(end+1:end+size(lonelyData,1),1:numDataCols,1:size(lonelyData,3)) = lonelyData;
        end
        
        if ((strcmpi(lastPathName, currPathName) == 0) | pairedCompiledData(1,1:numDataCols) == zeros(1,numDataCols))
            pairedCompiledData = pairedData;
        % Otherwise add the new data
        else
            pairedCompiledData(end+1:end+size(pairedData,1),1:numDataCols,1:size(pairedData,3)) = pairedData;
        end
        
        % Plots histograms of the paired and unpaired cells total times
        figure(5)
        s(1) = subplot(2,2,1);
        s(2) = subplot(2,2,2);
        s(3) = subplot(2,2,3);
        s(4) = subplot(2,2,4);
        % Transit times
        hist(s(1),lonelyCompiledData(:,1,1))
        hist(s(3),pairedCompiledData(:,1,1))
        title(s(1), 'Unpaired Cells','FontWeight','bold')
        title(s(3), 'Paired Cells','FontWeight','bold')
        xlabel(s(3), 'Total Transit Time (ms)')
        % Areas
        hist(s(2),lonelyCompiledData(:,1,2))
        hist(s(4),pairedCompiledData(:,1,2))
        title(s(2), 'Unpaired Cells','FontWeight','bold')
        title(s(4), 'Paired Cells','FontWeight','bold')
        xlabel(s(4), 'Area (pixels)')
        linkaxes([s(1) s(3)],'xy');
        linkaxes([s(2) s(4)],'xy');
        
        WriteExcelOutput(outputFilename, lonelyCompiledData, pairedCompiledData);
        
        lastPathName = currPathName;
    end
end

%% Output debugging information
totalTime = toc(tStart);
avgTimePerVideo = totalTime/length(videoNames);

disp(sprintf('\n\n==========='));
disp(['Total time to analyze ', num2str(length(videoNames)), ' video(s): ', num2str(totalTime), ' secs']);
disp(['Average time per video: ', num2str(avgTimePerVideo), ' secs']);
disp(sprintf('\nOutputting metadata...'));

runOutputPaths = unique(pathNames);
for i = 1:length(runOutputPaths)
    runOutputFile = fopen(fullfile(runOutputPaths{i}, 'process_log.txt'), 'wt');
    vidIndices = strcmp(runOutputPaths{i}, pathNames);
    vidsProcessed = videoNames(vidIndices);
    
    fprintf(runOutputFile, '%s\n\n', 'The following files were processed from this folder:');
    fprintf(runOutputFile, '%s\n', '============');
    for j = 1:length(vidsProcessed)
        fprintf(runOutputFile, '%s\n', vidsProcessed{j});
    end
    fprintf(runOutputFile, '%s\n\n', '============');
    
    fprintf(runOutputFile, '%s%s\n', 'Processing was finished at: ', datestr(now, 'mm-dd-YY HH:MM:SS'));
    fprintf(runOutputFile, '%s%s\n', 'Output files are located at: ', outputFolderName);
    
    fclose(runOutputFile);
end

disp('Done.');