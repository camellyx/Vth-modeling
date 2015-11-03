function [vopt, rber, rber_split] = getVopt(vths)
    
    %% initialize
    vopt = [70; 115; 165];
    
    %% find va_opt
    rber = getRBER(vths, vopt);
    next_rber = getRBER(vths, [vopt(1)+1; vopt(2); vopt(3)]);
    while (next_rber <= rber)
        rber = next_rber;
        vopt(1) = vopt(1) + 1;
        next_rber = getRBER(vths, [vopt(1)+1; vopt(2); vopt(3)]);
    end
    next_rber = getRBER(vths, [vopt(1)-1; vopt(2); vopt(3)]);
    while (next_rber <= rber)
        rber = next_rber;
        vopt(1) = vopt(1) - 1;
        next_rber = getRBER(vths, [vopt(1)-1; vopt(2); vopt(3)]);
    end
    
    %% find vb_opt
    rber = getRBER(vths, vopt);
    next_rber = getRBER(vths, [vopt(1); vopt(2)+1; vopt(3)]);
    while (next_rber <= rber)
        rber = next_rber;
        vopt(2) = vopt(2) + 1;
        next_rber = getRBER(vths, [vopt(1); vopt(2)+1; vopt(3)]);
    end
    next_rber = getRBER(vths, [vopt(1); vopt(2)-1; vopt(3)]);
    while (next_rber <= rber)
        rber = next_rber;
        vopt(2) = vopt(2) - 1;
        next_rber = getRBER(vths, [vopt(1); vopt(2)-1; vopt(3)]);
    end
    
    %% find va_opt
    rber = getRBER(vths, vopt);
    next_rber = getRBER(vths, [vopt(1); vopt(2); vopt(3)+1]);
    while (next_rber <= rber)
        rber = next_rber;
        vopt(3) = vopt(3) + 1;
        next_rber = getRBER(vths, [vopt(1); vopt(2); vopt(3)+1]);
    end
    next_rber = getRBER(vths, [vopt(1); vopt(2); vopt(3)-1]);
    while (next_rber <= rber)
        rber = next_rber;
        vopt(3) = vopt(3) - 1;
        next_rber = getRBER(vths, [vopt(1); vopt(2); vopt(3)-1]);
    end
    
    [rber, rber_split] = getRBER(vths, vopt);
end