%% Cross Correlation Testing

% Load the input image and the template
temp = imread('C:\Users\Mike\Desktop\Masking\mask.tif');
frame = imread('C:\Users\Mike\Desktop\Masking\video.tif');
template = temp(:,:,1);

% Perform the cross correlation
cc = normxcorr2(template,frame);  
[max_cc, imax] = max(abs(cc(:)));
[ypeak, xpeak] = ind2sub(size(cc),imax(1));
corr_offset = [ (ypeak-size(template,1)) (xpeak-size(template,2)) ];

% Preallocate an array of the size of the template, and then move the
% corresponding (correlated) pixels from the frame into the array
newFrame = uint8(zeros(size(template)));
% xx is the number of columns (x values)
for xx = 1:size(newFrame,2)
   % yy is the number of rows (y values)
   for yy = 1: size(newFrame,1)
       newFrame(yy,xx) = frame(yy+corr_offset(1),xx+corr_offset(2));
   end
end

figure(1)
imshow(newFrame)
figure(2)
imshow(template)

for xx = 1:size(newFrame,2)
   % yy is the number of rows (y values)
   for yy = 1: size(newFrame,1)
       if template(yy,xx) == 255
          template(yy,xx) = 1; 
       else
           template(yy,xx) = 0;
       end
   end
end 

newFrame2 = template(:,:,1).*newFrame;
figure(3)
imshow(newFrame2)

imwrite(newFrame2,'C:\Users\Mike\Desktop\Masking\maskedvideo.tif','tif','Compression','none');