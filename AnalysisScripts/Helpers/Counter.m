datsC = cellDataLama;

sum = 0;
for i = 1:length(datsC)
    if isempty(datsC{i})
        continue;
    end
    currLane = datsC{i};
    for j = 1:length(currLane)
        if isempty(currLane{j})
            continue;
        end
        
        sum = sum + 1;
    end
end

sum