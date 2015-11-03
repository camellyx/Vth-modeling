function [v] = fitGaussMix(folder, pec, vths)

    % call this function in block_XXX folder
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % set file names and find old results %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fig_file_name = sprintf([folder '/fitted_vth_distribution_GMix.fig'], pec);
    out_file_name = sprintf([folder '/fitted_parameters_GMix.mat'], pec);
    if exist(out_file_name, 'file') == 2
        load(out_file_name);
        if exist(fig_file_name, 'file') == 2
            openfig(fig_file_name, 'new', 'invisible');
            print(sprintf([folder '/fitted_vth_distribution_GMix'], pec), '-dpng');
            return;
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % get counts in each bin %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % read vths for this block under pec
    % vths = readBlock(pec);

    % generate measured pdf
    mpdf.ER = accumarray(vths.ER+1, 1) ./ size(vths.ER, 1);
    mpdf.ER(232) = 0;

    mpdf.P1 = accumarray(vths.P1+1, 1) ./ size(vths.P1, 1);
    mpdf.P1(232) = 0;

    mpdf.P2 = accumarray(vths.P2+1, 1) ./ size(vths.P2, 1);
    mpdf.P2(232) = 0;

    mpdf.P3 = accumarray(vths.P3+1, 1) ./ size(vths.P3, 1);
    mpdf.P3(232) = 0;

    % get the actual counts for each bin
%     binpdf.ER = mpdf.ER([1:102 202:301 401:502]);
%     binpdf.P1 = mpdf.P1([1:102 202:301 401:502]);
%     binpdf.P2 = mpdf.P2([1:102 202:301 401:502]);
%     binpdf.P3 = mpdf.P3([1:102 202:301 401:502]);
    getbinpdf = @(p) [sum(p(1:39)); p(40:231)];
    binpdf = [getbinpdf(mpdf.ER)'; 
              getbinpdf(mpdf.P1)';
              getbinpdf(mpdf.P2)';
              getbinpdf(mpdf.P3)'];
          
    %%%%%%%%%%%%%%%%%%%%%
    % set initial guess %
    %%%%%%%%%%%%%%%%%%%%%
    v_def = fitGauss(folder, pec, vths);
    v_def(1) = 0;
    v_def(10) = 1;  % alpha.ER
    v_def(11) = 2;  % alpha.P1
    v_def(12) = 2;  % beta.P1
    v_def(13) = 2;  % alpha.P2
    v_def(14) = 2;  % beta.P2
    v_def(15) = 0.8;  % alpha.P3
    v_def(16) = 2;  % beta.P3
%     v_def(16) = size(vths.ER,1) / (size(vths.ER(vths.ER>250),1)+1); % progerr.ER->P3
%     v_def(17) = size(vths.P1,1) / (size(vths.P1(vths.P1>290),1)+1); % progerr.P1->P2
%     v_def(18) = size(vths.P2,1) / (size(vths.P2(vths.P2<200),1)+1); % progerr.P2->P1
%     v_def(19) = size(vths.P3,1) / (size(vths.P3(vths.P3<250),1)+1); % progerr.P3->ER
    v_def(17) = log(size(vths.ER(vths.ER>125),1) / size(vths.ER,1)); % progerr.ER->P3
    v_def(18) = log(size(vths.P1(vths.P1>125),1) / size(vths.P1,1)); % progerr.P1->P2
    v_def(19) = log(size(vths.P2(vths.P2<90),1) / size(vths.P2,1)); % progerr.P2->P1
    v_def(20) = log(size(vths.P3(vths.P3<90),1) / size(vths.P3,1)); % progerr.P3->ER
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % construct objective function (loss function) = - Sigma(P * log(Q)) %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % xgap = @(gap) [4:98 154:248 304:398];
    xgap = @(gap) [39:230];
    
    rfun = @(x) (1 - normcdf(x)) ./ (normpdf(x)+(normcdf(x)==1)) ...
        + (x>8.29236)./(x+1./(x+2./(x+3./x)));
    gauss_div = @(x, mu, sigma) (x-mu)./sigma;
    % This is cdf
    mixcdf_help = @(x, mu, sigma, alpha, beta, gauss) ...
        normcdf(gauss) ...
        - normpdf(gauss) .* ...
        ( beta.*rfun(alpha*sigma - gauss) ...
          - alpha.*rfun(beta*sigma + gauss) ) ./ (alpha + beta);
    mixcdf = @(x, mu, sigma, alpha, beta) ...
        mixcdf_help(x, mu, sigma, alpha, beta, gauss_div(x, mu, sigma));
    cdf2pdf = @(cdf) [cdf 1] - [0 cdf];
    mixpdf = @(x, mu, sigma, alpha, beta) cdf2pdf(mixcdf(x, mu, sigma, alpha, beta));
    % This is pdf
%     mixpdf_help = @(x, mu, sigma, alpha, beta, gauss) ...
%           (alpha * beta / (alpha + beta)) .* ...
%           normpdf(gauss) .* (rfun(alpha*sigma - gauss) + rfun(beta*sigma + gauss));
%     mixpdf = @(x, mu, sigma, alpha, beta) ...
%         mixpdf_help(x, mu, sigma, alpha, beta, gauss_div(x, mu, sigma));
    mixpdfs = @(x, v) [nansum(mixpdf(x, v(2), v(3), 1/v(10), 1/v(10)),1);
                       nansum(mixpdf(x, v(4), v(5), 1/v(11), 1/v(12)),1);
                       nansum(mixpdf(x, v(6), v(7), 1/v(13), 1/v(14)),1);
                       nansum(mixpdf(x, v(8), v(9), 1/v(15), 1/v(16)),1)];
    progerr = @(v) [1-exp(v(17)) 0 0 exp(v(17));
                    0 1-exp(v(18)) exp(v(18)) 0;
                    0 exp(v(19)) 1-exp(v(19)) 0;
                    exp(v(20)) 0 0 1-exp(v(20))];
    binpdf_est = @(x, v) progerr(v) * mixpdfs(x, v);
    
    mylog = @(a) log(a+(a==0));
    objfun = @(v) - sum(sum(binpdf .* mylog(binpdf_est(xgap(v(1)), v)))) + sum((v(3:16)<0)*100) + sum((v(17:20)>0)*100);
    
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
                   'TolFun', 1e-9, ...
                   'TolX', 1e-9, ...
                   'FunValCheck', 'off'));
    
    objfun_P3 = @(v) objfun([0 v_def(2:7) v(1:2) v_def(10:14) v(3:4) v_def(17:19) v(5)]);
    [v3, err, exitflag, output] = mysearch(objfun_P3, v_def([8 9 15 16 20]));
    v_def([8 9 15 16 20]) = v3;
    
    objfun_P2 = @(v) objfun([0 v_def(2:5) v(1:2) v_def(8:12) v(3:4) v_def(15:18) v(5) v_def(20)]);
    [v2, err, exitflag, output] = mysearch(objfun_P2, v_def([6 7 13 14 19]));
    v_def([6 7 13 14 19]) = v2;
    
    objfun_P1 = @(v) objfun([0 v_def(2:3) v(1:2) v_def(6:10) v(3:4) v_def(13:17) v(5) v_def(19:20)]);
    [v1, err, exitflag, output] = mysearch(objfun_P1, v_def([4 5 11 12 18]));
    v_def([4 5 11 12 18]) = v1;
    
    objfun_ER = @(v) objfun([0 v(1:2) v_def(4:9) v(3) v_def(11:16) v(4) v_def(18:20)]);
    [v0, err, exitflag, output] = mysearch(objfun_ER, v_def([2 3 10 17]));
    v_def([2 3 10 17]) = v0;
    v = v_def;

    %%%%%%%%%%%%%%%%
    % Plot results %
    %%%%%%%%%%%%%%%%
    % plot actual data points for each bin
    figure('Visible', 'off');
    v(1) = 0;
    semilogy([0:231]', mpdf.ER, 'mo');
    hold;
    semilogy([0:231]', mpdf.P1, 'bo');
    semilogy([0:231]', mpdf.P2, 'ro');
    semilogy([0:231]', mpdf.P3, 'ko');
    
    % plot estimated points
    y = binpdf_est(0:230, v);
    semilogy(0:231, y(1,:), 'm');
    semilogy(0:231, y(2,:), 'b');
    semilogy(0:231, y(3,:), 'r');
    semilogy(0:231, y(4,:), 'k');
    
    % set x y limit
    ylim([1e-7 1e0]);
    xlim([0 231]);
    
    %%%%%%%%%%%%%%%%
    % save to file %
    %%%%%%%%%%%%%%%%
    save(out_file_name, 'v');
    savefig(fig_file_name);
    print(sprintf([folder '/fitted_vth_distribution_GMix'], pec), '-dpng');
      
end