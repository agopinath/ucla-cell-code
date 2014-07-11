clear xs; clear ys;
dbstop if error
usePercent = true;
if(cData{llane}{celll}(end, 9) < 7)
    return
end
allDegs = (1:361)*pi/180;

frameCount = length(pData{llane}{celll});

[delta, thetaLengthIdx1] = min(abs(allDegs-0));
[delta, thetaLengthIdx2] = min(abs(allDegs-pi));

baseHeight = pData{llane}{celll}(1, thetaLengthIdx1) +  pData{llane}{celll}(1, thetaLengthIdx2);

%% FIND LONGEST CONTIGUOUS 2.5 BLOCK
avgRun = 3;
dats{1}(datsIt, 8) = cData{llane}{celll}(1, 4); 
dats{1}(datsIt, 9) = baseHeight;
dats{2}(datsIt, 8) = cData{llane}{celll}(1, 4); 
dats{2}(datsIt, 9) = baseHeight;
dats{3}(datsIt, 8) = cData{llane}{celll}(1, 4); 
dats{3}(datsIt, 9) = baseHeight;
for i = 2:8
    currCon = i - 1;
    conStart = find(cData{llane}{celll}(:, 9) == i, 1, 'first');
    conEnd = find(cData{llane}{celll}(:, 9) == i, 1, 'last');
    
    if(isempty(conEnd) || isempty(conStart))
        return;
    end
    edgeDists = [];
    avg = [];
    pos = zeros(1, conEnd-conStart+1);
    for j = conStart:conEnd
        jIdx = j-conStart+1;
        edgeDists(jIdx) = pData{llane}{celll}(j, thetaLengthIdx1) +  pData{llane}{celll}(j, thetaLengthIdx2);
        avg(jIdx) = edgeDists(jIdx);
        
        if usePercent == true
            edgeDists(jIdx) = (avg(jIdx)-baseHeight)/baseHeight*100;
        end
        pos(jIdx) = cData{llane}{celll}(j, 3);
    end
    
    maxEdge = max(edgeDists);
    if(isempty(maxEdge))
        datsLen(datsIt, currCon) = nan;
        return;
    end
    datsLen(datsIt, currCon) = maxEdge;
    
    pos = smooth(pos, avgRun)';

    mm = pos(1);
    for k = length(pos):-1:3
        pos(k) = (pos(k) - pos(k-1));
    end
    if(length(pos) == 1)
        datsVels(datsIt, currCon) = nan;
        continue;
    end
    pos(2) = pos(2) - pos(1);
    pos(1) = pos(2); % get rid of sudden "jump" from unknown initial velocity
    pos = pos*fps/1000; % convert from um/frame to um/ms
    maxVel = max(pos);
    datsVels(datsIt, currCon) = maxVel/datsLen(datsIt, 8);
end

