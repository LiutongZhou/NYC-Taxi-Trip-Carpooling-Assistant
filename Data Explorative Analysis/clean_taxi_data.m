%% set input file directory and output directory
source_dir = 'D:\OneDrive - Columbia University\2016Fall\3. Infrastructural Systems Optimization\Final Project\data\';
dest_dir='F:\Augustinus\Documents\GitHub\CEOR4011_Final_Project\clean_yellow_sample_2016_06.csv';
ds=datastore([source_dir,'yellow_tripdata_2016-06.csv'], 'TreatAsMissing', 'NA');
ds.SelectedVariableNames = {'pickup_longitude','pickup_latitude','dropoff_longitude',...
    'dropoff_latitude','trip_distance','passenger_count'};
preview(ds)
%% clean data
%eliminate those that have 0 values
tbl=tall(ds);
ind=ismissing(        standardizeMissing(tbl,0,'DataVariables',...
        {'pickup_longitude','pickup_latitude','dropoff_longitude','dropoff_latitude','trip_distance'})...
        );
tbl(any(ind,2),:)=[];
tbl=gather(tbl);
%%
writetable(tbl,dest_dir)

