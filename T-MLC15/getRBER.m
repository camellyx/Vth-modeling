function [rber, rber_split] = getRBER(vths, vref)
    
    % initialize
    bits_per_page = size(vths.ER, 1) + size(vths.P1, 1) + size(vths.P2, 1) + size(vths.P3, 1);
    
    % lsb rber
    lsb_rber = sum( vths.ER > vref(2) ) + sum( vths.P1 > vref(2) ) + sum( vths.P2 <= vref(2) ) + sum( vths.P3 <= vref(2) );
    
    % msb rber
    msb_rber = sum( vths.ER > vref(1) & vths.ER <= vref(3) ) + sum( vths.P3 > vref(1) & vths.P3 <= vref(3) ) ...
             + sum( vths.P1 <= vref(1) | vths.P1 > vref(3) ) + sum( vths.P2 <= vref(1) | vths.P2 > vref(3) );
    
    % overall rber
    rber_split = [lsb_rber / bits_per_page; msb_rber / bits_per_page];
    rber = sum(rber_split) / 2;
    
end