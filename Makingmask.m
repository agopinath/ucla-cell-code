%%% Code to generate mask of channels
%%% BAV 08/26/2011

function Premask = Makingmask(img)

B=img;
level = graythresh(B);
BW = im2bw(B,level);
% figure(100);
% imshow(BW);

CleanBW  = bwareaopen(BW,200); %% Remove stray pixels 200 original
% figure(101);
% imshow(CleanBW);

Imagewithborder = addborder(CleanBW, 1, 62, 'inside');
% % % % % % ADDBORDER(IMG, T, C, S) adds a border to the image IMG with
% % % % % % %    thickness T, in pixels. C specifies the color, and should be in the
% % % % % % %    same format as the image itself. STROKE is a string indicating the
% % % % % % %    position of the border:
% % % % % % %       'inner'  - border is added to the inside of the image. The dimensions
% % % % % % %                  of OUT will be the same as IMG.
% % % % % % %       'outer'  - the border sits completely outside of the image, and does
% % % % % % %                  not obscure any portion of it.
% % % % % % %       'center' - the border straddles the edges of the image.
% figure(102);
% imshow(Imagewithborder);

Additions=xor(Imagewithborder,CleanBW);
% figure(103);
% imshow(Additions);

Thesidebigones  = bwareaopen(Additions,200); %% Remove the side big ones
% figure(104);
% imshow(Thesidebigones);

AdditonsReduce=Additions-Thesidebigones;
% figure(105);
% imshow(AdditonsReduce);

AdditonsReduce=bwareaopen(AdditonsReduce,10); %% Remove stray pixels 200 original
% figure(106);
% imshow(AdditonsReduce);

[L, num] = bwlabel(AdditonsReduce,4);
rgb = label2rgb(L,'jet',[.5 .5 .5]);
% figure(107), imshow(rgb,'InitialMagnification','fit')
% title('Label of D')

[r3, c3] = find(L==3);
[r4, c4] = find(L==4);

[r7, c7] = find(L==7);
[r8, c8] = find(L==8);

[r11, c11] = find(L==11);
[r12, c12] = find(L==12);

[r15, c15] = find(L==15);
[r16, c16] = find(L==16);

[r19, c19] = find(L==19);
[r20, c20] = find(L==20);

[r23, c23] = find(L==23);
[r24, c24] = find(L==24);

[r27, c27] = find(L==27);
[r28, c28] = find(L==28);

R=[r3;r4;r7;r8;r11;r12;r15;r16;r19;r20;r23;r24;r27;r28];
C=[c3;c4;c7;c8;c11;c12;c15;c16;c19;c20;c23;c24;c27;c28];

for i=1:length(R)
AdditonsReduce(R(i),C(i))=0;
end
% figure(108);
% imshow(AdditonsReduce); %%%% Plugs to close channels

Closedchannels=imadd(AdditonsReduce,CleanBW);
% figure(109);
% imshow(Closedchannels);
% 
% Closedchannelsdilate= bwmorph(Closedchannels,'dilate',1);
% figure;
% imshow(Closedchannelsdilate);
% 
FilledChannels = imfill(Closedchannels,'holes');
% figure(110), imshow(FilledChannels);

% FilledChannels1 = bwmorph(FilledChannels,'majority',1);
% figure, imshow(FilledChannels1);

% % %%%% At this point you have the outer channels clearly

Innerchannelstemplate=1-FilledChannels;
% figure(111), imshow(Innerchannelstemplate);

Innerchannelstemplate  = bwareaopen(Innerchannelstemplate,10); %% Remove stray pixels 200 original
% figure(112),imshow(Innerchannelstemplate);

[L1, num1] = bwlabel(Innerchannelstemplate,8);

[rleftmost, cleftmost] = find(L1==1);
[rrightmost, crightmost] = find(L1==9);

Rsub=[rleftmost;rrightmost];
Csub=[cleftmost;crightmost];

for j=1:length(Rsub)
Innerchannelstemplate(Rsub(j),Csub(j))=0;
end
% figure(113);
% imshow(Innerchannelstemplate); %%%% Plugs to close channels

[Rosub, Cosub] = find(Innerchannelstemplate);

for k=1:length(Rosub)
FilledChannels(Rosub(k),Cosub(k))=0;
end
% figure(114);
% imshow(FilledChannels);

for k=1:length(Rosub)
FilledChannels(Rosub(k),Cosub(k))=0;
end
% figure(115);
% imshow(FilledChannels);
% 
%%% Final mask

Premask=bwmorph(FilledChannels,'erode',0);
mask=1-Premask;
% figure(116);
% imshow(mask);


%%%% Checking the mask

[Rocheck, Cocheck] = find(mask);

for l=1:length(Rocheck)
B(Rocheck(l),Cocheck(l))=0;
end
% figure(117);
% imshow(B);

% % % % FilledChannels1 = imfill(CleanBW,'holes');
% % % % figure, imshow(FilledChannels1);
% % % 
% % % % [L, num] = bwlabel(FilledChannels1,4);
% % % % rgb = label2rgb(L,'jet',[.5 .5 .5]);
% % % % figure, imshow(rgb,'InitialMagnification','fit')
% % % % title('Label of FilledChannels1');
% % % 
% % % % Erodedimage=bwmorph(FilledChannels,'erode',15);
% % % % figure, imshow(Erodedimage);

    






