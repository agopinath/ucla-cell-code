numCons = 8; % number of constrictions; leave at 8 by default
cData = cellData10k; % takes a cellData variable
frameRate = 400; % sets frameRate to be used when plotting

dats = []; % stores constriction, area, and transit time

for currLane = 1:16
    numCells = length(cData{currLane});
    for currCell = 1:numCells
%         if(cData{currLane}{currCell}(1, 4) < 130)
%             continue;
%         end
        for currCon = 2:8
            time = length(find(cData{currLane}{currCell}(:, 9) == currCon));
            enterIdx = size(dats, 1) + 1;
            if(time == 0) % if not found, skip this constriction and store a NaN
                dats(enterIdx, :) = NaN;
                continue;
            end
            dats(enterIdx, 1) = currCon-1;
            dats(enterIdx, 2) = cData{currLane}{currCell}(1, 4);
            dats(enterIdx, 3) = (time/frameRate)*1000;
        end
    end
end

figure;

% mmm = dats(dats(:,1)==3, :); scatter(log(mmm(:, 2)), log(mmm(:, 3)));

scatter3(dats(:, 1), log(dats(:, 2)), log(dats(:, 3)));
for i = 1:7
    m = dats(dats(:,1)==i, :);
    d = corr([log(m(:, 2)), log(m(:, 3))]);
    d(2)
end

%corr([log(dats(:, 2)), log(dats(:, 3))])
% times = horzcat(times{1}', times{2}', times{3}', times{4}', times{5}',...
%                 times{6}', times{7}', times{8}', times{9}', times{10}',...
%                 times{11}', times{12}', times{13}', times{14}');
% times = cell2mat(times);
% boxplot(times); % plots using a box plot
% % NOTE: '+' in plot is the mean of the transit times for that region
% 
% xlabel('Region (1 = 1st con, 2 = gap after 1st con, 3 = 2nd con, etc.)')
% ylabel('Transit Times (ms)')
% title('Lane Regions vs. Transit Times');
% 
% %set(d,'XTick', (((1:16)-1)/2 +1));
% %xLabels = ['1'; '1.5'; '2'; '2.5'; '3'; '3.5'; '4'; '4.5'; '5'; '5.5'; '6'; '6.5'; '7'; '7.5'; '8'; '8.5';];
% %set(gca,'XTickLabel', xLabels);