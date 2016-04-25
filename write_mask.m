    
function [imgMasked, imgOut] = write_mask(mask, imgIn)
% use a mask (matrix of same size comprised of natural numbers)
% to 'write over' image: 

%imgMasked is the image in naive grayscale except
% GREEN (0, 0, 255) where mask == 1
% RED   (255, 0, 0) where mask > 1

%imgOut is the original m x n image (on LEFT)
% a m x 16 separation of BLUE (0, 255, 0)
% and then imageMasked on RIGHT

% create RED mask
red_mask = zeros([size(mask), 3]);
to_red = (mask > 0);
red_mask(:, :, 1) = to_red*1024;
red_mask(:, :, 2) = to_red*(-1024);
red_mask(:, :, 3) = to_red*(-1024);

% every element with a 1 will be > 256        
imgGray = rgb2gray(imgIn);
imgMasked = zeros([size(mask), 3]);
imgMasked(:, :, 1) = imgGray;
imgMasked(:, :, 2) = imgGray;
imgMasked(:, :, 3) = imgGray;
imgMasked = imgMasked + red_mask;
% every element in imgMasked will have
% blue and green channel < 0
separation = zeros([size(mask, 1), 8, 3]);
separation(:, :, 3) = 255;

imgOut = uint8([imgIn, separation, imgMasked]);
% every element in imgMasked will be grayscale except where mask has 1s,
end