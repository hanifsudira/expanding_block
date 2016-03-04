function mask = create_mask(bucket, init, imgIn)
M = 0;
for n=1:numel(bucket)
M = M+numel(bucket{n}.pixel);
end
mask = zeros(size(imgIn));


pullx = @(block) block.x;
pully = @(block) block.y;

x1 = cellfunc(pullx, bucket, 'UniformOutput', false);
y1 = cellfunc(pully, bucket, 'UniformOutput', false);
x2 = x1+(init.blockSize-1);
y2 = y1+(init.blockSize-1);

for m=1:M
    X = x1(m):x2(m); Y = y1(m):y2(m);
    mask(X, Y) = mask(X, Y) + 1;
end
end