function bucket = process_bucket(bucket, S, init)
% NOTE: I'M NOT SURE WHAT SIGMA SHOULD BE
% process the bucket comparing regions of size S^2
N = numel(bucket);
blockSize = size(bucket{1}, 1);
blockSize = blockSize(:);   % forcing to be vector array

errorstr = sprintf(['blockSize calculated within function procss_bucket: \n', 
    '   %g does not equal init.Blocksize: \n    %g'], ...
    blockSize, init.blockSize);
assert(blockSize == init.blockSize, errorstr)

connection = zeros(N, 'gpuArray')+1;

% If the two blocks are less than blockSize away, the blocks overlap:
overlap = zeros(N, 'gpuArray');
for n=1:N
    overlap(n, :) = ( abs(x(n)-x)+abs(y(n)-y) ) <blockSize;
end

% Compute the test statistic for every pairwise comparison for the UPPER
% LEFT S x S square of each block in the bucket. If for some block
% comparison, Pr(chi^2>t) <init.pvalThreshold where chi^2 follows a
% chi-squared distribution with S62 degrees of feedom, then set
% connection(i, j) to 0 for these blocks.

temporary_placeholder = 1;
sigma = temporary_placeholder;
warning('Sigma is currently a temporary placeholder')

%{
TODO: implement sigma correctly
%}

% seperate into SxS sub-squares

s_index = @(A) A(1:S, 1:S);
s_subBlock = cellfunc(s_index, bucket, 'UniformOutput', false);


% compute test statistic
t = @(A, B, sigma) norm(A-B)/(sigma^2)*blockSize;
less_than_threshhold = gpuArray(@(A) A>init.pvalThreshhold);

test_statistic = cellfunc(t, s_subBlock, 'UniformOutput', false);
warning('This test statistic is for the basic, not enhanced, algorithm')

%{
TODO: implement test statistic for ENHANCED expanding block algoirthm
%}

%%if test statistic less than threshhold, set conection(i, j) to zero:
significant = cellfunc(less_than_threshhold, test_statistic, ...
    'UniformOutput',false);

connection = connection - (overlap | significant);

% for each row in the connection matrix, if that row is all zeros, then the
% block corresponding to that row is not connected ot any other block in
% the bucket

to_keep = cell(N, 1);

held = 0; % this is the counter of how many elements we keep
for n=1:N
    if ~(isempty(connection(n, :)))
       held = held+1;
       to_keep{held} = bucket{n};
    end
end

bucket = to_keep(1:m);

%%9. Compute total remaining area of bucket, and discard remaning elments
%%if the total area is less than minArea

totalArea = numel(bucket)*blockSize^2;
if totalArea < init.minArea
    bucket = {};    %  this is the output
end
end