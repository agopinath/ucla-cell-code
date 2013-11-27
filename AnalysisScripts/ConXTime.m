llane = 3; celll = 1; numCons = 8;
ttheta = [0, pi/2, pi, 3/2*pi];
colors = {'black', 'blue', 'magenta', 'red', [1, 0.5, 0], 'cyan', 'green', 'yellow'};

figure;
for currCon = 2:numCons*2
    time = length(find(cellData{llane}{celll}(:, 9) == (currCon/2)));
    conTime(currCon-1) = time;
end

plot(1:15, conTime(:));