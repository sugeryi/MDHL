function[loss] = solveGloss(parents,X,i)
loss = 0;
len = length(parents);
if len
    x = X{parents(1)}(:,1);
    for j=2:len
        x = [x,X{parents(j)}(:,1)]; 
    end
    y = X{i}(:,1);
%     XX = sin(x)'*sin(x);
%     Xy = sin(x)'*y;
%     yy = sin(y)'*y;
    XX = x'*x;
    Xy = x'*y;
    yy = y'*y;
    params = inv(XX)*Xy;
    loss = GLoss(XX,Xy,yy,params);
else
    y = X{i}(:,1);
%     yy = sin(y)'*y;
    yy = y'*y;
    loss = (1/2)*yy;
end
end
        
        
    