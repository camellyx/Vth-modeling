clear;
%%%%%%%%%%%%%%%%
% Load numbers %
%%%%%%%%%%%%%%%%

folders = dir('cycle_*');
pecs = sort(arrayfun(@(f) sscanf(f.name, 'cycle_%d'), folders));
vopts = [];
rbers = [];
rber_splits = [];
rber_mins = [];
rber_split_mins = [];
rber_ests = [];
rber_split_ests = [];
for i = 1:size(pecs,1)
    vths = readBlock('cycle_%04d', '', '', pecs(i), pecs(i));
    [vopt, rber, rber_split] = getVopt(vths);
    gauss = load(sprintf('cycle_%04d/fitted_parameters.mat', pecs(i)));
    [vopt_gauss, rber_gauss, rber_split_gauss, pdf_gauss] = getGaussVopt(gauss.v);
    gmix = load(sprintf('cycle_%04d/fitted_parameters_GMix.mat', pecs(i)));
    [vopt_gmix, rber_gmix, rber_split_gmix, pdf_gmix] = getGMixVopt(gmix.v);
    gtmix = load(sprintf('cycle_%04d/fitted_parameters_GTMix.mat', pecs(i)));
    [vopt_gtmix, rber_gtmix, rber_split_gtmix, pdf_gtmix] = getGTMixVopt(gtmix.v);
    
    vopts(:,i,:) = [vopt vopt_gauss vopt_gmix vopt_gtmix]';
    rber_mins(:,i) = [rber; rber_gauss; rber_gmix; rber_gtmix];
    rber_split_mins(:,i,:) = [rber_split rber_split_gauss rber_split_gmix rber_split_gtmix]';
    
    [rber_gauss, rber_split_gauss] = pdf2RBER(pdf_gauss, vopt);
    [rber_gmix, rber_split_gmix] = pdf2RBER(pdf_gmix, vopt);
    [rber_gtmix, rber_split_gtmix] = pdf2RBER(pdf_gtmix, vopt);
    rbers(:,i) = [rber; rber_gauss; rber_gmix; rber_gtmix];
    rber_splits(:,i,:) = [rber_split rber_split_gauss rber_split_gmix rber_split_gtmix]';
    
    [rber_gauss, rber_split_gauss] = getRBER(vths, vopt_gauss);
    [rber_gmix, rber_split_gmix] = getRBER(vths, vopt_gmix);
    [rber_gtmix, rber_split_gtmix] = getRBER(vths, vopt_gtmix);
    rber_ests(:,i) = [rber; rber_gauss; rber_gmix; rber_gtmix];
    rber_split_ests(:,i,:) = [rber_split rber_split_gauss rber_split_gmix rber_split_gtmix]';
end
rber_splits(:,:,3) = rbers;
rber_split_mins(:,:,3) = rber_mins;
rber_split_ests(:,:,3) = rber_ests;

%%%%%%%%%%%%%%%%%%%%%
% Plot vopts vs PEC %
%%%%%%%%%%%%%%%%%%%%%
model = [' raw '; 'gauss'; 'glmix'; 'gtmix'];
vname = ['V_a'; 'V_b'; 'V_c'];

figure('Visible', 'on', 'Name', 'Vopt');
for i = 1:3
    subplot(1, 3, i);
    plot(pecs, vopts(:,:,i)' + repmat([0 .05 .1 .15], 11, 1), 'o-');
    title(vname(i,:));
    xlabel('PEC');
    legend(model);
    if i == 1
        ylabel('V_{opt} (V)');
    end
end
savefig('vopt_vs_pec.fig');

papersize = get(gcf, 'PaperSize');
left = (papersize(1)- 11)/2;
bottom = (papersize(2)- 5)/2;
myfiguresize = [left, bottom, 11, 5];
set(gcf,'PaperPosition', myfiguresize);
print('vopt_vs_pec', '-dpng');

%%%%%%%%%%%%%%%%%%%%%%%%
% Plot min rber vs PEC %
%%%%%%%%%%%%%%%%%%%%%%%%
rber_name = ['LSB'; 'MSB'; 'ALL'];

figure('Visible', 'on', 'Name', 'min RBER');
for i = 1:3
    subplot(1, 3, i);
    plot(pecs, rber_split_mins(:,:,i)', 'o-');
    title(rber_name(i,:));
    xlabel('PEC');
    legend(model);
    if i == 1
        ylabel('min achievable modelled RBER by each model');
    end
end
savefig('rber_min_vs_pec.fig');
set(gcf,'PaperPosition', myfiguresize);
print('rber_min_vs_pec', '-dpng');

%%%%%%%%%%%%%%%%%%%%
% Plot rber vs PEC %
%%%%%%%%%%%%%%%%%%%%
figure('Visible', 'on', 'Name', 'RBER');
for i = 1:3
    subplot(1, 3, i);
    plot(pecs, rber_splits(:,:,i)', 'o-');
    title(rber_name(i,:));
    xlabel('PEC');
    legend(model);
    if i == 1
        ylabel('estimated RBER by each model at measured OPT');
    end
end
savefig('rber_vs_pec.fig');
set(gcf,'PaperPosition', myfiguresize);
print('rber_vs_pec', '-dpng');

%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot Vopt rber vs PEC %
%%%%%%%%%%%%%%%%%%%%%%%%%
figure('Visible', 'on', 'Name', 'RBER @ Vopt');
for i = 1:3
    subplot(1, 3, i);
    plot(pecs, rber_split_ests(:,:,i)', 'o-');
    title(rber_name(i,:));
    xlabel('PEC');
    legend(model);
    if i == 1
        ylabel('actual RBER at Vopt of each model');
    end
end
savefig('rber_est_vs_pec.fig');
set(gcf,'PaperPosition', myfiguresize);
print('rber_est_vs_pec', '-dpng');

return;







