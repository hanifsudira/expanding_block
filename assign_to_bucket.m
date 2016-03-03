function bucket = assign_to_bucket(group)
% Place the blocks from groups i-1, i, and i+1 into bucket i

bucket = cell(numel(group), 1);

%% PROPERLY FORMAT
toRow = @(A) reshape(A, 1, []);
for i=1:numel(group)
group{i}.x = toRow(group{i}.x);
group{i}.y = toRow(group{i}.y);
group{i}.pixel = toRow(group{i}.pixel);
group{i}.variance = toRow(group{i}.variance);
end %REFORMAT EACH PROPERTY AS ROW

for i=1:numel(group)
    bucket{i} = overlap_block;
    if (i>1 && i<numel(group))
        bucket{i}.pixel = [...
            group{i-1}.pixel, group{i}.pixel, group{i+1}.pixel];
        bucket{i}.x = [group{i-1}.x, group{i}.x, group{i+1}.x];
        bucket{i}.y = [group{i-1}.y, group{i}.y, group{i+1}.y];
        bucket{i}.variance = [group{i-1}.variance, group{i}.variance, ...
            group{i+1}.variance];

    elseif i > 1
        bucket{i}.pixel = [group{i-1}.pixel, group{i}.pixel];
        bucket{i}.x = [group{i-1}.x, group{i}.x];
        bucket{i}.y = [group{i-1}.y, group{i}.y];
        bucket{i}.variance = [group{i-1}.variance, group{i}.variance];
        
    else % i = 1
        bucket{i}.pixel = [group{i}.pixel, group{i+1}.pixel];
        bucket{i}.x = [group{i}.x, group{i+1}.x];
        bucket{i}.y = [group{i}.y, group{i+1}.y];
        bucket{i}.variance = [group{i}.variance, group{i+1}.variance];
    end
end