function [eigen] = solveeigen(X)
[n,~] = size(X);
[~,~,nSamples] = size(X{1});

eigen = zeros(nSamples,n);
for j = 1:n
    for i= 1:nSamples
        [~,y]  = eig(X{j}(:,:,i));
        value = diag(y);
        eigen(i,j) = value(1);
    end
end
eigen = standardizeCols(eigen);
end
