function test_statistic = calculate_test_statistic(pixel1, pixel2, sigmaSq, S)
    pixel_diff = pixel1-pixel2;
    test_statistic(n, m) = (pixel_diff * pixel_diff')  / ...
        (sigmaSq(n,m) / S);
end