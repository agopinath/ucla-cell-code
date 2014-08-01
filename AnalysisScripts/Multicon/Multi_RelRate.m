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
    jjj = (currCon + .75);
    %% RELAXATION
    V = (cData{llane}{celll}(:, 9) == jjj);
    [conStart, conEnd] = IdxFinder(V);
    conStart = conStart - 1;
    
    if(conStart < 1 | conEnd == -1)
        dats(datsIt, 5) = NaN;
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
        
        maxEdge = avg(1);
        minEdge = avg(end);
        
        rate = (minEdge - maxEdge) / ((conEnd-conStart)/fps*1000);%((minEdgeIdx - maxEdgeIdx)/fps*1000);
        dats(datsIt, currCon) = abs(rate);
    end
end