function [vopt, rber, rber_split, pdf] = getGaussVopt(v)

    %% modelled pdf
    x = @(gap) [2:230]'; % shift by one to fit the original vths distribution
    estcdf = @(mu, sigma, gap) cdf('Normal', x(gap), mu, sigma);
    diff = @(a) [a; 1] - [0; a];
    binpdf_est = @(mu, sigma, gap) diff(estcdf(mu, sigma, gap));
    pdf_fun = @(v) [ binpdf_est(v(2), v(3), v(1)) ...
                     binpdf_est(v(4), v(5), v(1)) ...
                     binpdf_est(v(6), v(7), v(1)) ...
                     binpdf_est(v(8), v(9), v(1)) ];
    pdf = pdf_fun(v);
    
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