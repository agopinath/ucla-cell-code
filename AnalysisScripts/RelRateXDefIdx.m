numCons = 8; % number of constrictions; leave at 8 by default
dbstop if error
%celll = 1; llane = 2;
%dats = [];
useCellSize = false;

widthEdgeAngle1 = pi/2; widthEdgeAngle2 = 3*pi/2; 
lengthEdgeAngle1 = 0; lengthEdgeAngle2 = pi;

avgRun = 3;
usePercent = true;


allDegs = (1:361)*pi/180;

[delta, thetaWidthIdx1] = min(abs(allDegs-widthEdgeAngle1));
[delta, thetaWidthIdx2] = min(abs(allDegs-widthEdgeAngle2));
[delta, thetaLengthIdx1] = min(abs(allDegs-lengthEdgeAngle1));
[delta, thetaLengthIdx2] = min(abs(allDegs-lengthEdgeAngle2));

baseLength = pData{llane}{celll}(1, thetaLengthIdx1) +  pData{llane}{celll}(1, thetaLengthIdx2);
baseWidth = pData{llane}{celll}(1, thetaWidthIdx1) + pData{llane}{celll}(1, thetaWidthIdx2);
%clear thetaWidthIdx1; clear thetaWidthIdx2; clear thetaLengthIdx1; clear thetaLengthIdx2; 

baseIdx = baseLength/baseWidth;

edgeAngle = pi/2;
[delta, thetaIdx] = min(abs(allDegs-edgeAngle));
base = pData{llane}{celll}(1, thetaIdx);

if(cData{llane}{celll}(end, 9) < 7) % skip if cell has not passed 6th constriction
    return
end

for currCon = 2:8
    conStart = find(cData{llane}{celll}(:, 9) == currCon, 1, 'first');
    conEnd = find(cData{llane}{celll}(:, 9) == currCon, 1, 'last');
    defIdxs = [];
    eDists = [];
    avg = [];
    for j = conStart:conEnd
       jIdx = j-conStart+1;
        %if isempty(pData{llane}{celll}{j})
        if isempty(pData{llane}{celll})
            continue;
        end
        
        defLength = pData{llane}{celll}(j, thetaLengthIdx1) +  pData{llane}{celll}(j, thetaLengthIdx2);
        defWidth = pData{llane}{celll}(j, thetaWidthIdx1) + pData{llane}{celll}(j, thetaWidthIdx2);
        defIdx = defLength/defWidth;
        
        eDists(jIdx) = pData{llane}{celll}(j, thetaIdx);
        if usePercent == true
            eDists(jIdx) = (eDists(jIdx)-base)/base*100;
        end

        defIdxs(jIdx) = defIdx;
    end
    enterIdx = size(dats, 1) + 1;
    
    maxDefIdx = max(defIdxs);%find(defIdxs==max(defIdxs));
    if(isempty(maxDefIdx) || maxDefIdx == 0) % if not found, skip this constriction and store a NaN
        dats(enterIdx, :) = NaN;
        continue;
    end
    
    dats(enterIdx, 2) = maxDefIdx;
    
    minEdgeIdx = find(eDists == min(eDists));
    if(size(minEdgeIdx, 2) > 1)
        minEdgeIdx = minEdgeIdx(1);
    end
    
    if(minEdgeIdx == 0) % if not found, skip this constriction and store a NaN
        dats(enterIdx, :) = NaN;
        continue;
    end
    
    maxEdgeIdx = find(eDists(minEdgeIdx+1:end) == max(eDists(minEdgeIdx+1:end)));
    if(isempty(maxEdgeIdx) | maxEdgeIdx == 0) % if not found, skip this constriction and store a NaN
        dats(enterIdx, :) = NaN;
        continue;
    end
    
    if(size(maxEdgeIdx, 2) > 1)
        maxEdgeIdx = maxEdgeIdx(1);
    end
    
    maxEdgeIdx = maxEdgeIdx + minEdgeIdx;
    
    maxEdge = eDists(maxEdgeIdx);
    minEdge = eDists(minEdgeIdx);
    
    rate = (maxEdge - minEdge) / ((maxEdgeIdx - minEdgeIdx)/fps*1000);
    
    dats(enterIdx, 1) = currCon-1;
    dats(enterIdx, 3) = rate;
end