%%% Bino Abel Varghese
%%% Code to track cells
%%% First part of the code

function AnalysisCodeBAV(processed, videoName)
close all;
clc;
disp(['Starting analysis for video ', videoName, '...']);
cellSizes = zeros(1, 10);
frameCount = size(processed, 3);

height = size(processed, 1);
width = size(processed, 2);

for frameIdx = 1:frameCount
    currFrame = processed(:,:,frameIdx);
    mask = currFrame(1:40,1:width);
    imshow(mask);
end


