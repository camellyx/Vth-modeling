function [vopt, rber, rber_split, pdf] = getGMixVopt(v)

    %% modelled pdf
    x = [2:230]; % shift by one to fit the original vths distribution
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
    mixpdfs = @(x, v) [nansum(mixpdf(x, v(2), v(3), 1/v(10), 1/v(10)),1);
                       nansum(mixpdf(x, v(4), v(5), 1/v(11), 1/v(12)),1);
                       nansum(mixpdf(x, v(6), v(7), 1/v(13), 1/v(14)),1);
                       nansum(mixpdf(x, v(8), v(9), 1/v(15), 1/v(16)),1)];
    progerr = @(v) [1-exp(v(17)) 0 0 exp(v(17));
                    0 1-exp(v(18)) exp(v(18)) 0;
                    0 exp(v(19)) 1-exp(v(19)) 0;
                    exp(v(20)) 0 0 1-exp(v(20))];
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