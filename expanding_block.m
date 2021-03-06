function [IMAGE_PRESUMED_MODIFIED, mask, imgOut] =  ...
    expanding_block(imgIn, varargin)
tic
% Detects copy-move forgery via an expanding block method.


%% ACKNOWLEDGEMENTS:
% An expanding block algorithm to detect copy-paste duplication within
% an image. Code based off "An Efficien t Expanding Block Algorithm for
% Image Copy-Move Forgery Detection", by Gavin Lynch, Frank Y. Shih, and
% Hong-Yuan Mark Liao, Published in 'Information Sciences' Volume 239, pgs
% 253-265. The version accessed was most recently edited on August 1st,
% 2013.

%% PROGRAM DESCRIPTION:
% INPUT
%{
    imIn: a RGB image, either as an mxnx3 array or a string
%}

% OUTPUT
%{
    IMAGE_PRESUMED_MODIFIED = a logical flag. 1 if image modified, else 0.

    mask:   a spare 2d array the same width and height as image_in, 
            with value 1 in regions considered 'copies' and value 0
            elsewhere

    imgOut: [Original Image | 8 x col separator | masked image], where the
    separator is BLUE (0, 0, 255). The masked image is the original
    image grayscaled, and then overwritten in RED (255, 0, 0) by the mask.

% LIST OF DEPENDENCIES
OBJECTS:
expand_block_init: an OBJECT which contains the parameters for this
suppose the image has N overlapping blocks of size P^2

block:
    block.pixel: an Nx1 cell array. Each element is NxN uint8 gpuArray

    block.dim: a 2-element vector containning the # of blocks that fit into
    each dimension of the image

    block.avg_gray: a size-N double vector containing the average gray
    values of the corresponding element in block.pixel

    block.variance: a size-N double vector containing the variance of the 
    corresponding element in block.pixel

    std-deviation: a size-N double vector containing the std_deviation of
    the corresponding element in block.pixel

    block.x: a size-N double vector containing x position of the
    corresponding element in block.pixel

    block.y: a size-N double vector containing x position of the
    corresponding element in block.pixel


import_image(imgIn): imports an image as %FILENAME or m x n x 3 matrix
img_to_subBlocks(img, init): creates init.blockDistance sized subBlocks
quad_overlap(subBlock): creates overlapping blocks (init.blockDistance^2)
in size from subBlocks; records x-position and y-position of starting
blocks and holds in array

%}


%toRow = @(A) reshape(A, 1, []);
%toCol = @(A) reshape(A, [], 1);

%% -1:  DEBUG and INPUT HANDLING

DEBUG = 0;
if nargin >1
    if strcmp(varargin{1}, 'debug')
        DEBUG = 1;
    end
end

% if imgIn is a filename, convert to matrix;
if ischar(imgIn)
    imgIn = imread(imgIn);
end

% grayscale image and trim to a size divisible by init.blockDistance

if size(imgIn, 3) == 3
    img_gray_full = rgb2gray(imgIn);

elseif size(imgIn, 3) == 1
    img_gray_full = imgIn;

else  
    error('Image not RGB or single-channel')

end
init = set_expand_block_init(imgIn);

if DEBUG
    fprintf('init.blockSize = %g\n', init.blockSize)
    fprintf('init.blockDistance = %g\n', init.blockDistance)
    fprintf('init.minArea = %g\n', init.minArea)
    fprintf('init.numBuckets = %g\n', init.numBuckets)
end


% area not divisible by blockDistance
overScan = mod(size(img_gray_full), init.blockDistance);


% trim off overscan area
img = img_gray_full( 1: (end-overScan(1)) , 1:(end-overScan(2)) );

%% 0: SET INIT


%% 1: Divide an image into small overlapping blocks of blockSize^2

block = blockMaker(img, init);


%% 2. For each block, compute the average gray value as dominant feature

% We also compute variance
block = block_variance(block);
    

%% 3. Sort the blocks based on the dominant feature
% 
% ENHANCED EXPANDING BLOCK ALGORITHM
% 
%     leixgraphically sort variance
%     here, sorted is the column vector of variance {0<V<255*blockSize^2}
%     and key is the corresponding block in the original decomposition
%
block = block_sort(block, 'variance');

%number_of_blocks = numel(block.x);


%logIt(LOG, ['the SORTED variance is: \n', num2str(toRow(block.variance))]);
% REGULAR EXPADING BLOCK ALGORITHM:
% here, sorted is the columm vector of average gray values {0<G<255}
% %block = block_sort(block)


%% 4. From the sorted blocks, place the blocks evenly into numBuckets groups
group = assign_to_group(block, init);

%% 5.  Create numBuckets buckets. 
% Place the blocks from groups i-1, i, and i+1 into bucket i.
bucket = assign_to_bucket(group);


%% 6-9. Expanding Block Comparison:

m = ceil(log2(init.blockSize));  
S = 1:m;   

S = 2.^S;

% this is the most computationally intensive step. the program can be most
% significantly computationally improved by improving the speed of this
% step
N = numel(bucket);
M = numel(S);

last_percent = 0;
for n=1:N
    if DEBUG
       current_percent = floor(100*n/N);
       if current_percent > last_percent && mod(current_percent, 5) == 0
           last_percent = current_percent;
           fprintf(' %g percent complete! (bucket %g / %g\n', ...
               current_percent, n, N);
       end
    end
    for m = 1:M       
        bucket{n} = process_bucket(bucket{n}, S(m), init);
    end
    
end


%% 10: FLAG if presumed modified

BUCKET_MODIFIED = zeros(numel(bucket), 1);
for n=1:numel(bucket);
    if numel(bucket{n}.pixel) > 0
        BUCKET_MODIFIED(n) = 1;
    end
end
IMAGE_PRESUMED_MODIFIED = any(BUCKET_MODIFIED);

% 11. Cleanup: Create mask image from duplicated blocks;
if IMAGE_PRESUMED_MODIFIED
    % CREATE MASK
     mask = create_mask(bucket, init, imgIn); 

        
    % WRITE MASK TO OUTPUT IMAGE
    [~, imgOut] = write_mask(mask, imgIn);

else
    mask = uint8(zeros(size(imgIn)));
    imgOut = imgIn;

end

% this a matrix of ZEROS where the image is presumed 'clean' and ONES where
% the image is presumed to have copy-pasted elements


% this image is GRAYSCALE

if DEBUG
    toc
end
end