
flo = load('./DataGen4_250/dcorMatrix4_250.mat');
data=flo.dcorMatrix4_250;
p=length(data);
num=3;
CC=zeros(p,p);


for i=1:(p-1)
  j=i+1;
  [classScore, indexScore] = sort(data(j:p,i),1,'descend');
  indexScore = indexScore +i;
  if length(indexScore)<=num
      num = min(num,length(indexScore));
  end
  for k=1:num
      CC(indexScore(k,1),i)=1;
      CC(i,indexScore(k,1))=1;
  end
end


%   classScore = data(2:p,1);
%   [classScore, indexScore] = sort(classScore,1,'descend');
%   indexScore = indexScore +1;
%   for k=1:num
%       CC(indexScore(k,1),1)=1;
%       CC(1,indexScore(k,1))=1;
%   end
  
%  df=[5;4;2;8;7];
%  [classScore, indexScore] = sort(df,1,'descend');

save('./DataGen4_250/SkeleFirstPhase4_alarm_250_nm.mat','CC');
