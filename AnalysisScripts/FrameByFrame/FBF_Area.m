clear xs; clear ys;
dbstop if error

consNum = 7;
avgRun = 3;
usePercent = true;
if(cData{llane}{celll}(end, 9) < 7 | isempty(pData{llane}{celll}) | isempty(cData{llane}{celll}))
    return;
end
allDegs = (1:361)*pi/180;
[delta, thetaLengthIdx1] = min(abs(allDegs-0));
[delta, thetaLengthIdx2] = min(abs(allDegs-pi));
[delta, thetaWidthIdx1] = min(abs(allDegs-pi/2));
[delta, thetaWidthIdx2] = min(abs(allDegs-3*pi/2));

%% INITIALIZE 1st CON TRANSIT REGIONS
creepRegion = 1;
currCon = 1.25;
currConGap = 1.75;

V = (cData{llane}{celll}(:, 9) == currCon);
[conStart, conEnd] = IdxFinder(V);

%% UNCONS
dats(datsIt, 1) = cData{llane}{celll}(1, 4);

%% IN CONSTRICTION
if(isempty(conEnd) || isempty(conStart) || conEnd == -1)
    return;
end
for nn = conStart:conEnd
    mmm(nn-conStart+1) = cData{llane}{celll}(nn, 4);
end

dats(datsIt, 2) = median(mmm);

%% POST CON
V = (cData{llane}{celll}(:, 9) == currConGap);
[conStart, conEnd] = IdxFinder(V);
conStart = conStart - 1;

clear mmm;
if(conStart < 1 | conEnd == -1)
    dats(datsIt, 3) = NaN;
else
    for nn = conStart:conEnd
        mmm(nn-conStart+1) = cData{llane}{celll}(nn, 4);
    end
    dats(datsIt, 3) = median(mmm);
end
% if(~isnan(dats(datsIt, 2)))
%     dats(datsIt, 2) = dats(datsIt, 2) / dats(datsIt, 1);
% end
% if(~isnan(dats(datsIt, 3)))
%     dats(datsIt, 3) = dats(datsIt, 3) / dats(datsIt, 1);
% end


%% RELAXATION
V = (cData{llane}{celll}(:, 9) == currConGap);
[conStart, conEnd] = IdxFinder(V);
conStart = conStart - 1;
if(conStart < 1 | conEnd == -1)
    dats(datsIt, 4) = NaN;
else
    mmm = [];
    for nn = conStart:conEnd
        mmm(nn-conStart+1) = cData{llane}{celll}(nn, 4);
    end
    avgL = smooth(mmm, 3);
    
    maxEdge = avgL(1);
    minEdge = avgL(end);
    
    rate = (minEdge - maxEdge) / ((conEnd-conStart)/fps*1000);%((minEdgeIdx - maxEdgeIdx)/fps*1000);
    dats(datsIt, 4) = abs(rate) / dats(datsIt, 1);
end
%% lenRELAXATION
V = (cData{llane}{celll}(:, 9) == currConGap);
[conStart, conEnd] = IdxFinder(V);
conStart = conStart - 1;

if(conStart < 1 | conEnd == -1)
    dats(datsIt, 5) = NaN;
else
edgeDists = [];
for j = conStart:conEnd
    jIdx = j-conStart+1;
    edgeDists(jIdx, 1) = pData{llane}{celll}(j, thetaLengthIdx1) +  pData{llane}{celll}(j, thetaLengthIdx2);
    if usePercent
        edgeDists(jIdx, 1) = edgeDists(jIdx, 1)/baseHeight*100;
    end
end
avgL = smooth(edgeDists(:,1), 3);

maxEdge = avgL(1);
minEdge = avgL(end);

rate = (minEdge - maxEdge) / ((conEnd-conStart)/fps*1000);%((minEdgeIdx - maxEdgeIdx)/fps*1000);
dats(datsIt, 5) = abs(rate);
end