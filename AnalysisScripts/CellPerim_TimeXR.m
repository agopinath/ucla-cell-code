llane = 12; celll = 2;
ttheta = 0:pi/4:7/4*pi;%[0, pi/2, pi, 3/2*pi];
colors = {'black', 'blue', 'magenta', 'red', [1, 0.5, 0], 'cyan', 'green', 'yellow'};

if(~isempty(ttheta))
    numFrames = length(cellPerimsData{llane}{celll});
    x = 1:numFrames;
    for i = 1:length(ttheta)
        if(i ~= 1)
            hold on;
        else
            figure;
        end
        
        [delta, thetaIdx] = min(abs(cellPerimsData{llane}{celll}{1}(:,1)-ttheta(i)));
        for j = 1:numFrames
            y(j) = cellPerimsData{llane}{celll}{j}(thetaIdx, 2);
        end
        plot(x, y, 'color', colors{i});
    end
    legend(arrayfun(@num2str, ttheta, 'unif', 0), 'Location', 'SouthEast');
end