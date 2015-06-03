% This script map up select years or average years from the half degree
% NADA dataset

%% Start Clean
clear all
close all
clc

save_figure=0;

%% Pick years to average-include ALL years you want to average

% Years with >40 or >50 drought area coverage
%load yrs_drt_fix_ALLMED.mat
load yrs_drt_fix_MED_1.ALLMED.mat

% FOR FIGURE 6
%yr_interval = yrs_drt_40; name_tag = '40%';     L = [-6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6]./2; fig_flag = 'fig06';
yr_interval = yrs_drt_50; name_tag = '50%';     L = [-6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6]./2; fig_flag = 'fig06';

% FOR FIGURE 5
%yr_interval = 1125:1142; name_tag = 'pluv';     L = [-6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6]./2; fig_flag = 'fig05';
%yr_interval = 1237:1253; name_tag = 'drght';     L = [-6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6]./2; fig_flag = 'fig05';
%yr_interval = 1312:1329; name_tag = 'drght';     L = [-6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6]./2; fig_flag = 'fig05';
%yr_interval = 1351:1366; name_tag = 'drght';   L = [-6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6]./2; fig_flag = 'fig05';
%yr_interval = 1856:1881; name_tag = 'drght';   L = [-6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6]./2; fig_flag = 'fig05';
%yr_interval = 1942:1953; name_tag = 'drght';   L = [-6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6]./2; fig_flag = 'fig05';

% FOR FIGURE 10
%yr_interval = 1980:2012; name_tag = 'recent';   L = [-6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6]./4; fig_flag = 'fig10_11';


size(yr_interval)

%% Colorbar intervals
%L=[-5 -4 -3 -2 -1 0 1 2 3 4 5];
%L=[-6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6]./4;

%% Plotting parameters
%% Figure parameters
%proj_name='Mollweide'; lonlim=[-12 44],latlim=[30 72]; map_txt='EUR';	% GLOBE
proj_name='Mollweide'; lonlim=[-10 44.6]; latlim=[30 46.6]; map_txt='MED';	% GLOBE

% load boundaries
M_country=shape_read('/Users/bcook/Dropbox/MATLAB/map_political/10m_admin_0_countries');
M_states=shape_read('/Users/bcook/Dropbox/MATLAB/map_political/10m_admin_1_states_provinces_shp');
M_coast=shape_read('/Users/bcook/Dropbox/MATLAB/map_political/10m_coastline');
M_ocean=shape_read('/Users/bcook/Dropbox/MATLAB/map_political/10m_ocean');
M_lakes=shape_read('/Users/bcook/Dropbox/MATLAB/map_political/ne_10m_lakes');

%% Load lat/lon data and year vector
%load('/Users/bcook/Documents/GEODATA/OWDA/owda_hd_DIR_CUT_500.mat','lat','lon','yr')
load('subset.owda.fix.MED.1000-2012.mat','lon_reg','lat_reg','yr_export');
lon = lon_reg; lat = lat_reg; yr = yr_export;

%% Open structure for actual NADA data
owda=load('subset.owda.fix.MED.1000-2012.mat');

%% Load data you want to map up
[c,i_int,i_yr]=intersect(yr_interval,yr); % find locations of these years

% Now, load these years from the data structure
map_yrs(:,:,:)=owda.owda_region(i_yr,:,:);

% Mask out missing values -99
map_yrs(find(map_yrs<=-99))=nan;
% Average over this interval
map_yr_mean=squeeze(nanmean(map_yrs,1));

%% NOW, MAP THAT SHIT UP
cmap_bb = [   51      25       0
  102      47       0
  153      96      53
  204     155     122
  216     175     151
  242     218     205
  204     253     255
  153     248     255
  101     239     255
   50     227     255
    0     169     204
    0     122     153]./255;

cmap_bg = [     0.3294,0.1882,0.0196;
                0.3294,0.1882,0.0196;
                0.5490,0.3176,0.0392;
                0.5490,0.3176,0.0392;
                0.7490,0.5059,0.1765;
                0.7490,0.5059,0.1765;
                0.8745,0.7608,0.4902;
                0.8745,0.7608,0.4902;
                0.9647,0.9098,0.7647;
                0.9647,0.9098,0.7647;
                %1,1,1;
                %1,1,1;
                0.7804,0.9176,0.8980;
                0.7804,0.9176,0.8980;
                0.5020,0.8039,0.7569;
                0.5020,0.8039,0.7569;
                0.2078,0.5922,0.5608;
                0.2078,0.5922,0.5608;
                0.0039,0.4000,0.3686;
                0.0039,0.4000,0.3686;
                0.0000,0.2353,0.1882;
                0.0000,0.2353,0.1882;
            ];
                
% Set Colormap
cmap = cmap_bg;
cmap = cmap_bb;

% %% Export Area I want
% yr_export = [1000:2012];
% 
% [c,i_int,i_yr]=intersect(yr_export,yr); % find locations of these years
% 
% % Lat/Lon Regions
% i_lat=find(lat>=latlim(1) & lat<=latlim(2));
% i_lon=find(lon>=lonlim(1) & lon<=lonlim(2));
% 
% % Now, load these years from the data structure
% owda_region=owda.pdsi(i_yr,i_lat,i_lon);
% 
% lat_reg = lat(i_lat);
% lon_reg = lon(i_lon);
% 
% % Save region for analysis
% save(['subset.owda.' map_txt '.' num2str(yr_export(1)) '-' num2str(yr_export(end)) '.mat'],'lon_reg','lat_reg','owda_region','yr_export')

%%
figure
hold on
colormap(cmap)
m_proj(proj_name, 'lon', lonlim,'lat', latlim);
h=m_pcolor(lon-0.25,lat-0.25,map_yr_mean); set(h,'LineStyle','none');
m_grid('linestyle', 'none','fontsize',14,'fontname','arial',...
    'xticklabels',[],'yticklabels',[],...
    'FontWeight','bold');
%m_coast('color','k','LineWidth',2);
%m_plot(M_states.x,M_states.y,'LineWidth',1,'Color',[0 0 0])
m_plot(M_coast.x,M_coast.y,'LineWidth',2,'Color',[0 0 0])
m_plot(M_country.x,M_country.y,'LineWidth',1,'Color',[0 0 0])
% West Med
lonmin=-10; lonmax=0; latmin=32; latmax=42; % smaller area
bndry_lon=[lonmin lonmax lonmax lonmin lonmin];bndry_lat=[latmin latmin latmax latmax latmin];
m_line(bndry_lon,bndry_lat,'linewidth',2.5,'color',[0 0 0],'linestyle','--');
% Greece
%lonmin=19; lonmax=26; latmin=36; latmax=42; % smaller area
lonmin=19; lonmax=26; latmin=36; latmax=43; % Greece 2
bndry_lon=[lonmin lonmax lonmax lonmin lonmin];bndry_lat=[latmin latmin latmax latmax latmin];
m_line(bndry_lon,bndry_lat,'linewidth',2.5,'color',[0 0 0],'linestyle','--');
% Levant
%lonmin=35; lonmax=45; latmin=31; latmax=37; % Original Levant
%lonmin=35; lonmax=40; latmin=31; latmax=37; % Updated Levant Region (levant2)
lonmin=33; lonmax=40; latmin=30; latmax=37; % Updated Levant Region (levant3)

bndry_lon=[lonmin lonmax lonmax lonmin lonmin];bndry_lat=[latmin latmin latmax latmax latmin];
m_line(bndry_lon,bndry_lat,'linewidth',2.5,'color',[0 0 0],'linestyle','--');

% % Eastern Med
% lonmin=20; lonmax=37; latmin=36; latmax=41; % smaller area
% bndry_lon=[lonmin lonmax lonmax lonmin lonmin];bndry_lat=[latmin latmin latmax latmax latmin];
% m_line(bndry_lon,bndry_lat,'linewidth',2.5,'color',[0 0 0],'linestyle','--');
%m_plot(M_lakes.x,M_lakes.y,'LineWidth',2,'Color',[0 0 0])
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

return

if save_figure==1
    print('-depsc2','-painters',['./figures_new/' fig_flag '/comp.pdsi.' name_tag '.' num2str(min(yr_interval)) '-' num2str(max(yr_interval)) '.eps'])
    print('-dpdf','-painters',['./figures_new/' fig_flag '/comp.pdsi.' name_tag '.' num2str(min(yr_interval)) '-' num2str(max(yr_interval)) '.pdf'])
    %plot2svg(['./figures_new/' fig_flag '/comp.pdsi.' name_tag '.' num2str(min(yr_interval)) '-' num2str(max(yr_interval)) '.svg'],gcf)
    %exportfig(gcf,'test.eps')

end


figure
hold on
colormap(cmap)
m_proj(proj_name, 'lon', lonlim,'lat', latlim);
%h=m_pcolor(lon-0.25,lat-0.25,map_yr_mean); set(h,'LineStyle','none');
m_contourf(lon-0.25,lat-0.25,map_yr_mean)
m_grid('linestyle', 'none','fontsize',14,'fontname','arial',...
    'xticklabels',[],'yticklabels',[],...
    'FontWeight','bold');
%m_coast('color','k','LineWidth',2);
%m_plot(M_states.x,M_states.y,'LineWidth',1,'Color',[0 0 0])
m_plot(M_coast.x,M_coast.y,'LineWidth',2,'Color',[0 0 0])
m_plot(M_country.x,M_country.y,'LineWidth',1,'Color',[0 0 0])
% West Med
lonmin=-10; lonmax=0; latmin=32; latmax=42; % smaller area
bndry_lon=[lonmin lonmax lonmax lonmin lonmin];bndry_lat=[latmin latmin latmax latmax latmin];
m_line(bndry_lon,bndry_lat,'linewidth',2.5,'color',[0 0 0],'linestyle','--');
% Greece
%lonmin=19; lonmax=26; latmin=36; latmax=42; % smaller area
lonmin=19; lonmax=26; latmin=36; latmax=43; % Greece 2
bndry_lon=[lonmin lonmax lonmax lonmin lonmin];bndry_lat=[latmin latmin latmax latmax latmin];
m_line(bndry_lon,bndry_lat,'linewidth',2.5,'color',[0 0 0],'linestyle','--');
% Levant
%lonmin=35; lonmax=45; latmin=31; latmax=37; % Original Levant
%lonmin=35; lonmax=40; latmin=31; latmax=37; % Updated Levant Region (levant2)
lonmin=33; lonmax=40; latmin=30; latmax=37; % Updated Levant Region (levant3)

bndry_lon=[lonmin lonmax lonmax lonmin lonmin];bndry_lat=[latmin latmin latmax latmax latmin];
m_line(bndry_lon,bndry_lat,'linewidth',2.5,'color',[0 0 0],'linestyle','--');

% % Eastern Med
% lonmin=20; lonmax=37; latmin=36; latmax=41; % smaller area
% bndry_lon=[lonmin lonmax lonmax lonmin lonmin];bndry_lat=[latmin latmin latmax latmax latmin];
% m_line(bndry_lon,bndry_lat,'linewidth',2.5,'color',[0 0 0],'linestyle','--');
%m_plot(M_lakes.x,M_lakes.y,'LineWidth',2,'Color',[0 0 0])
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















