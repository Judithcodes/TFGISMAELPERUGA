function P=DropUEinHexagonCell(K,vertices,R)  %K : no. of UE 
% vertices: vertices of the hexagon with radius being 1; 
% R: radius of the hexagon
flag=1;
x_final=[];
y_final=[];
while (flag)
    x=R-rand(1,5*K)*2*R;
    y=R-rand(1,5*K)*2*R;
    % distance between users and BS should be larger than 0.14R
    IN1=inpolygon(x,y,real(0.14*R*vertices),imag(0.14*R*vertices));
    x_new1=x(not(IN1));
    y_new1=y(not(IN1));
    % distance between users and BS should be smaller than R
    IN=inpolygon(x_new1,y_new1,real(R*vertices),imag(R*vertices));
    x_new=x_new1(IN);
    y_new=y_new1(IN);
    x_final=[x_final x_new];
    y_final=[y_final y_new];
    if(length(x_final)<K)
        continue;
    else
        flag=0;
    end
end
idx=randperm(length(y_final));
P=x_final(idx(1:K)) + 1i*y_final(idx(1:K));
P=P.';

