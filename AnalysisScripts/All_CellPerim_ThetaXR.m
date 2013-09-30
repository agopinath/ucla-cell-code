%llane = 7; celll = 1; 
numCons = 8;
colors = {'black', 'blue', 'magenta', 'red', [1, 0.5, 0], 'cyan', 'green', 'yellow'};

%coords = cellPerimsData{llane}{celll}{1};
%figure; plot(coords(:,1), coords(:,2), 'color', 'black', 'LineWidth', 3);

for i = 1:numCons
    
end
xs = 0:(pi/180):(2*pi);
avgs = zeros(361, numCons);
nums = zeros(1, numCons);
for llane = 1:16
    numCells = length(cellData{llane});
    for celll = 1:numCells
        for i = 1:numCons
            conIdxs = find(cellData{llane}{celll}(:, 9) == i);
            if(isempty(conIdxs))
                continue;
            end
            cstart = conIdxs(1);
            cend = conIdxs(end);
            ys = cellPerimsData{llane}{celll}{:, cstart}(:, 2);
            for c = cstart+1:cend
                currYs = cellPerimsData{llane}{celll}{:, c};
                if(isempty(currYs))
                    continue;
                end
                ys = ys + currYs(:, 2);
            end
            ys = ys/(cend-cstart+1);
            curColor = colors{jj};ys = ys/cellData{llane}{celll}(1, 4); % normalize by dividing by uncon. cell area
            avgs(:, i) = avgs(:, i) + ys;
            nums(i) = nums(i) + 1;
        end
    end
end

figure;
for jj = 1:numCons
    nnn(:, jj) = avgs(:, jj) / nums(jj);
    curColor = colors{jj};
    if(jj ~= 1)
        hold on;
    end
    plot(xs, nnn(:, jj), 'color', curColor, 'LineWidth', 2);
end


legend('None', '1st', '2nd', '3rd', '4th', '5th', '6th', '7th', 'Location', 'SouthEast');
hold off;
1+1