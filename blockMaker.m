function block = blockMaker(img, init)

%% Efron's Notes:
%I preallocated the arrays for speed. Didn't bother with vectorizing or w/e
%because that's what got me into so much trouble in the first place.

% We now keep track of the x and y starting position and correctly 
%This function takes in a trimmed matrix representing the grayscale of an
%image, refered to as 'img', and will return a linear array of overlaping 
%pixel blocks, called 'blocks'.  Each block is a matrix of size 
%blockSize-by-blockSize.  This will work for any trimmed matrix as long
%as the number of rows and columns are divisble by the blockDistance.  It 
%will start at the top right corner of the img matrix and creat the blocks
%left to right.  Once it reaches right end it moves down the appropriate
%rows and repeats, a-la typewriter style.

%Note that this makes the overlap half the block size.  If we choose to
%adjust the overlap the variables outerCount and innerCount will need to 
%be adjusted. 

%Test results:
%Test1- 410x620 size image, made 2440 20x20 size blocks in 0.184299 sec
%Test2- 1024x1280 size image, made 4977 32x32 size blocks in 0.631426 sec
%% INPUT CHECK


assert(isnumeric(img) && size(img, 3) == 1, ['input "img" should be a', ...
    'grayscale image']);
assert(isa(init, 'expand_block_init'), ['input "init" should be an' ...
    'expanding block init object']);
TRIMMED = not(any(mod(size(img), init.blockDistance)));
assert(TRIMMED, ['image is not trimmed: size is: \n %g, %g,' ...
    'which is not divisible by \n init.blockDistance: %g \n'], ...
    size(img, 1), size(img, 2), init.blockDistance);




%% CREATE BLOCKS

blockDim = (size(img))./init.blockDistance - ...
    (init.blockSize/init.blockDistance) + 1;
pixel = cell(blockDim);
x = zeros(blockDim);
y = zeros(blockDim);

rowStart = 1;
rowEnd = init.blockSize;

for i = 1:blockDim(1);
    colStart = 1;
    colEnd = init.blockSize;
    for j=1:blockDim(2)
        x(i, j) = colStart;
        y(i, j) = rowStart;
        pixel{i, j} = img(rowStart:rowEnd, colStart:colEnd);
        colStart = colStart+init.blockDistance;
        colEnd = colEnd+init.blockDistance;
    end
    rowStart = rowStart + init.blockDistance;
    rowEnd = rowEnd+init.blockDistance;
end

%% OUTPUT: output as overlap_block object

block = overlap_block;
block.pixel = reshape(pixel, 1, []);
block.x = reshape(x, 1, []);
block.y = reshape(y, 1, []);