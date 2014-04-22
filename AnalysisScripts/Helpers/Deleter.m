% cellLanePairs = {[14 2], [14 1], [10 4], [10 3],...
%                  [8 1], [7 1], [6 1], [3 2]};

cellLanes = [5 4 3 2 1 10 9 8 7 6 16 15 14 13 12 11];
cellLaneCells = {[10,9,7,6,5,4], [14,13,8,7,5,4,3], [26, 25, 23,22,21,20,19,18,17,16,13,12,11,10,7,5,4,3,2,1],...,};
[7,6, 4,3], [5,2,1], [19,15,14,12,11,10,9,8,6,4,2,1], [12,11, 10,9,5], [3], [13,11,10,9,7,3,2],...
[8,5,2,1], [6,5,4,3,2], [5, 4,3,2], [24,21,20,19,17,16,15,14,12,11,10,9,8,7,6,5,4,3,2,1],...
[12,8,7,5,4,2,1], [18,17,16,14,12,3,1], [24,23,22,21,20,17,16,12,11,10,8,6,5,4,3,2,1]};

length(cellLanes)
length(cellLaneCells)
deletedC = {};
deletedP = {};
delIdx = 1;


%% REPLACE HERE:
dataC = cellDataLama;
dataP = cellPerimsDataLama;
%%%

for i = 1:length(cellLanes)
    pairLane = cellLanes(i);
    for j = 1:length(cellLaneCells{i})
        pairCell = cellLaneCells{i}(j);
        
        deletedC{delIdx} = dataC{pairLane}{pairCell};
        deletedP{delIdx} = dataP{pairLane}{pairCell};
        delIdx = delIdx + 1;
        
        dataC{pairLane}{pairCell} = [];
        dataP{pairLane}{pairCell} = [];
    end
end

%% REPLACE HERE:
cellDataLama = dataC;
cellPerimsDataLama = dataP;
%%%