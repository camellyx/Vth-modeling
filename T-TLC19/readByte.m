function [vths] = readByte(data)

    % currently unused
    % can be called by an old version of readPage
    vths = sum(cell2mat(arrayfun(@(d) not(dec2binvec(d, 8)), data', 'UniformOutput', false)));
    
%     vths = [];
%     for i = 1:size(data, 2)
%         vths = [vths; not(dec2binvec(data(i), 8))];
%     end
%     vths = sum(vths);

end