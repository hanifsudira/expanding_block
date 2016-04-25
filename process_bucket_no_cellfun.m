function bucket = process_bucket(bucket, S, init)

x = bucket.x;
y = bucket.y;
variance = bucket.variance;
    %% INPUT SPECIFICATIONS:    
N = numel(x);
if N == 0
    return
end
% create an N x N connection matrix, set to ones
connection = zeros(N)+1;

% If two blocks are less than blockSize away, they overlap

    overlap = zeros(N);
for n=1:N
    overlapX = abs(x(n)-x) < init.blockSize;
    overlapY = abs(y(n)-y) < init.blockSize;
    overlap(n, :) =  and(overlapX, overlapY);
end
% sigmaSq is an estimate of the pooled variance of the blocks
sigmaSq = zeros(N);


for n=1:N
    sigmaSq(n, :) = (variance+variance(n))/2;
end

%% Compare the top-left SxS square of each block
s_subBlock = cell(N, 1);
for n=1:N
    pixel = bucket.pixel{n};
    s_subBlock{n}    = single(pixel(1:S, 1:S));
end
%fprintf('the size of s_subBlock is %g by %g', ...
 %   size(s_subBlock, 1), size(s_subBlock, 2));
%for n=1:5;
%    disp(s_subBlock{n})
%end
% create test statistic to determine whether blocks are too similar
disp(size(sigmaSq));
test_statistic = zeros(N);
for n=1:N
    for m=1:N
        pixel_difference = s_subBlock{m}-s_subBlock{n}
        sigmaSq(n, m)
        S^2
        test_statistic(n, m) = ( pixel_difference(:)'*pixel_difference(:)' / ...
            (sigmaSq(n, m) / (S^2) ) );
    end
end 
    
%% TYPE CONVERSION

%  %% DIAGNOISTIC
%fprintf('the size of sigmaSq is %g', size(sigmaSq(:, 1), 1))
%fprintf('\n the size of pixel2 is %g, %g', size(pixel2, 1), size(pixel2, 2));

%disp(abs((pixel2{3}-s_subBlock{3});
%disp(abs((pixel2{5}-s_subBlock{5});
%% CALCULATE TEST STATISTIC
pvalThreshold = chi2inv(.01,S^2); 
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
to_keep.x = x(key);
to_keep.y = y(key);
to_keep.variance = bucket.variance(key);

%$ OUTPUT BUCKET
bucket = to_keep;

if numel(x)*init.blockSize < init.minArea
    clear bucket;
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
