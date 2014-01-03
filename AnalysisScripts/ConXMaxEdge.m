clear xs; clear ys;

consNum = 8;
maxEdgeAngle = pi; % degrees, in rads, from theta=0 aligning with north, of max edge
avgRun = 1;
pData = cellPerimsDataMock;
cData = cellDataMock;
usePercent = true;
fps = 1000;

% UNCOMMENT BELOW FOR SINGLE CELL RUN
%llane = 5; celll = 1;
%maxExt = zeros(1, 7);
%maxExtIt = 1;
%
frameCount = length(pData{llane}{celll});

for currCon = 2:8
    conStart = find(cData{llane}{celll}(:, 9) == currCon, 1, 'first');
    conEnd = find(cData{llane}{celll}(:, 9) == currCon, 1, 'last');
    
    [delta, thetaIdx] = min(abs(pData{llane}{celll}{1}(:,1)-maxEdgeAngle));
    edgeDists = [];
    for j = conStart:conEnd
        edgeDists(j) = pData{llane}{celll}{j}(thetaIdx, 2);
        avg(j) = edgeDists(j);
%         if (j > avgRun)
%             avg(j) = avg(j-1) - avg(j-avgRun)/avgRun + avg(j)/avgRun;
%         end
        if usePercent == true
            if j == 1
                base = edgeDists(1);%cData{llane}{celll}{j}(1, 4);
                edgeDists(1) = 0;
            else
                edgeDists(j) = (avg(j)-base)/base*100;
            end
        end
    end
    
    maxEdge = max(edgeDists);
    maxExt(maxExtIt, currCon-1) = maxEdge;
end

%figure; boxplot(maxExt)

1+1;
