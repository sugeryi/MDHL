function [CC]=comparePval(X,k)
[~,p]=size(X);
CC = zeros(p,p);
for i=1:p
  for j=1:p
    if(abs(X(i,j))<=k )
            CC(i,j)=1;
%             CC(j,i)=1;
    else
            CC(i,j)=0;
  
    end
  end
end
end