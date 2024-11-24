function [P] = topologicalPermutation(adjMatrix)
% Input: DAG adjacency matrix
% Output: Permutation vector for a topological ordering

adjMatrix = sparse(adjMatrix);

display = 0;

p = length(adjMatrix);

P = 1:p;

%fprintf('Topological Sort...\n');

done = 0;
while ~done
    done = 1;
    for i = 1:p
        for j = 1:i-1
            if adjMatrix(i,j) == 1
                done = 0;
                %fprintf('Swapping %d and %d\n',P(i),P(j));
                adjMatrix(:,[i j]) = adjMatrix(:,[j i]);
                adjMatrix([i j],:) = adjMatrix([j i],:);
                P([i j]) = P([j i]);
				if display
                image(25*[adjMatrix+2*eye(p)]);
                pause(.1);
				end
            end
        end
    end
end