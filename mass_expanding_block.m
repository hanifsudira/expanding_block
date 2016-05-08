function is_modified = mass_expanding_block(filenames, varargin)


%% INPUT HANDLING
tic
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
fprintf(log, ['file_number', ...
    'input_filename, output_filename, considered_modified\n']);
fclose(log);
% IMPLEMENTATION DEPENDENT: I AM RUNNING ON AN I7-4960
% 

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
is_modified = zeros(number_of_files, 1);

%batch_start = [];   % not needed until later

batch_end = 0;

BATCH_SIZE = 32;
batch_count = ceil(number_of_files/BATCH_SIZE);
current_batch = 0;
last_toc = toc;
files_processed = 0;
running_total_batch_runtime = 0;
while current_batch < batch_count;

    current_batch = current_batch + 1;
    clc
    fprintf('running mass_expanding_block\n')
    fprintf('%g / %g files processed \n', batch_end, number_of_files);
    fprintf('running batch %g of %g \n', current_batch, batch_count),
    toc
    if current_batch > 1
        current_batch_runtime = (toc-last_toc)/60;
        running_total_batch_runtime = running_total_batch_runtime + ...
            current_batch_runtime; 
        average_batch_runtime = running_total_batch_runtime / (current_batch-1);
        fprintf('last batch took %4f minutes\n', current_batch_runtime);
        fprintf('estimated total runtime is %4f minutes \n', ...
            ( (average_batch_runtime)*batch_count));
        fprintf('estimated remaining runtime is %4f minutes \n', ...
            ( (average_batch_runtime)*(batch_count-(current_batch-1) ) ));
    end
    last_toc = toc;
    batch_start = max(batch_end, 1);
    batch_end = min(batch_start+(BATCH_SIZE-1), number_of_files);
    
    batch_input_filename = filenames(batch_start:batch_end);
    batch_output_filename = output_filenames(batch_start:batch_end);
    batch_is_modified = zeros(numel(batch_input_filename), 1);
%     batch_temp_image_storage = cell(BATCH_SIZE, 1);
    parfor n=1:numel(batch_input_filename)
        try
            [IMAGE_MODIFIED, ~, imgOut] = ...
                expanding_block(batch_input_filename{n});
            
            if IMAGE_MODIFIED
                batch_is_modified(n) = 1;
                imwrite(imgOut, batch_output_filename{n});
%               batch_temp_image_storage{n} = imgOut;
            end
        catch exception
            warning(exception.message)
        end
    end
    log = fopen(output_log, 'a');
    % log and write images before moving on to next batch
    for n=1:numel(batch_is_modified)
        files_processed = files_processed + 1;
%         if batch_is_modified(n)
%             imwrite(batch_temp_image_storage{n}, batch_output_filename{n})
%         end
        fprintf(log, '%g, %s, %g\n', ...
            files_processed, batch_input_filename{n}, batch_is_modified(n));
    end
    fclose(log);
    is_modified(batch_start:batch_end) = batch_is_modified;

end
fprintf('function complete!');
toc
end