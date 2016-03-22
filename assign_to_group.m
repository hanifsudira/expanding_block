function group = assign_to_group(block, init)

group = cell(init.numBuckets, 1);
N = numel(block.x)/init.numBuckets;
index = 1:N:numel(block.x);
disp(numel(block.x))
index = floor(index);
for n = 1:(init.numBuckets-1)
    group_start = index(n);
    group_end = index(n+1)-1;
    group{n} = overlap_block;
    group{n}.x = block.x(group_start:group_end);
    group{n}.y = block.y(group_start:group_end);
    group{n}.pixel = block.pixel(group_start:group_end);
    group{n}.variance = block.variance(group_start:group_end);
    assert(size(group{n}.x, 1) == size(group{n}.y, 1) && ... 
        size(group{n}.y, 2) == size(group{n}.y, 2), ...
        ' x and y vectors ~=')
end
% last group picks up the stragglers
n = init.numBuckets;
group{n} = overlap_block;
group{n}.x = block.x(group_end:end);
group{n}.y = block.x(group_end:end);
group{n}.pixel = block.pixel(group_end:end);
group{n}.variance = block.variance(group_end:end);
