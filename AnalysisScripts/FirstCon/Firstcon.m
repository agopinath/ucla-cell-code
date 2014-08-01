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
[delta, thetaWidthIdx1] = min(abs(allDegs-pi/2));
[delta, thetaWidthIdx2] = min(abs(allDegs-3*pi/2));

baseHeight = pData{llane}{celll}(1, thetaLengthIdx1) +  pData{llane}{celll}(1, thetaLengthIdx2);
baseWidth = pData{llane}{celll}(1, thetaWidthIdx1) +  pData{llane}{celll}(1, thetaWidthIdx2);

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
    edgeDists(jIdx, 1) = pData{llane}{celll}(j, thetaLengthIdx1) +  pData{llane}{celll}(j, thetaLengthIdx2);
    edgeDists(jIdx, 2) = pData{llane}{celll}(j, thetaWidthIdx1) +  pData{llane}{celll}(j, thetaWidthIdx2);
    
    if usePercent
        edgeDists(jIdx, 1) = edgeDists(jIdx, 1)/baseHeight*100;
        edgeDists(jIdx, 2) = edgeDists(jIdx, 2)/baseWidth*100;
    end
end
avg = smooth(edgeDists(:,1), avgRun);

dats(datsIt, 1) = baseHeight;
dats(datsIt, 2) = baseWidth;
dats(datsIt, 3) = cData{llane}{celll}(1, 4);
dats(datsIt, 4) = (conEnd-conStart+1)/fps*1000;
dats(datsIt, 5) = size(cData{llane}{celll}, 1)/fps*1000;


maxEdge = max(avg);
if(isempty(maxEdge))
    dats(datsIt, 6) = NaN;
else
    dats(datsIt, 6) = maxEdge;
end

%% RELAXATION
V = (cData{llane}{celll}(:, 9) == currConGap);
[conStart, conEnd] = IdxFinder(V);
conStart = conStart - 1;

if(conStart < 1 | conEnd == -1)
    dats(datsIt, 7) = NaN;
    dats(datsIt, 8) = NaN;
else
clear avg; clear avgL; clear avgW; clear edgeDists;
edgeDists = [];
for j = conStart:conEnd
    jIdx = j-conStart+1;
    edgeDists(jIdx, 1) = pData{llane}{celll}(j, thetaLengthIdx1) +  pData{llane}{celll}(j, thetaLengthIdx2);
    edgeDists(jIdx, 2) = pData{llane}{celll}(j, thetaWidthIdx1) +  pData{llane}{celll}(j, thetaWidthIdx2);
    if usePercent
        edgeDists(jIdx, 1) = edgeDists(jIdx, 1)/baseHeight*100;
        edgeDists(jIdx, 2) = edgeDists(jIdx, 2)/baseWidth*100;
    end
end
avgL = smooth(edgeDists(:,1), avgRun);

maxEdge = avgL(1);
minEdge = avgL(end);

rate = (minEdge - maxEdge) / ((conEnd-conStart)/fps*1000);%((minEdgeIdx - maxEdgeIdx)/fps*1000);
dats(datsIt, 7) = abs(rate);

avgW = smooth(edgeDists(:, 2), avgRun);

maxEdge = avgW(1);
minEdge = avgW(end);
rate = (minEdge - maxEdge) / ((conEnd-conStart)/fps*1000);
dats(datsIt, 8) = abs(rate);
% end

% relaxedEdgeR = min(edgeDists(maxEdgeIdx+1:end));
% 
% if(isempty(relaxedEdgeR))
%     dats(datsIt, 7) = NaN;
% else 
dats(datsIt, 9) = minEdge; % subtract from 100 to result in the closets of equilibiruim the edge becomes
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
    dats(datsIt, 10) = NaN;
    dats(datsIt, 11) = NaN;
    dats(datsIt, 12) = NaN;
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
    dats(datsIt, 10) = creepExtent;
    dats(datsIt, 11) = creepTime;
    dats(datsIt, 12) = creepRate;%creepTime/cData{llane}{celll}(1, 4);
end