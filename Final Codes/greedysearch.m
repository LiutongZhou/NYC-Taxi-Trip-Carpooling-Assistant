function X=greedysearch(Candidate,C,subtb)
dist=@(O,D) 1000*deg2km(distance(O,D));
Candidate=triu(Candidate,1);
nc=size(Candidate,1);
for i=1:nc-1
    c=find(Candidate(i,:))';
    if isempty(c)
        continue
    end
    n=length(c);
    d=dist(...
        repmat(subtb{i,{'D_lat','D_lon'}},n,1),...
        subtb{c,{'D_lat','D_lon'}}...
        );
    [~,idx] = sort(d);
    c=c(idx);
    for j=1:n
        if sum(subtb{[i;c(1:j)],'pc'}) > max(C([i;c(1:j)]))
            break
        end
        Candidate(i,:)=0;
        Candidate(i,c(1:j-1))=1;
    end
end
flipurd=@(X)triu(X,1)+triu(X)';
X=flipurd(Candidate);
end
