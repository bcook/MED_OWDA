% Create a map of the Proxy Site Locations. Locations will be color coded
% to indicate approximate start data of that proxy series.

% Start Clean
clear all
close all
clc

% If =1, save figure.
save_figure = 1;

%% Load Data
load ../data/proxy_locs.mat

%% Setup Figure

% Projection name and lon/lat boundaries
proj_name='Mollweide'; lonlim=[-10 44.6],latlim=[30 46.6]; 

% Load political and coastal boundaries
M_country=shape_read('/Users/bcook/Dropbox/MATLAB/map_political/10m_admin_0_countries');
M_states=shape_read('/Users/bcook/Dropbox/MATLAB/map_political/10m_admin_1_states_provinces_shp');
M_coast=shape_read('/Users/bcook/Dropbox/MATLAB/map_political/10m_coastline');

% Color Scheme
colors = [...
255,255,204
161,218,180
65,182,196
44,127,184
37,52,148]./255;

%% Create the Figure

figure
hold on
m_proj(proj_name, 'lon', lonlim,'lat', latlim);
m_grid('linestyle', 'none','fontsize',14,'fontname','arial',...
     'xticklabels',[],'yticklabels',[],...
     'FontWeight','bold');
%m_coast('color','k','LineWidth',2);
m_plot(M_coast.x,M_coast.y,'LineWidth',1,'Color',[0 0 0])
m_plot(M_country.x,M_country.y,'LineWidth',1,'Color',[0 0 0])

mxi = NaN(size(site_lats));

for i_site=1:length(site_lats)

    yr_start(i_site)
    % Choose Marker Color Based on Starting Year
    if yr_start(i_site)<=1100
        mark_col = colors(5,:)% [177	46	48]./255;  % RED
        mxi(i_site,1) = 1100
    elseif yr_start(i_site)>1100 & yr_start(i_site)<=1200
        mark_col = colors(4,:)% [177	111	52]./255;  % BROWN
        mxi(i_site,1) =  1200
    elseif yr_start(i_site)>1200 & yr_start(i_site)<=1300
        mark_col = colors(3,:) % [134	177	56]./255;   % Green
        mxi(i_site,1) = 1300
    elseif yr_start(i_site)>1300 & yr_start(i_site)<=1400
        mark_col = colors(2,:) % [50	134	177]./255; % Blue
        mxi(i_site,1) = 1400
    elseif yr_start(i_site)>=1400 & yr_start(i_site)<=1700
         mark_col = colors(1,:) % [66	51	176]./255;  % Purple
         mxi(i_site,1) = 1700
    else
        mark_col = [1 1 1]
    end
    
    mx(i_site)=m_plot(site_lons(i_site),site_lats(i_site),'Color','k','LineStyle','none',...
        'Marker','o','MarkerFaceColor',mark_col);

end

lx = legend([mx(find(mxi==1100,1,'first')) mx(find(mxi==1200,1,'first')) mx(find(mxi==1300,1,'first')) mx(find(mxi==1400,1,'first')) mx(find(mxi==1700,1,'first'))],'< 1100 CE','1101 - 1200 CE','1201 - 1300 CE','1301 - 1400 CE','1401-1700 CE','location','southoutside','orientation','horizontal')

% modify the legend appearance
legend boxoff
set(lx,'fontsize',14)
lxg=get(lx); lcc=lxg.Children; l2=[];
l2=findobj(lcc,{'type','patch','-or','type','line'});

for m=1:length(l2)
    set(l2(m),'markersize',16);
end

% title and figure output
titlestring=['Tree-Ring Chronologies']; 
title(['\fontname{helvetica} \fontsize{30} \bf{' titlestring '}']);
set(gcf,'Renderer','painters')
set(gcf,'OuterPosition',[292   999   845   570])
set(gcf,'PaperPositionMode','auto')
if save_figure==1
  print('-depsc','-painters',['../figures/fig01/proxy_site_locs.eps'])
end






















