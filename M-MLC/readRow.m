function [vths] = readRow(filename, value, pec, rec, row_number)

    PAGE_SIZE = 18256; % page size for Micron is 18256 B
    V_REFS = 101; % Micron has 101 read reference voltages

    % called by readBlock, read vths for a row of cells (MSB+LSB page)
    %   (even page and odd page are considered different rows for now)
    
    %% calculate page number for the row
    if mod(row_number, 2) == 0
        % even page
        LSB_page = row_number * 2 + 6;
        MSB_page = row_number * 2 + 12;
    else
        % odd page
        LSB_page = row_number * 2 + 5;
        MSB_page = row_number * 2 + 11;
    end
    % first row exception
    if row_number < 2
        LSB_page = LSB_page + 1;
    end

    LSB_file_name = sprintf(filename, pec, rec, LSB_page);
    MSB_file_name = sprintf(filename, pec, rec, MSB_page);
    %% read vths for LSB and MSB pages
    LSB_vth = readPage(LSB_file_name);
    MSB_vth = readPage(MSB_file_name);
    %% read write values for LSB and MSB pages
    LSB_value = readValue(value, LSB_page);
    MSB_value = readValue(value, MSB_page);
    
    %% add the gap, convert to 0:501 vths
    vth = convertVth(MSB_vth, LSB_vth);
    % disp([MSB_vth LSB_vth vth MSB_value LSB_value]);
    
    %% classify into different states
    vths.ER = vth( (MSB_value == 1) & (LSB_value == 1) );
    vths.P1 = vth( (MSB_value == 0) & (LSB_value == 1) );
    vths.P2 = vth( (MSB_value == 0) & (LSB_value == 0) );
    vths.P3 = vth( (MSB_value == 1) & (LSB_value == 0) );

end