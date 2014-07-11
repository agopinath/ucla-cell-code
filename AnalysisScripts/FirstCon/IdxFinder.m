function [conStart, conEnd] = IdxFinder(V)

D = diff(V);
b.beg = 1 + find(D == 1);
b.end = find(D == -1);
if V(end)
  b.end(end+1) = numel(V);
end

maxBLen = -1; maxBLenIdx = -1;
for jjk = 1:length(b.beg)
    if (b.end(jjk) - b.beg(jjk)) > maxBLen
        maxBLen = (b.end(jjk) - b.beg(jjk));
        maxBLenIdx = jjk;
    end
end

if(maxBLenIdx == -1) 
    conStart = -1;
    conEnd = -1;
else
    conStart = b.beg(maxBLenIdx);
    conEnd = b.end(maxBLenIdx);
end
end

