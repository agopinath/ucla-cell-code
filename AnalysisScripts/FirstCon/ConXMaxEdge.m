clear xs; clear ys;

consNum = 8;
%maxEdgeAngle = 0; % degrees, in rads, from theta=0 aligning with north, of max edge
avgRun = 2;
usePercent = true;
if(cData{llane}{celll}(end, 9) < 7 ...
   ||(cData{llane}{celll}(1, 4) < 170 ||  cData{llane}{celll}(1, 4) > 260))
    maxExt(maxExtIt, :) = NaN;
    return
end
allDegs = (1:361)*pi/180;

% UNCOMMENT BELOW FOR SINGLE CELL RUN
% llane = 11; celll = 1;
% maxExt = zeros(2, 7);
% maxExtIt = 1;
%
frameCount = length(pData{llane}{celll});
%[delta, thetaIdx] = min(abs(pData{llane}{celll}{1}(:,1)-maxEdgeAngle));
%base = pData{llane}{celll}{1}(thetaIdx, 2);

%[delta, thetaIdx] = min(abs(allDegs-maxEdgeAngle));
[delta, thetaLengthIdx1] = min(abs(allDegs-0));
[delta, thetaLengthIdx2] = min(abs(allDegs-pi));

baseHeight = pData{llane}{celll}(1, thetaLengthIdx1) +  pData{llane}{celll}(1, thetaLengthIdx2);
%base = pData{llane}{celll}(1, thetaIdx);

for currCon = 2:8
    conStart = find(cData{llane}{celll}(:, 9) == currCon, 1, 'first');
    conEnd = find(cData{llane}{celll}(:, 9) == currCon, 1, 'last');
    
    edgeDists = [];
    avg = [];
    for j = conStart:conEnd
        jIdx = j-conStart+1;
        %edgeDists(jIdx) = pData{llane}{celll}{j}(thetaIdx, 2);
        edgeDists(jIdx) = pData{llane}{celll}(j, thetaLengthIdx1) +  pData{llane}{celll}(j, thetaLengthIdx2);
        %pData{llane}{celll}(j, thetaIdx);
        avg(jIdx) = edgeDists(jIdx);
        
        if usePercent == true
            edgeDists(jIdx) = (avg(jIdx)-baseHeight)/baseHeight*100;
        end
    end
    
    maxEdge = max(edgeDists);
    if(isempty(maxEdge))
        maxExt(maxExtIt, currCon-1) = nan;
        return;
    end
    maxExt(maxExtIt, currCon-1) = maxEdge;
end

%figure; boxplot(maxExt)

1+1;
