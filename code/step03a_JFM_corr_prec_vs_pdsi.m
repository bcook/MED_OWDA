% This script will conduct a point by point correlations between the precipitation 
% data and the OWDA PDSI dataset.

% THIS VERSION: Winter Season (JFM)

% Start Clean
clear all
close all
clc

% if = 1, save figure to output
save_figure = 1;

% New OWDA Version
map_txt='MED_1'; 

%% Setup

% Precipitation Months
prec_mons = [1 2 3]; prec_mon_txt = 'JFM';

% Years to correlate
yrs_corr = [1950 2012]; 

%% Load and setup precipitation data
load(['../data/cru321.sub4pdsi.new.pre.' map_txt '.mat'])

% Seasonal Sum, all uears
prec_seas = squeeze(nansum(cru_subset(prec_mons,:,:,:),1));

% Locations of years I want. If months 9 or higher, take data from the previous year
if sum(length(find(prec_mons>9)))>0
    i_yrs_prec = find(yrs>=(yrs_corr(1)-1) & yrs<=(yrs_corr(end)-1));
else
    i_yrs_prec = find(yrs>=(yrs_corr(1)) & yrs<=(yrs_corr(end)));
end

% Now, select data.
prec_seas = squeeze(prec_seas(i_yrs_prec,:,:));

%% Load OWDA PDSI data
load(['../data/subset.owda.fix.' map_txt '.1000-2012.mat'])

% Trim Years
i_yrs_owda = find(yr_export>=yrs_corr(1) & yr_export<=yrs_corr(end));
pdsi_seas = squeeze(owda_region(i_yrs_owda,:,:));

%% Conduct point by point correlations
%  (with and without long term linear trend removed)

% Loop through each latituden and longitude gridcell
for i_lon = 1:length(lon_out)
    for i_lat = 1:length(lat_out)
        
        % Correlation for each grid point: with trends
        [r_pdsi(i_lat,i_lon),p_pdsi(i_lat,i_lon)] = corr(pdsi_seas(:,i_lat,i_lon),...
                prec_seas(:,i_lat,i_lon),'type','Spearman');

        % Correlation for each grid point: DETRENDED data
        [r_pdsi_det(i_lat,i_lon),p_pdsi_det(i_lat,i_lon)] = corr(detrend(pdsi_seas(:,i_lat,i_lon)),...
                detrend(prec_seas(:,i_lat,i_lon)),'type','Spearman');                    
        
    end
end

%% Plot Figure: With Trends
L_color=[0:0.2:1.0]

% Set projection and map limits
proj_name='Mollweide'; lonlim=[-10 44.6],latlim=[30 46.6]; 

% Load coastal and political boundaries
M_country=shape_read('/Users/bcook/Dropbox/MATLAB/map_political/10m_admin_0_countries');
M_states=shape_read('/Users/bcook/Dropbox/MATLAB/map_political/10m_admin_1_states_provinces_shp');
M_coast=shape_read('/Users/bcook/Dropbox/MATLAB/map_political/10m_coastline');

% Colormap
cmap = [
    0.9373,0.9529,1.0000
    0.9373,0.9529,1.0000
	0.7412,0.8431,0.9059
	0.7412,0.8431,0.9059
	0.4196,0.6824,0.8392
	0.4196,0.6824,0.8392
	0.1922,0.5098,0.7412
	0.1922,0.5098,0.7412
	0.0314,0.3176,0.6118
	0.0314,0.3176,0.6118
];

figure
hold on
colormap(cmap)
m_proj(proj_name, 'lon', lonlim,'lat', latlim);
h=m_pcolor(lon_reg-0.25,lat_reg-0.25,r_pdsi); set(h,'LineStyle','none');
m_grid('linestyle', 'none','fontsize',14,'fontname','arial',...
     'xticklabels',[],'yticklabels',[],...
     'FontWeight','bold');
m_plot(M_coast.x,M_coast.y,'LineWidth',2,'Color',[0 0 0])
m_plot(M_country.x,M_country.y,'LineWidth',1,'Color',[0 0 0])
caxis([min(L_color) max(L_color)]);
colorbar1 = colorbar('FontName','arial',...
                'FontSize',18,...
                'FontWeight','bold',...  
                'XLim',[-0.5 1.5],'LOCATION','EastOutside',...
                'Ytick',L_color(1:length(L_color)),'YTicklabel',L_color(1:length(L_color)));
titlestring=['spear rho, PDSI vs Prec, w/trend (' prec_mon_txt ')']; 
title(['\fontname{helvetica} \fontsize{24} \bf{' titlestring '}']);
set(gcf,'Renderer','painters')
set(gcf,'OuterPosition',[292   999   845   570])
set(gcf,'PaperPositionMode','auto')
if save_figure==1
  print('-depsc','-painters',['../figures/fig02/corr.owda.prec.withtrend.' map_txt '.' prec_mon_txt '.' num2str(min(yrs_corr)) '-' num2str(max(yrs_corr)) '.eps'])
end

%% Plot Figure: Detrended
L_color=[0:0.2:1.0]

% Set projection and map limits
proj_name='Mollweide'; lonlim=[-10 44.6],latlim=[30 46.6]; 

% Load coastal and political boundaries
M_country=shape_read('/Users/bcook/Dropbox/MATLAB/map_political/10m_admin_0_countries');
M_states=shape_read('/Users/bcook/Dropbox/MATLAB/map_political/10m_admin_1_states_provinces_shp');
M_coast=shape_read('/Users/bcook/Dropbox/MATLAB/map_political/10m_coastline');

% Colormap
cmap = [
    0.9373,0.9529,1.0000
    0.9373,0.9529,1.0000
	0.7412,0.8431,0.9059
	0.7412,0.8431,0.9059
	0.4196,0.6824,0.8392
	0.4196,0.6824,0.8392
	0.1922,0.5098,0.7412
	0.1922,0.5098,0.7412
	0.0314,0.3176,0.6118
	0.0314,0.3176,0.6118
];

figure
hold on
colormap(cmap)
m_proj(proj_name, 'lon', lonlim,'lat', latlim);
h=m_pcolor(lon_reg-0.25,lat_reg-0.25,r_pdsi_det); set(h,'LineStyle','none');
m_grid('linestyle', 'none','fontsize',14,'fontname','arial',...
     'xticklabels',[],'yticklabels',[],...
     'FontWeight','bold');
m_plot(M_coast.x,M_coast.y,'LineWidth',2,'Color',[0 0 0])
m_plot(M_country.x,M_country.y,'LineWidth',1,'Color',[0 0 0])
caxis([min(L_color) max(L_color)]);
colorbar1 = colorbar('FontName','arial',...
                'FontSize',18,...
                'FontWeight','bold',...  
                'XLim',[-0.5 1.5],'LOCATION','EastOutside',...
                'Ytick',L_color(1:length(L_color)),'YTicklabel',L_color(1:length(L_color)));
titlestring=['spear rho, PDSI vs Prec, detrend (' prec_mon_txt ')']; 
title(['\fontname{helvetica} \fontsize{24} \bf{' titlestring '}']);
set(gcf,'Renderer','painters')
set(gcf,'OuterPosition',[292   999   845   570])
set(gcf,'PaperPositionMode','auto')
if save_figure==1
  print('-depsc','-painters',['../figures/fig02/corr.owda.prec.detrend.' map_txt '.' prec_mon_txt '.' num2str(min(yrs_corr)) '-' num2str(max(yrs_corr)) '.eps'])
end





















