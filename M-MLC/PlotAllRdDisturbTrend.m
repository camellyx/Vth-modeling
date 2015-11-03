clear;
%%
%%%%%%%%%%%%%%%%
% Load numbers %
%%%%%%%%%%%%%%%%

read_cycle = [0; 2500; 5000; 10000; 20000];
pec = [10000; 14000; 19000; 20000];

block_folders = dir('block_*_Rd_Disturb');
for i = 1:size(block_folders, 1)
    block(i) = sscanf(block_folders(i).name, 'block_%d_Rd_Disturb');
end
block = sort(block);
for i = 1:size(block, 2)
    cd(sprintf('block_%d_Rd_Disturb', block(i)));
    for j = 1:size(read_cycle, 1)
        folder = sprintf('block_read_cycle_%04d', read_cycle(j));
        gmix = load([folder '/fitted_parameters_GMix.mat']);
        vs(:,j,i) = gmix.v';
    end
    cd('..');
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot mean vs read disturb %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
states = ['ER'; 'P1'; 'P2'; 'P3'];
[x,y] = meshgrid(pec, read_cycle);

figure('Visible', 'on', 'Name', 'Mean');
for i = 1:4
    subplot(2, 2, i);
    z = squeeze(vs(2*i,:,:));
    surf(x,y,z);
    title(states(i,:));
    xlabel('PEC');
    ylabel('Read Disturb Count');
    zlabel('Mean (V)');
end
savefig('mean_vs_rd_disturb.fig');

papersize = get(gcf, 'PaperSize');
left = (papersize(1)- 11)/2;
bottom = (papersize(2)- 5)/2;
myfiguresize = [left, bottom, 20, 10];
set(gcf,'PaperPosition', myfiguresize);
print('mean_vs_rd_disturb', '-dpng');

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot stdev vs read disturb %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('Visible', 'on', 'Name', 'Stdev');
for i = 1:4
    subplot(2, 2, i);
    z = squeeze(vs(2*i+1,:,:));
    surf(x,y,z);
    title(states(i,:));
    xlabel('PEC');
    ylabel('Read Disturb Count');
    zlabel('Stdev (V)');
end
savefig('stdev_vs_rd_disturb.fig');
set(gcf,'PaperPosition', myfiguresize);
print('stdev_vs_rd_disturb', '-dpng');

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot fat tail vs read disturb %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
param_names = ['alpha.ER'; 'alpha.P1'; ' beta.P1'; 'alpha.P2'; ' beta.P2'; ' beta.P3'];

figure('Visible', 'on', 'Name', 'Fat Tail (alpha, beta)');
for i = 1:6
    subplot(3,2,i);
    z = squeeze(vs(9+i,:,:));
    surf(x,y,z);
    title(param_names(i,:));
    xlabel('PEC');
    ylabel('Read Disturb Count');
    zlabel('Fat Tail');
end
savefig('tail_vs_rd_disturb.fig');
set(gcf,'PaperPosition', myfiguresize);
print('tail_vs_rd_disturb', '-dpng');

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot program error vs read disturb %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('Visible', 'on', 'Name', 'P(program error)');
for i = 1:4
    subplot(2, 2, i);
    z = squeeze(exp(vs(i+15,:,:)));
    surf(x,y,z);
    title(states(i,:));
    xlabel('PEC');
    ylabel('Read Disturb Count');
    zlabel('P(program error)');
end
savefig('perr_vs_rd_disturb.fig');
set(gcf,'PaperPosition', myfiguresize);
print('perr_vs_rd_disturb', '-dpng');

return;














