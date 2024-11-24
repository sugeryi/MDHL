%该函数用于判断是否从全0序列变成了全1序列,全1序列说明所有的子集都找完了

function [flag]=is_complete(a,len)
flag=1
for i=1:len
   if a(i)==0
   flag=0;
   end
end
clear i
end
