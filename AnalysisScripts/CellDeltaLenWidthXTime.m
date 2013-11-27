llane = 3; celll = 1; lenTheta = [0, pi]; widTheta = [pi/2, 3*pi/2];

frameCount = length(cellData{llane}{celll});
xs = 1:frameCount;
ys = cellData{llane}{celll}(:, 5);
avgRun = 5;
figure;
for i = 1:frameCount-avgRun
    [delta, len1] = min(abs(cellPerimsData{llane}{celll}{1}(:,1)-lenTheta(1)));
    [delta, len2] = min(abs(cellPerimsData{llane}{celll}{1}(:,1)-lenTheta(2)));
    [delta, wid1] = min(abs(cellPerimsData{llane}{celll}{1}(:,1)-widTheta(1)));
    [delta, wid2] = min(abs(cellPerimsData{llane}{celll}{1}(:,1)-widTheta(2)));
    ys(i, 1) = cellPerimsData{llane}{celll}{i}(len1, 2) + cellPerimsData{llane}{celll}{i}(len2, 2);
    ys(i, 2) = cellPerimsData{llane}{celll}{i}(wid1, 2) + cellPerimsData{llane}{celll}{i}(wid2, 2);
    if (i > avgRun*2)
        ys(i, 1) = ys(i-1, 1) - ys(i-avgRun, 1)/avgRun + ys(i, 1)/avgRun;
        ys(i, 2) = ys(i-1, 2) - ys(i-avgRun, 2)/avgRun + ys(i, 2)/avgRun;
    end
end
%mmm = ys;
mm = ys(1, 1);
nn = ys(1, 2);
for j = 2:frameCount
    ys(j, 1) = ys(j, 1) - mm;
    ys(j, 2) = ys(j, 2) - nn;
    mm = mm + ys(j, 1);
    nn = nn + ys(j, 2);
end

for i = 1:8
    idx1 = find(cellData{llane}{celll}(:, 9) == i, 1, 'first');
    idx2 = find(cellData{llane}{celll}(:, 9) == i, 1, 'last');
    finIndx = round((idx1+idx2)/2);
    if(~isempty(finIndx))
        indices(i) = finIndx;
    else
        indices(i) = NaN;
    end
end

hold on;
plot(xs, ys(:, 1), 'red');%, 'LineStyle', 'none', 'Marker', 'o');
plot(xs, ys(:, 2), 'blue');%, 'LineStyle', 'none', 'Marker', 'o');%'LineStyle', 'none', 'Marker', 'o');
%plot(xs, mmm(:, 2), 'red');%, 'LineStyle', 'none', 'Marker', 'o');%'LineStyle', 'none', 'Marker', 'o');

for j = 1:length(indices)
    if(~isnan(indices(j)))
        line([indices(j), indices(j)], [-20, 20], 'color', 'black');
    end
end
hold off;