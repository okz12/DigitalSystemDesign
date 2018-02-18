function accuracytest(N,step,res);
res = transpose(res);
N = transpose(N);
step = transpose(step);
for m=1:16
    tm(m) = sumvec(N(m), step(m));
end

diff = res - tm;
p_change = 100*diff./tm;
    
    [ax,p1,p2] = plotyy(step,diff,step,abs(p_change),'stem','plot');
    set(ax(1), 'XScale', 'log', 'YLIM', [-0.5E7 3.5E7], 'YTick',[0 1E7 2E7 3E7]);
    %set(ax(1), 'XScale', 'log');
    set(ax(2), 'XScale', 'log');
    grid on;
    ylabel(ax(1),'Raw Error') % label left y-axis
    ylabel(ax(2),'Absolute Error as a Percentage of Value') % label right y-axis
    xlabel(ax(1),'Step Size') % label x-axis
for m = 1:16
    %step N nios matlab error absolute % error
    sprintf('%f & %d & %.0f & %.10f & %.10f & %f\\\\ \\hline', step(m), N(m), res(m), tm(m), diff(m), abs(p_change(m)))
end

end
