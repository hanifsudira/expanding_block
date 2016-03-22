function group = assign_to_group(block, init)

N = numel(block.x);
group = cell(init.numBuckets, 1);

blocks_per_group = floor(N./init.numBuckets);
group_start = 1:blocks_per_group:N;
group_start = group_start(1:init.numBuckets);

group_end = group_start + blocks_per_group-1;
group_end(end) = N;

for n = 1:init.numBuckets
    group{n} = overlap_block;
    group{n}.x = block.x(group_start(n):group_end(n));
    group{n}.y = block.y(group_start(n):group_end(n));
    group{n}.pixel = block.pixel(group_start(n):group_end(n));
    group{n}.variance = block.variance(group_start(n):group_end(n));
    assert(size(group{n}.x, 1) == size(group{n}.y, 1) && ... 
        size(group{n}.y, 2) == size(group{n}.y, 2), ...
        ' x and y vectors ~=')
end
