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
    overlap(n, :) =  and(overlapX, overlapY);
end
% sigmaSq is an estimate of the pooled variance of the blocks
sigmaSq = zeros(N);
var = bucket.variance;

parfor n=1:N
    sigmaSq(n, :) = (var+var(n))/4;
end

sigmaSq = num2cell(sigmaSq);

s_index = @(pixel) pixel(1:S, 1:S);
%% Compare the top-left SxS square of each block


s_subBlock = cellfun(s_index, bucket.pixel, 'UniformOutput', false);
%fprintf('the size of s_subBlock is %g by %g', ...
 %   size(s_subBlock, 1), size(s_subBlock, 2));
%for n=1:5;
%    disp(s_subBlock{n})
%end
s_subBlock = repmat(s_subBlock, N, 1);  % we copy to avoid for loops;
pixel2 = s_subBlock(1, :)';

% create test statistic to determine whether blocks are too similar
    test = @(pixel1, pixel2, sigmaSq) norm(pixel1-pixel2) / ...
        (sigmaSq.*init.blockSize);
    test_statistic = zeros(N);
    
%% TYPE CONVERSION
toDouble = @(A) double(A);
s_subBlock = cellfun(toDouble, s_subBlock, 'UniformOutput', false);

pixel2 = cellfun(toDouble, pixel2, 'UniformOutput', false);
sigmaSq = cellfun(toDouble, sigmaSq, 'UniformOutput', false);

%  %% DIAGNOISTIC
%fprintf('the size of sigmaSq is %g', size(sigmaSq(:, 1), 1))
%fprintf('\n the size of pixel2 is %g, %g', size(pixel2, 1), size(pixel2, 2));

%disp(abs((pixel2{3}-s_subBlock{3});
%disp(abs((pixel2{5}-s_subBlock{5});
%% CALCULATE TEST STATISTIC
for j = 1:N
    test_statistic(:, j) = cellfun(test, s_subBlock(:, j), ...
        pixel2, sigmaSq(:, j));
end

pValThreshold = (chi2inv(0.95, S^2))^-1;
too_similar  = test_statistic > pValThreshold;


% if test statistic is greater than threshless than threshhold OR blocks
% overlap, set the connection matrix to zero there
connection = connection - (or(overlap, ~too_similar));
% for each row in the connection matrix, if that row is all zeros, then the
% block corresponding to that row is not connection to any other block in
% that bucket; remove that block from the bucket

% we create an a dictionary of nonzero rows, hold in to_keep, then overwrite
% bucket:
m = 0;
key = zeros(N, 1);
row_nonzero = any(connection);
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
%try assert(any(too_similar), '')
%catch
%    warning('no blocks are similar. \n init.pvalThreshhold = %g \n', ...
%        pValThreshold);
%end
try assert(any(diag(test_statistic)) == 0)
catch
    warning('diagonal elements of test_statistic do not match!')
end
end
