%% Data Compilation file; runs sequential segmentations and analyses; objective is minimal user input
% Updated 7/09/2013 by Mike
%       -Cut out the preprocessing 50 frames (required editing indicies of
%       the call for CellDetection
%       - Rearranged and commented the code to make it clearer
%       - Added the template.  Now MakeWaypoints is automatic and no
%       longer requires defining the cropping and constriction regions
%       - Eliminated redundant inputs and outputs from functions
%       - Eliminated 'segments', nobody used them
clc

%% Initializations
filename = 1;
filePath = 'G:\CellVideos\';
% Allocates an array for the data
compiledData = zeros(1,7);
% Initializes a progress bar
progressbar('Overall', 'Cell detection', 'Cell tracking');

%% Loading GUI
% Opens a GUI to select videos, user can select a single file at a time and
% ends selection by clicking 'cancel'
i = 1;
j = 1;
while (filename ~= 0)
    [filename, filePath] = uigetfile('.avi', 'Please select the next video file, if done select cancel.', filePath, 'multiselect','on');
    if size(filename,2) ~= 1
        filename = cellstr(filename);
        while j <= size(filename,2)
            filename1 = filename{j};
            videoNameLength(i) = length(filename1);
            pathNameLength(i) = length(filePath);
            videoNames(i,1:videoNameLength(i)) = filename1;
            pathNames(i,1:pathNameLength(i)) = filePath;
            i = i+1;
            j = j+1;
        end
        j = 1;
        filename = filename1;
        clear filename1
    end
end

% Reads title of fps from title of file
% Important that fps come after first underscore
% Title format to follow
% 'dev5x10_1200fps_48hrppb_glass_4psi_20x_0.6ms_p12_041'
for i = 1:size(videoNameLength, 2)
    j = 1; ii = 1;
    while videoNames(i,j) ~= 'f'
        while videoNames(i,j) == '_'
            if videoNames(i,k) == 'f'
                break
            end
            frameRate(ii) = videoNames(i,k);
            k = k+1;
            ii = ii+1;
        end
        j = j+1;
        k = j+1;
    end
    frameRates(i) = str2double(frameRate);
end

%Reads template size from title
%only works if one follows titling fomrat shown above
for ii = 1:size(videoNameLength,2)
    if size(videoNameLength,2) == 1
        templateSize = str2double(videoNames(4));
    else
        templateSize(ii) = str2double(videoNames(ii,4));
    end
end

tStart = tic;

% Creates a directory for each video, followed by another set of folders
% inside these for each segment of the video
for i = 1:size(videoNames,1)
    mkdir (pathNames(i,1:pathNameLength(i)), 'compiled_data\')
    
    % Makes folders
    mkdir(pathNames(i,1:pathNameLength(i)), [videoNames(i,1:videoNameLength(i))])
    [msg, msgid] = lastwarn;
    
end

for i = 1:size(videoNames,1)
    % Calls the MakeWaypoints function to define the constriction region.
    % This function draws a template with a line across each constriction;
    % these lines are used in calculating the transit time
    currPathName = pathNames(i,1:pathNameLength(i))
    currVideoName = videoNames(i,1:videoNameLength(i));
    
    currVideo = VideoReader([currPathName, currVideoName]);
    startFrame = 1;
    endFrame = currVideo.NumberOfFrames;
    [mask, lineTemplate, xOffset] = MakeWaypoints(currVideo, templateSize(i));
    
    % Calls CellDetection to filter the images and store them in
    % 'processedFrames'.  These stored image are binary and should
    % (hopefully) only have the cells in them
    [processedFrames] = CellDetection(currVideo, startFrame, endFrame, frameRates(i), currPathName, currVideoName, mask);
    progressbar((i/(2*size(videoNames,1))), [], [])
    
    % Calls CellTracking to track the located cells.
    [data] = CellTracking((endFrame-startFrame+1), frameRates(i), lineTemplate, processedFrames, xOffset, currVideo);
    progressbar((i/(size(videoNames,1))), 0, 0)
    
    % If data is generated (cells are found and tracked through the device)
    if (~isempty(data))
        % If the first row is zeros (has not been written to yet)
        if (compiledData(1,1:7) == zeros(1,7))
            compiledData = data;
        % Otherwise add the new data
        else
            compiledData(end+1:end+size(data,1),1:7) = data;
        end
        
        % plot histogram of compiled data
        figure(99)
        [n,xout] = hist(compiledData(:,7));
        bar(xout,n)
        
        % Writes out the transit time data in an excel file
        colHeader = {'Total Time (ms)', 'Constriction 1 to 2', 'Constriction 2 to 3', 'Constriction 3 to 4', 'Constriction 4 to 5', 'Constriction 5 to 6', 'Constriction 6 to 7'};
        xlswrite([currPathName, 'compiled_data\data_xlscomp'],colHeader,'Sheet1','A1');
        xlswrite([currPathName, 'compiled_data\data_xlscomp'],compiledData,'Sheet1','A2');
    end
end

totalTime = toc(tStart)
avgTimePerVideo = totalTime/size(videoNames,1)