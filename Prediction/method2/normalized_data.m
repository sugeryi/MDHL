function new_data = normalized_data(data)
[row,col] = size(data);
for i = 1: col
    X = data(:,i);
    X=X-repmat(mean(X),row,1);
    X=X*diag(1./std(X));
    data(:,i) = X;
end

new_data = data;
end

