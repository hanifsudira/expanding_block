function [IMAGE_PRESUMED_MODIFIED, mask, imgOut] =  ...
    expanding_block(imgIn, varargin)
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
    varargin: an expand_block_init OBJECT: parameters described in expanding_block_init.m.    
%}

% OUTPUT
%{
    mask:   a spare 2d array the same width and height as image_in, 
            with value 1 in regions considered 'copies' and value 0
            elsewhere

    imgOut: the original image, grayscaled, except at pixels with '1's in
            the mask. these areas are given red channel values of 255.
 
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




%%  BOILERPALTE: LOGGING AND TIMING:
% LOGGING :
lastToc = 0; tic;
if ischar(imgIn)
    LOG = makeLog(strcat('expanding_block', char(imgIn)));
else
    LOG = makeLOG('expanding_block');   % LOG FILENAME
end
    function timingStr = logTime(functionStr) %logs runtime of function
        
        assert(ischar(functionStr), ...
            'functionStr should be a character array')
        t = toc-lastToc;
        timingStr = sprintf('%s completed w/ runtime of %g seconds', ...
            functionStr, t);
        lastToc = toc;
    end
    function logIt(FILENAME, STR)% logs STRING to specified FILENAME
        log = fopen(FILENAME, 'a');
        fprintf(log, strcat('\n', STR, '\n'));
        fclose(log);
    end
toRow = @(A) reshape(A, 1, []);
toCol = @(A) reshape(A, [], 1);
%% 0: IMPORT HANDLING
imgIn = import_image(imgIn);

currentLog = sprintf('%g by %g image successfullly imported', ...
    size(imgIn, 1), size(imgIn, 2));
logIt(LOG, currentLog);

% grayscale image and trim to a size divisible by init.blockDistance

if size(imgIn, 3) == 3
    logIt(LOG, 'image is RGB')
    img_gray_full = rgb2gray(imgIn);

elseif size(imgIn, 3) == 1
    logIt(LOG, 'image is single-channel or grayscale')
    img_gray_full = imgIn;

else
    
    error('Image not RGB or single-channel')

end

assert(nargin <= 2, 'at most one varargin')
if nargin == 2
    init = varargin{1};
    assert(isa(init, 'expand_block_init'), ['varargin must be an' ...
        'expand_block init OBJECT']);
    logIt(LOG, 'user has specified the following parameters:')
    currentLog = sprintf(['blockSize = %g\n', 'blockDistance = %g\n' ...
        'numBuckets = %g\n', 'pvalThreshhold = %g\n', 'minArea = %g'], ...
        init.blockSize, init.blockDistance, init.numBuckets, ...
        init.pvalThreshold, init.minArea);
    logIt(LOG, currentLog);

else
    init = expand_block_init;
    logIt(LOG, 'default "expanding_block_init" used')

end


% area not divisible by blockDistance
overScan = mod(size(img_gray_full), init.blockDistance);


% trim off overscan area
img = img_gray_full( 1: (end-overScan(1)) , 1:(end-overScan(2)) );

% LOG
currentLog = sprintf('OVERSCAN of %g by %g pixels', ...
    overScan(1), overScan(2));
currentLog = strcat(currentLog, sprintf('\n image trimmed to %g by %g', ...
    size(img, 1), size(img, 2)));

    logIt(LOG, currentLog)
    logIt(LOG, logTime('0: Input Handling')); 

%% 1: Divide an image into small overlapping blocks of blockSize^2

try block = blockMaker(img, init);
catch ME
    errorStr = getReport(ME,'extended');
    logIt(LOG, errorStr)
    rethrow(ME)
end

    logIt(LOG, logTime('1: blockMaker')); 
%% 2. For each block, compute the average gray value as dominant feature

% We also compute variance
try block = block_variance(block);
catch ME
    errorStr = getReport(ME,'extended');
    logIt(LOG, errorStr)
    rethrow(ME)
end
logIt(LOG, logTime('2: block_variance:')); 
logIt(LOG, ['variance is: \n', num2str(block.variance)])

%% 3. Sort the blocks based on the dominant feature
% 
% ENHANCED EXPANDING BLOCK ALGORITHM
% 
%     leixgraphically sort variance
%     here, sorted is the column vector of variance {0<V<255*blockSize^2}
%     and key is the corresponding block in the original decomposition
%
try block = block_sort(block, 'variance');
catch ME
    errorStr = getReport(ME,'extended');
    logIt(LOG, errorStr)
    rethrow(ME)
end
logIt(LOG, logTime('3: block_sort')); 
logIt(LOG, ['the SORTED variance is: \n', num2str(toRow(block.variance))]);
% REGULAR EXPADING BLOCK ALGORITHM:
% here, sorted is the columm vector of average gray values {0<G<255}
% %block = block_sort(block)


%% 4. From the sorted blocks, place the blocks evenly into numBuckets groups
try group = assign_to_group(block, init);
catch ME
    errorStr = getReport(ME,'extended');
    logIt(LOG, errorStr)
    rethrow(ME)
end
logIt(LOG, logTime('4: assign_to_group')); 
%% 5.  Create numBuckets buckets. 
% Place the blocks from groups i-1, i, and i+1 into bucket i.
try bucket = assign_to_bucket(group);
catch ME
    errorStr = getReport(ME,'extended');
    logIt(LOG, errorStr)
    rethrow(ME)
end
logIt(LOG, logTime('5: assign_to_bucket')); 
%% 6-9. Expanding Block Comparison:

m = ceil(log2(init.blockSize));  
S = 1:m;   
S = 2.^S;

% PROCESS BUCKETS IN PARALLEL.
% this is the most computationally intensive step. the program can be most
% significantly computationally improved by improving the speed of this
% step
N = numel(bucket);
M = numel(S);
process_log = cell(N, M);
parfor n=1:N
    for m = 1:M
        %DEBUG:
%            fprintf('\n we are on bucket %g, size of S is %g \n', n, S(m));
       bucket{n} = process_bucket(bucket{n}, S(m), init);
       process_log{n, m} = sprintf(['the xy co-ordinates of bucket %g ' ...
           '    after stepsize %g are \n x: \n %s, \n y: \n %s'], ...
           n, S(m), num2str(bucket{n}.x), num2str(bucket{n}.y))
           
    end
end
for n=1:N
    for m=1:M
        logIt(LOG, process_log{n, m})
    end
end

logIt(LOG, logTime('6:9: Expanding Block Comparison')); 
%% 10: FLAG if presumed modified

BUCKET_MODIFIED = zeros(numel(bucket), 1);
for n=1:numel(bucket);
    if numel(bucket{n}.pixel) > 0
        BUCKET_MODIFIED(n) = 1;
    end
end
IMAGE_PRESUMED_MODIFIED = any(BUCKET_MODIFIED);

if IMAGE_PRESUMED_MODIFIED
    logIt(LOG, 'Image Presumed Modified!')
    % CREATE MASK
    try mask = create_mask(bucket, init, imgIn); 
    catch ME
        errorStr = getReport(ME,'extended');
        logIt(LOG, errorStr)
        rethrow(ME)
    end
        logIt(LOG, logTime('create_mask'));
    % WRITE MASK TO OUTPUT IMAGE
    try [~, imgOut] = write_mask(mask, imgIn);
    catch ME
        errorStr = getReport(ME,'extended');
        logIt(LOG, errorStr)
        rethrow(ME)
       
    end
    logIt(LOG, logTime('write_mask'));
else
    logIt(LOG, 'Image is CLEAN')
    mask = uint8(zeros(size(imgIn)));
    imgOut = imgIn;
end

% this a matrix of ZEROS where the image is presumed 'clean' and ONES where
% the image is presumed to have copy-pasted elements


% this image is GRAYSCALE
logIt(LOG, 'FUNCTION RAN!')
end