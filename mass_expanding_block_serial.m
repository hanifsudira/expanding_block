function is_modified = mass_expanding_block_serial(filenames, varargin)


%% INPUT HANDLING
%tic
CUSTOM_OUTPUT_FOLDER = 0;
CUSTOM_OUTPUT_LOG = 0;
if nargin > 1
    for n=1:length(varargin)
        if strcmp(varargin{n}, 'output_folder')
            CUSTOM_OUTPUT_FOLDER = 1;
            output_folder = varargin{n+1};
            try mkdir(output_folder);
            catch %pass
            end
        elseif strcmp(varargin{n}, 'output_log')
            CUSTOM_OUTPUT_LOG = 1;
            output_log = varargin{n+1};
        end
    end
end

if not(CUSTOM_OUTPUT_LOG);
    time = datestr(now);
    time = time(1:(end-3));
    time = strrep(time, ' ', '-');
    time = strrep(time, ':', '-');
    output_log = strcat('mass_expand_test_log_', time, '.csv');
end

log = fopen(output_log, 'w');
fprintf(log, ['file_name,', ...
    'file_number, considered_modified\n']);
fclose(log);
% IMPLEMENTATION DEPENDENT: I AM RUNNING ON AN I7-4960
% SPLIT INTO BATCHES OF TWELVE (twelve workes on MY matlab PARPOOL:

number_of_files = numel(filenames);

if CUSTOM_OUTPUT_FOLDER
    format_output = @(A) strcat(output_folder, '/', 'expand_block_', A);
else
    format_output = @(A) strcat('expand_block_', A);
end

output_filenames = cell(number_of_files, 1);
for n=1:number_of_files
    output_filenames{n} = format_output(filenames{n});
end
is_modified = zeros(number_of_files, 1, 'logical');

%batch_start = [];   % not needed until later

batch_end = 0;

batch_size = 64;
batch_count = ceil(number_of_files/batch_size);
current_batch = 0;
while current_batch < batch_count;
    current_batch = current_batch + 1;
%     fprintf('%g / %g files processed \n', batch_end, number_of_files);
%     fprintf('starting batch %g of %g \n', current_batch, batch_count),
%     fprintf('runtime so far is %f minutes \n', toc/60)
%     if current_batch > 1
%         fprintf('estimated remaining runtime is %f minutes \n', ...
%             (toc * batch_count / (current_batch - 1))/60);
%     end
    
    batch_start = max(batch_end, 1);
    batch_end = min(batch_start+(batch_size-1), number_of_files);
    
    batch_input_filename = filenames(batch_start:batch_end);
    batch_output_filename = output_filenames(batch_start:batch_end);
    batch_is_modified = zeros(numel(batch_input_filename), 1, 'logical');
    batch_temp_image_storage = cell(batch_size, 1);
    for n=1:numel(batch_input_filename)
        try
            [IMAGE_MODIFIED, ~, imgOut] = ...
                expanding_block(batch_input_filename{n});
            
            if IMAGE_MODIFIED
                batch_is_modified(n) = true;
                batch_temp_image_storage{n} = imgOut;
            end
        catch exception
            warning(exception.message)
        end
    end
    log = fopen(output_log, 'a');
    % log and write images before moving on to next batch
    for n=1:numel(batch_is_modified)
        if batch_is_modified(n)
            imwrite(batch_temp_image_storage{n}, batch_output_filename{n})
        end
        fprintf(log, '%s, %04g, %g\n', ...
            batch_input_filename{n}, n, batch_is_modified(n));
    end
    fclose(log);
    is_modified(batch_start:batch_end) = batch_is_modified;

end

end