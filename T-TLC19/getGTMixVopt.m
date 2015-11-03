function [vopt, rber, rber_split, pdf] = getGTMixVopt(v)

    %% modelled pdf
    x = [2:230]; % shift by one to fit the original vths distribution
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
    pdf = binpdf_est(x, v)';
    
    %% initialize
    vopt = [70; 115; 165];
    
    %% find va_opt
    rber = pdf2RBER(pdf, vopt);
    next_rber = pdf2RBER(pdf, [vopt(1)+1; vopt(2); vopt(3)]);
    while (next_rber <= rber)
        rber = next_rber;
        vopt(1) = vopt(1) + 1;
        next_rber = pdf2RBER(pdf, [vopt(1)+1; vopt(2); vopt(3)]);
    end
    next_rber = pdf2RBER(pdf, [vopt(1)-1; vopt(2); vopt(3)]);
    while (next_rber <= rber)
        rber = next_rber;
        vopt(1) = vopt(1) - 1;
        next_rber = pdf2RBER(pdf, [vopt(1)-1; vopt(2); vopt(3)]);
    end
    
    %% find vb_opt
    rber = pdf2RBER(pdf, vopt);
    next_rber = pdf2RBER(pdf, [vopt(1); vopt(2)+1; vopt(3)]);
    while (next_rber <= rber)
        rber = next_rber;
        vopt(2) = vopt(2) + 1;
        next_rber = pdf2RBER(pdf, [vopt(1); vopt(2)+1; vopt(3)]);
    end
    next_rber = pdf2RBER(pdf, [vopt(1); vopt(2)-1; vopt(3)]);
    while (next_rber <= rber)
        rber = next_rber;
        vopt(2) = vopt(2) - 1;
        next_rber = pdf2RBER(pdf, [vopt(1); vopt(2)-1; vopt(3)]);
    end
    
    %% find va_opt
    rber = pdf2RBER(pdf, vopt);
    next_rber = pdf2RBER(pdf, [vopt(1); vopt(2); vopt(3)+1]);
    while (next_rber <= rber)
        rber = next_rber;
        vopt(3) = vopt(3) + 1;
        next_rber = pdf2RBER(pdf, [vopt(1); vopt(2); vopt(3)+1]);
    end
    next_rber = pdf2RBER(pdf, [vopt(1); vopt(2); vopt(3)-1]);
    while (next_rber <= rber)
        rber = next_rber;
        vopt(3) = vopt(3) - 1;
        next_rber = pdf2RBER(pdf, [vopt(1); vopt(2); vopt(3)-1]);
    end
    
    [rber, rber_split] = pdf2RBER(pdf, vopt);
    
end