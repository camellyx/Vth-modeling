function [vths] = readRow(filename, value, pec, rec, row_number)

    PAGE_SIZE = 18336; % page size for Toshiba is 17664 B
    V_REFS = 384; % Toshiba has 128 read reference voltages

    % called by readBlock, read vths for a row of cells (MSB+LSB page)
    %   (even page and odd page are considered different rows for now)
    
    % calculate page number for the row
    LSB_page = row_number * 3;
    CSB_page = row_number * 3 + 1;
    MSB_page = row_number * 3 + 2;

%     if row_number == 0
%         LSB_page = 0;
%         CSB_page = 2;
%     elseif row_number == 1
%         LSB_page = 1;
%     elseif row_number == 84
%         MSB_page = 256;
%     elseif row_number == 85
%         CSB_page = 255;
%         MSB_page = 257;
%     elseif row_number == 86
%         LSB_page = 258;
%         CSB_page = 260;
%     elseif row_number == 87
%         LSB_page = 259;
%     elseif row_number == 170
%         MSB_page = 514;
%     elseif row_number == 171
%         CSB_page = 513;
%         MSB_page = 515;
%     end

    LSB_file_name = sprintf(filename, pec, rec, LSB_page);
    CSB_file_name = sprintf(filename, pec, rec, CSB_page);
    MSB_file_name = sprintf(filename, pec, rec, MSB_page);
    % read vths for LSB, CSB and MSB pages
    LSB_vth = readPage(LSB_file_name);
    CSB_vth = readPage(CSB_file_name);
    MSB_vth = readPage(MSB_file_name);
    % read write values for LSB, CSB and MSB pages
    LSB_value = readValue(value, LSB_page);
    CSB_value = readValue(value, CSB_page);
    MSB_value = readValue(value, MSB_page);
    value = bi2de([LSB_value CSB_value MSB_value]);
    
    % add the gap, convert to 0:501 vths
    vth = convertVth(MSB_vth, CSB_vth, LSB_vth);
    % disp([MSB_value MSB_vth]);
%     x = 7;
%     figure;
%     hist(MSB_vth(value == x), 0:256);
%     figure;
%     hist(CSB_vth(value == 4 | value == 6), 0:256);
%     figure;
%     hist(LSB_vth(value == x), 0:256);
%     figure;
%     hist(MSB_vth - LSB_vth, -256:256);
%     figure;
%     hist3([LSB_vth MSB_vth], [128 128]);
%     figure;
%     hist3([CSB_vth MSB_vth], [128 128]);
%     figure;
%     hist3([CSB_vth LSB_vth], [128 128]);
    
    % classify into different states
    vths.ER = vth( value == 7 );
    vths.P1 = vth( value == 6 );
    vths.P2 = vth( value == 4 );
    vths.P3 = vth( value == 0 );
    vths.P4 = vth( value == 2 );
    vths.P5 = vth( value == 3 );
    vths.P6 = vth( value == 1 );
    vths.P7 = vth( value == 5 );

end