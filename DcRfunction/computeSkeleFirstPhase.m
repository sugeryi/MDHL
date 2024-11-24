
flo = load('./DataGen4_water_250/DistCorr4_water_250.mat');
data=flo.DistCorr4_water_250;
p=length(data);
k=0.05;
CC=zeros(p,p);
for i=1:p
  for j=(i+1):p
    if(abs(data(i,j))<k )
            CC(i,j)=1;
            CC(j,i)=1;
    end
  end
end
save('./DataGen4_water_250/SkeleFirstPhase4_water_250.mat','CC');