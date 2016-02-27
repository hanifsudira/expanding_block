function block = block_variance(block)
assert(isa(block, 'overlap_block'), ['input should be an overlapping_block' ...
    '\nis a: %s'], class(block));
% find variance of the block:

f_mean = @(pixel) sum(pixel(:)/numel(pixel));
f_variance = @(pixel, mean) sum(pixel-mean);
col = @(A) reshape(A, [], 1);

block.avg_gray =  col((cellfun(f_mean, block.pixel)), [], 1);
block.variance = col( cellfun(f_variance, pixel, num2cell(block.avg_gray)));
end