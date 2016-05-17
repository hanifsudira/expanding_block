function test_expanding_block()

filenames = {
    'AU_face.png', 'CM_face.png'
    'AU_statue.png', 'CM_statue.png'
    'AU_tower.png', 'CM_tower.png'
    'AU_uniform.png', 'CM_uniform.png'};

% run expanding_block on filename

for n=1:numel(filenames)
    input_filename = filenames{1};
    output_filename = strcat('output_', input_filename);
    fprintf('starting expanding_block on file %g/8: \n%s', ...
        n, input_filename);
    
    [flag, ~, imgOut] = expanding_block(input_filenamefilename);
    if flag
        fprintf('file considered modified. saving output to %s', ...
            output_filename)
        imshow(output_filename)
    else
        fprintf('file considered clean. saving output to %s', ...
            output_filename)
    end
end
end