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
clc

%% Initializations
% Allocates an array for the data
numDataCols = 8;
compiledData = zeros(1, numDataCols);
compiledDataPath = 'G:\CellVideos\';
% Initializes a progress bar
progressbar('Overall', 'Cell detection', 'Cell tracking');

%% Load video files and prepare any metadata
[pathNames, videoNames] = PromptForVideos('G:\CellVideos\');

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

% Creates a directory for the compiled data if it doesn't already exist
if ~(exist(fullfile(compiledDataPath, 'compiled_data\'), 'file') == 7)
    mkdir(fullfile(compiledDataPath, 'compiled_data\'));
end

%% Iterates through videos to filter, analyze, and output the compiled data
for i = 1:length(videoNames)
    % Initializations
    currPathName = pathNames{i};
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
    progressbar((i/(2*size(videoNames,1))), [], [])
    
    % Calls CellTracking to track the detected cells.
    [data] = CellTracking((endFrame-startFrame+1), frameRates(i), lineTemplate, processedFrames, xOffset);
    progressbar((i/(size(videoNames,1))), 0, 0)
    
    % If data is generated (cells are found and tracked through the device)
    if (~isempty(data))
        % If the first row is zeros (has not been written to yet)
        if (compiledData(1,1:numDataCols) == zeros(1,numDataCols))
            compiledData = data;
        % Otherwise add the new data
        else
            compiledData(end+1:end+size(data,1),1:numDataCols) = data;
        end
        
        % plot histogram of compiled data
        figure(99)
        [n,xout] = hist(compiledData(:,1,1));
        bar(xout,n);
        
        % Writes out the transit time data in an excel file
        colHeader1 = {'Total Time (ms)', 'Unconstricted Area'};
        colHeader2 = {'Total Time (ms)', 'Unconstricted Area', 'C1 to C2', 'C2 to C3', 'C3 to C4', 'C4 to C5', 'C5 to C6', 'C6 to C7'};
        colHeader3 = {'Unconstricted Area', 'A1', 'A2', 'A3', 'A4', 'A5', 'A6', 'A7'};
        colHeader4 = {'Unconstricted D', 'D1', 'D2', 'D3', 'D4', 'D5', 'D6', 'D7'};
        colHeader5 = {'Unconstricted E', 'E1', 'E2', 'E3', 'E4', 'E5', 'E6', 'E7'};
        xlswrite([compiledDataPath, 'compiled_data\data_xlscomp'],colHeader1,'Sheet1','A1');
        xlswrite([compiledDataPath, 'compiled_data\data_xlscomp'],compiledData(:,1,1),'Sheet1','A2');
        xlswrite([compiledDataPath, 'compiled_data\data_xlscomp'],compiledData(:,1,2),'Sheet1','B2');
        
        xlswrite([compiledDataPath, 'compiled_data\data_xlscomp'],colHeader2,'Sheet2','A1');
        xlswrite([compiledDataPath, 'compiled_data\data_xlscomp'],compiledData(:,:,1),'Sheet2','A2');
        
        xlswrite([compiledDataPath, 'compiled_data\data_xlscomp'],colHeader3,'Sheet3','A1');
        xlswrite([compiledDataPath, 'compiled_data\data_xlscomp'],compiledData(:,:,2),'Sheet3','A2');
        
        xlswrite([compiledDataPath, 'compiled_data\data_xlscomp'],colHeader4,'Sheet4','A1');
        xlswrite([compiledDataPath, 'compiled_data\data_xlscomp'],compiledData(:,:,3),'Sheet4','A2');
        
        xlswrite([compiledDataPath, 'compiled_data\data_xlscomp'],colHeader5,'Sheet5','A1');
        xlswrite([compiledDataPath, 'compiled_data\data_xlscomp'],compiledData(:,:,4),'Sheet5','A2');
    end
end

%% Output debugging information
totalTime = toc(tStart);
avgTimePerVideo = totalTime/length(videoNames);

disp(sprintf('\n\n==========='));
disp(['Total time to analyze ', num2str(length(videoNames)), ' video(s): ', num2str(totalTime), ' secs']);
disp(['Average time per video: ', num2str(avgTimePerVideo), ' secs']);
disp('');
