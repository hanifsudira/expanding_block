function FLAG = flag_if_modified(bucket)
N = numel(bucket.x);
if N
    FLAG = 1;
else
    FLAG = 0;
end