clear xs; clear ys;
llane = 4; celll = 6;
ttheta = {[pi/3, 2*pi/3], [pi/4, 3*pi/4]};
avgRun = 3;
colors = {'magenta', 'blue', 'black', 'magenta', 'red', [1, 0.5, 0], 'cyan', 'green', 'yellow'};
cData = dropDatatSilicone10cST;
pData = dropPerimsDatatSilicone10cST;
fps = 800;
figure;
allDegs = (1:361)*pi/180;

if(~isempty(ttheta))
    frameCount = size(pData{llane}{celll}, 1);
    xs = (1:frameCount)/fps*1000;
    for i = 1:length(ttheta)
        if i > 1
            hold on;
        end
        currInt = ttheta{i};
        [delta, thetaSt] = min(abs(allDegs-currInt(1)));
        [delta, thetaEnd] = min(abs(allDegs-currInt(2)));
        for j = 1:frameCount
            dists = zeros(1, thetaEnd-thetaSt);
            for k = thetaSt+1:thetaEnd
                r1 = pData{llane}{celll}(j, k-1);
                r2 = pData{llane}{celll}(j, k);
                theta1 = pData{llane}{celll}(j, k-1);
                theta2 = pData{llane}{celll}(j, k);
                
                dists(k-thetaSt) = sqrt(r1^2 + r2^2 - 2*r1*r2*cos(theta1-theta2));
%                 if (j > avgRun)
%                     ys(j) = ys(j-1) - ys(j-avgRun)/avgRun + ys(j)/avgRun;
%                 end
            end
            ys(j) = sum(dists);
            if (j > avgRun)
                ys(j) = ys(j-1) - ys(j-avgRun)/avgRun + ys(j)/avgRun;
            end
        end
        subplot(2,1,1); 
        plot(xs, ys, 'color', colors{i}, 'LineWidth', 1);
        clear ys;
    end
%     legend(arrayfun(@num2str, ttheta, 'unif', 0), 'Location', 'SouthEast');
    
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
            line([indices(j, 1), indices(j, 1)], [-100 1000], 'color', 'black');
        end
        
%         %if(~isnan(indices(j, 2)))
%         %    line([indices(j, 2), indices(j, 2)], [0 100], 'color', 'green');
%         %end
    end
end
clear pData; clear cData;
hold off;