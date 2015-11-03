function [v] = fitGaussTMix(folder, pec, vths)

    % call this function in block_XXX folder
    
    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % set file names and find old results %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fig_file_name = sprintf([folder '/fitted_vth_distribution_GTMix.fig'], pec);
    out_file_name = sprintf([folder '/fitted_parameters_GTMix.mat'], pec);
%     if exist(out_file_name, 'file') == 2
%         load(out_file_name);
%         if exist(fig_file_name, 'file') == 2
%             openfig(fig_file_name, 'new', 'invisible');
%             print(sprintf([folder '/fitted_vth_distribution_GTMix'], pec), '-dpng');
%             return;
%         end
%     end

    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % get counts in each bin %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
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
    % getbinpdf = @(p) [p(5:98) p(205:298) p(405:498)];
    getbinpdf = @(p) [sum(p(1:4))     p(5:98) ...
                      sum(p(99:204))  p(205:298) ...
                      sum(p(299:404)) p(405:498) sum(p(499:505))];
    binpdf = [getbinpdf(mpdf.ER'); ...
              getbinpdf(mpdf.P1'); ...
              getbinpdf(mpdf.P2'); ...
              getbinpdf(mpdf.P3')];
          
    %%
    %%%%%%%%%%%%%%%%%%%%%
    % set initial guess %
    %%%%%%%%%%%%%%%%%%%%%
    v_def = fitGauss(folder, pec, vths);
    v_def(1) = 40;
    v_def(10) = 10;  % alpha.ER
    v_def(11) = 10;  % alpha.P1
    v_def(12) = 1000;  % beta.P1
    v_def(13) = 10;  % alpha.P2
    v_def(14) = 1000;  % beta.P2
    v_def(15) = 1000;  % alpha.P3
    v_def(16) = 1000;  % beta.P3
    v_def(17) = 1;     % alpha.ER_err
    v_def(18) = 1;     % alpha.P1_err
    v_def(19) = log(size(vths.ER(vths.ER>125),1) / size(vths.ER,1)); % progerr.ER->P3
    v_def(20) = log(size(vths.P1(vths.P1>125),1) / size(vths.P1,1)); % progerr.P1->P2
    
    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % construct objective function (loss function) = - Sigma(P * log(Q)) %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % xgap = @(gap) [4:98 154:248 304:398];
    % xgap = @(gap) [4:98 gap+104:gap+198 2*gap+204:2*gap+298];
    xgap = @(gap) [4:98 144:238 284:378];
    
    gauss_div = @(x, mu, sigma) (x-mu)./sigma;
    % This is cdf
    mixcdf_help = @(gauss, alpha, beta) ...
        (gauss<0) .* tcdf(gauss, beta) + ...
        (gauss>=0) .* tcdf(gauss, alpha);
    mixcdf = @(x, mu, sigma, alpha, beta) ...
        mixcdf_help(gauss_div(x, mu, sigma), alpha, beta);
    cdf2pdf = @(cdf) [cdf 1] - [0 cdf];
    mixpdf = @(x, mu, sigma, alpha, beta) cdf2pdf(mixcdf(x, mu, sigma, alpha, beta));
    % This is pdf
    mixpdfs = @(x, v) [nansum(mixpdf(x, v(2), v(3), v(10), Inf),1);     % ER
                       nansum(mixpdf(x, v(4), v(5), v(11), v(12)),1);   % P1
                       nansum(mixpdf(x, v(6), v(7), v(13), v(14)),1);   % P2
                       nansum(mixpdf(x, v(8), v(9), v(15), v(16)),1);   % P3
                       nansum(mixpdf(x, v(6), v(7), v(18), v(14)),1);   % P1_err
                       nansum(mixpdf(x, v(8), v(9), v(17), v(16)),1)];  % ER_err
    progerr = @(v) [1-exp(v(19)) 0 0 0 0 exp(v(19));
                    0 1-exp(v(20)) 0 0 exp(v(20)) 0;
                    0 0 1 0 0 0;
                    0 0 0 1 0 0];
    binpdf_est = @(x, v) progerr(v) * mixpdfs(x, v);
    
    mylog = @(a) log(a+(a==0));
    kldiv_help = @(x, x_hat, v) - sum(sum( x .* mylog(x_hat) )) + sum((v(3:18)<0)*100) + sum((v(19:20)>-2)*100);
    rms_help = @(x, x_hat, v) sum(nansum( (x<1e-3 & x>1e-6) .* (log(x) - log(x_hat)).^2 )) + sum((v(3:18)<0)*10000) + sum((v(19:20)>0)*10000);
    objfun = @(v) kldiv_help(binpdf, binpdf_est(xgap(v(1)), v), v);
    
    %%
    %%%%%%%%%%%%%%%%%%%%%
    % find minimal loss %
    %%%%%%%%%%%%%%%%%%%%%
%     [v, err, exitflag, output] ...
%       = fminsearch( ...
%           objfun, v, ...
%           optimset('MaxIter', 1e4, ...
%                    'MaxFunEvals', 3e4, ...
%                    'TolFun', 1e-9, ...
%                    'TolX', 1e-9, ...
%                    'FunValCheck', 'off'))
    mysearch = @(myfun, myv) fminsearch( ...
          myfun, myv, ...
          optimset('MaxIter', 2e3, ...
                   'MaxFunEvals', 4e3, ...
                   'TolFun', 1e-6, ...
                   'TolX', 1e-6, ...
                   'FunValCheck', 'off'));
    
    objfun_P3 = @(v) objfun([0 v_def(2:7) v(1:2) v_def(10:14) v(3:4) v_def(17:20)]);
    [v3, err, exitflag, output] = mysearch(objfun_P3, v_def([8 9 15 16]));
    v_def([8 9 15 16]) = v3;
    
    objfun_P2 = @(v) objfun([0 v_def(2:5) v(1:2) v_def(8:12) v(3:4) v_def(15:20)]);
    [v2, err, exitflag, output] = mysearch(objfun_P2, v_def([6 7 13 14]));
    v_def([6 7 13 14]) = v2;
    
    objfun_P1 = @(v) objfun([0 v_def(2:3) v(1:2) v_def(6:10) v(3:4) v_def(13:17) v(5) v_def(19) v(6)]);
    [v1, err, exitflag, output] = mysearch(objfun_P1, v_def([4 5 11 12 18 20]));
    v_def([4 5 11 12 18 20]) = v1;
    
    objfun_ER = @(v) objfun([0 v(1:2) v_def(4:9) v(3) v_def(11:16) v(4) v_def(18) v(5) v_def(20)]);
    [v0, err, exitflag, output] = mysearch(objfun_ER, v_def([2 3 10 17 19]));
    v_def([2 3 10 17 19]) = v0;
    
    objfun = @(v) rms_help(binpdf, binpdf_est(xgap(v(1)), v), v);
    objfun_tail = @(v) objfun([0 v_def(2:9) v(1:11)]);
    [vt, err, exitflag, output] = mysearch(objfun_tail, v_def(10:20));
    v_def(10:20) = vt;

    v = v_def;

    %%
    %%%%%%%%%%%%%%%%
    % Plot results %
    %%%%%%%%%%%%%%%%
    % plot actual data points for each bin
    figure('Visible', 'off');
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
    y = binpdf_est(1:505, v);
    semilogy(2:505, y(1,2:505), 'm');
    semilogy(2:505, y(2,2:505), 'b');
    semilogy(2:505, y(3,2:505), 'r');
    semilogy(2:505, y(4,2:505), 'k');
    
    % set x y limit
    ylim([1e-7 1e0]);
    xlim([0 2*v(1)+301]);
    
    %%
    %%%%%%%%%%%%%%%%
    % save to file %
    %%%%%%%%%%%%%%%%
    save(out_file_name, 'v');
    savefig(fig_file_name);
    print(sprintf([folder '/fitted_vth_distribution_GTMix'], pec), '-dpng');
      
end