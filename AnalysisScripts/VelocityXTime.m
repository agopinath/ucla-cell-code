llane = 3; celll = 1;
cData = cellDataM;
fps = 2000;

frameCount = length(cData{llane}{celll});
xs = (1:frameCount)/fps*1000;
ys = cData{llane}{celll}(:, 3);

avgRun = 3;
% for i = 1:frameCount
%     if (i > avgRun)
%         ys(i) = ys(i-1) - ys(i-avgRun)/avgRun + ys(i)/avgRun;
%     end
% end
mmm = ys;

mm = ys(1);
for j = 2:frameCount
    ys(j) = (ys(j) - mm);
    mm = mm + ys(j);
end

ys(1) = ys(2); % get rid of sudden "jump" from unknown initial velocity
ys = ys*fps/1000 % convert from um/frame to um/ms

%figure; 
subplot(2,1,1);
%hold on;
plot(xs, ys, 'red');
%hold off;
% subplot(2,1,2);
% hold on;
% plot(xs, mmm, 'blue');
% hold off;
%legend({'Velocity (um/ms)', 'Transposed Centroid Y'} , 'Location', 'SouthEast');

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

indices = indices/fps*1000
for j = 1:length(indices)
    if(~isnan(indices(j, 1)))
        subplot(2,1,1);
        line([indices(j, 1), indices(j, 1)], [-5 5], 'color', 'black');
%         subplot(2,1,2);
%         line([indices(j, 1), indices(j, 1)], [-5 5], 'color', 'black');
    end
    
%     if(~isnan(indices(j, 2)))
%         line([indices(j, 2), indices(j, 2)], [0 10], 'color', 'magenta');
%     end
end
