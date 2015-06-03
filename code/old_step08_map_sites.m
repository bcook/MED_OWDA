% Create a map of the Proxy Site Locations, and color them in based on the
% approximate start date of the proxies

% Start Clean
clear all
close all
clc

% If =1, save figure
save_figure = 1;

%% Load Data
load proxy_locs.mat

%% Setup Figure

% Projection and lat/lon range
proj_name='Mollweide'; lonlim=[-10 44.6],latlim=[30 46.6]; 

% Load political and coastal boundaries
M_country=shape_read('/Users/bcook/Dropbox/MATLAB/map_political/10m_admin_0_countries');
M_states=shape_read('/Users/bcook/Dropbox/MATLAB/map_political/10m_admin_1_states_provinces_shp');
M_coast=shape_read('/Users/bcook/Dropbox/MATLAB/map_political/10m_coastline');

%% Create Figure
figure
hold on
m_proj(proj_name, 'lon', lonlim,'lat', latlim);
m_grid('linestyle', 'none','fontsize',14,'fontname','arial',...
     'xticklabels',[],'yticklabels',[],...
     'FontWeight','bold');
%m_coast('color','k','LineWidth',2);
m_plot(M_coast.x,M_coast.y,'LineWidth',1,'Color',[0 0 0])
m_plot(M_country.x,M_country.y,'LineWidth',1,'Color',[0 0 0])

%for i_site=1:length(site_lats)
for i_site=1:length(site_lats)

    yr_start(i_site)
    % Choose Marker Color Based on Starting Year
    if yr_start(i_site)<=1100
        mark_col = [177	46	48]./255;  % RED
    elseif yr_start(i_site)>1100 & yr_start(i_site)<=1200
        mark_col = [177	111	52]./255;  % BROWN
    elseif yr_start(i_site)>1200 & yr_start(i_site)<=1300
        mark_col = [134	177	56]./255;   % Green
    elseif yr_start(i_site)>1300 & yr_start(i_site)<=1400
        mark_col = [50	134	177]./255; % Blue
    elseif yr_start(i_site)>=1400 & yr_start(i_site)<=1700
         mark_col = [66	51	176]./255;  % Purple
    else
        mark_col = [1 1 1]
    end
    
    m=m_plot(site_lons(i_site),site_lats(i_site),'Color','k','LineStyle','none',...
        'Marker','o','MarkerFaceColor',mark_col);

end
%     % UK
%     lonmin=-11; lonmax=1.75; latmin=50; latmax=59; % smaller area
%     bndry_lon=[lonmin lonmax lonmax lonmin lonmin];bndry_lat=[latmin latmin latmax latmax latmin];
%     m_line(bndry_lon,bndry_lat,'linewidth',2.5,'color',[0 0 0],'linestyle','--');  
%caxis([min(L_color) max(L_color)]);
%colorbar1 = colorbar('FontName','arial',...
%                'FontSize',18,...
%                'FontWeight','bold',...  
%                'XLim',[-0.5 1.5],'LOCATION','EastOutside',...
%                'Ytick',L_color(1:length(L_color)),'YTicklabel',L_color(1:length(L_color)));
titlestring=['Proxy Site Locations']; 
title(['\fontname{helvetica} \fontsize{30} \bf{' titlestring '}']);
set(gcf,'Renderer','painters')
set(gcf,'OuterPosition',[292   999   845   570])
set(gcf,'PaperPositionMode','auto')
if save_figure==1
  print('-depsc','-painters',['./figures_new/fig01/proxy_site_locs.eps'])
end






















