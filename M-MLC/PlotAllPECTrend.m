clear;
%%
%%%%%%%%%%%%%%%%
% Load numbers %
%%%%%%%%%%%%%%%%

pec = [0; 2500; 5000; 7500; 10000; 12000; 14000; 16000; 18000; 19000; 20000];

block_folders = dir('block_*');
j = 1;
for i = 1:size(block_folders, 1)
    if ( size(strfind(block_folders(i).name, '_'), 2) == 1 )
        block(j) = sscanf(block_folders(i).name, 'block_%d');
        j = j+1;
    end
end
block = sort(block);
for i = 1:size(block, 2)
    cd(sprintf('block_%d', block(i)));
    for j = 1:size(pec, 1)
        if j > i
            vs(:,i,j) = NaN;
        else
            folder = sprintf('cycle_%04d', pec(j));
            gmix = load([folder '/fitted_parameters_GMix.mat']);
            vs(:,i,j) = gmix.v';
        end
    end
    cd('..');
end

%%
%%%%%%%%%%%%%%%%%%%%
% Plot mean vs PEC %
%%%%%%%%%%%%%%%%%%%%
states = ['ER'; 'P1'; 'P2'; 'P3'];
[x,y] = meshgrid(pec, block);

figure('Visible', 'on', 'Name', 'Mean');
for i = 1:4
    subplot(2, 2, i);
    z = squeeze(vs(2*i,:,:));
    surf(x,y,z);
    title(states(i,:));
    xlabel('PEC');
    ylabel('Block Number');
    zlabel('Mean (V)');
end
savefig('mean_vs_PEC.fig');

papersize = get(gcf, 'PaperSize');
left = (papersize(1)- 11)/2;
bottom = (papersize(2)- 5)/2;
myfiguresize = [left, bottom, 20, 10];
set(gcf,'PaperPosition', myfiguresize);
print('mean_vs_PEC', '-dpng');

%%
%%%%%%%%%%%%%%%%%%%%%
% Plot stdev vs PEC %
%%%%%%%%%%%%%%%%%%%%%
figure('Visible', 'on', 'Name', 'Stdev');
for i = 1:4
    subplot(2, 2, i);
    z = squeeze(vs(2*i+1,:,:));
    surf(x,y,z);
    title(states(i,:));
    xlabel('PEC');
    ylabel('Block Number');
    zlabel('Stdev (V)');
end
savefig('stdev_vs_PEC.fig');
set(gcf,'PaperPosition', myfiguresize);
print('stdev_vs_PEC', '-dpng');

%%
%%%%%%%%%%%%%%%%%%%%%%%%
% Plot fat tail vs PEC %
%%%%%%%%%%%%%%%%%%%%%%%%
param_names = ['alpha.ER'; 'alpha.P1'; ' beta.P1'; 'alpha.P2'; ' beta.P2'; 'alpha.P3'; ' beta.P3'];

figure('Visible', 'on', 'Name', 'Fat Tail (alpha, beta)');
for i = 1:6
    subplot(3,2,i);
    z = squeeze(vs(9+i,:,:));
    surf(x,y,z);
    title(param_names(i,:));
    xlabel('PEC');
    ylabel('Block Number');
    zlabel('Fat Tail');
end
savefig('tail_vs_PEC.fig');
set(gcf,'PaperPosition', myfiguresize);
print('tail_vs_PEC', '-dpng');

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot program error vs PEC %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('Visible', 'on', 'Name', 'P(program error)');
for i = 1:4
    subplot(2, 2, i);
    z = squeeze(exp(vs(i+15,:,:)));
    surf(x,y,z);
    title(states(i,:));
    xlabel('PEC');
    ylabel('Block Number');
    zlabel('P(program error)');
end
savefig('perr_vs_PEC.fig');
set(gcf,'PaperPosition', myfiguresize);
print('perr_vs_PEC', '-dpng');

return;














