function [spddatt] = prodLogm3D(data,dim,nSamples)


spddatt=zeros(dim,dim,nSamples);

for j = 1:nSamples
    spddatt(:,:,j)=expm(data(:,:,j));
end



end

