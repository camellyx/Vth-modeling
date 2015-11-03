function [vths] = readBlock(folder, vth_filename, write_filename, pec, rec)

    % call this function in block_XXX folder, called by plotVthDistribution
    % to plot the threshold voltage distribution
    % read the vths for the block, classified by original states
    out_file_name = sprintf([folder '/vths.mat'], pec);
    % load vths from file to skip re-computation
%     if exist(out_file_name, 'file') == 2
%         load(out_file_name);
%         return;
%     end

    % define a series of constants
    PAGE_SIZE = 18336; % page size for Toshiba is 9168 B
    BLOCK_SIZE = 384; % block size for Toshiba is 516 pages
    V_REFS = 256; % Toshiba has 256 read reference voltages
%     if ( strcmpi(chip, 'Micron') == 1 )
%         % Micron
%         PAGE_SIZE = 18256; % page size for Micron is 18256 B
%         BLOCK_SIZE = 512; % block size for Micron is 512 pages
%         V_REFS = 101; % Micron has 101 read reference voltages
%     elseif ( strcmpi(chip, 'Toshiba') == 1 )
%         % Toshiba
%         PAGE_SIZE = 17664; % page size for Toshiba is 17664 B
%         BLOCK_SIZE = 256; % block size for Toshiba is 256 pages
%         V_REFS = 128; % Toshiba has 128 read reference voltages
%     else
%         fprintf('Unknown chip manufacturer [%s].\n', chip);
%         return;
%     end

    file_name = sprintf(write_filename, pec);
    file = fopen(file_name);
    % read originally-written values into register
    value = reshape(fread(file), PAGE_SIZE, BLOCK_SIZE);
    fclose(file);
    
    vths.ER = [];
    vths.P1 = [];
    vths.P2 = [];
    vths.P3 = [];
    vths.P4 = [];
    vths.P5 = [];
    vths.P6 = [];
    vths.P7 = [];
    for row = 1:10 % (BLOCK_SIZE/3) % TLC divide by 3
        % read vths from all rows
        vth = readRow(vth_filename, value, pec, rec, row-1);
        % merge vths for each states
        vths.ER = [vths.ER; vth.ER];
        vths.P1 = [vths.P1; vth.P1];
        vths.P2 = [vths.P2; vth.P2];
        vths.P3 = [vths.P3; vth.P3];
        vths.P4 = [vths.P4; vth.P4];
        vths.P5 = [vths.P5; vth.P5];
        vths.P6 = [vths.P6; vth.P6];
        vths.P7 = [vths.P7; vth.P7];
    end
    save(out_file_name, 'vths');
    
    % Plot distribution
    pdf.ER = accumarray(vths.ER+1, 1) ./ size(vths.ER, 1);
    pdf.ER(630) = 0;
    
    pdf.P1 = accumarray(vths.P1+1, 1) ./ size(vths.P1, 1);
    pdf.P1(630) = 0;
    
    pdf.P2 = accumarray(vths.P2+1, 1) ./ size(vths.P2, 1);
    pdf.P2(630) = 0;
    
    pdf.P3 = accumarray(vths.P3+1, 1) ./ size(vths.P3, 1);
    pdf.P3(630) = 0;
    
    pdf.P4 = accumarray(vths.P4+1, 1) ./ size(vths.P4, 1);
    pdf.P4(630) = 0;
    
    pdf.P5 = accumarray(vths.P5+1, 1) ./ size(vths.P5, 1);
    pdf.P5(630) = 0;
    
    pdf.P6 = accumarray(vths.P6+1, 1) ./ size(vths.P6, 1);
    pdf.P6(630) = 0;
    
    pdf.P7 = accumarray(vths.P7+1, 1) ./ size(vths.P7, 1);
    pdf.P7(630) = 0;
    
    x = [0:629]';
    figure('Visible', 'off');
    semilogy(x, pdf.ER, 'mo');
    hold;
    semilogy(x, pdf.P1, 'kx');
    semilogy(x, pdf.P2, 'bo');
    semilogy(x, pdf.P3, 'rx');
    semilogy(x, pdf.P4, 'ro');
    semilogy(x, pdf.P5, 'bx');
    semilogy(x, pdf.P6, 'ko');
    semilogy(x, pdf.P7, 'mx');
    
    xlim([0 628]);
    ylim([1e-7 1e0]);
    
    pdf_file_name = sprintf([folder '/pdf.mat'], pec);
    save(pdf_file_name, 'pdf');
    
    fig_file_name = sprintf([folder '/vth_distribution.fig'], pec);
    savefig(fig_file_name);
    print(sprintf([folder '/vth_distribution'], pec), '-dpng');

end