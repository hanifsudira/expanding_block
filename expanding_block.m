function [subBlock, block] = expanding_block_01(imIn, varargin)
% an expanding block algorithm to detect copy-paste duplication within
% an image
%% input and output
%{
    imIn: an RGB image, either as an mxnx3 array or a string
    varargin: an expand_block_init OBJECT: parameters described in expanding_block_init.m.    
%}


%%  0 input handling:
imIn = import_image(imIn);

% grayscale image and trim so that blockDistance / blockSize

if size(imIn, 3) == 3
    im_gray_full = rgb2gray(imIn);
elseif size(imIn, 3) == 1
    warning('Image only has single channel: treating as grayscale');
    im_gray_full = imIn;
else
    error('Image not RGB or single-channel')
end

assert(nargin <= 2, 'at most one varargin')

if nargin == 2
    init = varargin{1};
else
    init = expand_block_init;
end
overScan = mod(size(im_gray_full), init.blockDistance);

% hold extra pixels for reconstruction later:
extraPixels = im_gray_full( (end-overScan(1)) : end , (end-overScan(2)):end);

% trim
img = im_gray_full( 1:end-(overScan(1)), 1:(end-overScan(2)) );

%% 1: Divide an image into small overlapping blocks of blockSize^2


%{
EFRON'S METHOD: 
% construct blockDistance x blockDistance subBlocks
%}
subBlock = img_to_subBlocks(img, init);


block = quad_overlap(subBlock);     


%{
TAYLOR'S METHOD:
?
%}

%% 2. For each block, compute the average gray value as dominnt feature

% We also compute variance
[avg_gray, variance] = block_variance(block);



%% 3. Sort the blocks based on the dominant feature
%{ 
ENHANCED EXPANDING BLOCK ALGORITHM

    leixgraphically sort variance
    here, sorted is the column vector of variance {0<V<255*blockSize^2}
    and key is the corresponding block in the original decomposition
%}
[key, sorted] = dominant_sort(variance);
%{
REGULAR EXPADING BLOCK ALGORITHM:
    here, sorted is the columm vector of average gray values {0<G<255}

[key, sorted] = dominant_sort(avg_gray);

%}
Find variance: expanding block level
% find variance of gray level in blocks:


%% 4. From the sorted blocks, place the blocks evenly into numBuckets groups
    group = assign_to_group(block, init);


%% 5.  Create numBuckets buckets. 
% Place the blocks from groups i-1, i, and i+1 into bucket i.

       connection = zeros(N)+1
end