%%% Bino Abel Varghese
%%% Code to track cells
%%% First part of the code

function cellSizes = AnalysisCodeBAV(processed, videoName)
disp(['Starting analysis for video ', videoName, '...']);

DEBUG_FLAG = 1;
% to keep track of the frames from in which the unconstricted cell sizes were recorded
unconFrames = zeros(1, 20);
unconFrameIdx = 1;

% preallocating array to store unconstricted cell sizes
% as well as counter to keep track of the current index
unconstricted = zeros(1, 20);
unconIdx = 1;

frameCount = size(processed, 3);

height = size(processed, 1);
width = size(processed, 2);

for frameIdx = 1:frameCount
    currFrame = processed(:,:,frameIdx);
    mask = currFrame(1:40,1:width);
    
    comps = bwconncomp(mask);
    if comps.NumObjects > 0
        mask = imclearborder(mask);
        comps = bwconncomp(mask);
        if comps.NumObjects > 0
            s = regionprops(comps, 'Centroid', 'MajorAxisLength', 'MinorAxis');
            
            for i = 1:length(s)
                currCell = s(i);
                isUnconstricted = abs(currCell.Centroid(2) - 30) < 4;
                if(isUnconstricted)
                    unconstricted(unconIdx) = (currCell.MajorAxisLength + currCell.MinorAxisLength)/2;
                    unconIdx = unconIdx+1;
                    if DEBUG_FLAG == 1
                        unconFrames(unconFrameIdx) = frameIdx;
                        unconFrameIdx = unconFrameIdx+1;
                    end
                end
            end
        end
    end
end