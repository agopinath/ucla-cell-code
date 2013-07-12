%%% Bino Abel Varghese
%%% Code to track cells
%%% First part of the code

function unconstrictedSizes = AnalysisCodeBAV(processed, videoName)
disp(['Starting analysis for video ', videoName, '...']);

DEBUG_FLAG = 1;

% preallocating array to store unconstricted cell sizes
% as well as counter to keep track of the current index
unconstrictedSizes = [];
unconIdx = 1;

frameCount = size(processed, 3);

height = size(processed, 1);
width = size(processed, 2);
maskRows = 5:45;
maskCols = 1:width;

% to keep track of the frames from in which the unconstricted cell sizes were recorded
unconFrames = zeros(length(maskRows), length(maskCols), 'uint8');
unconFrameIdx = 1;

t = tic;
for frameIdx = 1:frameCount
    currFrame = processed(:,:,frameIdx);
    mask = currFrame(maskRows, maskCols);
    %imshow(mask);
    comps = bwconncomp(mask);
    if comps.NumObjects > 0
        mask = imclearborder(mask);
        comps = bwconncomp(mask);
        if comps.NumObjects > 0
            s = regionprops(comps, 'Centroid', 'Eccentricity', 'MajorAxisLength', 'MinorAxis');
            
            for i = 1:length(s)
                currCell = s(i);
                if(currCell.Eccentricity > 0.7) 
                    continue;
                end
                isUnconstricted = abs(currCell.Centroid(2) - 30) < 1.4;
                if(isUnconstricted)
                    csize = sqrt((currCell.MajorAxisLength*currCell.MajorAxisLength + currCell.MinorAxisLength*currCell.MinorAxisLength)/2);
                    unconstrictedSizes(unconIdx) = csize;
                    unconIdx = unconIdx+1;
                    if DEBUG_FLAG == 1
                        unconFrames(:,:, unconFrameIdx) = mask(:,:);
                        unconFrameIdx = unconFrameIdx+1;
                    end
                end
            end
        end
    end
end

disp(['Found ', num2str(length(unconstrictedSizes)), ' unconstricted cells in ', num2str(toc(t)), ' secs']);
