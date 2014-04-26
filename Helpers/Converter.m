%% Converter.m
% Converts existing cellPerimsData-type files from original cellPerimsData format to new format:
%     - replaces 361x2 double frame entries with a (num frames) x 361 double matrix
%     which stores non-redundant data

%% MOD HERE
%input = cellPerimsDataLama3;

%% Process and convert
for currLane = 1:16
    numCells = length(cellPerimsDataLama3{currLane});
    if(numCells == 0)
        continue;
    end
    for currCell = 1:numCells
%         if(currLane == 16 && (currCell == 3 || currCell == 8))
%             cellPerimsDataLama3{currLane}{currCell} = [];
%             continue;
%         end
        numFrames = length(cellPerimsDataLama3{currLane}{currCell});
        newEntries = zeros(numFrames, 361);
        for cFrame = 1:numFrames
            if(isempty(cellPerimsDataLama3{currLane}{currCell}{cFrame}))
                 newEntries(cFrame, :) = nan(1,361);
                continue;
            end
            vals = cellPerimsDataLama3{currLane}{currCell}{cFrame}(:,2);
            newEntries(cFrame, :) = vals';
        end
        clear vals;
        cellPerimsDataLama3{currLane}{currCell} = newEntries;
        clear newEntries;
    end
end

%% MOD HERE
%cellPerimsDataLama3 = input;