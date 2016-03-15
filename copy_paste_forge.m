function imgOut = copy_paste_forge(imgIn, varargin)


if nargin == 2;
    try copies = varargin{1};
        assert(isnumeric(copies))
        assert(isscalar(copies))
        assert(copies - floor(copies) == 0)
        assert(copies > 0);
    catch
        error('number_of_forgeries should be a positive integer');
    end
else
    copies = 1;
end
imgOut = imgIn;

[rows, cols, ~] = size(imgIn);

rows = rows - mod(rows, 12); 
cols = cols - mod(cols, 12);

% so evenly divisible by 3 and 4

limiting_dim = min(rows, cols);

for j=1:copies
    forgeSize = randi(100, limiting_dim/4);
    copy_from_row = randi([1, rows/4]);
    copy_from_row = copy_from_row:(copy_from_row+forgeSize);
    
    copy_from_col = randi([1, cols/4]);
    copy_from_col = copy_from_col:(copy_from_col+forgeSize);
    
    copy_to_row = randi([rows/2, floor(rows*2/3)]);
    copy_to_row = copy_to_row:(copy_to_row+forgeSize);
    
    copy_to_col = randi([cols/2, floor(cols*2/3)]);
    copy_to_col = copy_to_col:(copy_to_col+forgeSize);
    
    imgOut(copy_to_row, copy_to_col, :) = ...
        imgIn(copy_from_row, copy_from_col, :);
end
