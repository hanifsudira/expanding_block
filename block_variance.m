function [avg_gray, variance] = block_variance(block)
% find the variance of a block and output as a column vector
f_mean = @(A) sum(A(:)/numel(A));
f_variance = @(A, avg) sum(A(:)-avg);
avg_gray =  num2cell(cellfun(f_mean, block)); % cell for cellfunc
variance = cellfun(f_variance, block, avg_gray);
variance = reshape(variance, numel(variance), 1);
end