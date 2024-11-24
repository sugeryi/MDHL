function [miss,extra,reverse,missorient,total]=CompareDag(DAG_Com,G)
numOfVar=size(G,1);
miss=0;
extra=0;
reverse=0;
missorient=0;
total=0;
for i=1:numOfVar
  for j=1:numOfVar

    if(DAG_Com(i,j)==0&&G(i,j)==1) 
        if (DAG_Com(j,i)==1)
             reverse=reverse+1;
        else
             miss=miss+1;
        end
    end
   
   if(DAG_Com(i,j)==1&&G(i,j)==0) 
        if (G(j,i)==1)
            reverse=reverse+1;
        else
            extra=extra+1;
        end
   end
  
  if(DAG_Com(i,j)==-1)
     missorient=missorient+1;
  end
    
  total=miss+extra+reverse+missorient;
  end
end


clear k guide i j pos pos1 temp m
end
