clear xs; clear ys;
% llane = 13; celll = 14;
ttheta = [0, pi/2, pi, 3/2*pi];
colors = {'black', 'blue', 'magenta', 'red', [1, 0.5, 0], 'cyan', 'green', 'yellow'};
avgRun = 5;
usePercent = true;
fps = 300;

allDegs = (1:361)*pi/180;
figure;

if(~isempty(ttheta))
    frameCount = size(pData{llane}{celll}, 1);%length(pData{llane}{celll});
    xs = ((1:frameCount)/fps)*1000;
    for i = 1:1%length(ttheta)
        [delta, thetaIdx] = min(abs(allDegs-ttheta(i)));
        for j = 1:frameCount
            if isempty(pData{llane}{celll})
                continue;
            end
            ys(j) = pData{llane}{celll}(j, thetaIdx) + pData{llane}{celll}(j, 180);
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
    for j = 2:length(indices)
        
        if(~isnan(indices(j, 1)))
            line([indices(j, 1), indices(j, 1)], [-100 100], 'color', 'green', 'LineWidth', 2);
        end
        
%         if(~isnan(indices(j, 2)))
%             line([indices(j, 2), indices(j, 2)], [-100 100], 'color', 'green');
%         end
    end
end

xlabel('Time Elapsed (ms)');
ylabel('Edge Extension (%)');
title(['lane= ', num2str(llane), ' cell= ', num2str(celll)]);
