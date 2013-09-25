llane = 12; celll = 7; numCons = 8;
colors = {'black', 'blue', 'magenta', 'red', [1, 0.5, 0], 'cyan', 'green', 'yellow'};

USE_AVGS = true;

coords = cellPerimsData{llane}{celll}{1};
figure; plot(coords(:,1), coords(:,2), 'color', 'red', 'LineWidth', 3);

for i = 1:numCons
    conIdxs = find(cellData{llane}{celll}(:, 9) == i);
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
            coords = cellPerimsData{llane}{celll}{n};
            plot(coords(:,1), coords(:,2), 'color', curColor, 'LineWidth', 2);
        end
    end
    hold off;
else
    for i = 1:numCons
        cstart = cons(i, 1);
        cend = cons(i, 2);
        d = cellPerimsData{llane}{celll}{:, cstart}(:, 2);
        for c = cstart+1:cend
            d = d + cellPerimsData{llane}{celll}{:, c}(:, 2);
        end
        d = d/(cend-cstart+1);
        thetas = cellPerimsData{llane}{celll}{1, 1}(:, 1);
        avgs = horzcat(thetas, d);
        
        curColor = colors{i};
        if(i ~= 1)
            hold on;
        end
        plot(avgs(:,1), avgs(:,2), 'color', curColor, 'LineWidth', 2);
    end
    legend('None', '1st', '2nd', '3rd', '4th', '5th', '6th', '7th', 'Location', 'SouthEast');
    hold off;
    1+1
end