consNum = 8;
cData = cellDataLama;%cellData0uMLama;
pData = cellPerimsDataLama;%cellPerimsData0uMLama;
fps = 800;

idx = 1;
xs = [];
ys = [];

for laneNum = 11:16
    numCells = length(cData{laneNum});
    for cellNum = 1:numCells
        llane = laneNum; celll = cellNum;
        %%ys(idx) = size(cData{laneNum}{cellNum}, 1);
        %xs(idx) = cData{laneNum}{cellNum}(1, 4);
        %idx = idx + 1;
        %figure;
        
        CellPerim_TimeXR
        hold off;
        %i = 1;
    end
end

%figure;
%scatter(xs, ys);

hold off;
1+1