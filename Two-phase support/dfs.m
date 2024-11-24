

function [simpathnode] = dfs(adj_mat, start, directed)

% DFS Perform a depth-first search of the graph starting from 'start'.
% [d, pre, post, cycle, f, pred] = dfs(adj_mat, start, directed)
%
% Input:
% adj_mat(i,j)=-1 iff i is connected to j.
% start is the root vertex of the dfs tree; if [], all nodes are searched
% directed = 1 if the graph is directed
%
% Output:
% d(i) is the time at which node i is first discovered.
% pre is a list of the nodes in the order in which they are first encountered (opened).
% post is a list of the nodes in the order in which they are last encountered (closed).
% 'cycle' is true iff a (directed) cycle is found.
% f(i) is the time at which node i is finished.
% pred(i) is the predecessor of i in the dfs tree.
%
% If the graph is a tree, preorder is parents before children,
% and postorder is children before parents.
% For a DAG, topological order = reverse(postorder).
%
% See Cormen, Leiserson and Rivest, "An intro. to algorithms" 1994, p478.

adj=adj_mat
adj_mat=triu(adj_mat);%考虑兼容性，只取上三角部分

n = length(adj_mat);

global white gray black color
white = 0; gray = 1; black = 2;
color = white*ones(1,n);

global time_stamp
time_stamp = 0;

global d f
d = zeros(1,n);
f = zeros(1,n);

global pred
pred = zeros(1,n);

global cycle
cycle = 0;

global pre post 
pre = [];
post = [];

global pathnode simpathnode 
pathnode = [];
simpathnode = cell(n,n);

if ~isempty(start)
  dfs_visit(start, adj_mat, directed);

else

 %for u=1:n
   %if color(u)==white
     dfs_visit(1, adj_mat, directed);
   %end
 % end

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


end


%%%%%%%%%%

function dfs_visit(u, adj_mat, directed)

global white gray black color time_stamp d f pred cycle  pre post pathnode simpathnode

pre = [pre u];
pathnode=[pathnode u];
color(u) = gray;
time_stamp = time_stamp + 1;
d(u) = time_stamp;
if directed
  ns = children(adj_mat, u);
else
  ns = neighbors(adj_mat, u);
  %ns = setdiff(ns, pred(u)); % don't go back to visit the guy who called you!
  ns = setdiff(ns, pathnode); 
end
%{
以下三句是为随机选路而设置
lns=length(ns);
pos=randperm(lns);
ns=ns(pos);
%}

for v=ns(:)'
   fprintf('u=%d, v=%d, color(v)=%d\n', u, v, color(v))
     pred(v)=u;
     dfs_visit(v, adj_mat, directed);
  end

len=length(pathnode)
y=pathnode(len)

if(len>=3)
   for i=1:len-1
    % dlmwrite('E:\temp\result.txt',pathnode,'-append','delimiter','\t');
     x=pathnode(i)
     simpathnode{x,y}=union(simpathnode{x,y},pathnode(i+1:len-1) )
   end
end
pathnode=pathnode(1:len-1)
%color(u) = black;
post = [post u];
time_stamp = time_stamp + 1;
f(u) = time_stamp;

function cs = children(adj_mat, i, t)
% CHILDREN Return the indices of a node's children in sorted order
% c = children(adj_mat, i, t)
%
% t is an optional argument: if present, dag is assumed to be a 2-slice DBN

if nargin < 3
  cs = find(adj_mat(i,:));
else
  if t==1
    cs = find(adj_mat(i,:));
  else
    ss = length(adj_mat)/2;
    j = i+ss;
    cs = find(adj_mat(j,:)) + (t-2)*ss;
  end
end

function ns = neighbors(adj_mat, i)
% NEIGHBORS Find the parents and children of a node in a graph.
% ns = neighbors(adj_mat, i)

%ns = myunion(children(adj_mat, i), parents(adj_mat, i));
ns = [find(adj_mat(i,:)) find(adj_mat(:,i))'];