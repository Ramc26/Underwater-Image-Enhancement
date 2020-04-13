

A = imread('image4.png');
figure
imshow(A,'InitialMagnification',25)
title('Original Image')

x = 2800;
y = 1000;
gray_val = [A(y,x,1) A(y,x,2) A(y,x,3)];

B = chromadapt(A,gray_val);


figure
imshow(B,'InitialMagnification',25)
title('White-Balanced Image')