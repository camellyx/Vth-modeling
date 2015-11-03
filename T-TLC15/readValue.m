function [bit_value] = readValue(value, page_number)

    PAGE_SIZE = 18336; % page size for Toshiba is 9168 B
    
    % page_number translation
    % page_number = mod(page_number,258) * 2 + (page_number >= 258);

    % called by readPPage, get the original values for a page
    % extract the bytes read from that page, and convert to bit values
    bit_value = reshape(de2bi(value(:, page_number+1))', PAGE_SIZE * 8, 1);

end