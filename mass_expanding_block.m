function is_modified = mass_expanding_block(filenames, varargin)


%% INPUT HANDLING
tic
CUSTOM_OUTPUT_FOLDER = 0;
if nargin > 1
    for n=1:length(varargin)
        if strcmp(varargin{n}, 'output_folder')
            CUSTOM_OUTPUT_FOLDER = 1;
            output_folder = varargin{n+1};
        end
    end
end

% IMPLEMENTATION DEPENDENT: I AM RUNNING ON AN I7-4960
% SPLIT INTO BATCHES OF TWELVE (twelve workes on MY matlab PARPOOL:

number_of_files = numel(filenames);

if CUSTOM_OUTPUT_FOLDER
    format_output = @(A) strcat(output_folder, '/', 'expand_block_', A);
else
    format_output = @(A) strcat('expand_block_', A);
end

output_filenames = cellfun(format_output, filenames, 'UniformOutput', false);
is_modified = zeros(number_of_files);

%batch_start = [];   % not needed until later

batch_end = 0;

batch_count = ceil(number_of_files/12);
current_batch = 0;
while current_batch < batch_count;         
    current_batch = current_batch + 1;
    fprintf('%g / %g files processed \n', batch_end, number_of_files);
    fprintf('starting batch %g of %g \n', current_batch, batch_count), 
    fprintf('runtime so far is %f minutes \n', toc/60)
    if current_batch > 1
        fprintf('estimated remaining runtime is %f minutes \n', ...
            (toc * batch_count / (current_batch - 1)));
    end
     
    batch_start = max(batch_end, 1);
    batch_end = min(batch_start+11, number_of_files);
    
    batch_input_filename = filenames(batch_start:batch_end);
    batch_output_filename = output_filenames(batch_start:batch_end);
    batch_is_modified = zeros(numel(batch_input_filename), 1);
    parfor n=1:numel(batch_input_filename)
        try
            [IMAGE_MODIFIED, ~, imgOut] = ...
                expanding_block(batch_input_filename{n});
            
            if IMAGE_MODIFIED
                batch_is_modified(n) = 1;
            end
            imwrite(imgOut, batch_output_filename{n})
        catch exception
            warning(exception.message)
        end
    end
    is_modified(batch_start:batch_end) = batch_is_modified;
end
fprintf('function complete!')