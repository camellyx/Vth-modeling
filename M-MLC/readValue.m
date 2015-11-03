function [bit_value] = readValue(value, page_number)

    PAGE_SIZE = 18256; % page size for Micron is 18256 B

    % called by readPPage, get the original values for a page
    % extract the bytes read from that page, and convert to bit values
    bit_value = reshape(de2bi(value(:, page_number+1))', PAGE_SIZE * 8, 1);

end