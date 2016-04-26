function mask = create_mask(bucket, init, imgIn)
% use saved x and y positions to mark blocks considered copied.
% the mask is one in those areas and zero elsewhere
[rows, cols, ~] = size(imgIn);
mask = zeros(rows, cols);
x = [];
y = [];
for n=1:numel(bucket);
    x = [x, bucket{n}.x];
    y = [y, bucket{n}.y];
end
XY = sortrows([x', y']);
x = XY(:, 1); y = XY(:, 2);
%disp(sortrows([x1', y1']))
x2 = x + init.blockSize-1;
y2 = y + init.blockSize-1;
N = numel(x);
for n=1:N
    mask(y(n):y2(n), x(n):x2(n)) = ...
        mask(y(n):y2(n), x(n):x2(n))+1;
end
% convert to logical
mask = mask > 0;
end