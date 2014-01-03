numCons = 8;

times = cell(1, 16);
frameRate = frameRates(1);
for currLane = 1:16
    numCells = length(cellData{currLane});
    for currCell = 1:numCells
        for currCon = 2:numCons*2+1
            time = length(find(cellData{currLane}{currCell}(:, 9) == (currCon/2)));
            if(time == 0)
                times{currCon-1}{end+1} = NaN;
                continue;
            end
            times{currCon-1}{end+1} = time*frameRate;
        end
    end
end

figure;
times = horzcat(times{1}', times{2}', times{3}', times{4}', times{5}',...
                times{6}', times{7}', times{8}', times{9}', times{10}',...
                times{11}', times{12}', times{13}', times{14}',...
                times{15}', times{16}');
times = cell2mat(times);
boxplot(times);