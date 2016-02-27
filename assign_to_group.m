function group = assign_to_group(block, init)

N = numel(block.pixel);
group = cell(init.numBuckets, 1);
blocks_per_group = floor(N/init.numBuckets);
remainder = mod(N, blocks_per_group);
r = remainder-1;

split = @(t) (reshape(t(1:(end-remainder)), [], blocks_per_group));

PIXEL = split(block.pixel);
VAR = split(block.variance);
X = split(block.x);
Y = split(block.y);

for i=1:(init.numBuckets)
    group{i} = overlap_block;
    group{i}.x = X(:, i);
    group{i}.y = Y(:, i);
    group{i}.pixel = PIXEL(:, i);
    group{i}.variance = VAR(:, i);
end

group{i}.x = [group{i}.x, block.x(end-r:end)];
group{i}.y = [group{i}.y, block.y(end-r:end)];
group{i}.pixel = [group{i}.pixel, block.pixel(end-r:end)];
group{i}.variance = [group{i}.variance, block.variance(end-r:end)];
%{
try assert(blocks_per_group - unrounded_bpg == 0, 'genericerror')
catch
    warning(['number of groups:    %g \n', ...
        'does not divide number of blocks:   %g: \n' ...
        'this may cause unintended behavior\n'], numel(group), numel(block));
end

v = cell(init.numBuckets, 1);
for m=1:(init.numBuckets)
    if m<init.numBuckets
        v{m} = (m*blocks_per_group+1) : blocks_per_group;
    else
        v{m} = (m*blocks_per_group+1):N;
    group{m}.pixel = block.pixel(v{m});
    group{m}.x = block.x(v{m});
    group{m}.y = block.y(v{m});
    group{m}.variance = block.variance(v{m});    
end

%}