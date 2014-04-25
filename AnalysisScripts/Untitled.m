cData = cellDataMock; %%CHANGE

sizeMat = [];
for currLane = 1:16
    numCells = length(cData{currLane});
    for currCell = 1:numCells
        
        V = (cData{currLane}{currCell}(:, 9) == currCon);
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
        
        sizeMat(end+1) = maxBLen;%length(find(cData{currLane}{currCell}(:, 9) == 2));%cData{currLane}{currCell}(1, 4);
    end
end

figure; hist(sizeMat, 50);
prctile(sizeMat, [25, 85])