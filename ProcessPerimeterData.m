function [pcoords] = ProcessPerimeterData(currCell)
    %% Convert boundary points data to polar coords
    numPts = size(currCell.BoundaryPoints, 1);
    pcoords = zeros(numPts, 2);
    normX = currCell.BoundaryPoints(:, 1)-currCell.Centroid(1);
    normY = currCell.BoundaryPoints(:, 2)-currCell.Centroid(2);
    [theta, r] = cart2pol(normX, normY);
    
    pcoords(:, 1) = -theta; % store angles after converting it to degrees
                            % and negating to orient it properly
    pcoords(:, 2) = r; % store polar radii length
    
    % orient data with y-axis by converting angles into compass direction
    % (theta=0 is aligned with y-axis and angle increases move clockwise)
    pcoords(:,1) = -pcoords(:,1) + (pi/2);
    
    %% Temporary vector rth to hold processed angle data
    rth = pcoords;
    
    % add 2*pi radians to all angles less than 0 radians to make positive
    rth(rth(:,1)<0,1) = (2*pi) + rth(rth(:,1)<0,1); 
    % remove last entry because it is the same as the first
    rth(end, :) = [];
    % order rows by angle (theta), where 0 rads < theta < 2*pi rads
    rth = sortrows(rth, 1);
    
    %% Handle duplicate angle entries by adding random offset
    [n, bin] = histc(rth(:,1), unique(rth(:,1)));
    multiple = find(n > 1);
    dupAngles = find(ismember(bin, multiple));
    
    if(~isempty(dupAngles))
        for dupIdx = 2:length(dupAngles)
            rndOffset = 0.25*((2*pi)/size(rth, 1))+(rand()/10);
            rth(dupAngles(dupIdx), 1) = rth(dupAngles(dupIdx), 1) + rndOffset;
        end
    end
    
    %% Interpolate angles between min(theta) and max(theta)
    pts = 0:(pi/180):(2*pi);
    mm = interp1(rth(:,1), rth(:,2), pts);
    pcoords = zeros(length(pts), 2);
    pcoords(:,1) = pts;
    pcoords(:,2) = mm;
    
    %% Interpolate angles between 0 to min(theta), and max(theta) to 2*PI radians
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

