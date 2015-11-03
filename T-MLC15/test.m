    pec=0;
    % read vths for this block under pec
    vths = readBlock(pec);

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
    getbinpdf = @(p) [sum(p(1:4))       p(5:98) ...
                      sum([p(99:204)])  p(205:298) ...
                      sum([p(299:404)]) p(405:498) sum(p(499:505))];
    binpdf = [getbinpdf(mpdf.ER'); ...
              getbinpdf(mpdf.P1'); ...
              getbinpdf(mpdf.P2'); ...
              getbinpdf(mpdf.P3')];
    minbinpdf = 1 ./ min([size(vths.ER,1) size(vths.P1,1) size(vths.P2,1) size(vths.P3,1)]);
          
    %%%%%%%%%%%%%%%%%%%%%
    % set initial guess %
    %%%%%%%%%%%%%%%%%%%%%
    v_def = fitGaussWithGap(pec);
    v_def(1) = 50;
    v_def(6) = 270;
    v_def(10) = 2.5;  % alpha.ER
    v_def(11) = 10;  % alpha.P1
    v_def(12) = 10;  % beta.P1
    v_def(13) = 8;  % alpha.P2
    v_def(14) = 6;  % beta.P2
    v_def(15) = 12;  % beta.P3
%     v_def(16) = size(vths.ER,1) / (size(vths.ER(vths.ER>250),1)+1); % progerr.ER->P3
%     v_def(17) = size(vths.P1,1) / (size(vths.P1(vths.P1>290),1)+1); % progerr.P1->P2
%     v_def(18) = size(vths.P2,1) / (size(vths.P2(vths.P2<200),1)+1); % progerr.P2->P1
%     v_def(19) = size(vths.P3,1) / (size(vths.P3(vths.P3<250),1)+1); % progerr.P3->ER
    v_def(16) = log(size(vths.ER(vths.ER>250),1) / size(vths.ER,1)); % progerr.ER->P3
    v_def(17) = log(size(vths.P1(vths.P1>290),1) / size(vths.P1,1)); % progerr.P1->P2
    v_def(18) = log(size(vths.P2(vths.P2<200),1) / size(vths.P2,1)); % progerr.P2->P1
    v_def(19) = log(size(vths.P3(vths.P3<250),1) / size(vths.P3,1)); % progerr.P3->ER
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % construct objective function (loss function) = - Sigma(P * log(Q)) %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % xgap = @(gap) [4:98 154:248 304:398];
    xgap = @(gap) [4:98 gap+104:gap+198 2*gap+204:2*gap+298];
    
    rfun = @(x) (1 - normcdf(x)) ./ (normpdf(x)+(normcdf(x)==1)) ...
        + (normcdf(x)==1)./(x+1./(x+2./(x+3./x)));
%     rfun = @(x) (1 - normcdf(x)) ./ (normpdf(x)+(normcdf(x)==1));
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
    mixpdfs = @(x, v) [mixpdf(x, v(2), v(3), 1/v(10), 1/v(10));
                       mixpdf(x, v(4), v(5), 1/v(11), 1/v(12));
                       mixpdf(x, v(6), v(7), 1/v(13), 1/v(14));
                       mixpdf(x, v(8), v(9), 1/v(15), 1/v(15))];
    progerr = @(v) [1-exp(v(16)) 0 0 exp(v(16));
                    0 1-exp(v(17)) exp(v(17)) 0;
                    0 exp(v(18)) 1-exp(v(18)) 0;
                    exp(v(19)) 0 0 1-exp(v(19))];

    binpdf_est = @(x, v) progerr(v) * mixpdfs(x, v);
    
    mylog = @(a) log(a+(a==0));
    objfun = @(v) - sum(sum(binpdf .* mylog(binpdf_est(xgap(v(1)), v)))) ...
        + sum(v(3:15)<=0)*100 + sum(v(16:19)>log(0.5))*100;
    
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
          optimset('MaxIter', 1e4, ...
                   'MaxFunEvals', 3e4, ...
                   'TolFun', 1e-9, ...
                   'TolX', 1e-9, ...
                   'FunValCheck', 'off'));
    
    objfun_P3 = @(v) objfun([v_def(1:7) v(1:2) v_def(10:14) v(3) v_def(16:18) v(4)]);
    [v3, err, exitflag, output] = mysearch(objfun_P3, v_def([8 9 15 19]))
    v_def([8 9 15 19]) = v3;
    
    objfun_P2 = @(v) objfun([v_def(1:5) v(1:2) v_def(8:12) v(3:4) v_def(15:17) v(5) v_def(19)]);
    [v2, err, exitflag, output] = mysearch(objfun_P2, v_def([6 7 13 14 18]))
    v_def([6 7 13 14 18]) = v2;
    
    objfun_P1 = @(v) objfun([v_def(1:3) v(1:2) v_def(6:10) v(3:4) v_def(13:16) v(5) v_def(18:19)]);
    [v1, err, exitflag, output] = mysearch(objfun_P1, v_def([4 5 11 12 17]))
    v_def([4 5 11 12 17]) = v1;
    
    objfun_ER = @(v) objfun([v_def(1) v(1:2) v_def(4:9) v(3) v_def(11:15) v(4) v_def(17:19)]);
    [v0, err, exitflag, output] = mysearch(objfun_ER, v_def([2 3 10 16]))
    v_def([2 3 10 16]) = v0;
    
    % [v, err, exitflag, output] = mysearch(objfun, v_def);
    v = v_def;

    %%%%%%%%%%%%%%%%
    % Plot results %
    %%%%%%%%%%%%%%%%
    % plot actual data points for each bin
    figure('Visible', 'on');
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
%     ylim([1e-7 1e0]);
%     xlim([0 2*v(1)+301]);