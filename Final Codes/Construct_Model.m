function problem=Construct_Model(Candidate,pc,C)
%Constructs the integer programming model as described in my posted pdf 
%   input: Candidate: the index matrix Candidate
%   pc: passenger counts of a trip.
%   C: capacity of the cars
%   output: a structured problem 
n=size(Candidate,1);
if isrow(pc)
    pc=pc';
end
if isrow(C)
    C=C';
end
%% equallity constraint3: set diagonal values of X =1
beq3=ones(n,1);
Aeq3=sparse(1:n,sub2ind([n,n],1:n,1:n),1,n,n*n); % Aeq3 has n rows n*n columns, thus n equalities
%% equality constarint 2 set x(i,j)=x(j,i)
% n*(n-1)/2 is the number of elements of an upper triangle n*n matrix := nnz( triu(ones(n),1) )
ind1=zeros(n*(n-1)/2,1);ind2=ind1;
count=0;
for i=1:n
    ind1(count+1:count+n-i)= sub2ind([n n],repmat(i,1,n-i) ,i+1:n);
    ind2(count+1:count+n-i)=sub2ind([n n],i+1:n,repmat(i,1,n-i));
    count=count+n-i;
end
Aeq2=sparse(1:n*(n-1)/2,ind1,1,n*(n-1)/2,n*n,n*(n-1));
Aeq2=Aeq2+sparse(1:n*(n-1)/2,ind2,-1,n*(n-1)/2,n*n);
beq2=zeros(size(Aeq2,1),1);
%% equality constraint 6
filter=find(~logical(Candidate));%tilter: a linear index of non candidates in X  
Aeq6=sparse(1:length(filter),filter,1,length(filter),n*n);%Aeq6: has size:= length(filter) cross n*n
beq6=zeros(size(Aeq6,1),1);
% Assemble the equality constraints together in Aeq and beq; 
Aeq=[Aeq3;Aeq2;Aeq6];beq=[beq3;beq2;beq6];
%% Inequality constraints
A=kron(pc',speye(n));% A ia size:= n cross n*n sparse matrix
b=C;
%% binary constarints
intcon=1:n*n; 
lb=zeros(n*n,1);ub=ones(n*n,1);
%% set objective function
f=-ones(1,n*n);
%% capsulate the model setup
problem.solver = 'intlinprog';
problem.options = optimoptions('intlinprog');
problem.f = f;
problem.intcon = intcon;
problem.Aineq = A;
problem.bineq = b;
problem.Aeq = Aeq;
problem.beq = beq;
problem.lb = lb;
problem.ub=ub;
end