function plottrips(G)
%plottrips(G) visualize the input graph G 
%   
figure
plot(G,'XData',G.Nodes.O_lon,'YData',G.Nodes.O_lat,...
    'NodeLabel',{},'MarkerSize',1,'LineWidth',2,'EdgeColor','k','EdgeAlpha',1,...
    'NodeCData',degree(G));%
xlabel('Longitude','FontSize',13);ylabel('Latitude','FontSize',13);
title('Paired Taxi Trips','FontSize',15);
map=jet;
map(1,:)=[1,1,1];
colormap(map)
c=colorbar;
c.Label.String='paired trips';
c.FontSize=11;
end