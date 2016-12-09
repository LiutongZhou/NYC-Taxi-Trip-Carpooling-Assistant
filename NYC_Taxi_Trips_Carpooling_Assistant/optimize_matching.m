optimize_matching
%% An implementation of the simple carpool mathcing integer programming model
% ver. 2.1
% author Liutong Zhou
% created on 12/5/2016 v1.0
% updated on 12/7/2016 v2.0
% updated on 12/8/2016 v2.1
%% Read taxi trip data
if exist('tb' ,'var')~=1
    inp_dir='D:\OneDrive - Columbia University\2016Fall\3. Infrastructural Systems Optimization\Final Project\data\';
    filename=[inp_dir,'Filetered Data_050115_730_11.xlsx'];
    filename = inputdlg({'Enter your input file: for example  C:\...\Data\filename.xlsx'},'Input Data',1,cellstr(filename),'on');
    if isempty(filename)
        return
    end
    disp('Loading....................................');
    filename=filename{:};
    opts=detectImportOptions(filename,'Sheet','Sheet1');
    opts.SelectedVariableNames={'tpep_pickup_datetime','passenger_count',...
        'pickup_latitude','pickup_longitude','dropoff_latitude','dropoff_longitude'};
    tb=readtable(filename,opts);
    tb=rmmissing(tb);
    tb.Properties.VariableNames={'dept_time','pc','O_lat','O_lon',...
        'D_lat','D_lon'}; % pc='passenger count','O_lat'='origin_latitude'
    tb=sortrows(tb,'dept_time','ascend');
    clear filename inp_dir
end
%% Inut your tolerances and choose your preferred  Algorithm
% Example:
% everyone has a 150-meter tolerance for distance between departure origns
% everyone has a 500-meter tolerance for distance between destinations
% everyone has a 8-minute tolerance for waiting time of departure
% usually people have different tolerances, so that input can be vectors
% capacity of the ith car is C(i) for i=1...n
n=height(tb); % n is the total number of trips given as input
answer=inputdlg({'Enter your tolerance for distance between origins (meters):',...
    'tolerance for distance between destinations (meters):',...
    'tolerance for departure waiting time (minutes):',...
    'maximum number of passengers in a car:',...
    'Preferred Algorithm: 1 for Integer Programming or 2 for Greedy Search'},...
    'Input Parameters',1,{'150','500','8','3','1'},'on');
if length(answer)~=5
    return
end
tolo=str2double(answer{1})*ones(n,1); %tolo(i): the ith passenger's tolerance for origin distance eg. 150 meters
told=str2double(answer{2})*ones(n,1); %told(i): the ith passenger's tolerance for destination distance 500 meters
tolt=repmat(duration(0,str2double(answer{3}),0,'Format','m'),n,1); %tolt(i) : the ith passenger's tolerance for departure waiting duration eg. 8 minutes
C=max(tb.pc,str2double(answer{4})); % capacity of the ith car: C(i) we set an treshold for passengers count:3
fprintf('Your chosen tolerance for distance between origins: %d meters\n',tolo(1));
fprintf('Your chosen tolerance for distance between destinations: %d meters\n',told(1));
fprintf('Your chosen tolerance for departure waiting time: %s\n',tolt(1));
fprintf('Your chosen tolerance for maximal number of passengers in a car: %d persons\n',C(1));
fprintf('Begin to optimize the trips from %s to %s\n',datestr(min(tb.dept_time)),datestr(max(tb.dept_time)));
%% Constructing Candidate index set called Candidate and eliminate those trips with no candidate
% Candidate(i,j)=1 if the ith trip and jth trip satisfy  both the ith
% and the jth passenger's tolerance
% find candidate and filtered data using tolerances
[Candidate,subtb,ind]=find_candidate(tb,tolo,told,tolt);
C=C(ind);% ind: a logical index to original input table tb, subtb=tb(ind,:)
%% Construct an integer programming model and Get the results
if str2num(answer{5})==1
    problem=Construct_Model(Candidate,subtb.pc,C);
    X=Run_Model(problem);
    disp(['Total number of input trips: ',num2str(height(tb))]);
end
%% Another way to solve the problem: a greedy algorithm
% pair the ith trip with its closest candidate for i=1...n
if str2num(answer{5})==2
    X=greedysearch(Candidate,C,subtb);
    disp(['Total number of input trips: ',num2str(height(tb))]);
end
clear answer
%% visualize the topology
% construct a graph
ispaired=has_candidate(X);
G=graph(X(ispaired,ispaired),'OmitSelfLoops');
G.Nodes=subtb(ispaired,:);
% plot the graph
figure;plot_pairs(G);
% plot a sub graph
ind=find(G.Nodes.O_lon>-74 & G.Nodes.O_lon<-73.96);
subG=subgraph(G,ind);
figure;plot_pairs(subG);
%% Rerieve the paired Trips
answer=inputdlg({'For example: If you want to retrieve the 3rd and 6th paired trip''s results, input'},...
    'Rerieve the paired Trips',1,{'3,6'},'on');
if ~isempty(answer)
    n=str2num(answer{:});
    for i=n
        retrieve_paired_trips(G,i);
    end
    
end
disp('Completed');
pause