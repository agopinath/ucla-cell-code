clear xs; clear ys;
dbstop if error

consNum = 8;
avgRun = 3;
usePercent = true;
if(cData{llane}{celll}(end, 9) < 7 | isempty(pData{llane}{celll}) | isempty(cData{llane}{celll}))
    return;
end
allDegs = (1:361)*pi/180;

frameCount = length(pData{llane}{celll});

[delta, thetaLengthIdx1] = min(abs(allDegs-0));
[delta, thetaLengthIdx2] = min(abs(allDegs-pi));

baseHeight = pData{llane}{celll}(1, thetaLengthIdx1) +  pData{llane}{celll}(1, thetaLengthIdx2);
baseTrailingEdge = pData{llane}{celll}(1, thetaLengthIdx1);
baseLeadingEdge = pData{llane}{celll}(1, thetaLengthIdx2);

%% INITIALIZE 1st CON TRANSIT REGIONS
creepRegion = 1;
currCon = 1.25;
currConGap = 1.75;

% conStart = find(cData{llane}{celll}(:, 9) == creepRegion, 1, 'first');
% conEnd = find(cData{llane}{celll}(:, 9) == currCon, 1, 'last');
V = (cData{llane}{celll}(:, 9) == currCon);
[conStart, conEnd] = IdxFinder(V);

%% IN CONSTRICTION
if(isempty(conEnd) || isempty(conStart) || conEnd == -1)
    return;
end
edgeDists = [];
for j = conStart:conEnd
    jIdx = j-conStart+1;
    edgeDists(jIdx) = pData{llane}{celll}(j, thetaLengthIdx1) +  pData{llane}{celll}(j, thetaLengthIdx2);
    
    if usePercent
        edgeDists(jIdx) = edgeDists(jIdx)/baseHeight*100;
    end
end
avg = smooth(edgeDists, avgRun);

dats(datsIt, 1) = (conEnd-conStart+1)/fps*1000;
dats(datsIt, 2) = size(cData{llane}{celll}, 1)/fps*1000;
dats(datsIt, 3) = baseHeight;

maxEdge = max(avg);
if(isempty(maxEdge))
    dats(datsIt, 4) = NaN;
else
    dats(datsIt, 4) = maxEdge;
end

%% RELAXATION
V = (cData{llane}{celll}(:, 9) == currConGap);
[conStart, conEnd] = IdxFinder(V);
conStart = conStart - 1;

if(conStart < 1 | conEnd == -1)
    dats(datsIt, 5) = NaN;
    dats(datsIt, 6) = NaN;
else
edgeDists = [];
for j = conStart:conEnd
    jIdx = j-conStart+1;
    edgeDists(jIdx) = pData{llane}{celll}(j, thetaLengthIdx1) +  pData{llane}{celll}(j, thetaLengthIdx2);
    
    if usePercent
        edgeDists(jIdx) = edgeDists(jIdx)/baseHeight*100;
    end
end
avg = smooth(edgeDists, avgRun);
% 
% maxEdgeIdx = find(edgeDists == max(edgeDists));
% if(isempty(maxEdgeIdx) | maxEdgeIdx == 0) % if not found, skip this constriction and store a NaN
%     dats(datsIt, 6) = NaN;
% end
% 
% if(size(maxEdgeIdx, 2) > 1)
%     maxEdgeIdx = maxEdgeIdx(1);
% end
% 
% minEdgeIdx = find(edgeDists(maxEdgeIdx+1:end) == min(edgeDists(maxEdgeIdx+1:end)));
% if(size(minEdgeIdx, 2) > 1)
%     minEdgeIdx = minEdgeIdx(1);
% end
% 
% if(isempty(minEdgeIdx) | minEdgeIdx == 0) % if not found, skip this constriction and store a NaN
%     dats(datsIt, 6) = NaN;
% else
%     minEdgeIdx = minEdgeIdx + maxEdgeIdx;

    maxEdge = avg(1);
    minEdge = avg(end);

    rate = (minEdge - maxEdge) / ((conEnd-conStart)/fps*1000);%((minEdgeIdx - maxEdgeIdx)/fps*1000);
    dats(datsIt, 5) = abs(rate);
% end

% relaxedEdgeR = min(edgeDists(maxEdgeIdx+1:end));
% 
% if(isempty(relaxedEdgeR))
%     dats(datsIt, 7) = NaN;
% else 
    dats(datsIt, 6) = minEdge; % subtract from 100 to result in the closets of equilibiruim the edge becomes
% end

end
%% CREEP
% conStart = find(cData{llane}{celll}(:, 9) == creepRegion, 1, 'first');
% conEnd = find(cData{llane}{celll}(:, 9) == creepRegion, 1, 'last')+1;
% 
% if(isempty(conEnd) || isempty(conStart))
%     return;
% end

V = (cData{llane}{celll}(:, 9) == creepRegion);
[conStart, conEnd] = IdxFinder(V);
conEnd = conEnd + 1;

if(conStart == -1 | conEnd == -1)
    dats(datsIt, 8) = NaN;
    dats(datsIt, 9) = NaN;
    dats(datsIt, 10) = NaN;
else
    edgeDists = [];
    for j = conStart:conEnd
        jIdx = j-conStart+1;
        edgeDists(jIdx) = pData{llane}{celll}(j, thetaLengthIdx1) + pData{llane}{celll}(j, thetaLengthIdx2);
        
        if usePercent
            edgeDists(jIdx) = edgeDists(jIdx)/baseHeight*100;
        end
    end
    avg = smooth(edgeDists, avgRun);
    
    creepExtent = avg(end) - avg(1);
    creepTime = (conEnd - conStart)/fps*1000;
    creepRate = creepExtent / creepTime;
    dats(datsIt, 8) = creepExtent;
    dats(datsIt, 9) = creepTime;
    dats(datsIt, 10) = creepRate;%creepTime/cData{llane}{celll}(1, 4);
end

%% GENERAL
dats(datsIt, 7) = cData{llane}{celll}(1, 4);