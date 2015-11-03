function [bit_value] = readValue(value, page_number)

    PAGE_SIZE = 17664; % page size for Toshiba is 17664 B

    % called by readPPage, get the original values for a page
    % extract the bytes read from that page, and convert to bit values
    bit_value = reshape(de2bi(value(:, page_number+1))', PAGE_SIZE * 8, 1);

end