clc
clear all;
close all;

addpath('support')
warning off

%%% selection of input 

cd underwater_images
[J P]=uigetfile('*.*','Select an Input Image');

img=imread(strcat(P,J));
cd ..
img=imresize(img,[256 256]);
figure,imshow(img),title('Input Image')


% white balance
img = wbalance(img);

figure,imshow(img),title('White Balance')

%%% gamma correction

[lab1 img1] = gamma_correction(img);


% optimized contrast enhancement method

low = 0.2;
high = 0.9;
img1 = imadjust(img1,[low high],[]);
figure,imshow(img1)
figure,imshow(img1),title('Gamma Correction')

%%% sharpening image

img2 = imsharpen(img1);
img2 = uint8(img2);
lab2 = rgb_to_lab(img2);
figure,imshow(img2);title('Shapned Image')

% input1
R1 = double(lab1(:, :, 1)) / 255;
% calculate laplacian contrast weight
WL1 = abs(imfilter(R1, fspecial('Laplacian'), 'replicate', 'conv'));
figure,imshow(WL1),title('Laplacian')

%calculate Luminance weight
WC1 = sqrt(((double(img1(:,:,1))/255 - double(R1)).^2 + ...
            (double(img1(:,:,2))/255 - double(R1)).^2 + ...
            (double(img1(:,:,3))/255 - double(R1)).^2) / 3);
% calculate the saliency weight
WS1 = saliency_detection(img1);
figure,imshow(WS1,[]),title('saliency 1')
% calculate the exposedness weight for saturation
sigma = 0.25;
aver = 0.5;
WE1 = exp(-(R1 - aver).^2 / (2*sigma^2));
figure,imshow(WE1,[]),title('saturation')
% input2
R2 = double(lab2(:, :, 1)) / 255;
% calculate laplacian contrast weight
WL2 = abs(imfilter(R2, fspecial('Laplacian'), 'replicate', 'conv'));
%calculate Luminance weight
WC2 = sqrt(((double(img2(:,:,1))/255 - double(R2)).^2 + ...
            (double(img2(:,:,2))/255 - double(R2)).^2 + ...
            (double(img2(:,:,3))/255 - double(R2)).^2) / 3);
% calculate the saliency weight
WS2 = saliency_detection(img2);
figure,imshow(WS2,[]),title('saliency 2')
% calculate the exposedness weight for saturation
sigma = 0.25;
aver = 0.5;
WE2 = exp(-(R2 - aver).^2 / (2*sigma^2));
figure,imshow(WE2,[]),title('saturation 2')
% calculate the normalized weight
W1 = (WL1 + WC1 + WS1 + WE1) ./ ...
     (WL1 + WC1 + WS1 + WE1 + WL2 + WC2 + WS2 + WE2);
W2 = (WL2 + WC2 + WS2 + WE2) ./ ...
     (WL1 + WC1 + WS1 + WE1 + WL2 + WC2 + WS2 + WE2);
%W1 = (WC1 + WS1 + WE1) ./ ...
%     (WC1 + WS1 + WE1 + WC2 + WS2 + WE2);
%W2 = (WC2 + WS2 + WE2) ./ ...
%     (WC1 + WS1 + WE1 + WC2 + WS2 + WE2);
figure,imshow(W1,[]);title('Normalized Weight1')
figure,imshow(W2,[]);title('Normalized Weight2')

% calculate the gaussian pyramid
level = 5;
Weight1 = gaussian_pyramid(W1, level);
Weight2 = gaussian_pyramid(W2, level);

% calculate the laplacian pyramid
% input1
R1 = laplacian_pyramid(double(double(img1(:, :, 1))), level);
G1 = laplacian_pyramid(double(double(img1(:, :, 2))), level);
B1 = laplacian_pyramid(double(double(img1(:, :, 3))), level);
% input2
R2 = laplacian_pyramid(double(double(img2(:, :, 1))), level);
G2 = laplacian_pyramid(double(double(img2(:, :, 2))), level);
B2 = laplacian_pyramid(double(double(img2(:, :, 3))), level);

% fusion
for i = 1 : level
   R_r{i} = Weight1{i} .* R1{i} + Weight2{i} .* R2{i};
   R_g{i} = Weight1{i} .* G1{i} + Weight2{i} .* G2{i};
   R_b{i} = Weight1{i} .* B1{i} + Weight2{i} .* B2{i};
end

% reconstruct & output
R = pyramid_reconstruct(R_r);
G = pyramid_reconstruct(R_g);
B = pyramid_reconstruct(R_b);
fusion = cat(3, uint8(R), uint8(G), uint8(B));

figure, imshow(fusion),title('Fused Image')
