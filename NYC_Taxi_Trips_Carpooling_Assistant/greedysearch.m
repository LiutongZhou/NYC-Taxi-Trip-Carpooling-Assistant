function X=greedysearch(Candidate,C,subtb)
tic
dist=@(O,D) 1000*deg2km(distance(O,D));
n=size(Candidate,1);
ind=find(has_candidate(Candidate)); %
X=logical(eye(n));
for i=ind' % for each i of those that has at least a candidate
    c=find(i<ind); % look from the unexplored candidate set (upper right triangle of X)
    lc=length(c); %we pair i with its nearest neighbors
    d=dist(...
        repmat(subtb{i,{'O_lat','O_lon'}},lc,1),...
        subtb{c,{'O_lat','O_lon'}}...
        );
    [~,idx] = sort(d);
    sorted_c=c(idx);% sorted_c is a linear index
    for j=1:lc
        leftX=find(X(i,1:i))';
        leftX=[leftX;sorted_c(1:j)]';%update leftX: a linear index to X
        if sum(subtb{leftX,'pc'}) > max(C(leftX))
            break
        end
    end
    X(i,sorted_c(1:j-1))=1;
    X(sorted_c(1:j-1),i)=1;
end
%%  report results
ispaired=has_candidate(X); % ispaired(i)=1 if the ith trip is paired, otherwise 0
paired_number=nnz(ispaired);
fprintf('we paired %d trips using a greedy search method\n',paired_number);
t=toc;
fprintf('Running time: %f s \n',t);
X=logical(sparse(X));
end
