%% An implementation of the simple carpool mathcing integer programming model
% ver. 1.0
% author Liutong Zhou
% created on 12/5/2016
%% Read taxi trip data
clear;
if exist('tb')~=1
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
end
%% Inut your tolerances here for time and distance
% Example:
% everyone has a 100-meter tolerance for distance between departure origns
% everyone has a 1000-meter tolerance for distance between destinations
% everyone has a 10-minute tolerance for waiting time of departure
% usually people have different tolerance
% capacity of the ith car is C(i) for i=1...n
n=height(tb); % n is the total number of trips given as input
tolo=100*ones(n,1); %tolo(i): the ith passenger's tolerance for origin distance eg. 100 meters
told=1000*ones(n,1); %told(i): the ith passenger's tolerance for destination distance 100 meters
tolt=repmat(duration(0,10,0,'Format','m'),n,1); %tolt(i) : the ith passenger's tolerance for departure waiting duration eg. 10 minutes
C=max(tb.pc,4); % capacity of the ith car: C(i) we set an treshold for passengers count:4
%% Constructing Candidate index set called Candidate and eliminate those trips with no candidate
% Candidate(i,j)=1 if the ith trip and jth trip satisfy  both the ith
% and the jth passenger's tolerance
% find candidate and filtered data using tolerances
[Candidate,subtb,has_candidate]=find_candidate(tb(1:700,:),tolo,told,tolt);
C=C(has_candidate);
has_candidate=@(Candidate) any(Candidate-eye(size(Candidate,1)),2);
%% Construct the integer programming model
problem=Construct_Model(Candidate,subtb.pc,C);
% do some tunning on the solver for efficiency
problem.options.CutMaxIterations =25;
problem.options.IntegerPreprocess ='advanced';
problem.options.MaxTime=3600;
%% Get the results
tic
x= intlinprog(problem);
X=reshape(sparse(x),size(Candidate));
X=logical(X);
ispaired=has_candidate(X); % ispaired(i)=1 if the ith trip is paired, otherwise 0
paired_number=nnz(ispaired);
fprintf('we paired %d trips out of %d trips \n',paired_number,n);
t1=toc
%% Another way to solve the problem: a greedy algorithm
% pair the ith trip with its closest candidate for i=1...n
tic
X2=greedysearch(Candidate,C,subtb);
ispaired=has_candidate(X2); % ispaired(i)=1 if the ith trip is paired, otherwise 0
paired_number=nnz(ispaired);
fprintf('we paired %d trips out of %d trips \n',paired_number,n);
t2=toc
save results.mat X2
%% visualize the topology
% construct a graph
gplot(Candidate,subtb{:,{'O_lon','O_lat'}})
G=graph(X(ispaired,ispaired),'OmitSelfLoops');
G.Nodes=subtb(ispaired,{'O_lat','O_lon'});
% plot the graph
plottrips(G);
% plot a sub graph
ind=find(G.Nodes.O_lon>-74 & G.Nodes.O_lon<-73.96);
subG=subgraph(G,ind);
plottrips(subG);