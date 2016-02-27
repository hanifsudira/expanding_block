function mask = create_mask(bucket, init, img_size)

N = numel(bucket);
recombined = bucket{1:N};
M = numel(recombined);
mask = zeros(img_size);

x = zeros(M, 1);
y = zeros(M, 1);

pullx = @(block) block.x;
pully = @(block) block.y;

x1 = cellfunc(pullx, recombined, 'UniformOutput', false);
y1 = cellfunc(pully, recombined, 'UniformOutput', false);
x2 = x1+(init.blockSize-1);
y2 = y1+(init.blockSize-1);

for m=1:M
    mask(x1(m):x2(m), y1(m):y2(m)) = 1;
end
end