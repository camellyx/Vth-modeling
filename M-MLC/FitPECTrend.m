%%%%%%%%%%%%%%%%
% Load numbers %
%%%%%%%%%%%%%%%%

% All PE Cycles
pecs = [0; 2500; 5000; 7500; 10000; 12000; 14000; 16000; 18000; 19000; 20000];

% All folders
block_folders = dir('block_*');
j = 1;
for i = 1:size(block_folders, 1)
    if ( size(strfind(block_folders(i).name, '_'), 2) == 1 )
        block(j) = sscanf(block_folders(i).name, 'block_%d');
        j = j+1;
    end
end

% All blocks sorted
block = sort(block);

% From the smallest block
x = [];
vs = [];
for i = 1:size(block, 2)
    cd(sprintf('block_%d', block(i)));
    for j = 1:i
        folder = sprintf('cycle_%04d', pecs(j));
        gmix = load([folder '/fitted_parameters_GMix.mat']);
        x = [x pecs(j)];
        vs = [vs gmix.v'];
    end
    cd('..');
end

% All pecs
for i = 1:size(pecs, 1)
    ypecs(:,i) = median(vs(:,x==pecs(i)),2);
end
pecpars = [];

%%
%%%%%%%%%%%%%%%%%%%%
% Fit mean vs PEC %
%%%%%%%%%%%%%%%%%%%%
% Power law fit
plfun = @(pec, v) v(1).*((pec).^v(2)) + v(3);
mysearch = @(myfun, myv) fminsearch( ...
      myfun, myv, ...
      optimset('MaxIter', 1e5, ...
               'MaxFunEvals', 3e5, ...
               'TolFun', 1e-6, ...
               'TolX', 1e-6, ...
               'FunValCheck', 'off'));

%%
%%%%%%%%%%%%%%%%%%%%
% Plot mean vs PEC %
%%%%%%%%%%%%%%%%%%%%
states = ['ER'; 'P1'; 'P2'; 'P3'];

figure('Visible', 'on', 'Name', 'Mean');
for i = 1:4
    subplot(2, 2, i);
    % plot raw data
    zz = squeeze(vs(2*i,:,:));
    plot(x,zz,'bo');
    hold;
    % update objfun
    xx = pecs;
    zz = ypecs(2*i,:)';
    objfun = @(v) sum(sum((plfun(xx, v) - zz).^2)) + 10000*(v(2)<=0);
    % fit
    pars = mysearch(objfun, [1e-2 1 zz(1)]);
    pecpars = [pecpars; pars];
    xx = pecs(1):1:pecs(end);
    zz = plfun(xx, pars);
    % plot fitted curve
    plot(xx',zz','r');
    title(states(i,:));
    xlabel('PEC');
    ylabel('Mean (V)');
end

savefig('fitted_mean_vs_PEC.fig');

% papersize = get(gcf, 'PaperSize');
% left = (papersize(1)- 11)/2;
% bottom = (papersize(2)- 5)/2;
% myfiguresize = [left, bottom, 20, 10];
% set(gcf,'PaperPosition', myfiguresize);
print('fitted_mean_vs_PEC', '-dpng');

%%
%%%%%%%%%%%%%%%%%%%%%
% Plot stdev vs PEC %
%%%%%%%%%%%%%%%%%%%%%
figure('Visible', 'on', 'Name', 'Stdev');
for i = 1:4
    subplot(2, 2, i);
    % plot raw data
    zz = squeeze(vs(2*i+1,:,:));
    plot(x,zz,'bo');
    hold;
    % update objfun
    xx = pecs;
    zz = ypecs(2*i+1,:)';
    objfun = @(v) sum(sum((plfun(xx, v) - zz).^2));
    % fit
    pars = mysearch(objfun, [1e-2 1 zz(1)]);
    pecpars = [pecpars; pars];
    xx = pecs(1):1:pecs(end);
    zz = plfun(xx, pars);
    % plot fitted curve
    plot(xx',zz','r');
    title(states(i,:));
    xlabel('PEC');
    ylabel('Stdev (V)');
end
savefig('fitted_stdev_vs_PEC.fig');
% set(gcf,'PaperPosition', myfiguresize);
print('fitted_stdev_vs_PEC', '-dpng');

%%
%%%%%%%%%%%%%%%%%%%%%%%%
% Plot fat tail vs PEC %
%%%%%%%%%%%%%%%%%%%%%%%%
param_names = ['alpha.ER'; 'alpha.P1'; ' beta.P1'; 'alpha.P2'; ' beta.P2'; 'alpha.P3'; ' beta.P3'];

figure('Visible', 'on', 'Name', 'Fat Tail (alpha, beta)');
for i = 1:6
    subplot(3,2,i);
    % plot raw data
    zz = squeeze(vs(9+i,:,:));
    plot(x,zz,'bo');
    hold;
    % update objfun
    xx = pecs;
    zz = ypecs(9+i,:)';
    objfun = @(v) sum(sum((plfun(xx, v) - zz).^2));
    % fit
    pars = mysearch(objfun, [1e-2 2.5 zz(1)]);
    pecpars = [pecpars; pars];
    xx = pecs(1):1:pecs(end);
    zz = plfun(xx, pars);
    % plot fitted curve
    plot(xx',zz','r');
    title(param_names(i,:));
    xlabel('PEC');
    ylabel('Fat Tail');
end
savefig('fitted_tail_vs_PEC.fig');
% set(gcf,'PaperPosition', myfiguresize);
print('fitted_tail_vs_PEC', '-dpng');

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot program error vs PEC %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('Visible', 'on', 'Name', 'P(program error)');
for i = 1:4
    subplot(2, 2, i);
    % plot raw data
    zz = squeeze(vs(15+i,:,:));
    plot(x,zz,'bo');
    hold;
    % update objfun
    xx = pecs;
    zz = ypecs(15+i,:)';
    objfun = @(v) sum(sum((plfun(xx, v) - zz).^2));
    % fit
    pars = mysearch(objfun, [1e-2 1 zz(1)]);
    pecpars = [pecpars; pars];
    xx = pecs(1):1:pecs(end);
    zz = plfun(xx, pars);
    % plot fitted curve
    plot(xx',zz','r');
    title(states(i,:));
    xlabel('PEC');
    ylabel('P(program error)');
end
savefig('fitted_perr_vs_PEC.fig');
% set(gcf,'PaperPosition', myfiguresize);
print('fitted_perr_vs_PEC', '-dpng');

save('fitted_pec_trend', 'pecpars');

return;














