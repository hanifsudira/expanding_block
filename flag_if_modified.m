function FLAG = flag_if_modified(bucket)
% flags a bucket
disp(numel(bucket))
N = numel(bucket);
bucket_empty = zeros(N, 1);
for n=1:N
    bucket_empty(n) = size(bucket{n}.pixel, 1);
    %disp(bucket{n}.pixel)
end
%DEBUG:
% disp(bucket_empty)
if any(~bucket_empty)
    FLAG = 1;
else
    FLAG = 0;
end
