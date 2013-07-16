%% Code entry point; runs sequential segmentations and analyses; objective is minimal user input and to compile and output analysis data
% Updated 7/09/2013 by Mike
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

% Reads title of fps from title of file
% Important that fps come after first underscore
% Title format to follow
% 'dev5x10_1200fps_48hrppb_glass_4psi_20x_0.6ms_p12_041'
for i = 1:length(videoNames)
    videoName = videoNames{i};
    underscores = regexp(videoName, '_'); % get indices of underscores present in filename
    toParse = videoName(1:underscores(2)-1); % get everything up until the framerate
    [j,k] = regexp(videoName, '\d*x'); % store start/end indices of template size
    [m, n] = regexp(videoName, '\d*fps'); % store start/end indices of frame rate
    templateSize = videoName(j:(k-1)); % 'k-1' removes the 'x' character at the end
    frameRate = videoName(m:(n-3)); % 'n-3' to removes the 'fps' characters at the end
    
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
    [processedFrames] = CellDetection(currVideo, startFrame, endFrame, frameRates(i), currPathName, currVideoName, mask);
    progressbar((i/(2*size(videoNames,1))), [], [])
    
    % Calls CellTracking to track the detected cells.
    [data] = CellTracking((endFrame-startFrame+1), frameRates(i), lineTemplate, processedFrames, xOffset, currVideo);
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
        bar(xout,n)
        
        compiledData(:,2,1) = compiledData(:,1,2);
        
        % Writes out the transit time data in an excel file
        colHeader = {'Total Time (ms)', 'Unconstricted Area', 'C1 to C2', 'C2 to C3', 'C3 to C4', 'C4 to C5', 'C5 to C6', 'C6 to C7', [], [], 'Unconstricted Area', 'A1', 'A2', 'A3', 'A4', 'A5', 'A6', 'A7'};
        xlswrite([currPathName, 'compiled_data\data_xlscomp'],colHeader,'Sheet1','A1');
        xlswrite([currPathName, 'compiled_data\data_xlscomp'],compiledData(:,:,1),'Sheet1','A2');
        xlswrite([currPathName, 'compiled_data\data_xlscomp'],compiledData(:,:,2),'Sheet1','K2');
    end
end

%% Output debugging information
totalTime = toc(tStart);
avgTimePerVideo = totalTime/length(videoNames);

disp(sprintf('\n\n==========='));
disp(['Total time to analyze ', num2str(length(videoNames)), ' video(s): ', num2str(totalTime), ' secs']);
disp(['Average time per video: ', num2str(avgTimePerVideo), ' secs']);
disp('');
