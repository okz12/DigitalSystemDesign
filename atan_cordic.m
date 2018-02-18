function z=atan_cordic(angle, iter)
    %pre-calculated and stored
    phi = 2.^-(1:iter);
    angles = atan(phi);
    
    %initial values
    z=0;
    x = angle;
    y = 1;
    
    for n = 1:iter;
        if (x*y>=0)
            z = z + angles(n);
            xn = x + y*phi(n);
            yn = y - x*phi(n);
        else
            z = z - angles(n);
            xn = x - y*phi(n);
            yn = y + x*phi(n);
        end
        x=xn;
        y=yn;
        %disp([x; y])
    end
    %disp([x; y])
    z=sign(z)*pi/2 - z;
    if(eq(angle,0))%zero bypass
      z=0;
    end
end