clear xs; clear ys;

consNum = 8;
edgeAngle = pi; % degrees, in rads, from theta=0 aligning with north, of edge to analyze
avgRun = 2;
pData = cellPerimsData;
usePercent = true;
fps = 1000;

% UNCOMMENT BELOW FOR SINGLE CELL RUN
% llane = 5; celll = 1;
% extDists = zeros(1, 7);
% extDistIt = 1;
%
frameCount = length(pData{llane}{celll});
[delta, thetaIdx] = min(abs(pData{llane}{celll}{1}(:,1)-edgeAngle));
base = pData{llane}{celll}{1}(thetaIdx, 2);

for currCon = 2:8
    conStart = find(cData{llane}{celll}(:, 9) == currCon, 1, 'first');
    conEnd = find(cData{llane}{celll}(:, 9) == currCon, 1, 'last');
    
    edgeDists = [];
    avg = [];
    for j = conStart:conEnd
        jIdx = j-conStart+1;
        edgeDists(jIdx) = pData{llane}{celll}{j}(thetaIdx, 2);
        avg(jIdx) = edgeDists(jIdx);
%         if (jIdx > avgRun)
%             avg(jIdx) = avg(jIdx-1) - avg(jIdx-avgRun)/avgRun + avg(jIdx)/avgRun;
%         end
        if usePercent == true
            edgeDists(jIdx) = (avg(jIdx)-base)/base*100;
        end
    end
    
    useMin = true;
    if(mean(edgeDists) < 0)
        useMin = false;
    end
    
    if(useMin)
        relaxedEdgeR = min(edgeDists);
    else
        relaxedEdgeR = max(edgeDists);
    end
    
    %signedRelaxedEdgeR = edgeDists(relaxedEdgeIdx);
    extDists(extDistIt, currCon-1) = relaxedEdgeR;
end

%figure; boxplot(extDists)

1+1;
