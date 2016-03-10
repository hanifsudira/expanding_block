function mask = create_mask(bucket, init,   imgIn)
dim = size(imgIn);
mask = zeros(dim(1), dim(2));
x1 = [];
y1 = [];
for n=1:numel(bucket);
    x1 = [x1, bucket{n}.x];
    y1 = [y1, bucket{n}.y];
end
x2 = x1 + init.blockSize-1;
y2 = y1 + init.blockSize-1;
N = numel(x1);

for n=1:N
    X = x1(n):x2(n); Y = y1(n):y2(n);
    mask(X, Y) = mask(X, Y)+1;
end