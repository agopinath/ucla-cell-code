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
    
    %% CREEP
    
    V = (cData{llane}{celll}(:, 9) == jjj);
    [conStart, conEnd] = IdxFinder(V);
    conEnd = conEnd + 1;
    conEnd = min(length(cData{llane}{celll}), conEnd);
    
    if(conStart == -1 | conEnd == -1)
        dats(datsIt, currCon) = NaN;
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
        
        for j = 1:min(length(avg), numSamples)
            dats(datsIt, j) = avg(j);
        end
        if min(length(avg), numSamples) < numSamples
            dats(datsIt, length(avg)+1:numSamples) = NaN;
        end
    end
end