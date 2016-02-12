function imOut = expanding_block(imIn, varargin)
% an expanding block algorithm to detect copy-paste duplication within
% an image
%% input and output
%{
    imIn: an RGB image, either as an mxnx3 array or a string
    varargin: an expbls OBJECT: parameters described in explbs.m.
    
%}


%% input handling:
asssert(ischar(imIn) || size(imIn, 3) == 3)
w
if ischar(imIn):
    
assert(size(imIn, 3))

assert(nargin<2, 'At most two input arguments')

if nargin == 1
    init = nargin{1}
    assert(isa(init, 'expbls', 'varargin must be an expbls OBJECT'))
    %%
    % 
    % <<FILENAME.PNG>>
    % 
else
    init = expbls; % default settings specified in expbls.m
end
%% grayscale image and trim so that blockDistance / blockSize

im_gray_full= rgb2gray(gpuArray(imIn));
overScan = mod(size(imIn, blockSize));
im = im_gray_full( 1:end-(overScan(1)), 1:(end-overScan(2)) );
% extraPixels = im_gray_full(end-overScan(1):end, end-overScan(2):end);
[height, width] = size(im);

%% Split into Blocks
% lexigraphically sorted: starting from top left, moving all the way to
% the right, then going up and repeating (left--right, )
blockDim = [(width-blockSize)/blockDistance,(height-blockSize/blockDistance)];
numBlocks = numel(blockDim);
blocks = zeros(blockSize, blockSize, numBlocks, 'gpuArray');

blocks = constructBlocks(
%NOTE: THIS SHOULD PROBABLY BE VECTORIZED?
for m=1:blockDim(2) %width
    for n=1:blockDim(1) %height
        if mod(n, 10)+1 == 1
            disp(n)
        end
        
        currentBlock = 32*(m-1)+n;
        blockStart = [32*(n-1)+1, 32*(m-1)+1];
        blockEnd = blockStart+[31, 31];
        blocks(:, :, currentBlock) = im(blockStart(1):blockEnd(1), blockStart(2):blockEnd(2));
    end
end
%% sort by Dominant Feature
grayVals = reshape(sum(sum(blocks)), numBlocks, 1);
grayDict = dominant_sort(grayVals); %