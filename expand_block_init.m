classdef expand_block_init
    %expanding block algorithm settings
    properties
        blockSize = 32 
        % width and height of a block; total is blockSizeAin^2.
        
        blockDistance = 16   
        % distance between blocks; generally 1/4 of block size
        
        numBuckets = 128
        % number of buckets used to compare blocks
        
        pvalThreshold = 9.68
        % threshold for block comparison
    end
end