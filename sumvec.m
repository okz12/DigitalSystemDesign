function y=sumvec(N, step);
x=0:step:((N-1)*step);
        y=0;
        for i = 1:N
            y = y + x(i) + x(i)*x(i)*atan(floor((x(i)/4) - 32));
        end
end