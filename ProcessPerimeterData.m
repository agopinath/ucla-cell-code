function [pcoords] = ProcessPerimeterData(currCell)
    numPts = size(currCell.BoundaryPoints, 1);
    pcoords = zeros(numPts, 2);
    normX = currCell.BoundaryPoints(:, 1)-currCell.Centroid(1);
    normY = currCell.BoundaryPoints(:, 2)-currCell.Centroid(2);
    [theta, r] = cart2pol(normX, normY);
    pcoords(:, 1) = -theta; % store angle after converting it to degrees
                            % and negating to orient it properly
    pcoords(:, 2) = r; % store polar radii length
    pcoords(:,1) = -pcoords(:,1) + (pi/2);
    
    rth = pcoords;
    rth(rth(:,1)<0,1) = (2*pi) + rth(rth(:,1)<0,1);
    rth(end, :) = [];
    rth = sortrows(rth, 1);
    pts = 0:(pi/180):(2*pi);
    
    [n, bin] = histc(rth(:,1), unique(rth(:,1)));
    multiple = find(n > 1);
    dupAngles = find(ismember(bin, multiple));
    
    if(~isempty(dupAngles))
        for dupIdx = 2:length(dupAngles)
            rndOffset = 0.25*((2*pi)/size(rth, 1))+(rand()/10);
            rth(dupAngles(dupIdx), 1) = rth(dupAngles(dupIdx), 1) + rndOffset;
        end
    end
    
    mm = interp1(rth(:,1), rth(:,2), pts);
    pcoords = zeros(length(pts), 2);
    pcoords(:,1) = pts;
    pcoords(:,2) = mm;
    %pcoords = pcoords(~any(isnan(pcoords),2),:);

    firstHalfNans = find(isnan(pcoords(1:180,2)));
    secHalfNans = find(isnan(pcoords(181:end,2)));
    hasNansFirst = length(firstHalfNans) > 0;
    hasNansSec = length(secHalfNans) > 0;

    if(hasNansFirst || hasNansSec)
        if(hasNansFirst && hasNansSec)
            firstNan = firstHalfNans(end);
            secNan = secHalfNans(1) + 180;
        elseif(hasNansFirst)
            firstNan = firstHalfNans(end);
            secNan = size(pcoords, 1);
        elseif(hasNansSec)
            firstNan = 1;
            secNan = secHalfNans(1) + 180;
        end

        edgeThetas = [pcoords(secNan-1, 1)-(2*pi), pcoords(firstNan+1, 1)];
        edgeRs = [pcoords(secNan-1, 2), pcoords(firstNan+1, 2)];

        mm = interp1(edgeThetas, edgeRs, pcoords(1:firstNan,1));
        pcoords(1:firstNan, 2) = mm;
        mm = interp1(edgeThetas, edgeRs, (pcoords(secNan:end,1)-(2*pi)));
        pcoords(secNan:end, 2) = mm;
    end
end

