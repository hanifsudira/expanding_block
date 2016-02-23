function imgOut = write_mask(mask, img_gray_full)
% use a mask (matrix of same size comprised of zeros and ones)
% to 'write over' grayscale image with RED (255, 0, 0) where mask has ones
    red_mask = zeros([size(mask), 3]);
    red_mask(:, :, 1) = mask*512;          
    % every element with a 1 will be > 512
    red_mask(:, :, 2) = -(mask*512);
    red_mask(:, :, 3) = -(mask*512);        
    % every element with a 1 will be < -256
    
    imgOut = zeros([size(mask), 3]);
    imgOut(:, :, 1) = img_gray_full;
    imgOut(:, :, 2) = img_gray_full;
    imgOut(:, :, 3) = img_gray_full;
    imgOut = imgOut + red_mask;
    % every element in imgOut will have red channel > 255,
    % blue and green channel < 0
    
    imgOut = uint8(imgOut);
    % every element in imgOut will be grayscale except where mask has 1s,
end