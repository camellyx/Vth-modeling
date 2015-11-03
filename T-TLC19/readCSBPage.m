function [vths] = readCSBPage(file_name)
% This version is 340x faster the the latter

    PAGE_SIZE = 9168; % page size for Toshiba is 17664 B
    V_REFS = 256; % Toshiba has 128 read reference voltages

    % called by readPPage, read vths of one page
    % disp(file_name);
    file = fopen(file_name);
    data = fread(file);
    fclose(file);
    % convert byte values of 101 reads into a bit matrix
    bits = reshape(not(de2bi(data, 8))', PAGE_SIZE*8, V_REFS);
    bits(3,:)'
    % sum up the bits to get the threshold voltage range of each cell
    vths = sum(bits, 2);

end