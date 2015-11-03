clear;
%%%%%%%%%%%%%%%%
% Load numbers %
%%%%%%%%%%%%%%%%

ret_time = ['1m'; '3m'; '6m'; '1y'];

block_folders = dir('block_*_Retention');
for i = 1:size(block_folders, 1)
    block(i) = sscanf(block_folders(i).name, 'block_%d_Retention');
end
block = sort(block);
for i = 1:size(block, 2)
    cd(sprintf('block_%d_Retention', block(i)));
    for j = 1:size(ret_time, 1)
        cd(ret_time(j,:));
        folder = dir('cycle_*');
        pec(i) = sscanf(folder.name, 'cycle_%d');
        gmix = load([folder.name '/fitted_parameters_GTMix.mat']);
        vs(:,j+1,i) = gmix.v';
        cd('..');
    end
    cd('..');
    cd(sprintf('block_%d/cycle_%04d', block(i), pec(i)));
    gmix = load('fitted_parameters_GTMix.mat');
    vs(:,1,i) = gmix.v';
    cd('../..');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot mean vs retention %
%%%%%%%%%%%%%%%%%%%%%%%%%%
states = ['ER'; 'P1'; 'P2'; 'P3'];
retention_time = [0; 30; 90; 180; 360];
[x,y] = meshgrid(pec, retention_time);

figure('Visible', 'on', 'Name', 'Mean');
for i = 1:4
    subplot(2, 2, i);
    z = squeeze(vs(2*i,:,:));
    surf(x,y,z);
    title(states(i,:));
    xlabel('PEC');
    ylabel('Retention Time (days)');
    zlabel('Mean (V)');
end
savefig('tmean_vs_retention.fig');

papersize = get(gcf, 'PaperSize');
left = (papersize(1)- 11)/2;
bottom = (papersize(2)- 5)/2;
myfiguresize = [left, bottom, 20, 10];
set(gcf,'PaperPosition', myfiguresize);
print('tmean_vs_retention', '-dpng');

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot stdev vs retention %
%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('Visible', 'on', 'Name', 'Stdev');
for i = 1:4
    subplot(2, 2, i);
    z = squeeze(vs(2*i+1,:,:));
    surf(x,y,z);
    title(states(i,:));
    xlabel('PEC');
    ylabel('Retention Time (days)');
    zlabel('Stdev (V)');
end
savefig('tstdev_vs_retention.fig');
set(gcf,'PaperPosition', myfiguresize);
print('tstdev_vs_retention', '-dpng');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot fat tail vs retention %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
param_names = ['alpha.ER'; 'alpha.P1'; ' beta.P1'; 'alpha.P2'; ' beta.P2'; 'alpha.P3'; ' beta.P3'; 'a.ER_err'; 'a.P1_err'];

figure('Visible', 'on', 'Name', 'Fat Tail (alpha, beta)');
for i = 1:9
    subplot(3,3,i);
    z = squeeze(vs(9+i,:,:));
    surf(x,y,z);
    title(param_names(i,:));
    xlabel('PEC');
    ylabel('Retention Time (days)');
    zlabel('Fat Tail');
end
savefig('ttail_vs_retention.fig');
set(gcf,'PaperPosition', myfiguresize);
print('ttail_vs_retention', '-dpng');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot program error vs retention %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('Visible', 'on', 'Name', 'P(program error)');
for i = 1:2
    subplot(1, 2, i);
    z = squeeze(exp(vs(i+18,:,:)));
    surf(x,y,z);
    title(states(i,:));
    xlabel('PEC');
    ylabel('Retention Time (days)');
    zlabel('P(program error)');
end
savefig('tperr_vs_retention.fig');
set(gcf,'PaperPosition', myfiguresize);
print('tperr_vs_retention', '-dpng');

return;


% clear;
% %%%%%%%%%%%%%%%%
% % Load numbers %
% %%%%%%%%%%%%%%%%
% 
% ret_time = ['1m'; '3m'; '6m'; '1y'];
% 
% block_folders = dir('block_*_Retention');
% for i = 1:size(block_folders, 1)
%     block(i) = sscanf(block_folders(i).name, 'block_%d_Retention');
% end
% block = sort(block);
% for i = 1:size(block, 2)
%     cd(sprintf('block_%d_Retention', block(i)));
%     for j = 1:size(ret_time, 1)
%         cd(ret_time(j,:));
%         folder = dir('cycle_*');
%         pec(i) = sscanf(folder.name, 'cycle_%d');
%         gmix = load([folder.name '/fitted_parameters_GMix.mat']);
%         vs(:,j+1,i) = gmix.v';
%         cd('..');
%     end
%     cd('..');
%     cd(sprintf('block_%d/cycle_%04d', block(i), pec(i)));
%     gmix = load('fitted_parameters_GMix.mat');
%     vs(:,1,i) = gmix.v';
%     cd('../..');
% end
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%
% % Plot mean vs retention %
% %%%%%%%%%%%%%%%%%%%%%%%%%%
% states = ['ER'; 'P1'; 'P2'; 'P3'];
% retention_time = [0; 30; 90; 180; 360];
% [x,y] = meshgrid(pec, retention_time);
% 
% figure('Visible', 'on', 'Name', 'Mean');
% for i = 1:4
%     subplot(2, 2, i);
%     z = squeeze(vs(2*i,:,:));
%     surf(x,y,z);
%     title(states(i,:));
%     xlabel('PEC');
%     ylabel('Retention Time (days)');
%     zlabel('Mean (V)');
% end
% savefig('mean_vs_retention.fig');
% 
% papersize = get(gcf, 'PaperSize');
% left = (papersize(1)- 11)/2;
% bottom = (papersize(2)- 5)/2;
% myfiguresize = [left, bottom, 20, 10];
% set(gcf,'PaperPosition', myfiguresize);
% print('mean_vs_retention', '-dpng');
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Plot stdev vs retention %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure('Visible', 'on', 'Name', 'Stdev');
% for i = 1:4
%     subplot(2, 2, i);
%     z = squeeze(vs(2*i+1,:,:));
%     surf(x,y,z);
%     title(states(i,:));
%     xlabel('PEC');
%     ylabel('Retention Time (days)');
%     zlabel('Stdev (V)');
% end
% savefig('stdev_vs_retention.fig');
% set(gcf,'PaperPosition', myfiguresize);
% print('stdev_vs_retention', '-dpng');
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Plot fat tail vs retention %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% param_names = ['alpha.ER'; 'alpha.P1'; ' beta.P1'; 'alpha.P2'; ' beta.P2'; 'alpha.P3'; ' beta.P3'];
% 
% figure('Visible', 'on', 'Name', 'Fat Tail (alpha, beta)');
% for i = 1:7
%     subplot(3,3,i);
%     z = squeeze(vs(9+i,:,:));
%     surf(x,y,z);
%     title(param_names(i,:));
%     xlabel('PEC');
%     ylabel('Retention Time (days)');
%     zlabel('Fat Tail');
% end
% savefig('tail_vs_retention.fig');
% set(gcf,'PaperPosition', myfiguresize);
% print('tail_vs_retention', '-dpng');
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Plot program error vs retention %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure('Visible', 'on', 'Name', 'P(program error)');
% for i = 1:4
%     subplot(2, 2, i);
%     z = squeeze(exp(vs(i+16,:,:)));
%     surf(x,y,z);
%     title(states(i,:));
%     xlabel('PEC');
%     ylabel('Retention Time (days)');
%     zlabel('P(program error)');
% end
% savefig('perr_vs_retention.fig');
% set(gcf,'PaperPosition', myfiguresize);
% print('perr_vs_retention', '-dpng');
% 
% return;














