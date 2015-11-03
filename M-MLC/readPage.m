function [vths] = readPage(file_name)
% This version is 340x faster the the latter

    PAGE_SIZE = 18256; % page size for Micron is 18256 B
    V_REFS = 101; % Micron has 101 read reference voltages

    % called by readPPage, read vths of one page
    file = fopen(file_name);
    data = fread(file);
    fclose(file);
    % convert byte values of 101 reads into a bit matrix
    bits = reshape(not(de2bi(data, 8))', PAGE_SIZE*8, V_REFS);
    % sum up the bits to get the threshold voltage range of each cell
    vths = sum(bits, 2);

end

% function [vths] = readPage(file_name, chip)
% 
%     if ( strcmpi(chip, 'Micron') == 1 )
%         % Micron
%         PAGE_SIZE = 18256; % page size for Micron is 18256 B
%         V_REFS = 101; % Micron has 101 read reference voltages
%     elseif ( strcmpi(chip, 'Toshiba') == 1 )
%         % Toshiba
%         PAGE_SIZE = 17664; % page size for Toshiba is 17664 B
%         V_REFS = 101; % Toshiba has 101 read reference voltages
%     else
%         fprintf('Unknown chip manufacturer [%s].\n', chip);
%         return;
%     end
%     
%     tic
%     file = fopen(file_name);
%     data = fread(file);
%     data = reshape(data, PAGE_SIZE, V_REFS);
%     vths = [];
%     for byte = 1:PAGE_SIZE
%         vths = [vths; readByte(data(byte,:))];
%     end
%     toc
% 
% end
