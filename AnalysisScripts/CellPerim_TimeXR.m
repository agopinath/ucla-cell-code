clear xs; clear ys;
%llane = 13; celll = 1;
ttheta = [0, pi/2, pi, 3/2*pi];
colors = {'black', 'blue', 'magenta', 'red', [1, 0.5, 0], 'cyan', 'green', 'yellow'};
avgRun = 2;
pData = cellPerimsDataMock;
cData = cellDataMock;
usePercent = true;
fps = 1000;

figure;
%subplot(2,1,2);
if(~isempty(ttheta))
    frameCount = length(pData{llane}{celll});
    xs = ((1:frameCount)/fps)*1000;
    for i = 1:length(ttheta)
        [delta, thetaIdx] = min(abs(pData{llane}{celll}{1}(:,1)-ttheta(i)));
        for j = 1:frameCount
            ys(j) = pData{llane}{celll}{j}(thetaIdx, 2);
            avg(j) = ys(j);
            if (j > avgRun)
                avg(j) = avg(j-1) - avg(j-avgRun)/avgRun + avg(j)/avgRun;
            end
            if usePercent == true
                if j == 1
                    base = ys(1);
                    ys(1) = 0;
                else
                    ys(j) = (avg(j)-base)/base*100;
                end
            end
        end
        if i == 3
            plot(xs, ys, 'color', colors{i}, 'LineWidth', 2);
        else
            plot(xs, ys, 'color', colors{i});
        end
        if i == 1
            hold on;
        end
    end
    %legend(arrayfun(@num2str, ttheta, 'unif', 0), 'Location', 'SouthEast');
    
    for i = 1:8
        idx = find(cData{llane}{celll}(:, 9) == i, 1, 'first');
        if(~isempty(idx))
            indices(i, 1) = idx;
        else
            indices(i, 1) = NaN;
        end

        idx = find(cData{llane}{celll}(:, 9) == i, 1, 'last');
        if(~isempty(idx))
            indices(i, 2) = idx;
        else
            indices(i, 2) = NaN;
        end
    end
    indices = indices/fps*1000;
    for j = 1:length(indices)
        
        if(~isnan(indices(j, 1)))
            line([indices(j, 1), indices(j, 1)], [-100 100], 'color', 'black');
        end
        
        %if(~isnan(indices(j, 2)))
        %    line([indices(j, 2), indices(j, 2)], [-100 100], 'color', 'green');
        %end
    end
end
