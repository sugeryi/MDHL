%��һ�����ϵ��ݼ�
function [Result,R_len]= miji(a,len)

Result = zeros(pow2(len),len) 
R_len = pow2(len);
k=1;
Result(k)=[];
k=k+1;
guide=1:len+1; %����ָ���Ƿ�Ҫ�������������:0λ�����,1λ���
i=0,j=0,pos=len-1,pos1=0;   %��ʶ���һ��0�����ƴ����λ��
for i=1:len %��ʼ��ָʾ����,���̬��Ϊ0
   guide(i)=0;
end
guide(len+1)=1; %����ÿ�ν��м�1�Ĳ���

while(~is_complete(guide,len))   %�˹����Ƕ����ƴ����00...0��11...1�Ĺ���
  temp=[]
   for j=1:len
    
    if(j>=pos) %��������һ��0��λ�ü����Ժ�,��λ��ֵ�Ǳ�λ����һλȡ���
       guide(j)= (guide(j)~=guide(j+1) );
     end
    if(guide(j)==0) %����ָʾ��һ�����0��λ��
        pos1=j;
     else
       temp=[temp,a(j)];
       %��0�ľʹ洢��Ӧ��Ԫ��
     end
    end %for
   m=size(temp,2)
   Result(k,[1:m])=temp;
   k=k+1;
   pos=pos1;
 end %while

clear k guide i j pos pos1 temp m
end
