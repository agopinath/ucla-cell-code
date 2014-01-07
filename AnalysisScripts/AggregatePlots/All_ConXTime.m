numCons = 8; % number of constrictions; leave at 8 by default
cData = cellData; % takes a cellData variable
frameRate = 1000; % sets frameRate to be used when plotting

times = cell(1, 16);

for currLane = 1:16
    numCells = length(cData{currLane});
    for currCell = 1:numCells
        for currCon = 2:numCons*2+1
            time = length(find(cData{currLane}{currCell}(:, 9) == (currCon/2)));
            if(time == 0) % if not found, skip this constriction and store a NaN
                times{currCon-1}{end+1} = NaN;
                continue;
            end
            times{currCon-1}{end+1} = (time/frameRate)*1000; % convert from # frames to framerate
        end
    end
end

figure;
times = horzcat(times{1}', times{2}', times{3}', times{4}', times{5}',...
                times{6}', times{7}', times{8}', times{9}', times{10}',...
                times{11}', times{12}', times{13}', times{14}',...
                times{15}', times{16}');
times = cell2mat(times);
bplot(times); % plots using a box plot
% NOTE: '+' in plot is the mean of the transit times for that region

xlabel('Region (2 = 1st con, 3 = gap after 1st con, 4 = 2nd con, etc.)')
ylabel('Transit Times ')
title('Lane Regions vs. Transit Times');

%set(d,'XTick', (((1:16)-1)/2 +1));
%xLabels = ['1'; '1.5'; '2'; '2.5'; '3'; '3.5'; '4'; '4.5'; '5'; '5.5'; '6'; '6.5'; '7'; '7.5'; '8'; '8.5';];
%set(gca,'XTickLabel', xLabels);