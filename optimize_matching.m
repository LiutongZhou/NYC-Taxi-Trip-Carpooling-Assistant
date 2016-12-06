%% An implementation of the simple carpool mathcing integer programming model
% ver. 1.0
% author Liutong Zhou
% created on 12/5/2016
%% Read taxi trip data
clear;
inp_dir='D:\OneDrive - Columbia University\2016Fall\3. Infrastructural Systems Optimization\Final Project\data\';
filename=[inp_dir,'Filetered Data_050115_730_11.xlsx'];
opts=detectImportOptions(filename,'Sheet','Sheet1');
opts.SelectedVariableNames={'tpep_pickup_datetime','passenger_count',...
    'pickup_latitude','pickup_longitude','dropoff_latitude','dropoff_longitude'};
tb=readtable(filename,opts);
tb=rmmissing(tb);
tb.Properties.VariableNames={'dept_time','pc','O_lat','O_lon',...
    'D_lat','D_lon'}; % pc='passenger count','O_lat'='origin_latitude'
tb=sortrows(tb,'dept_time','ascend');
%test only 
tb=tb(1:600,:);
%
%% Inut your tolerances here for time and distance
% Example:
% everyone has a 100-meter tolerance for distance between departure origns
% everyone has a 100-meter tolerance for distance between destinations
% everyone has a 10-minute tolerance for waiting time of departure
% usually people have different tolerance
% capacity of the ith car is C(i) for i=1...n
n=height(tb); % n is the total number of trips given as input
tolo=4000*ones(n,1); %tolo(i): the ith passenger's tolerance for origin distance eg. 100 meters
told=4000*ones(n,1); %told(i): the ith passenger's tolerance for destination distance 100 meters
tolt=repmat(duration(0,60,0,'Format','m'),n,1); %tolt(i) : the ith passenger's tolerance for departure waiting duration eg. 10 minutes
C=max(tb.pc,4); % capacity of the ith car: C(i) we set an treshold for passengers count:3
%% Constructing Candidate index set called Candidate
% Candidate(i,j)=1 if the ith trip and jth trip satisfy  both the ith 
% and the jth passenger's tolerance 
find_candidate
%% Construct the integer programming model
n=size(Candidate,1);
%equallity constraint3
beq3=ones(n,1);
Aeq3=sparse(1:n,sub2ind([n,n],1:n,1:n),1,n,n*n);
% equality constarint 2
ind1=zeros(n*n,1);ind2=ind1;
for i=1:n
    for j=i:n
        ind1=sub2ind(size(Candidate),i,j);
        ind2=sub2ind(size(Candidate),j,i);
    end
end
Aeq2=sparse(1:(1+n)*n/2,ind1,1,(1+n)*n/2,n*n);
Aeq2(1:end,ind2)=-1;
beq2=zeros(size(Aeq2,1),1);
%%
% equality constraint 6
filter=find(~logical(Candidate));
Aeq6=sparse(1:length(filter),filter,0,length(filter),n*n);
beq6=zeros(size(filter));
%%
Aeq=[Aeq2;Aeq3];
beq=[beq2;beq3];
A=kron(tb.pc',speye(n));b=C; % Inequality constraints
intcon=1:n; % binary constarints
lb=zeros(n*n,1);ub=ones(n*n,1);
f=-ones(1,numel(Candidate));
%% run model
x = intlinprog(f,intcon,A,b,Aeq,beq,lb,ub);
%% report the results
1;
X=reshape(x,size(Candidate));
ispaired=any(triu(X,1),2); % ispaired(i)=1 if the ith trip is paired otherwise 0
paired=nnz(ispaired);
fprintf('we paired %d trips out of %d trips',paired,n);
%% visualize the topology
gplot(Candidate,tb{:,{'O_lon','O_lat'}})
G=graph(adjacency-diag(diag(adjacency)));
plot(G);
