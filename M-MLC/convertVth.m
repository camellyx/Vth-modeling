function [vth] = convertVth(MSB_vth, LSB_vth)

    % The bottom one is more accurate (tolerates misread MSB_vth values)
    % vth = MSB_vth + LSB_vth - (LSB_vth == 0) * 99 + (LSB_vth < 51) * 99 + (LSB_vth >= 51) .* (301 - 2 * MSB_vth) + (LSB_vth == 101) * 99;
    vth = 200 + LSB_vth + (LSB_vth == 0) .* (MSB_vth - 200) + (LSB_vth == 101) .* (200 - MSB_vth);

end