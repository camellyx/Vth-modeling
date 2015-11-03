function [] = modelPEC(pec)

    % load pecpars
    load('fitted_pec_trend.mat');
    
    % power law function
    plfun = @(pec, v) v(:,1).*((pec).^v(:,2)) + v(:,3);
    
    % get model parameters
    pars = plfun(pec, pecpars);
    
    %%
    %%%%%%%%%%%%%%%%%
    % Plot Raw Data %
    %%%%%%%%%%%%%%%%%
    
    % Prepare figure
    figure('Visible', 'on');
    
    % All PE Cycles
    pecs = [0; 2500; 5000; 7500; 10000; 12000; 14000; 16000; 18000; 19000; 20000];
    
    first_held = 1;
    if ismember(pec, pecs)
        % All folders
        block_folders = dir('block_*');
        j = 1;
        for i = 1:size(block_folders, 1)
            folder = [block_folders(i).name sprintf('/cycle_%04d', pec)];
            if ( exist(folder) == 7 )
                vths = readBlock(folder, '', '', pec, pec);
                
                % generate measured pdf
                mpdf.ER = accumarray(vths.ER+1, 1) ./ size(vths.ER, 1);
                mpdf.ER(505) = 0;

                mpdf.P1 = accumarray(vths.P1+1, 1) ./ size(vths.P1, 1);
                mpdf.P1(505) = 0;

                mpdf.P2 = accumarray(vths.P2+1, 1) ./ size(vths.P2, 1);
                mpdf.P2(505) = 0;

                mpdf.P3 = accumarray(vths.P3+1, 1) ./ size(vths.P3, 1);
                mpdf.P3(505) = 0;
                
                % plot meaasured pdf
                v = 40;
                semilogy([2:101 v(1)+102:v(1)+201 2*v(1)+202:2*v(1)+301]', ...
                    [mpdf.ER(2:101); mpdf.ER(202:301); mpdf.ER(402:501)], 'mo');
                if first_held == 1
                    hold;
                    first_held = 0;
                end
                semilogy([2:101 v(1)+102:v(1)+201 2*v(1)+202:2*v(1)+301]', ...
                    [mpdf.P1(2:101); mpdf.P1(202:301); mpdf.P1(402:501)], 'bo');
                semilogy([2:101 v(1)+102:v(1)+201 2*v(1)+202:2*v(1)+301]', ...
                    [mpdf.P2(2:101); mpdf.P2(202:301); mpdf.P2(402:501)], 'ro');
                semilogy([2:101 v(1)+102:v(1)+201 2*v(1)+202:2*v(1)+301]', ...
                    [mpdf.P3(2:101); mpdf.P3(202:301); mpdf.P3(402:501)], 'ko');
            end
        end
    end
    
    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Gaussian Mixture Model %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
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
    mixpdfs = @(x, v) [mixpdf(x, v(2), v(3), 1/v(10), 1/v(10));
                       mixpdf(x, v(4), v(5), 1/v(11), 1/v(12));
                       mixpdf(x, v(6), v(7), 1/v(13), 1/v(14));
                       mixpdf(x, v(8), v(9), 1/v(15), 1/v(15))];
    progerr = @(v) [1-exp(v(16)) 0 0 exp(v(16));
                    0 1-exp(v(17)) exp(v(17)) 0;
                    0 exp(v(18)) 1-exp(v(18)) 0;
                    exp(v(19)) 0 0 1-exp(v(19))];
    binpdf_est = @(x, v) progerr(v) * mixpdfs(x, v);
    
    %% get modeled distribution
    v = [40; pars(1); pars(5); pars(2); pars(6); ...
             pars(3); pars(7); pars(4); pars(8); ...
             pars(9:18)];
    y = binpdf_est(1:505, v);
    
    %% plot modeled distribution
    semilogy(2:505, y(1,2:505), 'm');
    if first_held == 1
        hold;
        first_held = 0;
    end
    semilogy(2:505, y(2,2:505), 'b');
    semilogy(2:505, y(3,2:505), 'r');
    semilogy(2:505, y(4,2:505), 'k');
    
    % set x y limit
    ylim([1e-7 1e0]);
    xlim([0 2*v(1)+301]);
    
    print(sprintf('modeledPEC_%04d', pec), '-dpng');

end




















