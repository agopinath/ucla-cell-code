%% Cross Correlation Testing

% Load the input image and the template
template = imread(C:\Users\Mike\Desktop\Masking\mask.png);
frame = imread(C:\Users\Mike\Desktop\Masking\video.tif);

% Perform the cross correlation
cc = normxcorr2(BW,offsetTemplate); 
cc = normxcorr2(BW,offsetTemplate); 
[max_cc, imax] = max(abs(cc(:)));
[ypeak, xpeak] = ind2sub(size(cc),imax(1));
corr_offset = [ (ypeak-size(template,1)) (xpeak-size(template,2)) ];
isequal(corr_offset,offset) % 1 means offset was recovered