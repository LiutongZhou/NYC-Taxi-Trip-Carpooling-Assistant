function tb=retrieve_paired_trips(G,i)
%% retrieve the ith paired trips
figure
ind=neighbors(G,i);
tb=G.Nodes([i;ind],:);
fprintf('No. %d paired trip\n',i);
disp(tb);
subG=subgraph(G,[i;ind]);
g=plot_pairs(subG);
g.MarkerSize=5;
g.LineWidth=1.5;
colormap jet;
title(['the ',num2str(i),'th pair']);
grid on
figure
X=tb{:,{'O_lon','D_lon'}}';
Y=tb{:,{'O_lat','D_lat'}}';
f=plot(X,Y,'.-','LineWidth',1,'MarkerSize',15);
title(['the ',num2str(i),'th paired trips'],'FontSize',15);
xlabel('Longitude','FontSize',15);ylabel('Latitude','FontSize',15);
labelpoints(X(1,1), Y(1,1), 'Origin','adjust_axes' ,1);
labelpoints(X(2,1), Y(2,1), 'Destination','adjust_axes' ,1);
grid on
end
