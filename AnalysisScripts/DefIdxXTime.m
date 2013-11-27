llane = 3; celll = 1; lenTheta = [0, pi]; widTheta = [pi/2, 3*pi/2];

frameCount = length(cellData{llane}{celll});
xs = 1:frameCount;

avgWindow = 3;
for i = 1:frameCount
    [delta, len1] = min(abs(cellPerimsData{llane}{celll}{1}(:,1)-lenTheta(1)));
    [delta, len2] = min(abs(cellPerimsData{llane}{celll}{1}(:,1)-lenTheta(2)));
    [delta, wid1] = min(abs(cellPerimsData{llane}{celll}{1}(:,1)-widTheta(1)));
    [delta, wid2] = min(abs(cellPerimsData{llane}{celll}{1}(:,1)-widTheta(2)));
    ys(i, 2) = 0;
    avgCt = 0;
    for jj = (i-avgWindow):(i+avgWindow)
        if(jj > 0 && jj < frameCount)
            ys(i, 2) = ys(i, 2) + (cellPerimsData{llane}{celll}{jj}(len1, 2) + cellPerimsData{llane}{celll}{jj}(len2, 2)) /...
                                  (cellPerimsData{llane}{celll}{jj}(wid1, 2) + cellPerimsData{llane}{celll}{jj}(wid2, 2));
            avgCt = avgCt + 1;
        end
    end
    ys(i, 2) = ys(i, 2)/(avgCt);
end
mm = ys(1, 2);
for j = 2:frameCount
    ys(j, 2) = ys(j, 2) - mm;
    mm = mm + ys(j, 2);
end
figure; plot(xs, ys(:, 2), 'red');

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
