
%% all figures directly in this folder
fig_files = dir('*.fig');

for j = 1:size(fig_files, 1)
    if ( size(strfind(fig_files(j).name, 'hist'), 2) >= 1 )
        continue;
    end
    disp(fig_files(j).name)
    f = openfig(fig_files(j).name);
    saveppt2('AllFigs.ppt', 'f', f, 't', fig_files(j).name);
end

%% all figures in subfolders
% folders = dir('./*');
% 
% for i = 1:size(folders, 1)
%     if (~isdir(folders(i).name))
%         continue;
%     end
%     
%     fig_files = dir([folders(i).name '/*.fig']);
% 
%     for j = 1:size(fig_files, 1)
%         f = openfig([folders(i).name '/' fig_files(j).name]);
%         saveppt2('AllFigs.ppt', 'f', f, 't', [folders(i).name '/' fig_files(j).name]);
%     end
%     
% end

