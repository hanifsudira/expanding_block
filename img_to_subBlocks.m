function subBlocks = img_to_subBlocks(img, blockDistance)

%{
img: cropped image
init: a expand_block_init OBJECT
%}
subBlocks_temp = reshape(img, init.blockDistance, init.blockDistance, ...
    numel(img)./(init.blockDistance^2));
dim_subBlocks = size(img)./init.blockDistance;
subBlocks = cell(dim_subBlocks);
for j=1:numel(subBlocks)
subBlocks{j} = subBlocks_temp(:, :, j);
end