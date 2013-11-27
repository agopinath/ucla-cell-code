llane = 9; celll = 1;
ttheta = [0, pi/2, pi, 3/2*pi];
colors = {'black', 'blue', 'magenta', 'red', [1, 0.5, 0], 'cyan', 'green', 'yellow'};

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
        end
        plot(xs, ys, 'color', colors{i});
    end
    legend(arrayfun(@num2str, ttheta, 'unif', 0), 'Location', 'SouthEast');
end