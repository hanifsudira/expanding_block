classdef overlap_block
    % an object that contains the overlapping blocks used by
    % expanding_block
    properties
        pixel       % pixel{n} contains the pixels of the nth block
         
        avg_gray    % avg_gray(n) = mean( elements in pixel{n})
        variance    % variance(n) = mean( (pixel{n} - avg_gray(n) ).^2)
        x           % x(n) = x-position (col) of pixel{n}(1, 1)
        y           % y(n) = y-position (row) of pixel{n}(1, 1)
    end
end