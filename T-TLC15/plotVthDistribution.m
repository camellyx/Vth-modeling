function [pdf] = plotVthDistribution(pec)

    % TODO: rewrite this function to new readBlock() format
    % call this function in block_XXX folder
    fig_file_name = sprintf('cycle_%04d/vth_distribution.fig', pec);
    out_file_name = sprintf('cycle_%04d/pdf.mat', pec);
    if exist(out_file_name, 'file') == 2
        load(out_file_name);
        if exist(fig_file_name, 'file') == 2
            openfig(fig_file_name);
            print(sprintf('cycle_%04d/vth_distribution', pec), '-dpng');
            return;
        end
    end
    
    figure;

    % read vths for this block under pec
    vths = readBlock(pec);
    
    % generate pdf
    pdf.ER = accumarray(vths.ER+1, 1) ./ size(vths.ER, 1);
    pdf.ER(505) = 0;
    pdf.ER(1) = 0;
    
    pdf.P1 = accumarray(vths.P1+1, 1) ./ size(vths.P1, 1);
    pdf.P1(505) = 0;
    pdf.P1(102) = 0;
    
    pdf.P2 = accumarray(vths.P2+1, 1) ./ size(vths.P2, 1);
    pdf.P2(505) = 0;
    pdf.P2(401) = 0;
    
    pdf.P3 = accumarray(vths.P3+1, 1) ./ size(vths.P3, 1);
    pdf.P3(505) = 0;
    pdf.P3(502) = 0;
    x = [0:504]';
    
    % plot pdf as curve
    plot(x, pdf.ER, x, pdf.P1, x, pdf.P2, x, pdf.P3);
    
    % set x, y range
    xlim([0 504]);
    ylim([0 0.1]);
    
    % save pdf data and figure
    save(out_file_name, 'pdf');
    savefig(fig_file_name);
    print(sprintf('cycle_%04d/vth_distribution', pec), '-dpng');

end