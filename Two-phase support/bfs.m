

function [simpathnode] = bfs(adj_mat, start)

% BFS Perform a breadth-first search of the graph starting from 'start'.
% [simpathnode] = bfs(adj_mat, start)
%
% Input:
% adj_mat(i,j)=-1 iff i is connected to j.
% start is the root vertex of the bfs tree; 

%
% Output: simpathnode records the all vertices on
%   simple paths between any two vertices.

%

adj=adj_mat
adj_mat=triu(adj_mat);%考虑兼容性，只取上三角部分

n = length(adj_mat);


global pathnode simpathnode 
pathnode = [];
simpathnode = cell(n,n);

bfs_visit(start, adj_mat);
  

for i=1:n
  for j=1:n
    if(i~=j) 
        for k=1:n
           if( k~=i && k~=j && adj(j,k)~=0 )
                 if( ( ~isempty(simpathnode{i,k}) && ~ismember(j,simpathnode{i,k} ) )|| adj(i,k)~=0  )
                     temp=union(simpathnode{i,k},simpathnode{k,j} )
                     simpathnode{i,j}=union(simpathnode{i,j},temp )
                     simpathnode{i,j}=union(simpathnode{i,j},k )
                     simpathnode{i,j}=setdiff(simpathnode{i,j},[i j])
                  end
           end
        end
    end
   end
  end




%%%%%%%%%%

function bfs_visit(u, adj_mat)

global pathnode simpathnode
  path={}
  pathnode=[pathnode u];
  ns = neighbors(adj_mat, u);
  ns = setdiff(ns, pathnode); % don't go back to visit the guy who called you!
  ns_len=length(ns)
 for i=1:ns_len
     path=[path u]
 end

while(ns_len>0)
  ns_total=[]  
   for i=1:ns_len
        pathnode= [path{i} ns(i)];
        len=length(pathnode)
        y=pathnode(len)
        if(len>=3)
          for i=1:len-2
%             dlmwrite('E:\temp\result.txt',pathnode,'-append','delimiter','\t');
             x=pathnode(i)
             simpathnode{x,y}=union(simpathnode{x,y},pathnode(i+1:len-1) )
          end
        end

       ns_p = neighbors(adj_mat, ns(i));
       ns_p = setdiff(ns, pathnode); 
       ns_p_len=length(ns_p)
       if (ns_p_len>=1) 
          for j=1:ns_p_len
             path=[path pathnode]
          end
          ns_total=[ns_total ns_p]
       end
       
    end %for
   for i=1:ns_len
     path(1)=[]
   end
   ns=ns_total
   ns_len=length(ns)

  end %while
  
 
function ns = neighbors(adj_mat, i)

% NEIGHBORS Find the parents and children of a node in a graph.
ns = [find(adj_mat(i,:)) find(adj_mat(:,i))'];