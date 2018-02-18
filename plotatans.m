function plotatans(i)

    for n=1:length(i)
        if(i(n)>=0)
            bi(n)=atan(i(n));
        else
            bi(n)=atan(i(n)) + pi;
        end
    cor(n)=atan_cordic(i(n),30);
    end
    plot(i,bi,i,cor);
    legend('Built-In','Cordic');

end