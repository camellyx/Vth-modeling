function [] = myplot(x, v)
    figure('Visible', 'on');
    plot(x, v, 'o');
    hold;
    plot(x, v);
end