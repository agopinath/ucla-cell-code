function CellTrackingEveryFrame(numFrames, framerate, template, processedFrames, xOffset)

progressbar([],[],0)
% Change WRITEVIDEO_FLAG to true in order to print a video of the output,
% defaults to false.
WRITEVIDEO_FLAG = false;

%% Initializations

% HARD CODED x coordinates for the center of each lane (1-16), shifted by
% the offset found in 'MakeWaypoints'
laneCoords = [16 48 81 113 146 178 210 243 276 308 341 373 406 438 471 503] + xOffset;

%% Labels each grid line in the template from 1-8 starting at the top
[tempmask, ~] = bwlabel(template);

% Preallocates an array to store the y coordinate of each line
lineCoordinate = zeros(1,8);

% Uses the labeled template to find the y coordinate of each line
for jj = 1:8
    q = regionprops(ismember(tempmask, jj), 'PixelList');
    lineCoordinate(jj) = q(1,1).PixelList(1,2);
end
clear tempmask;

%% Opens a videowriter object if needed
if(WRITEVIDEO_FLAG)
    outputVideo = VideoWriter('G:\CellVideos\compiled_data\output_video.avi');
    outputVideo.FrameRate = cellVideo.FrameRate;
    open(outputVideo)
end

%% Cell Labeling
for ii = 1:numFrames
    currentFrame = processedFrames(:,:,ii);
    
    if(WRITEVIDEO_FLAG)
        tempFrame = imoverlay(read(cellVideo,ii), bwperim(logical(workingFrame)), [1 1 0]);
        writeVideo(outputVideo, tempFrame);
    end
    
    % Progress bar update
    if mod(ii, floor((numFrames)/100)) == 0
        progressbar([],[], (ii/(numFrames)))
    end
end

% Closes the video if it is open
if(WRITEVIDEO_FLAG)
    close(outputVideo);
end
