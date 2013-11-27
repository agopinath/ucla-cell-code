llane = 3; celll = 1;

frameCount = length(cellData{llane}{celll});
xs = 1:frameCount;
ys = cellData{llane}{celll}(:, 3);
figure; plot(xs, ys, 'red');
