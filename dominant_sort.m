function sorted_dict = dominant_sort(word)
% lexigraphic sort of vector with associated keys
% outputs a 2-column matrix
    n = numel(word);
    word = reshape(word, n, 1);
    key = reshape(1:n, n, 1);
    dict = [word,key];
    sorted_dict = sortrows(dict);
end