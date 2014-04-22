llane = 3; celll = 1; numCons = 8;
colors = {'black', 'blue', 'magenta', 'red', [1, 0.5, 0], 'cyan', 'green', 'yellow'};

cData = cellData1;
pData = cellPerimsData1;

USE_AVGS = true;

allDegs = ((1:361)*pi/180)';

coords = pData{llane}{celll}(1, :);
coords = smooth(coords', 150, 'moving');
figure; plot(allDegs, coords', 'color', 'black', 'LineWidth', 3);

for i = 1:numCons
    conIdxs = find(cData{llane}{celll}(:, 9) == i);
    cons(i, 1) = conIdxs(1);
    cons(i, 2) = conIdxs(end);
end

if(~USE_AVGS)
    hold on;
    for j = 1:numCons
        sCon = cons(j, 1);
        eCon = cons(j, 2);
        curColor = colors{j};
        for n = sCon:eCon
            coords = pData{llane}{celll}(n, :);
            plot(allDegs, coords, 'color', curColor, 'LineWidth', 2);
        end
    end
    hold off;
else
    for i = 3:3
        cstart = cons(i, 1);
        cend = cons(i, 2);
        d = pData{llane}{celll}(cstart, :);
        for c = cstart+1:cend
            d = d + pData{llane}{celll}(c, :);
        end
        d = d/(cend-cstart+1);
        %thetas = pData{llane}{celll}{1, 1}(:, 1);
        avgs = horzcat(allDegs, d');
        
        curColor = colors{i};
        if(i ~= 1)
            hold on;
        end
        avgs(:,2) = smooth(avgs(:,2)', 10, 'moving');
        plot(avgs(:,1), avgs(:,2)', 'color', 'magenta', 'LineWidth', 4);
    end
%     legend('Unconstricted', '1st', '2nd', '3rd', '4th', '5th', '6th', '7th', 'Location', 'SouthEast');
    hold off;
    1+1
end

%xlabel('Theta');
%ylabel('Distance from Centroid (um)');

ti = get(gca,'TightInset')
set(gca,'Position',[ti(1) ti(2)+.02 1-ti(3)-ti(1) 1-ti(4)-ti(2)]);