clear xs; clear ys;
dbstop if error
consNum = 8;
%maxEdgeAngle = 0; % degrees, in rads, from theta=0 aligning with north, of max edge
avgRun = 2;
usePercent = true;
if(cData{llane}{celll}(end, 9) < 7) %...
   %||(cData{llane}{celll}(1, 4) < 170 ||  cData{llane}{celll}(1, 4) > 260))
    dats(datsIt, :) = NaN;
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
[delta, thetaLengthIdx1] = min(abs(allDegs-pi/2));
[delta, thetaLengthIdx2] = min(abs(allDegs-3*pi/2));

baseHeight = pData{llane}{celll}(1, thetaLengthIdx1) +  pData{llane}{celll}(1, thetaLengthIdx2);
%base = pData{llane}{celll}(1, thetaIdx);

conStart = find(cData{llane}{celll}(:, 9) == 4, 1, 'first');
conEnd = find(cData{llane}{celll}(:, 9) == 4, 1, 'last');

if(isempty(conEnd) || isempty(conStart))
    return;
end
conEdgeDists = [];
avg = [];
for j = conStart:conEnd
    jIdx = j-conStart+1;
    conEdgeDists(jIdx) = pData{llane}{celll}(j, thetaLengthIdx1) +  pData{llane}{celll}(j, thetaLengthIdx2);
    avg(jIdx) = conEdgeDists(jIdx);
    
    if usePercent == true
        conEdgeDists(jIdx) = (avg(jIdx)-baseHeight)/baseHeight*100;
    end
end

dats(datsIt, 1) = length(find(cData{llane}{celll}(:, 9) == 2))/fps*1000;
dats(datsIt, 2) = size(cData{llane}{celll}, 1)/fps*1000;
dats(datsIt, 3) = baseHeight;

maxEdge = max(conEdgeDists);
if(isempty(maxEdge))
    dats(datsIt, 4) = nan;
    return;
end
dats(datsIt, 4) = maxEdge;
dats(datsIt, 5) = maxEdge/100*baseHeight+baseHeight;

conStart = find(cData{llane}{celll}(:, 9) == 2.5, 1, 'first');
conEnd = find(cData{llane}{celll}(:, 9) == 3, 1, 'first');
if(isempty(conStart) || isempty(conEnd))
    dats(datsIt, 6) = nan;
    return;
end
edgeDists = [];
avg = [];
for j = conStart:conEnd
    jIdx = j-conStart+1;
    %if isempty(pData{llane}{celll}{j})
    if isempty(pData{llane}{celll})
        continue;
    end
    %edgeDists(jIdx) = pData{llane}{celll}{j}(thetaIdx, 2);
    edgeDists(jIdx) = pData{llane}{celll}(j, thetaLengthIdx1) +  pData{llane}{celll}(j, thetaLengthIdx2);
    avg(jIdx) = edgeDists(jIdx);
    if usePercent == true
        edgeDists(jIdx) = (avg(jIdx)-baseHeight)/baseHeight*100;
    end
end

minEdgeIdx = find(conEdgeDists == min(conEdgeDists));
if(size(minEdgeIdx, 2) > 1)
    minEdgeIdx = minEdgeIdx(1);
end

if(minEdgeIdx == 0) % if not found, skip this constriction and store a NaN
    dats(datsIt, 6) = NaN;
end

maxEdgeIdx = find(conEdgeDists(minEdgeIdx+1:end) == max(conEdgeDists(minEdgeIdx+1:end)));
if(isempty(maxEdgeIdx) | maxEdgeIdx == 0) % if not found, skip this constriction and store a NaN
    dats(datsIt, 6) = NaN;
end

if(size(maxEdgeIdx, 2) > 1)
    maxEdgeIdx = maxEdgeIdx(1);
end

maxEdgeIdx = maxEdgeIdx + minEdgeIdx;

maxEdge = conEdgeDists(maxEdgeIdx);
minEdge = conEdgeDists(minEdgeIdx);

rate = (maxEdge - minEdge) / ((maxEdgeIdx - minEdgeIdx)/fps*1000);
dats(datsIt, 6) = rate;

% useMin = false;
% % if(mean(edgeDists) < 0)
% %     useMin = false;
% % end
% 
% if(useMin)
%     relaxedEdgeR = min(edgeDists);
% else
%     relaxedEdgeR = max(edgeDists);
% end
relaxedEdgeR = min((edgeDists));

if(isempty(relaxedEdgeR))
    dats(datsIt, 7) = NaN;
else 
    dats(datsIt, 7) = relaxedEdgeR;
end
dats(datsIt, 8) =  log(dats(datsIt, 1)) / log(dats(datsIt, 3));
dats(datsIt, 9) = cData{llane}{celll}(1, 4);