function g=plot_pairs(G)
%plottrips(G) visualize the input graph G 
% out put a graphplot object 
%   
g=plot(G,'XData',G.Nodes.O_lon,'YData',G.Nodes.O_lat,...
    'NodeLabel',{},'MarkerSize',0.8,'LineWidth',1.25,'EdgeColor','k','EdgeAlpha',1,...
    'NodeCData',degree(G));%
xlabel('Longitude','FontSize',13);ylabel('Latitude','FontSize',13);
title('Paired Taxi Trips','FontSize',15);
map=jet;
map(1,:)=[1,1,1];
colormap(map)
c=colorbar;
c.Label.String='paired trips';
c.FontSize=11;
grid on
end