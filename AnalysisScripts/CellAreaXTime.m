cData = dropDatatSilicone10cST;
pData = dropPerimsDatatSilicone10cST;
dats = [];

%figure;
i = 1;
for laneNum = 1:16
    numCells = length(cData{laneNum});
    for cellNum = 1:numCells
        dats(i, 1) = 1;
        dats(i, 2) = cData{laneNum}{cellNum}(1, 4);
        if(dats(i, 2) < 25 || dats(i, 2) > 200)
            dats(i, :) = NaN;
            continue;
        end
        dats(i, 3) = size(pData{laneNum}{cellNum}, 1);
        i = i + 1;
    end
end

figure; scatter(dats(:,2), dats(:,3));