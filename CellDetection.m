%% CellDetection.m
% function processed = CellDetection(cellVideo, startFrame, endFrame, folderName, videoName, mask)
% CellDetection loads the videos selected earlier and processes each frame
% to isolate the cells.  When debugging, the processed frames can be
% written to a video, or the outlines of the detected cells can be overlaid
% on the video.

% Code from Dr. Amy Rowat's Lab, UCLA Department of Integrative Biology and
% Physiology
% Code originally by Bino Varghese (October 2011)
% Updated by David Hoelzle (January 2013)
% Updated by Mike Scott (July 2013)
% Rewritten by Ajay Gopinath (July 2013)

% Inputs
%   - cellVideo: a videoReader object specifying a video to load
%   - startFrame: an integer specifying the frame to start analysis at
%   - endFrame: an integer specifying the frame to end analysis at
%   - folderName: a string specifying the filepath
%   - videoName: a string specifying the video's name
%   - mask: a logical array that was loaded in makeWaypoints and is used to
%       erase objects found outside of the lanes of the cell deformer.

% Outputs
%   - processed: An array of dimensions (height x width x frames) that
%       stores the processed frames.  Is of binary type.

% Changes
% Automation and efficiency changes made 03/11/2013 by Dave Hoelzle 
% Commenting and minor edits on 6/25/13 by Mike Scott 
% Increase in speed (~3 - 4x faster) + removed disk output unless debugging made on 7/5/13 by Ajay G.

function processed = CellDetection(cellVideo, startFrame, endFrame, folderName, videoName, mask)

%%% This code analyzes a video of cells passing through constrictions
%%% to produce and return a binary array of the video's frames which
%%% have been processed to yield only the cells.

DEBUG_FLAG = false; % flag for whether to show debug info
WRITEMOVIE_FLAG = false; % flag for whether to write processed frames to movie on disk
USEMASK_FLAG = false; % flag whether to binary AND the processed frames with the supplied mask
OVERLAYOUTLINE_FLAG = false; % flag whether to overlay detected outlines of cells on original frames

% 0 -> for normal fps hl60/large cells
% 1 -> for RBC cells
% 2 -> for high fps hl60/large cells
% 3 -> for clear high fps droplet vids
DETECT_TYPE = 4;

if DETECT_TYPE == 0
    flags = [DEBUG_FLAG, WRITEMOVIE_FLAG, false, OVERLAYOUTLINE_FLAG];
elseif DETECT_TYPE == 1
    flags = [DEBUG_FLAG, WRITEMOVIE_FLAG, true, OVERLAYOUTLINE_FLAG];
elseif DETECT_TYPE == 2 || DETECT_TYPE == 3 || DETECT_TYPE == 4 
    flags = [DEBUG_FLAG, WRITEMOVIE_FLAG, true, OVERLAYOUTLINE_FLAG];
end

% Start/END
% ...07:2100, 2249
% ...08: 1185, 1215
% ...08:
%minoil 002.001: 730, 803

startBG = 1250;%2100;
endBG = 1300;%2249;

if DETECT_TYPE == 0
    processed = DefaultDetection(cellVideo, startFrame, endFrame, folderName, videoName, mask, flags);
elseif DETECT_TYPE == 1
    processed = RBCDetection(cellVideo, startFrame, endFrame, folderName, videoName, mask, flags);    
elseif DETECT_TYPE == 2
    processed = HighFPSDetection(cellVideo, startFrame, endFrame, folderName, videoName, mask, flags, startBG, endBG);
elseif DETECT_TYPE == 3
    processed = DropletHighFPSDetection(cellVideo, startFrame, endFrame, folderName, videoName, mask, flags, startBG, endBG);
elseif DETECT_TYPE == 4
    processed = MultiDropletHighFPSDetection(cellVideo, startFrame, endFrame, folderName, videoName, mask, flags);
end