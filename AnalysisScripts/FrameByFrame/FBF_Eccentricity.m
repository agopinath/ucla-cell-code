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

baseHeight = pData{llane}{celll}(1, thetaLengthIdx1) +  pData{llane}{celll}(1, thetaLengthIdx2);
baseWidth = pData{llane}{celll}(1, thetaWidthIdx1) +  pData{llane}{celll}(1, thetaWidthIdx2);

%% INITIALIZE 1st CON TRANSIT REGIONS
creepRegion = 1;
currCon = 1.25;
currConGap = 1.75;

V = (cData{llane}{celll}(:, 9) == currCon);
[conStart, conEnd] = IdxFinder(V);

%% UNCONS
len = pData{llane}{celll}(1, thetaLengthIdx1) +  pData{llane}{celll}(1, thetaLengthIdx2);
wid = pData{llane}{celll}(1, thetaWidthIdx1) +  pData{llane}{celll}(1, thetaWidthIdx2);
if(len <= 0 || wid <= 0)
    dats(datsIt, :) = NaN;
    return;
end
dats(datsIt, 4) = axes2ecc(max([len wid]), min([len wid]));
dats(datsIt, 1) = cData{llane}{celll}(1, 4);

dats(datsIt, 3) = (conEnd-conStart+1)/fps*1000;
%% IN CONSTRICTION
if(isempty(conEnd) || isempty(conStart) || conEnd == -1)
    return;
end
dats(datsIt, 2) = cData{llane}{celll}(floor(conStart+(conEnd-conStart)/2), 4);
for nn = conStart:conEnd
    len = pData{llane}{celll}(nn, thetaLengthIdx1) +  pData{llane}{celll}(nn, thetaLengthIdx2);
    wid = pData{llane}{celll}(nn, thetaWidthIdx1) +  pData{llane}{celll}(nn, thetaWidthIdx2);
    if(len <= 0 || wid <= 0)
        dats(datsIt, :) = NaN;
        return;
    end
    mmm(nn-conStart+1) = axes2ecc(max([len wid]), min([len wid]));
end

dats(datsIt, 5) = median(mmm);

%% Post Con
V = (cData{llane}{celll}(:, 9) == currConGap);
[conStart, conEnd] = IdxFinder(V);
conStart = conStart - 1;

clear mmm;
if(conStart < 1 | conEnd == -1)
    dats(datsIt, 6) = NaN;
else
    for nn = conStart:conEnd
        len = pData{llane}{celll}(nn, thetaLengthIdx1) +  pData{llane}{celll}(nn, thetaLengthIdx2);
        wid = pData{llane}{celll}(nn, thetaWidthIdx1) +  pData{llane}{celll}(nn, thetaWidthIdx2);
        if(len <= 0 || wid <= 0)
            dats(datsIt, :) = NaN;
            return;
        end
        mmm(nn-conStart+1) = axes2ecc(max([len wid]), min([len wid]));
    end
    dats(datsIt, 6) = median(mmm);
end
% if(~isnan(dats(datsIt, 2)))
%     dats(datsIt, 5) = dats(datsIt, 5) / dats(datsIt, 4);
% end
% if(~isnan(dats(datsIt, 3)))
%     dats(datsIt, 6) = dats(datsIt, 6) / dats(datsIt, 4);
% end


%% Eccentricity Relaxation Rate
V = (cData{llane}{celll}(:, 9) == currConGap);
[conStart, conEnd] = IdxFinder(V);
conStart = conStart - 1;
if(conStart < 1 | conEnd == -1)
    dats(datsIt, 7) = NaN;
else
    mmm = [];
    for nn = conStart:conEnd
        len = pData{llane}{celll}(nn, thetaLengthIdx1) +  pData{llane}{celll}(nn, thetaLengthIdx2);
        wid = pData{llane}{celll}(nn, thetaWidthIdx1) +  pData{llane}{celll}(nn, thetaWidthIdx2);
        if(len <= 0 || wid <= 0)
            dats(datsIt, :) = NaN;
            return;
        end
        mmm(nn-conStart+1) = axes2ecc(max([len wid]), min([len wid]));
    end
    avgL = smooth(mmm, 3);
    
    maxEdge = avgL(1);
    minEdge = avgL(end);
    
    rate = (minEdge - maxEdge) / ((conEnd-conStart)/fps*1000);%((minEdgeIdx - maxEdgeIdx)/fps*1000);
    dats(datsIt, 7) = abs(rate) / dats(datsIt, 4);
end

%% Len/Wid Relaxation Rate
V = (cData{llane}{celll}(:, 9) == currConGap);
[conStart, conEnd] = IdxFinder(V);
conStart = conStart - 1;
if(conStart < 1 | conEnd == -1)
    dats(datsIt, 8) = NaN;
    dats(datsIt, 9) = NaN;
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
    dats(datsIt, 8) = abs(rate);
    
    avgW = smooth(edgeDists(:, 2), avgRun);
    
    maxEdge = avgW(1);
    minEdge = avgW(end);
    rate = (minEdge - maxEdge) / ((conEnd-conStart)/fps*1000);
    dats(datsIt, 9) = abs(rate);
end