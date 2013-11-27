clear xs; clear ys;
llane = 3; celll = 1;
ttheta = [0, pi/2, pi, 3/2*pi];
colors = {'black', 'blue', 'magenta', 'red', [1, 0.5, 0], 'cyan', 'green', 'yellow'};
avgRun = 2;
if(~isempty(ttheta))
    frameCount = length(cellPerimsData{llane}{celll});
    xs = 1:frameCount;
    for i = 1:length(ttheta)
        if(i ~= 1)
            hold on;
        else
            figure;
        end
        
        [delta, thetaIdx] = min(abs(cellPerimsData{llane}{celll}{1}(:,1)-ttheta(i)));
        for j = 1:frameCount
            ys(j) = cellPerimsData{llane}{celll}{j}(thetaIdx, 2);
            if (j > avgRun)
                ys(j) = ys(j-1) - ys(j-avgRun)/avgRun + ys(j)/avgRun;
            end
        end
        if i == 3
            plot(xs, ys, 'color', colors{i}, 'LineWidth', 2);
        else
            plot(xs, ys, 'color', colors{i});
        end
    end
    legend(arrayfun(@num2str, ttheta, 'unif', 0), 'Location', 'SouthEast');
    
    for i = 1:8
        idx = find(cellData{llane}{celll}(:, 9) == i, 1, 'first');
        if(~isempty(idx))
            indices(i, 1) = idx;
        else
            indices(i, 1) = NaN;
        end

        idx = find(cellData{llane}{celll}(:, 9) == i, 1, 'last');
        if(~isempty(idx))
            indices(i, 2) = idx;
        else
            indices(i, 2) = NaN;
        end
    end

    for j = 1:length(indices)
        if(~isnan(indices(j, 1)))
            line([indices(j, 1), indices(j, 1)], [0 35], 'color', 'black');
        end
        
        %if(~isnan(indices(j, 2)))
        %    line([indices(j, 2), indices(j, 2)], [0 35], 'color', 'green');
        %end
    end
end
