%%%%%%%%%%%%%%%%
% Load numbers %
%%%%%%%%%%%%%%%%

folders = dir('cycle_*');
pecs = sort(arrayfun(@(f) sscanf(f.name, 'cycle_%d'), folders));
vs = [];
for i = 1:size(pecs,1)
    gmix = load(sprintf('cycle_%04d/fitted_parameters_GTMix.mat', pecs(i)));
    vs = [vs; gmix.v];
end

%%%%%%%%%%%%%%%%%%%%
% Plot mean vs PEC %
%%%%%%%%%%%%%%%%%%%%
states = ['ER'; 'P1'; 'P2'; 'P3'];

figure('Visible', 'on', 'Name', 'Mean');
for i = 1:4
    subplot(1, 4, i);
    plot(pecs, vs(:,2*i), 'o-');
    title(states(i,:));
    xlabel('PEC');
    if i == 1
        ylabel('Mean (V)');
    end
end
savefig('tmean_vs_pec.fig');

papersize = get(gcf, 'PaperSize');
left = (papersize(1)- 11)/2;
bottom = (papersize(2)- 5)/2;
myfiguresize = [left, bottom, 11, 5];
set(gcf,'PaperPosition', myfiguresize);
print('tmean_vs_pec', '-dpng');

%%%%%%%%%%%%%%%%%%%%%
% Plot stdev vs PEC %
%%%%%%%%%%%%%%%%%%%%%
figure('Visible', 'on', 'Name', 'Stdev');
for i = 1:4
    subplot(1, 4, i);
    plot(pecs, vs(:,2*i+1), 'o-');
    title(states(i,:));
    xlabel('PEC');
    if i == 1
        ylabel('Stdev (V)');
    end
end
savefig('tstdev_vs_pec.fig');
set(gcf,'PaperPosition', myfiguresize);
print('tstdev_vs_pec', '-dpng');

%%%%%%%%%%%%%%%%%%%%%%%%
% Plot fat tail vs PEC %
%%%%%%%%%%%%%%%%%%%%%%%%
param_names = ['alpha.ER'; 'alpha.P1'; ' beta.P1'; 'alpha.P2'; ' beta.P2'; 'alpha.P3'; ' beta.P3'; 'a.ER_err'; 'a.P1_err'];

figure('Visible', 'on', 'Name', 'Fat Tail (alpha, beta)');
semilogy(pecs, vs(:,10:18), 'o-');
legend(param_names);
xlabel('PEC');
ylabel('Fat Tail');
savefig('ttail_vs_pec.fig');
set(gcf,'PaperPosition', myfiguresize);
print('ttail_vs_pec', '-dpng');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot program error vs PEC %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('Visible', 'on', 'Name', 'P(program error)');
for i = 1:2
    subplot(1, 2, i);
    plot(pecs, exp(vs(:,i+18)), 'o-');
    title(states(i,:));
    xlabel('PEC');
    if i == 1
        ylabel('P(program error)');
    end
end
savefig('tperr_vs_pec.fig');
set(gcf,'PaperPosition', myfiguresize);
print('tperr_vs_pec', '-dpng');


% %%%%%%%%%%%%%%%%
% % Load numbers %
% %%%%%%%%%%%%%%%%
% 
% folders = dir('cycle_*');
% pecs = sort(arrayfun(@(f) sscanf(f.name, 'cycle_%d'), folders));
% vs = [];
% for i = 1:size(pecs,1)
%     gmix = load(sprintf('cycle_%04d/fitted_parameters_GMix.mat', pecs(i)));
%     vs = [vs; gmix.v];
% end
% 
% %%%%%%%%%%%%%%%%%%%%
% % Plot mean vs PEC %
% %%%%%%%%%%%%%%%%%%%%
% states = ['ER'; 'P1'; 'P2'; 'P3'];
% 
% figure('Visible', 'on', 'Name', 'Mean');
% for i = 1:4
%     subplot(1, 4, i);
%     plot(pecs, vs(:,2*i), 'o-');
%     title(states(i,:));
%     xlabel('PEC');
%     if i == 1
%         ylabel('Mean (V)');
%     end
% end
% savefig('mean_vs_pec.fig');
% 
% papersize = get(gcf, 'PaperSize');
% left = (papersize(1)- 11)/2;
% bottom = (papersize(2)- 5)/2;
% myfiguresize = [left, bottom, 11, 5];
% set(gcf,'PaperPosition', myfiguresize);
% print('mean_vs_pec', '-dpng');
% 
% %%%%%%%%%%%%%%%%%%%%%
% % Plot stdev vs PEC %
% %%%%%%%%%%%%%%%%%%%%%
% figure('Visible', 'on', 'Name', 'Stdev');
% for i = 1:4
%     subplot(1, 4, i);
%     plot(pecs, vs(:,2*i+1), 'o-');
%     title(states(i,:));
%     xlabel('PEC');
%     if i == 1
%         ylabel('Stdev (V)');
%     end
% end
% savefig('stdev_vs_pec.fig');
% set(gcf,'PaperPosition', myfiguresize);
% print('stdev_vs_pec', '-dpng');
% 
% %%%%%%%%%%%%%%%%%%%%%%%%
% % Plot fat tail vs PEC %
% %%%%%%%%%%%%%%%%%%%%%%%%
% param_names = ['alpha.ER'; 'alpha.P1'; ' beta.P1'; 'alpha.P2'; ' beta.P2'; 'alpha.P3'; ' beta.P3'];
% 
% figure('Visible', 'on', 'Name', 'Fat Tail (alpha, beta)');
% plot(pecs, vs(:,10:16), 'o-');
% legend(param_names);
% xlabel('PEC');
% ylabel('Fat Tail');
% savefig('tail_vs_pec.fig');
% set(gcf,'PaperPosition', myfiguresize);
% print('tail_vs_pec', '-dpng');
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Plot program error vs PEC %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure('Visible', 'on', 'Name', 'P(program error)');
% for i = 1:4
%     subplot(1, 4, i);
%     plot(pecs, exp(vs(:,i+16)), 'o-');
%     title(states(i,:));
%     xlabel('PEC');
%     if i == 1
%         ylabel('P(program error)');
%     end
% end
% savefig('perr_vs_pec.fig');
% set(gcf,'PaperPosition', myfiguresize);
% print('perr_vs_pec', '-dpng');













