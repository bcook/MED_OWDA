% This script map up select years or averages of years from the half degree
% OWDA dataset.

% THIS VERSION: Map up composites of years with >40% or >50% of the area in
% drought.

%% Start Clean
clear all
close all
clc

%% Setup some variables

% Years with >40 or >50 drought area coverage (only for these maps)
load('../data/yrs_drt_fix_MED_1.ALLMED.mat')

% Colorbar scale
L = [-6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6]./2; 

% Figure flag for saving output
fig_flag = 'fig06';

% If =1, save figure file
save_figure=1;

%% Figure parameters

% Projection and lat/lon range for 
proj_name='Mollweide'; lonlim=[-10 44.6]; latlim=[30 46.6]; map_txt='MED';	% GLOBE

% load physical and political boundaries
M_country=shape_read('/Users/bcook/Dropbox/MATLAB/map_political/10m_admin_0_countries');
M_states=shape_read('/Users/bcook/Dropbox/MATLAB/map_political/10m_admin_1_states_provinces_shp');
M_coast=shape_read('/Users/bcook/Dropbox/MATLAB/map_political/10m_coastline');
M_ocean=shape_read('/Users/bcook/Dropbox/MATLAB/map_political/10m_ocean');
M_lakes=shape_read('/Users/bcook/Dropbox/MATLAB/map_political/ne_10m_lakes');

% Set colormap to use
cmap = [    51      25       0
            102     47       0
            153     96      53
            204     155     122
            216     175     151
            242     218     205
            204     253     255
            153     248     255
            101     239     255
            50      227     255
            0       169     204
            0       122     153]./255;

%% Load OWDA Data

% lat/lon data and year vector
load('../data/subset.owda.fix.MED_1.1000-2012.mat','lon_reg','lat_reg','yr_export');
lon = lon_reg; 
lat = lat_reg; 
yr = yr_export;

% Open structure for OWDA PDSI
owda=load('../data/subset.owda.fix.MED_1.1000-2012.mat');

%% FIGURE: 40% Drought Area Composite

% Year List to Composite
yr_interval = yrs_drt_40; name_tag = '40%';    

% Years Composited:
%   1112,1120,1147,1160,1161,1163,1164,1169,1176,1195,1197,1198,1204,
%   1228,1229,1242,1243,1244,1245,1246,1248,1251,1252,1253,1304,1315,
%   1317,1323,1324,1333,1334,1354,1355,1356,1357,1358,1359,1360,1361,
%   1362,1363,1364,1366,1371,1401,1403,1420,1421,1422,1426,1427,1434,
%   1435,1438,1439,1440,1469,1479,1483,1486,1488,1489,1491,1494,1500,
%   1502,1503,1512,1516,1517,1521,1528,1542,1543,1544,1545,1548,1549,
%   1560,1561,1607,1614,1623,1624,1627,1637,1644,1648,1650,1660,1664,
%   1672,1676,1679,1680,1683,1685,1686,1687,1693,1701,1715,1716,1718,
%   1725,1746,1750,1779,1781,1782,1786,1794,1796,1797,1801,1802,1804,
%   1806,1807,1811,1820,1822,1823,1830,1834,1840,1847,1856,1861,1862,
%   1863,1869,1870,1873,1874,1877,1878,1879,1880,1887,1893,1894,1909,
%   1927,1928,1935,1942,1944,1945,1947,1948,1949,1950,1962,1984,1985,
%   1986,1989,1990,1991,1993,1994,1999,2000,2001,2007,2008,2012

% Find locations of these years
[c,i_int,i_yr]=intersect(yr_interval,yr); 

% Now, load these years from the data structure
map_yrs(:,:,:)=owda.owda_region(i_yr,:,:);

% Mask out missing values -99
map_yrs(find(map_yrs<=-99))=nan;

% Average over this interval.
map_yr_mean=squeeze(mean(map_yrs,1));

% Create The Figure
figure
hold on
colormap(cmap)
m_proj(proj_name, 'lon', lonlim,'lat', latlim);
h=m_pcolor(lon-0.25,lat-0.25,map_yr_mean); set(h,'LineStyle','none');
m_grid('linestyle', 'none','fontsize',14,'fontname','arial',...
    'xticklabels',[],'yticklabels',[],...
    'FontWeight','bold');
% Create the coastal and country boundaries
m_plot(M_coast.x,M_coast.y,'LineWidth',2,'Color',[0 0 0])
m_plot(M_country.x,M_country.y,'LineWidth',1,'Color',[0 0 0])
% Western Mediterranean Box
lonmin=-10; lonmax=0; latmin=32; latmax=42; % smaller area
bndry_lon=[lonmin lonmax lonmax lonmin lonmin];bndry_lat=[latmin latmin latmax latmax latmin];
m_line(bndry_lon,bndry_lat,'linewidth',2.5,'color',[0 0 0],'linestyle','--');
% Greece Box
lonmin=19; lonmax=26; latmin=36; latmax=43; % Greece 2
bndry_lon=[lonmin lonmax lonmax lonmin lonmin];bndry_lat=[latmin latmin latmax latmax latmin];
m_line(bndry_lon,bndry_lat,'linewidth',2.5,'color',[0 0 0],'linestyle','--');
% Levant Box
lonmin=33; lonmax=40; latmin=30; latmax=37; % Updated Levant Region (levant3)
bndry_lon=[lonmin lonmax lonmax lonmin lonmin];bndry_lat=[latmin latmin latmax latmax latmin];
m_line(bndry_lon,bndry_lat,'linewidth',2.5,'color',[0 0 0],'linestyle','--');
caxis([min(L) max(L)]);
colorbar1 = colorbar('FontName','arial',...
                     'FontSize',18,...
                     'FontWeight','bold',...  
                     'XLim',[-0.5 1.5],'LOCATION','EastOutside',...
                     'Ytick',L(1:length(L)),'YTicklabel',L(1:length(L)));
titlestring=['PDSI, ' num2str(min(yr_interval)) '-' num2str(max(yr_interval)) ]; 
title(['\fontname{helvetica} \fontsize{30} \bf{' titlestring '}']);
set(gcf,'Renderer','painters')
set(gcf,'OuterPosition',[292   999   845   570])
set(gcf,'PaperPositionMode','auto')

% Save Figure
if save_figure==1
    print('-depsc2','-painters',['../figures/' fig_flag '/comp.pdsi.n' num2str(length(yr_interval)) '.' ...
        name_tag '.' num2str(min(yr_interval)) '-' num2str(max(yr_interval)) '.eps'])
end

% Clear variables I need to reuse
clear map_yrs yr_interval

%% FIGURE: 50% Drought Area Composite

% Year List to Composite
yr_interval = yrs_drt_50; name_tag = '50%';  

% Years Composited:
%   1147,1161,1228,1243,1244,1245,1246,1324,1356,1358,1359,1366,1420,
%   1434,1438,1483,1494,1512,1528,1548,1549,1561,1607,1614,1679,1683,
%   1687,1715,1725,1782,1802,1806,1822,1862,1873,1874,1893,1945,1947,
%   1948,1949,1989,1990,2000,2012

% Find locations of these years
[c,i_int,i_yr]=intersect(yr_interval,yr); 

% Now, load these years from the data structure
map_yrs(:,:,:)=owda.owda_region(i_yr,:,:);

% Mask out missing values -99
map_yrs(find(map_yrs<=-99))=nan;

% Average over this interval.
map_yr_mean=squeeze(mean(map_yrs,1));

% Create The Figure
figure
hold on
colormap(cmap)
m_proj(proj_name, 'lon', lonlim,'lat', latlim);
h=m_pcolor(lon-0.25,lat-0.25,map_yr_mean); set(h,'LineStyle','none');
m_grid('linestyle', 'none','fontsize',14,'fontname','arial',...
    'xticklabels',[],'yticklabels',[],...
    'FontWeight','bold');
% Create the coastal and country boundaries
m_plot(M_coast.x,M_coast.y,'LineWidth',2,'Color',[0 0 0])
m_plot(M_country.x,M_country.y,'LineWidth',1,'Color',[0 0 0])
% Western Mediterranean Box
lonmin=-10; lonmax=0; latmin=32; latmax=42; % smaller area
bndry_lon=[lonmin lonmax lonmax lonmin lonmin];bndry_lat=[latmin latmin latmax latmax latmin];
m_line(bndry_lon,bndry_lat,'linewidth',2.5,'color',[0 0 0],'linestyle','--');
% Greece Box
lonmin=19; lonmax=26; latmin=36; latmax=43; % Greece 2
bndry_lon=[lonmin lonmax lonmax lonmin lonmin];bndry_lat=[latmin latmin latmax latmax latmin];
m_line(bndry_lon,bndry_lat,'linewidth',2.5,'color',[0 0 0],'linestyle','--');
% Levant Box
lonmin=33; lonmax=40; latmin=30; latmax=37; % Updated Levant Region (levant3)
bndry_lon=[lonmin lonmax lonmax lonmin lonmin];bndry_lat=[latmin latmin latmax latmax latmin];
m_line(bndry_lon,bndry_lat,'linewidth',2.5,'color',[0 0 0],'linestyle','--');
caxis([min(L) max(L)]);
colorbar1 = colorbar('FontName','arial',...
                     'FontSize',18,...
                     'FontWeight','bold',...  
                     'XLim',[-0.5 1.5],'LOCATION','EastOutside',...
                     'Ytick',L(1:length(L)),'YTicklabel',L(1:length(L)));
titlestring=['PDSI, ' num2str(min(yr_interval)) '-' num2str(max(yr_interval)) ]; 
title(['\fontname{helvetica} \fontsize{30} \bf{' titlestring '}']);
set(gcf,'Renderer','painters')
set(gcf,'OuterPosition',[292   999   845   570])
set(gcf,'PaperPositionMode','auto')

% Save Figure
if save_figure==1
    print('-depsc2','-painters',['../figures/' fig_flag '/comp.pdsi.n' num2str(length(yr_interval)) '.' ...
        name_tag '.' num2str(min(yr_interval)) '-' num2str(max(yr_interval)) '.eps'])
end

% Clear variables I need to reuse
clear map_yrs yr_interval




