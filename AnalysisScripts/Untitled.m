cData = cellDataLama; %%CHANGE

sizeMat = [];
for currLane = 1:16
    numCells = length(cData{currLane});
    for currCell = 1:numCells
        
        V = (cData{currLane}{currCell}(:, 9) == 1.25);
        D = diff(V);
        b.beg = 1 + find(D == 1);
        b.end = find(D == -1);
        if V(end)
            b.end(end+1) = numel(V);
        end
        
        maxBLen = -1; maxBLenIdx = -1;
        for jjk = 1:length(b.beg)
            if (b.end(jjk) - b.beg(jjk)) > maxBLen
                maxBLen = (b.end(jjk) - b.beg(jjk));
                maxBLenIdx = jjk;
            end
        end
        
        V = (cData{currLane}{currCell}(:, 9) == 1);
        D = diff(V);
        b.beg = 1 + find(D == 1);
        b.end = find(D == -1);
        if V(end)
            b.end(end+1) = numel(V);
        end
        
        d = -1; maxBLenIdx = -1;
        for jjk = 1:length(b.beg)
            if (b.end(jjk) - b.beg(jjk)) > d
                d = (b.end(jjk) - b.beg(jjk));
                maxBLenIdx = jjk;
            end
        end
        
        sizeMat(end+1) = cData{currLane}{currCell}(1, 4);
        
        %length(find(cData{currLane}{currCell}(:, 9) == 1)) + length(find(cData{currLane}{currCell}(:, 9) == 1.25));
        %cData{currLane}{currCell}(1, 4);
    end
end
figure; hist(sizeMat, 15);
prctile(sizeMat, [30, 40])