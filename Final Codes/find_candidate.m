function [candidate,subtb,ind]=find_candidate(tb,tolo,told,tolt)
%% Constructing Candidate index set called Candidate and eliminate those trips with no candidate
%   input: tb: a table containing data
%   tolerances: tolo,told,tolt
%   output: candidate: a logical index set for tb. Candidate(i,j)=1 if 
%   the ith trip and jth trip satisfy nonlinear constarints 1 2 3
%   tb: a filtered table cantaining records for trips that have matching
%   candidates
%   ind: a logical index to original input table tb, subtb=tb(ind,:) 
%% Constructing Candidate index set
% Candidate(i,j)=1 if the ith trip and jth trip satisfy nonlinear constarints 1 2 3
% which are (1) the distance constarint on origin, (2)the distance constarint on destination and 
% (3) departure time constraint. Candidate is a symmetric n cross n matrix
n=height(tb);
Candidate=repmat(eye(n),1,1,3); % Candidate(:,:,i) is an index matrix of those pairs who satisfy constraint i (for i=1:3)
dist=@(O,D) 1000*deg2km(distance(O,D));%dist: a function for calculating distance between O and D in meters using (lat,lon).
for i=1:n-1
    Candidate(i,i+1:n,1:2)=cat(3, ...
        dist(...                                 
            repmat(tb{i,{'O_lat','O_lon'}},n-i,1),...
            tb{i+1:n,{'O_lat','O_lon'}}...
           )   < min(tolo(i+1:n),tolo(i)),... %(1) test whether the ith orign and jth origin satisfy distance tolerance
        dist(...
            repmat(tb{i,{'D_lat','D_lon'}},n-i,1),...
            tb{i+1:n,{'D_lat','D_lon'}}...
           )  <min(told(i+1:n),told(i))... %(2) test whether the ith destination and jth destination satisfy distance tolerance
       );
    Candidate(i,i+1:n,3)=abs(tb{i,'dept_time'}-tb{i+1:n,'dept_time'})...
           < min(tolt(i+1:n),tolt(i)); %(3) test whether the ith dept time and jth dept time satisfy waiting time tolerance
end
Candidate=sum(Candidate,3)==size(Candidate,3); % Test wether Candidate satisfy all the tolerance constraints
flipurd=@(X)triu(X,1)+triu(X)';% flip the upper right triangle down to form a symmetric matrix
Candidate=flipurd(Candidate);
Candidate=logical(Candidate);
%% eliminate those trips with no candidate
has_candidate=@(Candidate) any(Candidate-eye(size(Candidate,1)),2);
ind=has_candidate(Candidate);
subtb=tb(ind,:);
Candidate(~ind,:)=[];
Candidate(:,~ind)=[];
candidate=Candidate;
end