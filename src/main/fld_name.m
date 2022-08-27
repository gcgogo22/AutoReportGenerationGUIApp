function sub_fld = fld_name(main_fld)
% Input a folder directory to this function and it will return a cell array
% with all the sub-folder names
files = dir(main_fld);
dirFlags = [files.isdir];
subFlds = files(dirFlags);

num = size(subFlds, 1);
sub_fld = cell(num-2, 1);
for i = 3:1:num
    sub_fld{i-2} = fullfile(main_fld, subFlds(i).name);
end
end