function [rber, rber_split] = pdf2RBER(pdf, vref)
    
    max_vref = size(pdf, 1);

    % lsb rber
    lsb_rber = sum(sum( pdf(vref(2)+1:max_vref, 1:2) )) + sum(sum( pdf(1:vref(2), 3:4) ));
    
    % msb rber
    msb_rber = sum(sum( pdf(vref(1)+1:vref(3), [1 4]) )) ...
                + sum(sum( pdf([1:vref(1) vref(3)+1:max_vref], [2 3]) ));
    
    % overall rber
    rber_split = [lsb_rber; msb_rber] ./ 4;
    rber = sum(rber_split) / 2;
    
end