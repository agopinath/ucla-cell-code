numCons = 8; % number of constrictions; leave at 8 by default
dbstop if error
%celll = 1; llane = 2;
%relDats = [];

widthEdgeAngle1 = pi/2; widthEdgeAngle2 = 3*pi/2; 
lengthEdgeAngle1 = 0; lengthEdgeAngle2 = pi;

avgRun = 3;
usePercent = true;

currCon = 2;
%numSamples = 10; % num of frames to include in graph of frame # vs defidx

% if(useCellSize)
%     if(cData{llane}{celll}(1, 4) < 150)
%         defIdxs(defIdxIt, :) = NaN;
%         return;
%     end
%     if(cData{llane}{celll}(1, 4) > 240)
%         defIdxs(defIdxIt, :) = NaN;
%         return;
%     end
% end

allDegs = (1:361)*pi/180;

[delta, thetaWidthIdx1] = min(abs(allDegs-widthEdgeAngle1));
[delta, thetaWidthIdx2] = min(abs(allDegs-widthEdgeAngle2));
[delta, thetaLengthIdx1] = min(abs(allDegs-lengthEdgeAngle1));
[delta, thetaLengthIdx2] = min(abs(allDegs-lengthEdgeAngle2));

baseHeight = pData{llane}{celll}(1, thetaLengthIdx1) +  pData{llane}{celll}(1, thetaLengthIdx2);
baseWidth = pData{llane}{celll}(1, thetaWidthIdx1) + pData{llane}{celll}(1, thetaWidthIdx2);

if(cData{llane}{celll}(end, 9) < 8)
    return
end

%conStart = find(cData{llane}{celll}(:, 9) == currCon, 1, 'first');
conEnd = find(cData{llane}{celll}(:, 9) == (currCon+.5), 1, 'first')-1;
edgeDists = [];
avg = [];

%enterIdx = size(defIdxs, 1) + 1;
for j = conEnd:conEnd+numSamples
    jIdx = j-conEnd+1;
    %if isempty(pData{llane}{celll}{j})
    if isempty(pData{llane}{celll})
        continue;
    end
    
    %edgeDists(jIdx) = pData{llane}{celll}{j}(thetaIdx, 2);
    if(j > size(pData{llane}{celll}, 1))
        return;
    end
   defLength = pData{llane}{celll}(j, thetaLengthIdx1) +  pData{llane}{celll}(j, thetaLengthIdx2);
   defWidth = pData{llane}{celll}(j, thetaWidthIdx1) + pData{llane}{celll}(j, thetaWidthIdx2);
   defIdx = defLength/defWidth;
    
   defIdxs(defIdxIt, jIdx) = defIdx;
end

% for currCon = 2:8
%     conStart = find(cData{llane}{celll}(:, 9) == currCon, 1, 'first');
%     conEnd = find(cData{llane}{celll}(:, 9) == currCon, 1, 'last');
%     edgeDists = [];
%     avg = [];
%     enterIdx = size(defIdxs, 1) + 1;
%     for j = conEnd:conEnd+10
%         jIdx = j-conStart+1;
%         %if isempty(pData{llane}{celll}{j})
%         if isempty(pData{llane}{celll})
%             continue;
%         end
%         %edgeDists(jIdx) = pData{llane}{celll}{j}(thetaIdx, 2);
%         edgeDists(jIdx) = pData{llane}{celll}(j, thetaIdx);
%         if usePercent == true
%             edgeDists(jIdx) = (edgeDists(jIdx)-base)/base*100;
%         end
%         
%         
%         relDats(enterIdx, j-conEnd+1) = 
%     end
%     
%     
% end