function [C,flag] = Separate(i,j,X,C_ij,threshold)
    %judge if  there exists a subset of C d-separating i and j. If there is a subset, return flag=true ,else return flag=false
   [nSamples,numOfVar]=size(X)
    C=C_ij
    Yi=X(:,i) 
    Yj=X(:,j);      
    tempData=X(:,C_ij)
          
      betai=regress(Yi,tempData);
      ei=Yi-tempData*betai;
      betaj=regress(Yj,tempData);
      ej=Yj-tempData*betaj;   
      pij=corr(ei,ej);    
      k=size(C_ij,2)
      Sb=sqrt((1-pij^2)/(nSamples-k-2))  
      df=nSamples-k-2
      T=pij/Sb  
      p_value=(1-tcdf(abs(T),df))*2
      if p_value>threshold 
          flag=true;
          return;

      end  
 %if partial correlation on C equals zero(conditional independent), this means Xi and Xj is d-seperated by C. 

p= abs(pij)
while(k>1)
      l=size(C_ij,2)
       min=100
       c_min=[]
       for m=1 : l
           c=C_ij(1,m)
           temp_ij=setdiff(C_ij,c)
           tempData=X(:,temp_ij)
           betai=regress(Yi,tempData);
           ei=Yi-tempData*betai;
           betaj=regress(Yj,tempData);
           ej=Yj-tempData*betaj;   
           ppij=corr(ei,ej);  
           if abs(ppij)<min
                min=abs(ppij)
                c_min=c
           end
           kk=size( temp_ij,2)  
           SSb=sqrt((1-ppij^2)/(nSamples-kk-2))  
           ddf=nSamples-kk-2
           TT=ppij/SSb  
           pp_value=(1-tcdf(abs(TT),ddf))*2
           if pp_value>threshold 
                 flag=true;
                 return;
           end  
      end

     if min>p
       flag=false;
       return;
     else
       C_ij=setdiff(C_ij,c_min)
       p=min
     end
    k=size(C_ij,2)
 end %while
 flag=false
 return

