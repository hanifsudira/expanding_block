function bucket = process_bucket(bucket, S, init)

%% INPUT SPECIFICATIONS:    
N = numel(bucket.pixel);
if N == 0
    return
end
% create an N x N connection matrix, set to ones
connection = zeros(N)+1;

% If two blocks are less than blockSize away, they overlap
overlap = zeros(N);
for n=1:N
    overlapX = abs(bucket.x(n)-bucket.x) < init.blockSize;
    overlapY = abs(bucket.y(n)-bucket.y) < init.blockSize; 
    overlap(n, :) =  or(overlapX, overlapY);
end

% sigma is an estimate of the pooled variance of the blocks
sigma = zeros(N);
var = bucket.variance;

parfor n=1:N
    sigma(n, :) = sqrt(var+var(n))./2;
end

sigma = num2cell(sigma);

s_index = @(pixel) pixel(1:S, 1:S);
%% Compare the top-left SxS square of each block


s_subBlock = cellfun(s_index, bucket.pixel, 'UniformOutput', false);

s_subBlock = repmat(s_subBlock, N, 1);  % we copy to avoid for loops;


% create test statistic to determine whether blocks are too similar
    test = @(pixel1, pixel2, sigma) norm(pixel1-pixel2) / ( ...
        (sigma^2)*init.blockSize);
    test_statistic = zeros(N);
    pixel2 = s_subBlock(1, :);
    
%% TYPE CONVERSION
toDouble = @(A) double(A);
s_subBlock = cellfun(toDouble, s_subBlock, 'UniformOutput', false);
pixel2 = cellfun(toDouble, pixel2, 'UniformOutput', false);
sigma = cellfun(toDouble, sigma, 'UniformOutput', false);


for j = 1:N
    test_statistic(j, :) = cellfun(test, s_subBlock(j, :), ...
        pixel2, sigma(j, :));
end

too_similar  = test_statistic > init.pvalThreshold;


% if test statistic is greater than threshless than threshhold OR blocks
% overlap, set the connection matrix to zero there
connection = connection - (or(overlap, too_similar));

% for each row in the connection matrix, if that row is all zeros, then the
% block corresponding to that row is not connection to any other block in
% that bucket; remove that block from the bucket

% we create an a dictionary of nonzero rows, hold in to_keep, then overwrite
% bucket:
m = 0;
key = zeros(N, 1);
row_nonzero = any(connection');
for n=1:N
    if row_nonzero(n)
       m = m+1;
       key(m) = n;
    end
end
key = nonzeros(key);
% 
to_keep = overlap_block;
to_keep.pixel = bucket.pixel(key);
to_keep.x = bucket.x(key);
to_keep.y = bucket.y(key);
to_keep.variance = bucket.variance(key);

%$ OUTPUT BUCKET
bucket = to_keep;

%% DIAGNOSTICS:
try assert(any(too_similar), '')
catch
    warning('no blocks are similar. \n init.pvalThreshhold = %g \n', ...
        init.pvalThreshold);
end
try assert(any(diag(test_statistic)) == 0)
catch
    warning('diagonal elements of test_statistic do not match!')
end
end
