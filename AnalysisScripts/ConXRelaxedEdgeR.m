clear xs; clear ys;
dbstop if error
consNum = 8;
edgeAngle = pi/2; % degrees, in rads, from theta=0 aligning with north, of edge to analyze
avgRun = 2;
usePercent = true;
allDegs = (1:361)*pi/180;

% UNCOMMENT BELOW FOR SINGLE CELL RUN
% llane = 5; celll = 1;
% extDists = zeros(1, 7);
% extDistIt = 1;
%
frameCount = length(pData{llane}{celll});
%[delta, thetaIdx] = min(abs(pData{llane}{celll}{1}(:,1)-edgeAngle));
%base = pData{llane}{celll}{1}(thetaIdx, 2);

% [delta, thetaLengthIdx1] = min(abs(allDegs-pi/2));
% [delta, thetaLengthIdx2] = min(abs(allDegs-3*pi/2));
[delta, thetaLengthIdx1] = min(abs(allDegs-0));
[delta, thetaLengthIdx2] = min(abs(allDegs-pi));

baseHeight = pData{llane}{celll}(1, thetaLengthIdx1) + pData{llane}{celll}(1, thetaLengthIdx2);

[delta, thetaIdx] = min(abs(allDegs-edgeAngle));
base = pData{llane}{celll}(1, thetaIdx);

for currCon = 2:2
    conStart = find(cData{llane}{celll}(:, 9) == currCon+1, 1, 'first');
    conEnd = find(cData{llane}{celll}(:, 9) == currCon, 1, 'last');
    
    edgeDists = [];
    avg = [];
    for j = conEnd:conStart
        jIdx = j-conEnd+1;
        %edgeDists(jIdx) = pData{llane}{celll}{j}(thetaIdx, 2);
        edgeDists(jIdx) = pData{llane}{celll}(j, thetaLengthIdx1) + pData{llane}{celll}(j, thetaLengthIdx2);
        avg(jIdx) = edgeDists(jIdx);
%         if (jIdx > avgRun)
%             avg(jIdx) = avg(jIdx-1) - avg(jIdx-avgRun)/avgRun + avg(jIdx)/avgRun;
%         end
        if usePercent == true
            edgeDists(jIdx) = (avg(jIdx)-baseHeight)/baseHeight*100;
        end
    end
    
    useMin = true;
%     if(mean(edgeDists) < 0)
%         useMin = false;
%     end
    
    if(useMin)
        relaxedEdgeR = min(edgeDists);
    else
        relaxedEdgeR = max(edgeDists);
    end
    if(isempty(relaxedEdgeR))
        extDists(extDistIt, currCon-1) = NaN;
        continue;
    end
    %signedRelaxedEdgeR = edgeDists(relaxedEdgeIdx);
    extDists(extDistIt, currCon-1) = relaxedEdgeR;
end

%figure; boxplot(extDists)

1+1;
