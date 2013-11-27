llane = 3; celll = 1;

frameCount = length(cellData{llane}{celll});
xs = 1:frameCount;


avgRun = 3;
figure;
for i = 1:frameCount-avgRun
    ys(i) = cellData{llane}{celll}(i, 5);
    if (i > avgRun*2)
        ys(i) = ys(i-1) - ys(i-avgRun)/avgRun + ys(i)/avgRun;
    end
end

figure; plot(xs, ys);

for i = 1:8
    idx = find(cellData{llane}{celll}(:, 9) == i, 1, 'first');
    if(~isempty(idx))
        indices(i, 1) = idx;
    else
        indices(i, 1) = NaN;
    end
    
    if(i == 1) 
        indices(i, 2) = NaN;
        continue;
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
        line([indices(j, 1), indices(j, 1)], [-1 1], 'color', 'black');
    end
    
    if(~isnan(indices(j, 2)))
        line([indices(j, 2), indices(j, 2)], [-1 1], 'color', 'magenta');
    end
end
hold off;