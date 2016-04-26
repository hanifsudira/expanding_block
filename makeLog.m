function LOG_FILENAME = makeLog(calling_function_name)
%MAKES A LOGFILE for the calling function. calling_function name is a
%CHARACTER ARRAY. 

current_time = char(datetime('now','TimeZone','local','Format', ...
    'd-MMM-y-HH_mm'));
LOG_FILENAME = strcat(calling_function_name, current_time, '.txt');
log_out = fopen(LOG_FILENAME, 'w');

introString = sprintf('LOGFILE for %s at %s', ...
    calling_function_name, current_time);
fprintf(log_out, introString);
fclose(log_out);