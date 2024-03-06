

clearvars -except frameInfo t

% enter the x,y,z for geometric filter
x_inf = ;
x_sup = ;
y_inf = ;
y_sup = ;
z_inf = ;
z_sup = ;


bleach = []; %enter the bleaching per time point

[col,times] = size(frameInfo);

for t=1:times
    
FI = 10*bleach(t);
%FI = 15;
   
clearvars -except frameInfo t x_inf x_sup y_inf y_sup z_inf z_sup FI col times bleach

pos=find(frameInfo(t).x > x_inf & frameInfo(t).x < x_sup & frameInfo(t).y > y_inf & frameInfo(t).y < y_sup & frameInfo(t).z > z_inf & frameInfo(t).z < z_sup & frameInfo(t).A > FI);

%add here the filter by distance

x_pos = frameInfo(t).x(pos);
y_pos = frameInfo(t).y(pos);
z_pos = frameInfo(t).z(pos);
A_pos = frameInfo(t).A(pos);
c_pos = frameInfo(t).c(pos);



pos_filter = [];
pos_final = [];

[m,n] = size(pos);

rep = 0;


for i=1:n
    x = x_pos(i);
    y = y_pos(i);
    z = z_pos(i);
    A = A_pos(i);
    
    for j=1:n
        D = sqrt( (x - x_pos(j))^2 + (y - y_pos(j))^2 + (z - z_pos(j))^2 );
        pos_D(i,j) = D;
        if(D < 5)
            if(A < A_pos(j))
                pos_filter(i,j) = pos(j);
                rep = rep + 1;
            else
                pos_filter(i,j) = pos(i);
            end
        else  
            pos_filter(i,j) = pos(i);
        end
    end
end


for i=1:n
    count = 0;
    pos_original = pos_filter(i,1);
    for j=2:n
        number = pos_filter(i,j);
        if(pos_original ~= number)
            count = 1;
            index = j;
        end
    end
    if(count > 0)
        pos_final(i) = pos_filter(i,index);
    else
        pos_final(i) = pos_filter(i,1);
    end
    
end

j = 1;

for i=1:(n-1)
    if(pos_final(i) == pos_final(i+1))
        pos_end(j) = pos_final(i);
    else
        pos_end(j) = pos_final(i);
        j = j + 1;
    end
end


x_posf = frameInfo(t).x(pos_end);
y_posf = frameInfo(t).y(pos_end);
z_posf = frameInfo(t).z(pos_end);
A_posf = frameInfo(t).A(pos_end);

fname1 = sprintf("A_pos_%d.txt",t);
fname2 = sprintf("x_pos_%d.txt",t);
fname3 = sprintf("y_pos_%d.txt",t);
fname4 = sprintf("z_pos_%d.txt",t);



csvwrite(fname1,A_posf)
csvwrite(fname2,x_posf)
csvwrite(fname3,y_posf)
csvwrite(fname4,z_posf)

end
