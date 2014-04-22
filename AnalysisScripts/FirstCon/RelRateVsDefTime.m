numCons = 8; % number of constrictions; leave at 8 by default
dbstop if error
%celll = 1; llane = 2;
%relDats = [];
useCellSize = false;

edgeAngle = 0; % degrees, in rads, from theta=0 aligning with north, of edge to analyze
usePercent = true;

allDegs = (1:361)*pi/180;

[delta, thetaIdx] = min(abs(allDegs-edgeAngle));
%base = pData{llane}{celll}{1}(thetaIdx, 2);
base = pData{llane}{celll}(1, thetaIdx);

if(cData{llane}{celll}(end, 9) < 7 ...
  )% ||(cData{llane}{celll}(1, 4) < 25 ||  cData{llane}{celll}(1, 4) > 220))
    return
end

for currCon = 2:8
    conStart = find(cData{llane}{celll}(:, 9) == currCon, 1, 'first');
    conEnd = find(cData{llane}{celll}(:, 9) == currCon, 1, 'last');
    edgeDists = [];
    avg = [];
    for j = conStart:conEnd
        jIdx = j-conStart+1;
        %if isempty(pData{llane}{celll}{j})
        if isempty(pData{llane}{celll})
            continue;
        end
        %edgeDists(jIdx) = pData{llane}{celll}{j}(thetaIdx, 2);
        edgeDists(jIdx) = pData{llane}{celll}(j, thetaIdx);
        if usePercent == true
            edgeDists(jIdx) = (edgeDists(jIdx)-base)/base*100;
        end
    end
    enterIdx = size(relDats, 1) + 1;
    
    minEdgeIdx = find(edgeDists == min(edgeDists));
    if(size(minEdgeIdx, 2) > 1)
        minEdgeIdx = minEdgeIdx(1);
    end
    
    if(minEdgeIdx == 0) % if not found, skip this constriction and store a NaN
        relDats(enterIdx, :) = NaN;
        continue;
    end
    
    maxEdgeIdx = find(edgeDists(minEdgeIdx+1:end) == max(edgeDists(minEdgeIdx+1:end)));
    if(isempty(maxEdgeIdx) | maxEdgeIdx == 0) % if not found, skip this constriction and store a NaN
        relDats(enterIdx, :) = NaN;
        continue;
    end
    
    if(size(maxEdgeIdx, 2) > 1)
        maxEdgeIdx = maxEdgeIdx(1);
    end
    
    maxEdgeIdx = maxEdgeIdx + minEdgeIdx;
    
    maxEdge = edgeDists(maxEdgeIdx);
    minEdge = edgeDists(minEdgeIdx);
    
    rate = (maxEdge - minEdge) / ((maxEdgeIdx - minEdgeIdx)/fps*1000);
    
    if(~useCellSize)
        time = length(find(cData{llane}{celll}(:, 9) == currCon));
        if(time == 0) % if not found, skip this constriction and store a NaN
            relDats(enterIdx, :) = NaN;
            continue;
        end
        relDats(enterIdx, 2) = (time/fps)*1000;
    else
        relDats(enterIdx, 2) = cData{llane}{celll}(1, 4);
    end
    
    relDats(enterIdx, 1) = currCon-1;
    relDats(enterIdx, 3) = rate;
    relDats(enterIdx, 4) = cData{llane}{celll}(1, 4);
end