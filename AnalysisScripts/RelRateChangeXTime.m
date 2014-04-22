numCons = 8; % number of constrictions; leave at 8 by default
cData = cellData; % takes a cellData variable
pData = cellPerimsData; % takes a cellData variable
frameRate = 1200; % sets frameRate to be used when plotting
dbstop if error
%celll = 1; llane = 2;
%relDats = [];
useCellSize = false;

edgeAngle = pi/2; % degrees, in rads, from theta=0 aligning with north, of edge to analyze
avgRun = 3;
usePercent = true;
fps = 1000;

allDegs = (1:361)*pi/180;

[delta, thetaIdx] = min(abs(allDegs-edgeAngle));
%base = pData{llane}{celll}{1}(thetaIdx, 2);
base = pData{llane}{celll}(1, thetaIdx);

if(cData{llane}{celll}(end, 9) < 7)
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
        % edgeDists(jIdx) = pData{llane}{celll}{j}(thetaIdx, 2);
        edgeDists(jIdx) = pData{llane}{celll}(j, thetaIdx);
        if usePercent == true
            edgeDists(jIdx) = (edgeDists(jIdx)-base)/base*100;
        end
    end
    enterIdx = size(relCDats, 1) + 1;
    
    minEdgeIdx = find(edgeDists == min(edgeDists));
    if(length(minEdgeIdx) > 1)
        minEdgeIdx = minEdgeIdx(1);
    end
    
    if(minEdgeIdx == 0) % if not found, skip this constriction and store a NaN
        relCDats(enterIdx, :) = NaN;
        continue;
    end
    
    maxEdgeIdx = find(edgeDists(minEdgeIdx+1:end) == max(edgeDists(minEdgeIdx+1:end)));
    
    if(maxEdgeIdx == 0) % if not found, skip this constriction and store a NaN
        relCDats(enterIdx, :) = NaN;
        continue;
    end
    
    if(length(maxEdgeIdx) > 1)
        maxEdgeIdx = maxEdgeIdx(1);
    end
    
    maxEdgeIdx = maxEdgeIdx + minEdgeIdx;
    
    maxEdge = edgeDists(maxEdgeIdx);
    minEdge = edgeDists(minEdgeIdx);
    
    rate = (maxEdge - minEdge) / ((maxEdgeIdx - minEdgeIdx)/fps*1000);
    
    if(~useCellSize)
        time = length(find(cData{llane}{celll}(:, 9) == currCon));
        if(time == 0) % if not found, skip this constriction and store a NaN
            relCDats(enterIdx, :) = NaN;
            continue;
        end
        relCDats(enterIdx, 2) = (time/fps)*1000;
    else
        relCDats(enterIdx, 2) = cData{llane}{celll}(1, 4);
    end
    
    relCDats(enterIdx, 1) = currCon-1;
    relCDats(enterIdx, 3) = rate;
end