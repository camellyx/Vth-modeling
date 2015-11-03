function [vths] = readBlock(folder, vth_filename, write_filename, pec, rec)

    % call this function in block_XXX folder, called by plotVthDistribution
    % to plot the threshold voltage distribution
    % read the vths for the block, classified by original states
    out_file_name = sprintf([folder '/vths.mat'], pec);
    % load vths from file to skip re-computation
    if exist(out_file_name, 'file') == 2
        load(out_file_name);
        return;
    end

    % define a series of constants
    PAGE_SIZE = 18256; % page size for Micron is 18256 B
    BLOCK_SIZE = 512; % block size for Micron is 512 pages
    V_REFS = 101; % Micron has 101 read reference voltages
%     if ( strcmpi(chip, 'Micron') == 1 )
%         % Micron
%         PAGE_SIZE = 18256; % page size for Micron is 18256 B
%         BLOCK_SIZE = 512; % block size for Micron is 512 pages
%         V_REFS = 101; % Micron has 101 read reference voltages
%     elseif ( strcmpi(chip, 'Toshiba') == 1 )
%         % Toshiba
%         PAGE_SIZE = 17664; % page size for Toshiba is 17664 B
%         BLOCK_SIZE = 256; % block size for Toshiba is 256 pages
%         V_REFS = 101; % Toshiba has 101 read reference voltages
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
    for row = 0:247
        % read vths from all rows
        vth = readRow(vth_filename, value, pec, rec, row);
        % merge vths for each states
        vths.ER = [vths.ER; vth.ER];
        vths.P1 = [vths.P1; vth.P1];
        vths.P2 = [vths.P2; vth.P2];
        vths.P3 = [vths.P3; vth.P3];
    end
    save(out_file_name, 'vths');

end