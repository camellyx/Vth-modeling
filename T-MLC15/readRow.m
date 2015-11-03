function [vths] = readRow(filename, value, pec, rec, row_number)

    PAGE_SIZE = 17664; % page size for Toshiba is 17664 B
    V_REFS = 128; % Toshiba has 128 read reference voltages

    % called by readBlock, read vths for a row of cells (MSB+LSB page)
    %   (even page and odd page are considered different rows for now)
    
    % calculate page number for the row
    LSB_page = row_number * 2 - 1;
    MSB_page = row_number * 2 + 2;
    if row_number == 0
        LSB_page = 0;
        MSB_page = 2;
    elseif row_number == 127
        LSB_page = 253;
        MSB_page = 255;
    end

    LSB_file_name = sprintf(filename, pec, rec, LSB_page);
    MSB_file_name = sprintf(filename, pec, rec, MSB_page);
    % read vths for LSB and MSB pages
    LSB_vth = readPage(LSB_file_name);
    MSB_vth = readPage(MSB_file_name);
    % read write values for LSB and MSB pages
    LSB_value = readValue(value, LSB_page);
    MSB_value = readValue(value, MSB_page);
    
    % add the gap, convert to 0:501 vths
    vth = convertVth(MSB_vth, LSB_vth);
    % disp([MSB_vth(LSB_vth >= 55 & LSB_vth < 64) LSB_vth(LSB_vth >= 55 & LSB_vth < 64) vth(LSB_vth >= 55 & LSB_vth < 64) MSB_value(LSB_vth >= 55 & LSB_vth < 64) LSB_value(LSB_vth >= 55 & LSB_vth < 64)]);
    % disp([MSB_vth(LSB_vth >= 10 & LSB_vth < 20) LSB_vth(LSB_vth >= 10 & LSB_vth < 20) vth(LSB_vth >= 10 & LSB_vth < 20) MSB_value(LSB_vth >= 10 & LSB_vth < 20) LSB_value(LSB_vth >= 10 & LSB_vth < 20)]);
    % hist(MSB_vth-LSB_vth, -128:128);
    % hist(MSB_vth(LSB_vth >= 80 & LSB_vth < 90)+LSB_vth(LSB_vth >= 80 & LSB_vth < 90), 0:256);
    % hist3([MSB_vth LSB_vth], [128 128]);
    
    % classify into different states
    vths.ER = vth( (MSB_value == 1) & (LSB_value == 1) );
    vths.P1 = vth( (MSB_value == 0) & (LSB_value == 1) );
    vths.P2 = vth( (MSB_value == 0) & (LSB_value == 0) );
    vths.P3 = vth( (MSB_value == 1) & (LSB_value == 0) );

end