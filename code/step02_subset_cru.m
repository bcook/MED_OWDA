% This script will subset the CRU 3.21 data for my OWDA analyses. It will
% grab data from the same latitude/longitude range as my OWDA subset.

% Start Clean
clear all
close all
clc

save_figure=0;

%% Define Area/Years

% Select Years
yrs=[1901:2012]; 

% Latitude/Longitude range (same as in step01)
lonlim=[-10 45],latlim=[30 47]; map_txt='MED_1';

%% Define variable
%var_name='tmp';
%var_name='pre';
%var_name='pet';

%% Setup For CRU Subsetting

% Month and Year Vectors, going from January 1901 thru December 2012
yr_vect=floor(1901:(1/12):2012.95)';
mon_vect=repmat([1;2;3;4;5;6;7;8;9;10;11;12],[length(unique(yr_vect)) 1]) ;


%% TEMPERATURE FIRST

% Variable Name
var_name='tmp';

% Load lon/lat vectors
lon=ncread(['/Users/bcook/Documents/GEODATA/cru321/cru_ts3.21.1901.2012.' var_name '.dat.nc'],'lon');
lat=ncread(['/Users/bcook/Documents/GEODATA/cru321/cru_ts3.21.1901.2012.' var_name '.dat.nc'],'lat');

% Trim lat/lon down to the region I want
cut_lat_nam  = find(lat <=max(latlim) & lat >=min(latlim)); lat_out=lat(cut_lat_nam);
cut_lon_nam  = find(lon <=max(lonlim) & lon >=min(lonlim)); lon_out=lon(cut_lon_nam);

% Open a netcdf data structure and pull out the climate data for the years
% and spatial area that I want;
nc_data=ncgeodataset(['/Users/bcook/Documents/GEODATA/cru321/cru_ts3.21.1901.2012.' var_name '.dat.nc']);

% Load each month at a time
disp('Loading Temperature data...')
for i_mon=1:12;
   
    % Month
    i_mon
    
    % Find indices for current month, all years for the climatology period
    mon_locs=find(mon_vect==i_mon);
    yr_locs=(find(yr_vect>=yrs(1) & yr_vect<=yrs(end)));
    i_loc=intersect(mon_locs,yr_locs);
    
    % Pull out current month
    cru_curr=squeeze(double(nc_data{var_name}(i_loc,cut_lat_nam,cut_lon_nam)));  
    
    % If PET, convert from mm/day to mm
    if strcmp(var_name,'pet')==1
        
        for i_yr=1:length(yrs)
        
            % number of days in current month
            numdays=eomday(yrs(i_yr),i_mon);
            
            % Multiply the PET by this amount
            cru_curr(i_yr,:,:)=cru_curr(i_yr,:,:).*numdays;
            
        end
    end
    
    % Save all the months
    cru_subset(i_mon,:,:,:)=cru_curr;  
    
end

% Save output data as Matlab file format
save(['../data/cru321.sub4pdsi.new.' var_name '.' map_txt '.mat'],'cru_subset','lon_out','lat_out',...
    'yrs')

%% PRECIPITATION SECOND

% Variable Name
var_name='pre';

% Load lon/lat vectors
lon=ncread(['/Users/bcook/Documents/GEODATA/cru321/cru_ts3.21.1901.2012.' var_name '.dat.nc'],'lon');
lat=ncread(['/Users/bcook/Documents/GEODATA/cru321/cru_ts3.21.1901.2012.' var_name '.dat.nc'],'lat');

% Trim lat/lon down to the region I want
cut_lat_nam  = find(lat <=max(latlim) & lat >=min(latlim)); lat_out=lat(cut_lat_nam);
cut_lon_nam  = find(lon <=max(lonlim) & lon >=min(lonlim)); lon_out=lon(cut_lon_nam);

% Open a netcdf data structure and pull out the climate data for the years
% and spatial area that I want;
nc_data=ncgeodataset(['/Users/bcook/Documents/GEODATA/cru321/cru_ts3.21.1901.2012.' var_name '.dat.nc']);

% Load each month at a time
disp('Loading Precipitation data...')
for i_mon=1:12;
   
    % Month
    i_mon
    
    % Find indices for current month, all years for the climatology period
    mon_locs=find(mon_vect==i_mon);
    yr_locs=(find(yr_vect>=yrs(1) & yr_vect<=yrs(end)));
    i_loc=intersect(mon_locs,yr_locs);
    
    % Pull out current month
    cru_curr=squeeze(double(nc_data{var_name}(i_loc,cut_lat_nam,cut_lon_nam)));  
    
    % If PET, convert from mm/day to mm
    if strcmp(var_name,'pet')==1
        
        for i_yr=1:length(yrs)
        
            % number of days in current month
            numdays=eomday(yrs(i_yr),i_mon);
            
            % Multiply the PET by this amount
            cru_curr(i_yr,:,:)=cru_curr(i_yr,:,:).*numdays;
            
        end
    end
    
    % Save all the months
    cru_subset(i_mon,:,:,:)=cru_curr;  
    
end

% Save output data as Matlab file format
save(['../data/cru321.sub4pdsi.new.' var_name '.' map_txt '.mat'],'cru_subset','lon_out','lat_out',...
    'yrs')




