function [Gmin_adjMatrix,scores,evals] = DAGsearch3(X,maxIter,restartVal,complexityFactor,PP)
% Inputs:
%   X(instance,feature)
%   maxIter - maximum number of family evaluations
%   restartVal - probability of random restart after each step
%   complexityFactor - weight of free parameter term
%     (log(n)/2 == BIC, 1 == AIC)
%   PP(feature1,feature2) - 1 if we consider feature1 to be a parent of
%       feature 2, 0 if this is disallowed
% Outputs:
%   Gmin_adjMatrix - adjacency matrix for the highest scoring structure
%   scores - scores after each step
%   evals - number of family evaluations after each step

verbose=1;
doPlot=0;
[p,~] = size(X);
restart = 1;
Gmin_score = inf;
evals(1) = 0;
scores(1) = inf;
dags{1} = ones(p);
Ind = 2;
iter = 0;

K = inf;
while evals(end) < maxIter
    iter = iter + 1;
    if restart == 1
        % Restart Case
        % Generate a New Candidate
        % Randomly add edges to an empty graph until you make a cycle
       adjMatrix = zeros(p);
       ancMatrix = zeros(p);
       loops = 0;
       while 1
            i = ceil(rand*p);
            j = ceil(rand*p);
            if i ~= j && adjMatrix(i,j) == 0 && adjMatrix(j,i) == 0
                if ancMatrix(j,i) == 1 % Adding edge would cause a cycle
                    break;
                else
                    if sum(adjMatrix(:,j)) > K || PP(i,j) == 0
                        % Breaks fan-in bound or parent restriction
                    else
                        adjMatrix(i,j) = 1;
                        ancestorMatrixAddC_InPlace(ancMatrix,i,j);
                    end
                end
            elseif loops > p^2
                break;
            else
                loops = loops + 1;
                continue;
            end
       end
       
        % Compute Statistics
        graphScores = EvaluateGraph(X,adjMatrix,complexityFactor);

        % Set Candidate as Local Min
        Lmin_score = sum(graphScores);
        Lmin_adjMatrix = adjMatrix;

        % Compare to Global Min
        if Lmin_score < Gmin_score
            Gmin_score = Lmin_score;
            Gmin_adjMatrix = Lmin_adjMatrix;
        end

        % Update Counters
        evals(Ind) = evals(Ind-1)+1;
        scores(Ind) = inf;
        dags{Ind} = ones(p);
        Ind = Ind+1;
        evals(Ind) = evals(Ind-2) + p;
        scores(Ind) = sum(graphScores);
        dags{Ind} = sparse(adjMatrix);
        Ind = Ind+1;
        
        % Update state indicators
        atLocalMin = 0;
        restart = 0;

    else
        % 1st Iter after Restart
        atLocalMin = 1;
        if restart == 0
            % Test all deletions, additions, reversals
            if verbose == 2
                fprintf('Evaluating Deletions\n');
            end
            [delta_graphScores_del delEvals] = EvaluateDeletions(X,adjMatrix,complexityFactor,graphScores);
            if verbose == 2
                fprintf('Evaluating Additions\n');
            end
            [delta_graphScores_add addEvals] = EvaluateAdditions(X,adjMatrix,complexityFactor,graphScores,PP,K,ancMatrix);
            if verbose == 2
                fprintf('Evaluating Reversals\n');
            end
            [delta_graphScores_revJ delta_graphScores_revI revEvals] = ...
                EvaluateReversals(X,adjMatrix,complexityFactor,...
                graphScores,PP,K,delta_graphScores_del,ancMatrix);
        else
            % Update the scores of deletions, additions, reversals
            % (based on old scores and changes in graph)

            if verbose == 2
                fprintf('Updating Deletions\n');
            end
            [delta_graphScores_del delEvals] = UpdateDeletions(X,adjMatrix,...
                complexityFactor,graphScores,delta_graphScores_del,changed);
            if verbose == 2
                fprintf('Updating Additions\n');
            end
            [delta_graphScores_add addEvals] = UpdateAdditions(X,adjMatrix,...
                complexityFactor,graphScores,PP,K,delta_graphScores_add,changed,ancMatrix);
            if verbose == 2
                fprintf('Updating Reversals\n');
            end
            [delta_graphScores_revJ delta_graphScores_revI revEvals] = ...
                UpdateReversals(X,adjMatrix,complexityFactor,...
                graphScores,PP,K,delta_graphScores_del,...
                delta_graphScores_revJ,delta_graphScores_revI,changed,ancMatrix);
        end

        % Find Move that Decreases the Score the most

        [min_del delPos] = min(delta_graphScores_del(:));
        [min_add addPos] = min(delta_graphScores_add(:));
        [min_rev revPos] = min(delta_graphScores_revI(:)+delta_graphScores_revJ(:));

        if min_del <= min_add
            if min_del <= min_rev
                op = -1;
            else
                op = 0;
            end
        else
            if min_add <= min_rev
                op = 1;
            else
                op = 0;
            end
        end

        % Update Adjacency Matrix and Statistics

        if op == -1
            % Deletion
            if verbose == 1
                fprintf('Deleting Edge\n');
            end
            [i j] = ind2sub(p,delPos);
            adjMatrix(i,j) = 0;
            ancMatrix = ancestorMatrixBuildC(adjMatrix);
            changed = j; % delta_graphScores for j's family are obsolete
            graphScores(j) = graphScores(j) + delta_graphScores_del(i,j);
        elseif op == 1
            % Addition
            if verbose == 1
                fprintf('Adding Edge\n');
            end
            [i j] = ind2sub(p,addPos);
            adjMatrix(i,j) = 1;
            ancestorMatrixAddC_InPlace(ancMatrix,i,j);
            changed = j; % delta_graphScores for i's family are obsolete
            graphScores(j) = graphScores(j) + delta_graphScores_add(i,j);
        else
            % Reversal
            if verbose == 1
                fprintf('Reversing Edge\n');
            end
            [i j] = ind2sub(p,revPos);
            adjMatrix(i,j) = 0;
            adjMatrix(j,i) = 1;
            ancMatrix = ancestorMatrixBuildC(adjMatrix);
            changed = [i j]; % delta_graphScores i+j's families are obsolete
            graphScores(j) = graphScores(j) + delta_graphScores_revJ(i,j);
            graphScores(i) = graphScores(i) + delta_graphScores_revI(i,j);
        end

        % Check for local/global decrease

        configScore = sum(graphScores);

        if configScore < Lmin_score
            Lmin_score = configScore;
            Lmin_adjMatrix = adjMatrix;
            atLocalMin = 0;
            if Lmin_score < Gmin_score
                Gmin_score = Lmin_score;
                Gmin_adjMatrix = Lmin_adjMatrix;
            end
        end

        % Update Counters
        evals(Ind) = evals(Ind-1) + delEvals + addEvals + revEvals;
        scores(Ind) = sum(graphScores);
        dags{Ind} = sparse(Lmin_adjMatrix);
        Ind = Ind+1;

        restart = -1;
    end

    if doPlot
        clf;
        subplot(1,2,1);
        drawGraph(Lmin_adjMatrix);
        subplot(1,2,2);
        drawGraph(Gmin_adjMatrix);
        pause;
    end
    drawnow;


    % Output Iteration Log
    if verbose
        fprintf('DAGsearch: It %d, Evals = %d, Lmin = %.3f, Gmin = %.3f',iter,evals(end),Lmin_score,Gmin_score);
        drawnow;
    end

    % Set restart indicator to 1 if we are at a local minimum, or
    %   if we are doing a random restart
    if atLocalMin
        if verbose
            fprintf(' (Found Local Minimum)\n');
        end
        restart = 1;
    elseif restartVal > 0 && rand < restartVal % First condition avoid changing seed
        if verbose
            fprintf(' (Randomly Restarting)\n');
        end
        restart = 1;
    else
        if verbose
            fprintf('\n');
        end
    end


    if nargin == 9 && restart == 1
        if verbose
            fprintf('Found local minimum, returning\n');
            
        end
        break;
    end

end

end

function [familyScore] = EvaluateFamily(X,adjMatrix,complexityFactor,i)
[~,~,n]=size(X{i});
parents = find(adjMatrix(:,i));
len = length(parents);
if len
    x = reshape(X{parents(1)}(1,1,:),n,1);
    for k =2:len
        x = [x,reshape(X{parents(k)}(1,1,:),n,1)];
    end  
    y = reshape(X{i}(1,1,:),n,1);
    XX = x'*x;
    Xy = x'*y;
    yy = y'*y;
    params = inv(XX)*Xy;
    familyScore = score(GLoss(XX,Xy,yy,params),sum(adjMatrix(:,i)),complexityFactor);
else
    y = reshape(X{i}(1,1,:),n,1);
    yy = y'*y;
    familyScore = score((1/2)*yy,sum(adjMatrix(:,i)),complexityFactor);
end
end


function [graphScores] = EvaluateGraph(X,adjMatrix,complexityFactor)
p = length(adjMatrix);
for i = 1:p
    %fprintf('Evaluating family of %d\n',i);
    graphScores(i) = EvaluateFamily(X,adjMatrix,complexityFactor,i);
end
end

function [delta_scores,evals] = EvaluateDeletions(X,adjMatrix,complexityFactor,graphScores)
p = length(adjMatrix);
delta_scores = zeros(p);
evals = 0;
for i = 1:p
    for j = 1:p
        if adjMatrix(i,j) == 1
            % Evaluate deleting i => j
            %fprintf('Evaluating deletion of (%d,%d)\n',i,j);
            adjMatrix_del = adjMatrix;
            adjMatrix_del(i,j) = 0;
            delta_scores(i,j) = ....
                EvaluateFamily(X,adjMatrix_del,complexityFactor,j) ...
                - graphScores(j);
            evals = evals+1;
        end
    end
end
end

function [delta_scores,evals] = UpdateDeletions(X,adjMatrix,complexityFactor,...
    graphScores,delta_scores,changed)
p = length(adjMatrix);
evals = 0;
for i = 1:p
    for j = changed
        if adjMatrix(i,j) == 1
            % Evaluate deleting i => j
            %fprintf('Evaluating deletion of (%d,%d)\n',i,j);
            adjMatrix_del = adjMatrix;
            adjMatrix_del(i,j) = 0;
            delta_scores(i,j) = ....
                EvaluateFamily(X,adjMatrix_del,complexityFactor,j) ...
                - graphScores(j);
            evals = evals+1;
        else
            delta_scores(i,j) = 0; % This edge may have been deleted
        end
    end
end
end

function [delta_scores,evals] = EvaluateAdditions(X,adjMatrix,complexityFactor,graphScores,PP,K,ancMatrix)
p = length(adjMatrix);
delta_scores = zeros(p);
evals = 0;
for i = 1:p
    for j = 1:p
        if i ~= j && adjMatrix(i,j) == 0 && adjMatrix(j,i) == 0 && PP(i,j) == 1

            if sum(adjMatrix(:,j))+1 <= K && ~ancMatrix(j,i)
                % Evaluate adding i => j
                %fprintf('Evaluating addition of (%d,%d)\n',i,j);
                adjMatrix_add = adjMatrix;
                adjMatrix_add(i,j) = 1;
                delta_scores(i,j) = ...
                    EvaluateFamily(X,adjMatrix_add,complexityFactor,j) ...
                    - graphScores(j);
                evals = evals+1;
            end
        end
    end
end
end

function [delta_scores,evals] = UpdateAdditions(X,adjMatrix,complexityFactor,...
    graphScores,PP,K,delta_scores_old,changed,ancMatrix)
p = length(adjMatrix);
delta_scores = zeros(p);
evals = 0;
for i = 1:p
    for j = 1:p
        if i ~= j && adjMatrix(i,j) == 0 && adjMatrix(j,i) == 0 && PP(i,j) == 1

            if sum(adjMatrix(:,j))+1 <= K && ~ancMatrix(j,i)
                % Evaluate adding i => j
                %fprintf('Evaluating addition of (%d,%d)\n',i,j);

                if any(j==changed) || delta_scores_old(i,j) == 0
                    adjMatrix_add = adjMatrix;
                    adjMatrix_add(i,j) = 1;
                    delta_scores(i,j) = ...
                        EvaluateFamily(X,adjMatrix_add,complexityFactor,j) ...
                        - graphScores(j);
                    evals = evals+1;
                else
                    delta_scores(i,j) = delta_scores_old(i,j);
                end
            end
        end
    end
end
end



function [delta_scoresj,delta_scoresi,evals] = EvaluateReversals(X,adjMatrix,...
    complexityFactor,graphScores,PP,K,delta_scores_del,ancMatrix)
p = length(adjMatrix);
params = cell(p);
delta_scoresj = zeros(p);
delta_scoresi = zeros(p);
evals = 0;
for i = 1:p
    for j = 1:p
        if adjMatrix(i,j) == 1 && PP(j,i) == 1
            if sum(adjMatrix(:,i))+1 <= K && ~any(ancMatrix(i,find(ancMatrix(:,j)))==1)
                % Evaluate reversing i => j
                %fprintf('Evaluating reversal of (%d,%d)\n',i,j);
                adjMatrix_rev = adjMatrix;
                adjMatrix_rev(i,j) = 0;
                adjMatrix_rev(j,i) = 1;
                delta_scoresj(i,j) = delta_scores_del(i,j);
                delta_scoresi(i,j) = ...
                    EvaluateFamily(X,adjMatrix_rev,complexityFactor,i)...
                    - graphScores(i);
                evals = evals+1;

            end
        end
    end
end
end

function [delta_scoresj,delta_scoresi,evals] = UpdateReversals(X,adjMatrix,...
    complexityFactor,graphScores,PP,K,delta_scores_del,...
    delta_scoresj_old,delta_scoresi_old,changed,ancMatrix)
p = length(adjMatrix);
params = cell(p);
delta_scoresj = zeros(p);
delta_scoresi = zeros(p);
evals = 0;
for i = 1:p
    for j = 1:p
        if adjMatrix(i,j) == 1 && PP(j,i) == 1
            if sum(adjMatrix(:,i))+1 <= K && ~any(ancMatrix(i,find(ancMatrix(:,j)))==1)
                if any(i==changed) || any(j==changed) || ...
                        (delta_scoresj_old(i,j) == 0 && delta_scoresi_old(i,j) == 0)
                    % Evaluate reversing i => j
                    %fprintf('Evaluating reversal of (%d,%d)\n',i,j);
                    adjMatrix_rev = adjMatrix;
                    adjMatrix_rev(i,j) = 0;
                    adjMatrix_rev(j,i) = 1;
                    delta_scoresj(i,j) = delta_scores_del(i,j);
                    delta_scoresi(i,j) = ...
                        EvaluateFamily(X,adjMatrix_rev,complexityFactor,i)...
                        - graphScores(i);
                    evals = evals+1;
                else
                    delta_scoresj(i,j) = delta_scoresj_old(i,j);
                    delta_scoresi(i,j) = delta_scoresi_old(i,j);
                end

            end
        end
    end
end
end

% Returns 1 if the graph has cycles
function [c] = cycles(adjMatrix)
p = length(adjMatrix);
c = sum(diag((sparse(adjMatrix+eye(p)))^p) == ones(p,1)) ~= p;
end