llane = 3; celll = 1;

frameCount = length(cellData{llane}{celll});
xs = 1:frameCount;
ys = cellData{llane}{celll}(:, 3);

avgRun = 15;
for i = 1:frameCount
    if (i > avgRun)
        ys(i) = ys(i-1) - ys(i-avgRun)/avgRun + ys(i)/avgRun;
    end
end
mmm = ys;

mm = ys(1);
for j = 2:frameCount
    ys(j) = ys(j) - mm;
    mm = mm + ys(j);
end

figure; plot(xs, ys, 'red');
hold on;
plot(xs, mmm/50, 'blue');
hold off;
legend({'Velocity (um/ms)', 'Transposed Centroid Y'} , 'Location', 'SouthEast');

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
        line([indices(j, 1), indices(j, 1)], [0 10], 'color', 'black');
    end
    
    if(~isnan(indices(j, 2)))
        line([indices(j, 2), indices(j, 2)], [0 10], 'color', 'magenta');
    end
end
