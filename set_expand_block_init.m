function init = set_expand_block_init(img);
[rows, cols, ~] = size(img);
init = expand_block_init;

if rows*cols < 50^2;
    init.blockSize = 4;
    init.blockDistance = 1;
    init.numBuckets = 50;
    init.minArea = 32;
elseif rows*cols <= 150^2
    init.blockSize = 4;
    init.blockDistance = 4;
    init.numBuckets = 500;
    init.minArea = 32;
elseif rows*cols <= 350^2
    init.blockSize = 8;
    init.blockDistance = 1;
    init.numBuckets = 5000;
    init.minArea = 256;
elseif rows*cols <= 700^2
    init.blockSize = 8;
    init.blockDistance = 1;
    init.numBuckets = 12000;
    init.minArea = 256;
else
    init.blockSIze = 8;
    init.blockDistance = 1;
    init.numBuckets = round(rows*cols/128);
    init.minArea = 256;
end
end
    
        