classdef expand_block_init
% settings for expanding_block algorithm. set adaptively by
% set_expanding_block_init
    properties
        blockSize
        % width and height of a block; total is blockSizeAin^2.
        
        blockDistance   
        % distance between blocks; generally 1/4 of block size
        
        numBuckets
        % number of buckets used to compare blocks
        
        pvalThreshold
        % depreciated. set in process_block
        
        minArea
        % threshold f   or block comparison
    end
end