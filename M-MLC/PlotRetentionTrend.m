clear;
%%
%%%%%%%%%%%%%%%%
% Load numbers %
%%%%%%%%%%%%%%%%

vs = [];
ret_time = ['1m'; '3m'; '6m'; '1y'];
for j = 1:size(ret_time, 1)
    cd(ret_time(j,:));
    folder = dir('cycle_*');
    gmix = load([folder.name '/fitted_parameters_GMix.mat']);
    vs = [vs; gmix.v];
    cd('..');
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot mean vs retention %
%%%%%%%%%%%%%%%%%%%%%%%%%%
states = ['ER'; 'P1'; 'P2'; 'P3'];
retention_time = [30; 90; 180; 360];

figure('Visible', 'on', 'Name', 'Mean');
for i = 1:4
    subplot(1, 4, i);
    plot(retention_time, vs(:,2*i), 'o-');
    title(states(i,:));
    xlabel('Retention Time (days)');
    if i == 1
        ylabel('Mean (V)');
    end
end
savefig('mean_vs_retention.fig');

papersize = get(gcf, 'PaperSize');
left = (papersize(1)- 11)/2;
bottom = (papersize(2)- 5)/2;
myfiguresize = [left, bottom, 11, 5];
set(gcf,'PaperPosition', myfiguresize);
print('mean_vs_retention', '-dpng');

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot stdev vs retention %
%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('Visible', 'on', 'Name', 'Stdev');
for i = 1:4
    subplot(1, 4, i);
    plot(retention_time, vs(:,2*i+1), 'o-');
    title(states(i,:));
    xlabel('Retention Time (days)');
    if i == 1
        ylabel('Stdev (V)');
    end
end
savefig('stdev_vs_retention.fig');
set(gcf,'PaperPosition', myfiguresize);
print('stdev_vs_retention', '-dpng');

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot fat tail vs retention %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
param_names = ['alpha.ER'; 'alpha.P1'; ' beta.P1'; 'alpha.P2'; ' beta.P2'; ' beta.P3'];

figure('Visible', 'on', 'Name', 'Fat Tail (alpha, beta)');
plot(retention_time, vs(:,10:15), 'o-');
legend(param_names);
xlabel('Retention Time (days)');
ylabel('Fat Tail');
savefig('tail_vs_retention.fig');
set(gcf,'PaperPosition', myfiguresize);
print('tail_vs_retention', '-dpng');

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot program error vs retention %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('Visible', 'on', 'Name', 'P(program error)');
for i = 1:4
    subplot(1, 4, i);
    plot(retention_time, exp(vs(:,i+15)), 'o-');
    title(states(i,:));
    xlabel('Retention Time (days)');
    if i == 1
        ylabel('P(program error)');
    end
end
savefig('perr_vs_retention.fig');
set(gcf,'PaperPosition', myfiguresize);
print('perr_vs_retention', '-dpng');














