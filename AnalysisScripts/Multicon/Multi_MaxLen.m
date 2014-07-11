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

baseHeight = pData{llane}{celll}(1, thetaLengthIdx1) +  pData{llane}{celll}(1, thetaLengthIdx2);
baseTrailingEdge = pData{llane}{celll}(1, thetaLengthIdx1);
baseLeadingEdge = pData{llane}{celll}(1, thetaLengthIdx2);

for currCon = 1:consNum
    % Get max extension
    jjj = (currCon + .25);

    % conStart = find(cData{llane}{celll}(:, 9) == creepRegion, 1, 'first');
    % conEnd = find(cData{llane}{celll}(:, 9) == currCon, 1, 'last');
    V = (cData{llane}{celll}(:, 9) == jjj);
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

    maxEdge = max(avg);
    if(isempty(maxEdge))
        dats(datsIt, currCon) = NaN;
    else
        dats(datsIt, currCon) = maxEdge;
    end
end