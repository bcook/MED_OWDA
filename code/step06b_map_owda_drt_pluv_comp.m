% This script map up select years or averages of years from the half degree
% OWDA dataset.

% THIS VERSION: Map up composites of persistent drought and pluvial
% periods, including the most recent decades (1980-2012)

%% Start Clean
clear all
close all
clc

%% Setup some variables

% Colorbar scale
L = [-6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6]./2; 

% If =1, save figure file
save_figure=0;

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

%% FIGURE: 1125-1142

% Years and flags for saving output
yr_interval = 1125:1142; name_tag = 'pluv';
fig_flag = 'fig05';

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

%% FIGURE: 1237-1253

% Years and flags for saving output
yr_interval = 1237:1253; name_tag = 'drght'
fig_flag = 'fig05';

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

%% FIGURE: 1312-1329

% Years and flags for saving output
yr_interval = 1312:1329; name_tag = 'drght';
fig_flag = 'fig05';

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

%% FIGURE: 1351-1366

% Years and flags for saving output
yr_interval = 1351:1366; name_tag = 'drght';
fig_flag = 'fig05';

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

%% FIGURE: 1856-1881

% Years and flags for saving output
yr_interval = 1856:1881; name_tag = 'drght';
fig_flag = 'fig05';

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

%% FIGURE: 1942-1953

% Years and flags for saving output
yr_interval = 1942:1953; name_tag = 'drght';
fig_flag = 'fig05';

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

%% FIGURE: 1980-2012

% Years and flags for saving output
yr_interval = 1980:2012; name_tag = 'recent';
fig_flag = 'fig10_11';

% Change colorbar limits
L=L/2;

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
% MIDEAST Box
lonmin=33; lonmax=47; latmin=30; latmax=37; % Updated Levant Region (levant3)
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
