function [block] = block_sort(block, varargin)
% sorts lexigraphically blocks by average gray value or variance
% input: block_sort(block, 'variance') sorts by variance
% note: no for loops! pretty neat, huh?

assert(isa(block, 'overlap_block'), ['first input is a %s'...
    'must be a BLOCK object'], class(block))
row = @(t) reshape(t, [], 1);

N = numel(block.pixel);
pixel = row(block.pixel);
avg_gray = row(block.avg_gray);
variance = row(block.variance);
x = row(block.x);
y = row(block.y);
key = row(1:N);

if nargin>1 && strcmp(varargin{1}, 'variance')
    SORTED = sortrows([variance, y, x, key, avg_gray]);
    block.variance = SORTED(:, 1);
    block.avg_gray = SORTED(:, 5);
elseif nargin>1
    error('Second argument: %s, must be "variance" or blank')
else
    SORTED = sortrows([avg_gray, y, x, key, variance]);
    block.avg_gray = SORTED(:, 1);
    block.variance = SORTED(:, 5);
end

block.x = SORTED(:, 3);
block.y = SORTED(:, 2);
key = SORTED(:, 4);
block.pixel = pixel(key);
end