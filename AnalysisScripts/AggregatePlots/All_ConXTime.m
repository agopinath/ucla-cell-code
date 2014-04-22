% varsC = {cellData0uMMock, dropDataSilicone10cSt, cellData0uMLama, dropDataSilicone100kcSt};
% titles = {'0uM Blebbistatin Mock', '10 cSt Silicone Droplets', '0uM Blebbistatin LamA OE', '100k cSt Silicone Droplets'};
% frameRates = {1000, 500, 1000, 500};
varsC = {cellData4psi5um_d0, cellData4psi5um_d4};
titles = {'Silicone 10 cSt @ 2psi', 'Silicone 10 cSt @ 4psi', 'Silicone 10 cSt @ 6psi', 'Silicone 10 cSt @ 8psi'};
frameRates = {300, 300, 500, 500};
figure;
for nn = 1:length(varsC)
    numCons = 8; % number of constrictions; leave at 8 by default
    cData = varsC{nn}; % takes a cellData variable
    frameRate = frameRates{nn}; % sets frameRate to be used when plotting

    times = cell(3, 16);

    for currLane = 1:16
        numCells = length(cData{currLane});
        for currCell = 1:numCells
            if(cData{currLane}{currCell}(1, 4) < 40 || cData{currLane}{currCell}(1, 4) > 80)
                continue;
            end
            for currCon = 4:numCons*2+1
                time = length(find(cData{currLane}{currCell}(:, 9) == (currCon/2)));
                if(time == 0) % if not found, skip this constriction and store a NaN
                    times{currCon-3}{end+1} = NaN;
                    continue;
                end
                times{currCon-3}{end+1} = (time/frameRate)*1000; % convert from # frames to framerate
            end
        end
    end

    %figure;
    %subplot(2,2,2);
    times = horzcat(times{1}', times{2}', times{3}', times{4}', times{5}',...
                    times{6}', times{7}', times{8}', times{9}', times{10}',...
                    times{11}', times{12}', times{13}', times{14}');
    times = cell2mat(times);
    subplot(1,2,nn);
    boxplot(times); % plots using a box plot
    % NOTE: '+' in plot is the mean of the transit times for that region

    xlabel('Region (1 = 1st con, 2 = gap after 1st con, 3 = 2nd con, etc.)')
    ylabel('Transit Times (ms)')
    title(titles{nn});

    %set(d,'XTick', (((1:16)-1)/2 +1));
    %xLabels = ['1'; '1.5'; '2'; '2.5'; '3'; '3.5'; '4'; '4.5'; '5'; '5.5'; '6'; '6.5'; '7'; '7.5'; '8'; '8.5';];
    %set(gca,'XTickLabel', xLabels);
end