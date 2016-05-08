function bucket = process_bucket(bucket, S, init)

    %% INPUT SPECIFICATIONS:    
N = numel(bucket.x);
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
sigmaSq = zeros(N, 'single', 'gpuArray');
var = bucket.variance;

for n=1:N
    sigmaSq(n, :) = (var+var(n)/2);
end

%sigmaSq = num2cell(sigmaSq);

%s_index = @(pixel) pixel(1:S, 1:S);
%% Compare the top-left SxS square of each block
s_subBlock = zeros(N, S^2, 'single', 'gpuArray');
for n=1:N
    s_subBlock(n, :) = reshape(bucket.pixel{n}(1:S, 1:S), 1, []);
end
S = gpuArray(single(S));


test_statistic = zeros(N, 'single', 'gpuArray');

for n=1:N    
%    sigmaSq_temp = repmat(sigmaSq(n, :), init.blockSize, 1);
%   S_temp = zeros(N, init.blockSize, 'single', 'gpuArray');
    pixel_diff = @(pixel1, pixel2) (pixel1-pixel2).^2;
    pixel2 = repmat(s_subBlock(n, :), N, 1);
%    size(S_array)
    pixel_diff_unsummed = arrayfun(pixel_diff, ...
        s_subBlock, pixel2);
    test_statistic(n, :) = sum(pixel_diff_unsummed, 2);
end

test_statistic = gather(test_statistic ./ (sigmaSq/S));

%fprintf('the size of s_subBlock is %g by %g', ...
 %   size(s_subBlock, 1), size(s_subBlock, 2));
%for n=1:5;
%    disp(s_subBlock{n})
%end
%s_subBlock = repmat(s_subBlock, N, 1);  % we copy to avoid for loops;
%pixel2 = s_subBlock(1, :)';

% create test statistic to determine whether blocks are too similar
%test = @(pixel1, pixel2, sigmaSq) reshape((pixel1-pixel2), 1, [])* ...
%    reshape((pixel1-pixel2), [], 1) ./ (sigmaSq./ (S^2) );
%test_statistic = zeros(N);

%% TYPE CONVERSION
% toDouble = @(A) double(A);
% s_subBlock = cellfun(toDouble, s_subBlock, 'UniformOutput', false);
% 
% pixel2 = cellfun(toDouble, pixel2, 'UniformOutput', false);
% sigmaSq = cellfun(toDouble, sigmaSq, 'UniformOutput', false);

%  %% DIAGNOISTIC
%fprintf('the size of sigmaSq is %g', size(sigmaSq(:, 1), 1))
%fprintf('\n the size of pixel2 is %g, %g', size(pixel2, 1), size(pixel2, 2));

%disp(abs((pixel2{3}-s_subBlock{3});
%disp(abs((pixel2{5}-s_subBlock{5});
%% CALCULATE TEST STATISTIC
% for j = 1:N
%     test_statistic(:, j) = cellfun(test, s_subBlock(:, j), ...
%         pixel2, sigmaSq(:, j));
% end

pvalThreshold = chi2inv(0.01, S^2); 
too_similar  = test_statistic < pvalThreshold;

% if test statistic is greater than threshless than threshhold OR blocks
% overlap, set the connection matrix to zero there
connection = connection - ( or(overlap, not(too_similar) ) ) ;
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

if numel(bucket.x)*init.blockSize < init.minArea
    bucket = [];                   % clear it
    bucket = overlap_block;
end

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
