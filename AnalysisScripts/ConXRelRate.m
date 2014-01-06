clear xs; clear ys;
consNum = 8;
relAngle = 0; % degrees, in rads, from theta=0 aligning with north, of edge to analyze
avgRun = 2;
pData = cellPerimsDataMock;
usePercent = true;
fps = 1000;

% UNCOMMENT BELOW FOR SINGLE CELL RUN
% llane = 5; celll = 1;
% relRates = zeros(2, 7);
% relRateIt = 1;
%
frameCount = length(pData{llane}{celll});
[delta, thetaIdx] = min(abs(pData{llane}{celll}{1}(:,1)-relAngle));
base = pData{llane}{celll}{1}(thetaIdx, 2);

for currCon = 2:8
    conStart = find(cData{llane}{celll}(:, 9) == currCon, 1, 'first');
    conEnd = find(cData{llane}{celll}(:, 9) == currCon, 1, 'last');
    
    relEdgeDists = [];
    avg = [];
    for j = conStart:conEnd
        jIdx = j-conStart+1;
        relEdgeDists(jIdx) = pData{llane}{celll}{j}(thetaIdx, 2);
        avg(jIdx) = relEdgeDists(jIdx);
%         if (jIdx > avgRun)
%             avg(jIdx) = avg(jIdx-1) - avg(jIdx-avgRun)/avgRun + avg(jIdx)/avgRun;
%         end
        if usePercent == true
            relEdgeDists(jIdx) = (avg(jIdx)-base)/base*100;
        end
    end
    
    [maxEdge, maxEdgeIdx] = max(relEdgeDists);
    [minEdge, minEdgeIdx] = min(relEdgeDists(maxEdgeIdx:end));
    minEdgeIdx = minEdgeIdx + maxEdgeIdx; % account for offset 
    timeE = ((minEdgeIdx - maxEdgeIdx)/fps)*1000;
    deltaUm = minEdge - maxEdge;
    
    avgRate = deltaUm / timeE;
    relRates(relRateIt, currCon-1) = avgRate;
end

%figure; boxplot(relRates)

1+1;
