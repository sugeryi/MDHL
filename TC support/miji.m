%求一个集合的幂集
function [Result,R_len]= miji(a,len)

Result = zeros(pow2(len),len) 
R_len = pow2(len);
k=1;
Result(k)=[];
k=k+1;
guide=1:len+1; %用来指导是否要进行输出的数组:0位不输出,1位输出
i=0,j=0,pos=len-1,pos1=0;   %标识最后一个0二进制代码的位置
for i=1:len %初始化指示数组,最初态均为0
   guide(i)=0;
end
guide(len+1)=1; %满足每次进行加1的操作

while(~is_complete(guide,len))   %此过程是二进制代码从00...0到11...1的过程
  temp=[]
   for j=1:len
    
    if(j>=pos) %如果在最后一个0的位置及其以后,该位的值是本位和下一位取异或
       guide(j)= (guide(j)~=guide(j+1) );
     end
    if(guide(j)==0) %用于指示下一个最后0的位置
        pos1=j;
     else
       temp=[temp,a(j)];
       %非0的就存储相应的元素
     end
    end %for
   m=size(temp,2)
   Result(k,[1:m])=temp;
   k=k+1;
   pos=pos1;
 end %while

clear k guide i j pos pos1 temp m
end
