function block = block_variance(block)
assert(isa(block, 'overlap_block'), ['input should be an overlapping_block' ...
    '\nis a: %s'], class(block));
% find variance of the block:
N = numel(block.x);
block.avg_gray = zeros(N, 1);
block.variance = zeros(N, 1);
for n=1:N
pixel = reshape(block.pixel{n}, [], 1);
block.avg_gray(n) = mean(pixel);
block.variance(n) = mean( (pixel-block.avg_gray(n)).^2);
end