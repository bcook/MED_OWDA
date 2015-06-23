% This script will be used to conduct point by point correlations between
% my eastern and western mediterranean time series.

% Start Clean
clear all
close all
clc

% Save Figure if =1
save_figure = 1;

% Years over which to calculate the correlations
yrs_corr = [1100 2012]; 

%% Load Time Series Data
load ../data/pdsi.fix.MED_1.WESTMED.recenter1.mat;      westmed=ave_pdsi;
load ../data/pdsi.fix.MED_1.EASTMED.recenter1.mat;      eastmed=ave_pdsi;
load ../data/pdsi.fix.MED_1.MIDEASTSMALL.recenter1.mat; mideast=ave_pdsi;

% Trim Years to time range I want to correlate.
i_yrs_index = find(yr_owda_reg>=yrs_corr(1) & yr_owda_reg<=yrs_corr(end));

eastmed = eastmed(i_yrs_index);
westmed = westmed(i_yrs_index);
mideast = mideast(i_yrs_index);

%% Load the Gridded Mediterranean subset of OWDA PDSI data
load ../data/subset.owda.fix.MED_1.1000-2012.mat

% Trim Years
i_yrs_owda = find(yr_export>=yrs_corr(1) & yr_export<=yrs_corr(end));
pdsi_seas = squeeze(owda_region(i_yrs_owda,:,:));

%% Conduct point by point correlations

for i_lon = 1:length(lon_reg)
    for i_lat = 1:length(lat_reg)
        
        % Correlation for each grid point: PDSI
        [r_west(i_lat,i_lon),p_west(i_lat,i_lon)] = corr(pdsi_seas(:,i_lat,i_lon),...
            westmed,'type','Spearman');
        
        [r_east(i_lat,i_lon),p_east(i_lat,i_lon)] = corr(pdsi_seas(:,i_lat,i_lon),...
            eastmed,'type','Spearman');        

        [r_mideast(i_lat,i_lon),p_mideast(i_lat,i_lon)] = corr(pdsi_seas(:,i_lat,i_lon),...
            mideast,'type','Spearman');  
        
    end
end

%% Set up Stuff for Figure Plots

% Colorbar limits
L_color=[-1.0:0.2:1.0]

% Projection and geographic range
proj_name='Mollweide'; lonlim=[-10 44.6]; latlim=[30 46.6]; map_txt='MED';	% GLOBE

% Load Political and Coastal borders
M_country=shape_read('/Users/bcook/Dropbox/MATLAB/map_political/10m_admin_0_countries');
M_states=shape_read('/Users/bcook/Dropbox/MATLAB/map_political/10m_admin_1_states_provinces_shp');
M_coast=shape_read('/Users/bcook/Dropbox/MATLAB/map_political/10m_coastline');

% Colormap to use
cmap =   [
  0.3294,0.1882,0.0196
  0.3294,0.1882,0.0196
  0.5490,0.3176,0.0392
  0.5490,0.3176,0.0392
  0.7490,0.5059,0.1765
  0.7490,0.5059,0.1765
  0.8745,0.7608,0.4902
  0.8745,0.7608,0.4902
  0.9647,0.9098,0.7647
  0.9647,0.9098,0.7647
  0.7804,0.9176,0.8980
  0.7804,0.9176,0.8980
  0.5020,0.8039,0.7569
  0.5020,0.8039,0.7569
  0.2078,0.5922,0.5608
  0.2078,0.5922,0.5608
  0.0039,0.4000,0.3686
  0.0039,0.4000,0.3686
  0.0000,0.2353,0.1882
  0.0000,0.2353,0.1882
];

%% Western MED Figure
figure
hold on
colormap(cmap)
m_proj(proj_name, 'lon', lonlim,'lat', latlim);
h=m_pcolor(lon_reg-0.25,lat_reg-0.25,r_west); set(h,'LineStyle','none');
m_grid('linestyle', 'none','fontsize',14,'fontname','arial',...
     'xticklabels',[],'yticklabels',[],...
     'FontWeight','bold');
m_plot(M_coast.x,M_coast.y,'LineWidth',2,'Color',[0 0 0])
m_plot(M_country.x,M_country.y,'LineWidth',1,'Color',[0 0 0])
% West Med Box
lonmin=-10; lonmax=0; latmin=32; latmax=42; % smaller area
bndry_lon=[lonmin lonmax lonmax lonmin lonmin];bndry_lat=[latmin latmin latmax latmax latmin];
m_line(bndry_lon,bndry_lat,'linewidth',2.5,'color',[0 0 0],'linestyle','--');
% Eastern Med Box
lonmin=20; lonmax=37; latmin=36; latmax=41; % smaller area
bndry_lon=[lonmin lonmax lonmax lonmin lonmin];bndry_lat=[latmin latmin latmax latmax latmin];
m_line(bndry_lon,bndry_lat,'linewidth',2.5,'color',[0 0 0],'linestyle','--');
% MidEastSmall Box
lonmin=33; lonmax=47; latmin=30; latmax=34; % smaller area
bndry_lon=[lonmin lonmax lonmax lonmin lonmin];bndry_lat=[latmin latmin latmax latmax latmin];
m_line(bndry_lon,bndry_lat,'linewidth',2.5,'color',[0 0 0],'linestyle','--');

caxis([min(L_color) max(L_color)]);
colorbar1 = colorbar('FontName','arial',...
                'FontSize',18,...
                'FontWeight','bold',...  
                'XLim',[-0.5 1.5],'LOCATION','EastOutside',...
                'Ytick',L_color(1:length(L_color)),'YTicklabel',L_color(1:length(L_color)));
titlestring=['r, WestMED vs OWDA']; 
title(['\fontname{helvetica} \fontsize{30} \bf{' titlestring '}']);
set(gcf,'Renderer','painters')
set(gcf,'OuterPosition',[292   999   845   570])
set(gcf,'PaperPositionMode','auto')
if save_figure==1
  print('-depsc','-painters',['../figures/fig07/corr.westMED.owda.' num2str(min(yrs_corr)) '-' num2str(max(yrs_corr)) '.eps'])
end

%% Eastern MED Figure
figure
hold on
colormap(cmap)
m_proj(proj_name, 'lon', lonlim,'lat', latlim);
h=m_pcolor(lon_reg-0.25,lat_reg-0.25,r_east); set(h,'LineStyle','none');
m_grid('linestyle', 'none','fontsize',14,'fontname','arial',...
     'xticklabels',[],'yticklabels',[],...
     'FontWeight','bold');
m_plot(M_coast.x,M_coast.y,'LineWidth',2,'Color',[0 0 0])
m_plot(M_country.x,M_country.y,'LineWidth',1,'Color',[0 0 0])
% West Med Box
lonmin=-10; lonmax=0; latmin=32; latmax=42; % smaller area
bndry_lon=[lonmin lonmax lonmax lonmin lonmin];bndry_lat=[latmin latmin latmax latmax latmin];
m_line(bndry_lon,bndry_lat,'linewidth',2.5,'color',[0 0 0],'linestyle','--');
% Eastern Med Box
lonmin=20; lonmax=37; latmin=36; latmax=41; % smaller area
bndry_lon=[lonmin lonmax lonmax lonmin lonmin];bndry_lat=[latmin latmin latmax latmax latmin];
m_line(bndry_lon,bndry_lat,'linewidth',2.5,'color',[0 0 0],'linestyle','--');
% MidEastSmall Box
lonmin=33; lonmax=47; latmin=30; latmax=34; % smaller area
bndry_lon=[lonmin lonmax lonmax lonmin lonmin];bndry_lat=[latmin latmin latmax latmax latmin];
m_line(bndry_lon,bndry_lat,'linewidth',2.5,'color',[0 0 0],'linestyle','--');

caxis([min(L_color) max(L_color)]);
colorbar1 = colorbar('FontName','arial',...
                'FontSize',18,...
                'FontWeight','bold',...  
                'XLim',[-0.5 1.5],'LOCATION','EastOutside',...
                'Ytick',L_color(1:length(L_color)),'YTicklabel',L_color(1:length(L_color)));
titlestring=['r, EastMED vs OWDA']; 
title(['\fontname{helvetica} \fontsize{30} \bf{' titlestring '}']);
set(gcf,'Renderer','painters')
set(gcf,'OuterPosition',[292   999   845   570])
set(gcf,'PaperPositionMode','auto')
if save_figure==1
  print('-depsc','-painters',['../figures/fig07/corr.eastMED.owda.' num2str(min(yrs_corr)) '-' num2str(max(yrs_corr)) '.eps'])
end

%% MidEast MED Figure
figure
hold on
colormap(cmap)
m_proj(proj_name, 'lon', lonlim,'lat', latlim);
h=m_pcolor(lon_reg-0.25,lat_reg-0.25,r_mideast); set(h,'LineStyle','none');
m_grid('linestyle', 'none','fontsize',14,'fontname','arial',...
     'xticklabels',[],'yticklabels',[],...
     'FontWeight','bold');
m_plot(M_coast.x,M_coast.y,'LineWidth',2,'Color',[0 0 0])
m_plot(M_country.x,M_country.y,'LineWidth',1,'Color',[0 0 0])
% West Med Box
lonmin=-10; lonmax=0; latmin=32; latmax=42; % smaller area
bndry_lon=[lonmin lonmax lonmax lonmin lonmin];bndry_lat=[latmin latmin latmax latmax latmin];
m_line(bndry_lon,bndry_lat,'linewidth',2.5,'color',[0 0 0],'linestyle','--');
% Eastern Med Box
lonmin=20; lonmax=37; latmin=36; latmax=41; % smaller area
bndry_lon=[lonmin lonmax lonmax lonmin lonmin];bndry_lat=[latmin latmin latmax latmax latmin];
m_line(bndry_lon,bndry_lat,'linewidth',2.5,'color',[0 0 0],'linestyle','--');
% MidEastSmall Box
lonmin=33; lonmax=47; latmin=30; latmax=34; % smaller area
bndry_lon=[lonmin lonmax lonmax lonmin lonmin];bndry_lat=[latmin latmin latmax latmax latmin];
m_line(bndry_lon,bndry_lat,'linewidth',2.5,'color',[0 0 0],'linestyle','--');

caxis([min(L_color) max(L_color)]);
colorbar1 = colorbar('FontName','arial',...
                'FontSize',18,...
                'FontWeight','bold',...  
                'XLim',[-0.5 1.5],'LOCATION','EastOutside',...
                'Ytick',L_color(1:length(L_color)),'YTicklabel',L_color(1:length(L_color)));
titlestring=['r, MidEast vs OWDA']; 
title(['\fontname{helvetica} \fontsize{30} \bf{' titlestring '}']);
set(gcf,'Renderer','painters')
set(gcf,'OuterPosition',[292   999   845   570])
set(gcf,'PaperPositionMode','auto')
if save_figure==1
  print('-depsc','-painters',['../figures/fig07/corr.mideastsmall.owda.' num2str(min(yrs_corr)) '-' num2str(max(yrs_corr)) '.eps'])
end









