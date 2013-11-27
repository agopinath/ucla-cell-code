llane = 3; celll = 1; lenTheta = [0, pi]; widTheta = [pi/2, 3*pi/2];

frameCount = length(cellData{llane}{celll});
xs = 1:8;
ys = [];
avgWindow = 0;
for i = 1:8
    idx = find(cellData{llane}{celll}(:, 9) == i, 1, 'first');
    if(~isempty(idx))
        if(i > 1)
            idx = round((idx + find(cellData{llane}{celll}(:, 9) == i, 1, 'last'))/2);
        end
        [delta, len1] = min(abs(cellPerimsData{llane}{celll}{1}(:,1)-lenTheta(1)));
        [delta, len2] = min(abs(cellPerimsData{llane}{celll}{1}(:,1)-lenTheta(2)));
        [delta, wid1] = min(abs(cellPerimsData{llane}{celll}{1}(:,1)-widTheta(1)));
        [delta, wid2] = min(abs(cellPerimsData{llane}{celll}{1}(:,1)-widTheta(2)));
        ys(i, 1) = idx;
        ys(i, 2) = 0;
        avgCt = 0;
        for jj = (idx-avgWindow):(idx+avgWindow)
            if(jj > 0 && jj < frameCount)
                 ys(i, 2) = ys(i, 2) + (cellPerimsData{llane}{celll}{jj}(len1, 2) + cellPerimsData{llane}{celll}{jj}(len2, 2)) /...
                                  (cellPerimsData{llane}{celll}{jj}(wid1, 2) + cellPerimsData{llane}{celll}{jj}(wid2, 2));
                 avgCt = avgCt + 1;  
            end
        end
        ys(i, 2) = ys(i, 2)/(avgCt);
    end
end

figure; plot(xs, ys(:, 2), 'red', 'LineStyle', 'none', 'Marker', 'o');
% hold on;
% plot(xs, mmm/30, 'blue');
% hold off;
