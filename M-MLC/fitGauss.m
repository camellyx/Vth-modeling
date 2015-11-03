function [v] = fitGauss(folder, pec, vths)

    % call this function in block_XXX folder
    fig_file_name = sprintf([folder '/fitted_vth_distribution.fig'], pec);
    out_file_name = sprintf([folder '/fitted_parameters.mat'], pec);
%     if exist(out_file_name, 'file') == 2
%         load(out_file_name);
%         if exist(fig_file_name, 'file') == 2
%             openfig(fig_file_name, 'new', 'invisible');
%             print(sprintf([folder '/fitted_vth_distribution'], pec), '-dpng');
%             return;
%         end
%     end
    
    figure('Visible', 'off');

    % read vths for this block under pec
    % vths = readBlock(pec);

    % generate measured pdf
    mpdf.ER = accumarray(vths.ER+1, 1) ./ size(vths.ER, 1);
    mpdf.ER(505) = 0;

    mpdf.P1 = accumarray(vths.P1+1, 1) ./ size(vths.P1, 1);
    mpdf.P1(505) = 0;

    mpdf.P2 = accumarray(vths.P2+1, 1) ./ size(vths.P2, 1);
    mpdf.P2(505) = 0;

    mpdf.P3 = accumarray(vths.P3+1, 1) ./ size(vths.P3, 1);
    mpdf.P3(505) = 0;

    % get the actual counts for each bin
%     binpdf.ER = mpdf.ER([1:102 202:301 401:502]);
%     binpdf.P1 = mpdf.P1([1:102 202:301 401:502]);
%     binpdf.P2 = mpdf.P2([1:102 202:301 401:502]);
%     binpdf.P3 = mpdf.P3([1:102 202:301 401:502]);
    getbinpdf = @(p) [sum(p(1:4))       p(5:98) ...
                      sum([p(99:204)])  p(205:298) ...
                      sum([p(299:404)]) p(405:498) sum(p(499:502))];
    binpdf.ER = getbinpdf(mpdf.ER');
    binpdf.P1 = getbinpdf(mpdf.P1');
    binpdf.P2 = getbinpdf(mpdf.P2');
    binpdf.P3 = getbinpdf(mpdf.P3');
    
    % set initial guess
    v(1) = 40;  % gap
    v(2) = -170; % mu.ER
    v(3) = 60;  % sigma.ER
    v(4) = 150; % mu.P1
    v(5) = 20;  % sigma.P1
    v(6) = 280; % mu.P2
    v(7) = 20;  % sigma.P2
    v(8) = 450; % mu.P3
    v(9) = 20;  % sigma.P3

    % construct objective function (loss function) = - Sigma(P * log(Q))
    % x = @(gap) [4:98 gap+104:gap+198 2*gap+204:2*gap+298];
    % x = @(gap) [4:98 154:248 304:398];
    x = @(gap) [4:98 144:238 284:378];
    
    estcdf = @(mu, sigma, gap) cdf('Normal', x(gap), mu, sigma);
    diff = @(a) [a 1] - [0 a];
    binpdf_est = @(mu, sigma, gap) diff(estcdf(mu, sigma, gap));
    mylog = @(a) log(a+(a==0));
    objfun = @(v) - sum(binpdf.ER .* mylog(binpdf_est(v(2), v(3), v(1)))) ...
                  - sum(binpdf.P1 .* mylog(binpdf_est(v(4), v(5), v(1)))) ...
                  - sum(binpdf.P2 .* mylog(binpdf_est(v(6), v(7), v(1)))) ...
                  - sum(binpdf.P3 .* mylog(binpdf_est(v(8), v(9), v(1))));

    % find minimal loss
    [v, err, exitflag, output] = fminsearch(objfun, v, optimset('MaxIter', 1e3, 'MaxFunEvals', 2e3, 'TolFun', 1e-9, 'TolX', 1e-9, 'FunValCheck', 'on'));

    % plot actual data points for each bin
    v(1) = 40;
    semilogy([2:101 v(1)+102:v(1)+201 2*v(1)+202:2*v(1)+301]', ...
        [mpdf.ER(2:101); mpdf.ER(202:301); mpdf.ER(402:501)], 'mo');
    hold;
    semilogy([2:101 v(1)+102:v(1)+201 2*v(1)+202:2*v(1)+301]', ...
        [mpdf.P1(2:101); mpdf.P1(202:301); mpdf.P1(402:501)], 'bo');
    semilogy([2:101 v(1)+102:v(1)+201 2*v(1)+202:2*v(1)+301]', ...
        [mpdf.P2(2:101); mpdf.P2(202:301); mpdf.P2(402:501)], 'ro');
    semilogy([2:101 v(1)+102:v(1)+201 2*v(1)+202:2*v(1)+301]', ...
        [mpdf.P3(2:101); mpdf.P3(202:301); mpdf.P3(402:501)], 'ko');
    
    % plot estimated points
    semilogy(1:505, pdf('Normal', 1:505, v(2), v(3)), 'm');
    semilogy(1:505, pdf('Normal', 1:505, v(4), v(5)), 'b');
    semilogy(1:505, pdf('Normal', 1:505, v(6), v(7)), 'r');
    semilogy(1:505, pdf('Normal', 1:505, v(8), v(9)), 'k');
    
    % set x y limit
    ylim([1e-7 1e0]);
    xlim([0 2*v(1)+301]);
    
    % save to file
    save(out_file_name, 'v');
    savefig(fig_file_name);
    print(sprintf([folder '/fitted_vth_distribution'], pec), '-dpng');
    
    
%     % call this function in block_XXX folder
%     fig_file_name = sprintf('cycle_%04d/fitted_vth_distribution.fig', pec);
%     out_file_name = sprintf('cycle_%04d/fitted_parameters.mat', pec);
%     if exist(out_file_name, 'file') == 2
%         load(out_file_name);
%         if exist(fig_file_name, 'file') == 2
%             openfig(fig_file_name);
%             print(sprintf('cycle_%04d/fitted_vth_distribution', pec), '-dpng');
%             return;
%         end
%     end
%     
%     figure;
% 
%     % read vths for this block under pec
%     vths = readBlock(pec);
% 
%     % generate measured pdf
%     mpdf.ER = accumarray(vths.ER+1, 1) ./ size(vths.ER, 1);
%     mpdf.ER(505) = 0;
% 
%     mpdf.P1 = accumarray(vths.P1+1, 1) ./ size(vths.P1, 1);
%     mpdf.P1(505) = 0;
% 
%     mpdf.P2 = accumarray(vths.P2+1, 1) ./ size(vths.P2, 1);
%     mpdf.P2(505) = 0;
% 
%     mpdf.P3 = accumarray(vths.P3+1, 1) ./ size(vths.P3, 1);
%     mpdf.P3(505) = 0;
% 
%     % get the actual counts for each bin
%     binpdf.ER = mpdf.ER([1:102 202:301 401:502]);
%     binpdf.P1 = mpdf.P1([1:102 202:301 401:502]);
%     binpdf.P2 = mpdf.P2([1:102 202:301 401:502]);
%     binpdf.P3 = mpdf.P3([1:102 202:301 401:502]);
%     
%     % set initial guess
%     v(1) = 50;  % gap
%     v(2) = -30; % mu.ER
%     v(3) = 30;  % sigma.ER
%     v(4) = 120; % mu.P1
%     v(5) = 19;  % sigma.P1
%     v(6) = 265; % mu.P2
%     v(7) = 20;  % sigma.P2
%     v(8) = 415; % mu.P3
%     v(9) = 20;  % sigma.P3
% 
%     % construct objective function (loss function) = - Sigma(P * log(Q))
%     x = @(gap) [1:101 gap+101:gap+201 2*gap+201:2*gap+301]';
%     % x = @(gap) [1:101 151:251 301:401]';
%     estcdf = @(mu, sigma, gap) cdf('Normal', x(gap), mu, sigma);
%     diff = @(a) [a; 1] - [0; a];
%     binpdf_est = @(mu, sigma, gap) diff(estcdf(mu, sigma, gap));
%     mylog = @(a) log(a+(a==0));
%     objfun = @(v) - sum(binpdf.ER .* mylog(binpdf_est(v(2), v(3), v(1)))) ...
%                   - sum(binpdf.P1 .* mylog(binpdf_est(v(4), v(5), v(1)))) ...
%                   - sum(binpdf.P2 .* mylog(binpdf_est(v(6), v(7), v(1)))) ...
%                   - sum(binpdf.P3 .* mylog(binpdf_est(v(8), v(9), v(1))));
% 
%     % find minimal loss
%     [v, err, exitflag, output] = fminsearch(objfun, v, optimset('MaxIter', 1e5, 'MaxFunEvals', 5e5, 'TolFun', 1e-9, 'TolX', 1e-9, 'FunValCheck', 'on'))
% 
%     % plot actual data points for each bin
%     % v(1) = 50;
%     semilogy([2:101 v(1)+102:v(1)+201 2*v(1)+202:2*v(1)+301]', ...
%         [mpdf.ER(2:101); mpdf.ER(202:301); mpdf.ER(402:501)], 'mo');
%     hold;
%     semilogy([2:101 v(1)+102:v(1)+201 2*v(1)+202:2*v(1)+301]', ...
%         [mpdf.P1(2:101); mpdf.P1(202:301); mpdf.P1(402:501)], 'bo');
%     semilogy([2:101 v(1)+102:v(1)+201 2*v(1)+202:2*v(1)+301]', ...
%         [mpdf.P2(2:101); mpdf.P2(202:301); mpdf.P2(402:501)], 'ro');
%     semilogy([2:101 v(1)+102:v(1)+201 2*v(1)+202:2*v(1)+301]', ...
%         [mpdf.P3(2:101); mpdf.P3(202:301); mpdf.P3(402:501)], 'ko');
%     
%     % plot estimated points
%     semilogy(1:505, pdf('Normal', 1:505, v(2), v(3)), 'm');
%     semilogy(1:505, pdf('Normal', 1:505, v(4), v(5)), 'b');
%     semilogy(1:505, pdf('Normal', 1:505, v(6), v(7)), 'r');
%     semilogy(1:505, pdf('Normal', 1:505, v(8), v(9)), 'k');
%     
%     % set x y limit
%     ylim([1e-7 1e0]);
%     xlim([0 2*v(1)+301]);
%     
%     % save to file
%     save(out_file_name, 'v');
%     savefig(fig_file_name);
%     print(sprintf('cycle_%04d/fitted_vth_distribution', pec), '-dpng');

end