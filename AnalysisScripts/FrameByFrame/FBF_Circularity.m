clear xs; clear ys;
dbstop if error

consNum = 7;
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
baseTrailingEdge = pData{llane}{celll}(1, thetaLengthIdx1);
baseLeadingEdge = pData{llane}{celll}(1, thetaLengthIdx2);

%% INITIALIZE 1st CON TRANSIT REGIONS
creepRegion = 1;
currCon = 1.25;
currConGap = 1.75;

V = (cData{llane}{celll}(:, 9) == currCon);
[conStart, conEnd] = IdxFinder(V);

%% UNCONS
A = cData{llane}{celll}(1,4);
P = 0;
for kk = 1:360
    d1 = pData{llane}{celll}(1, kk);
    d2 = pData{llane}{celll}(1, kk+1);
    dist = sqrt(d1^2 + d2^2 - 2*d1*d2*cos(1));
    P = P + dist;
end
dats(datsIt, 1) = (4*pi*A)/(P^2);

%% IN CONSTRICTION
if(isempty(conEnd) || isempty(conStart) || conEnd == -1)
    return;
end
for nn = conStart:conEnd
    A = cData{llane}{celll}(nn,4);
    P = 0;
    for kk = 1:360
        d1 = pData{llane}{celll}(nn, kk);
        d2 = pData{llane}{celll}(nn, kk+1);
        dist = sqrt(d1^2 + d2^2 - 2*d1*d2*cos(1));
        P = P + dist;
    end
    mmm(nn-conStart+1) = (4*pi*A)/(P^2);
end

dats(datsIt, 2) = median(mmm);
dats(datsIt, 7) = cData{llane}{celll}(1, 4);
dats(datsIt, 8) = cData{llane}{celll}(floor(conStart+(conEnd-conStart/2)), 4);
%% PostCon
V = (cData{llane}{celll}(:, 9) == currConGap);
[conStart, conEnd] = IdxFinder(V);
conStart = conStart - 1;

clear mmm;
if(conStart < 1 | conEnd == -1)
    dats(datsIt, 3) = NaN;
else
    for nn = conStart:conEnd
        A = cData{llane}{celll}(nn,4);
        P = 0;
        for kk = 1:360
            d1 = pData{llane}{celll}(nn, kk);
            d2 = pData{llane}{celll}(nn, kk+1);
            dist = sqrt(d1^2 + d2^2 - 2*d1*d2*cos(1));
            P = P + dist;
        end
        mmm(nn-conStart+1) = (4*pi*A)/(P^2);
    end
    dats(datsIt, 3) = median(mmm);
end
if(~isnan(dats(datsIt, 2)))
    dats(datsIt, 2) = dats(datsIt, 2) / dats(datsIt, 1);
end
if(~isnan(dats(datsIt, 3)))
    dats(datsIt, 3) = dats(datsIt, 3) / dats(datsIt, 1);
end


%% Circularity Relaxation Rate
V = (cData{llane}{celll}(:, 9) == currConGap);
[conStart, conEnd] = IdxFinder(V);
conStart = conStart - 1;
if(conStart < 1 | conEnd == -1)
    dats(datsIt, 4) = NaN;
else
    mmm = [];
    for nn = conStart:conEnd
        A = cData{llane}{celll}(nn,4);
        P = 0;
        for kk = 1:360
            d1 = pData{llane}{celll}(nn, kk);
            d2 = pData{llane}{celll}(nn, kk+1);
            dist = sqrt(d1^2 + d2^2 - 2*d1*d2*cos(1));
            P = P + dist;
        end
        mmm(nn-conStart+1) = (4*pi*A)/(P^2);
    end
    avgL = smooth(mmm, 3);
    
    maxEdge = avgL(1);
    minEdge = avgL(end);
    
    rate = (minEdge - maxEdge) / ((conEnd-conStart)/fps*1000);%((minEdgeIdx - maxEdgeIdx)/fps*1000);
    dats(datsIt, 4) = abs(rate) / dats(datsIt, 1);
end

%% Len/Wid Relaxation Rate
V = (cData{llane}{celll}(:, 9) == currConGap);
[conStart, conEnd] = IdxFinder(V);
conStart = conStart - 1;
if(conStart < 1 | conEnd == -1)
    dats(datsIt, 5) = NaN;
    dats(datsIt, 6) = NaN;
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
    dats(datsIt, 5) = abs(rate);
    
    avgW = smooth(edgeDists(:, 2), avgRun);
    
    maxEdge = avgW(1);
    minEdge = avgW(end);
    rate = (minEdge - maxEdge) / ((conEnd-conStart)/fps*1000);
    dats(datsIt, 6) = abs(rate);
end