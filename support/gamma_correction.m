function [lab img1] = gamma_correction(rgb)
cform = makecform('srgb2lab');

rgbImage=rgb;
[X] = rgbImage;
I(:,:,1) = imadjust(rgbImage(:,:,1));
I(:,:,2) = imadjust(rgbImage(:,:,2));
I(:,:,3) = imadjust(rgbImage(:,:,3));
img1=I;
lab = applycform(rgb,cform);