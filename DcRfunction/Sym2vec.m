function [spddatt] = Sym2vec(data,nSamples,dimz,dim)
% data:三维矩阵


spddatt=zeros(nSamples,dimz);

for i = 1:nSamples
    step = 1;
    for j = 1:dim
        for k = j:dim
            spddatt(i,step) = data(j,k,i);
            step = step+1;
        end
    end
end


end

