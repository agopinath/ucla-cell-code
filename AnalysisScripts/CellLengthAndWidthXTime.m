llane = 3; celll = 1; lenTheta = [0, pi]; widTheta = [pi/2, 3*pi/2];

frameCount = length(cellData{llane}{celll});
xs = 1:frameCount;
ys = cellData{llane}{celll}(:, 5);
avgRun = 2;
figure;
for i = 1:frameCount-avgRun
    [delta, len1] = min(abs(cellPerimsData{llane}{celll}{1}(:,1)-lenTheta(1)));
    [delta, len2] = min(abs(cellPerimsData{llane}{celll}{1}(:,1)-lenTheta(2)));
    [delta, wid1] = min(abs(cellPerimsData{llane}{celll}{1}(:,1)-widTheta(1)));
    [delta, wid2] = min(abs(cellPerimsData{llane}{celll}{1}(:,1)-widTheta(2)));
    ys(i, 1) = cellPerimsData{llane}{celll}{i}(len1, 2) + cellPerimsData{llane}{celll}{i}(len2, 2);
    ys(i, 2) = cellPerimsData{llane}{celll}{i}(wid1, 2) + cellPerimsData{llane}{celll}{i}(wid2, 2);
    if(i == 1)
        unconLength = ys(i, 1);
        unconWidth = ys(i, 2);
    end
    ys(i, 1) = ys(i, 1) / unconLength;
    ys(i, 2) = ys(i, 2) / unconWidth;
    if (i > avgRun*2)
        ys(i, 1) = ys(i-1, 1) - ys(i-avgRun, 1)/avgRun + ys(i, 1)/avgRun;
        ys(i, 2) = ys(i-1, 2) - ys(i-avgRun, 2)/avgRun + ys(i, 2)/avgRun;
    end
end

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
hold on;
plot(xs, ys(:, 1), 'color', 'red');%, 'LineStyle', 'none', 'Marker', 'o');
plot(xs, ys(:, 2), 'color', 'blue');%, 'LineStyle', 'none', 'Marker', 'o');%'LineStyle', 'none', 'Marker', 'o');
legend({'L / L0', 'W / W0'} , 'Location', 'SouthEast');
for j = 1:length(indices)
    if(~isnan(indices(j, 1)))
        line([indices(j, 1), indices(j, 1)], [0 2], 'color', 'black');
    end
    
    if(~isnan(indices(j, 2)))
        line([indices(j, 2), indices(j, 2)], [0 2], 'color', 'magenta');
    end
end

hold off;
