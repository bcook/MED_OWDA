% This script will subset scPDSI data from the OWDA based on latitude, longitude,
% and year ranges I define.
%
% For this analysis, I will be pulling data from the Mediterranean region.

%% Start Clean
clear all
close all
clc

%% Latitude and Longitude Bounds
lonlim=[-10 45],latlim=[30 47]; map_txt='MED_1';	% GLOBE

% Time bounds: proxy coverage prior to 1000 CE gets kind of sparse.
yr_export = [1000:2012];

%% Load lat/lon data and year vector from the OWDA
load('/Users/bcook/Documents/GEODATA/OWDA/owda_hd_fix1_500.mat','lat','lon','yr')

%% Open structure for actual NADA data
owda=load('/Users/bcook/Documents/GEODATA/OWDA/owda_hd_fix1_500.mat');

%% Export Area/Years that I want

% Find the locations of the years I want
[c,i_ex,i_yr]=intersect(yr_export,yr); 

% Find the Lat/Lon locations
i_lat=find(lat>=latlim(1) & lat<=latlim(2));
i_lon=find(lon>=lonlim(1) & lon<=lonlim(2));

% Now, load these years from the data structure
owda_region=owda.pdsi(i_yr,i_lat,i_lon);

% Subset the latitude/longitude vectors
lat_reg = lat(i_lat);
lon_reg = lon(i_lon);

%% Now, save this data. 
%  This is what I will primarily work with for this project.

save(['../data/subset.owda.fix.' map_txt '.' num2str(yr_export(1)) '-' num2str(yr_export(end)) '.mat'],...
    'lon_reg','lat_reg','owda_region','yr_export')











