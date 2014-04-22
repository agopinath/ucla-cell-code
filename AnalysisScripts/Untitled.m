cData = cellData_d4_6psi; %%CHANGE

sizeMat = [];
for currLane = 1:16
    numCells = length(cData{currLane});
    for currCell = 1:numCells
        sizeMat(end+1) = length(find(cData{currLane}{currCell}(:, 9) == 2));%cData{currLane}{currCell}(1, 4);
    end
end

figure; hist(sizeMat, 10);
prctile(sizeMat, [25, 95])