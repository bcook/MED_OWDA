% Correlations between CPC teleconnection patterns and precip and PDSI

% Start Clean
clear all
close all
clc

%map_txt='MED';	 % Old OWDA Version
map_txt='MED_1'; % New OWDA Version

save_figure  = 1; % save figure
sig_mask     = 0; % significance masking

%% Setup
% Precipitation/Index Months
% prec_mons = [1 2 3 4]; prec_mon_txt = 'JFMA';
% prec_mons = [1 2 3]; prec_mon_txt = 'JFM';
 prec_mons = [4 5 6]; prec_mon_txt = 'AMJ';
% prec_mons = [3 4 5]; prec_mon_txt = 'MAM';
% prec_mons = [10 11 12]; prec_mon_txt = 'OND';

% Years to correlate
yrs_corr = [1950 2012]; 
%yrs_corr = [1951 1978];    % Tree rings only
%yrs_corr = [1979 2012];   % Instrumental only

%% Choose Teleconnection Pattern
%telecon_name = 'NAO';       % JFMA
%telecon_name = 'SCA';       % JFM/AMJ
%telecon_name = 'EAWR';
telecon_name = 'EA';        % JFM/AMJ
%telecon_name = 'POL';
%telecon_name = 'MEI';

index_mons = load(['./telecons/' telecon_name '.txt']);

% Pull out year vector and average seasonal index
index_yrs  = index_mons(:,1);
index_mons = index_mons(:,2:end);
index_seas = nanmean(index_mons(:,prec_mons),2);

% Trim Years
i_yrs_index = find(index_yrs>=yrs_corr(1) & index_yrs<=yrs_corr(end));
index_seas = squeeze(index_seas(i_yrs_index));

%% Load and setup precipitation data
load(['cru321.sub4pdsi.new.pre.' map_txt '.mat'])

% Seasonal Average
prec_seas = squeeze(nansum(cru_subset(prec_mons,:,:,:),1));

% Trim Years
i_yrs_prec = find(yrs>=yrs_corr(1) & yrs<=yrs_corr(end));
prec_seas = squeeze(prec_seas(i_yrs_prec,:,:));

%% Load OWDA PDSI data
load(['subset.owda.fix.' map_txt '.1000-2012.mat'])

% Trim Years
i_yrs_owda = find(yr_export>=yrs_corr(1) & yr_export<=yrs_corr(end));
pdsi_seas = squeeze(owda_region(i_yrs_owda,:,:));

%% Conduct point by point correlations

for i_lon = 1:length(lon_out)
    for i_lat = 1:length(lat_out)
        
        % Correlation for each grid point: PDSI
        [r_pdsi(i_lat,i_lon),p_pdsi(i_lat,i_lon)] = corr(pdsi_seas(:,i_lat,i_lon),...
            index_seas,'type','Spearman');

        % Correlation for each grid point: Precipitation
        [r_prec(i_lat,i_lon),p_prec(i_lat,i_lon)] = corr(prec_seas(:,i_lat,i_lon),...
            index_seas,'type','Spearman');
        
    end
end

% Significance Masking
if sig_mask==1
    r_pdsi(find(p_pdsi>0.05))=nan;
    r_prec(find(p_prec>0.05))=nan;    
end

%% Set up Stuff for Figure PlotsPlot Figure
L_color=[0:0.1:0.9].*.75;
L_color=[0:0.2:1.0]
L_color=[-1.0:0.2:1.0]

proj_name='Mollweide'; lonlim=[-10 44.6],latlim=[30 46.6]; 
%map_txt='MED';	% GLOBE

% load boundaries
M_country=shape_read('/Users/bcook/Dropbox/MATLAB/map_political/10m_admin_0_countries');
M_states=shape_read('/Users/bcook/Dropbox/MATLAB/map_political/10m_admin_1_states_provinces_shp');
M_coast=shape_read('/Users/bcook/Dropbox/MATLAB/map_political/10m_coastline');
%M_ocean=shape_read('/Users/bcook/Dropbox/MATLAB/map_political/10m_ocean');
%M_lakes=shape_read('/Users/bcook/Dropbox/MATLAB/map_political/ne_10m_lakes');

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

% cmap = [
%   0.9686,0.9843,1.0000
%   0.9686,0.9843,1.0000
%   0.8706,0.9216,0.9686
%   0.8706,0.9216,0.9686
%   0.7765,0.8588,0.9373
%   0.7765,0.8588,0.9373
%   0.6196,0.7922,0.8824
%   0.6196,0.7922,0.8824
%   0.4196,0.6824,0.8392
%   0.4196,0.6824,0.8392
%   0.2588,0.5725,0.7765
%   0.2588,0.5725,0.7765
%   0.1294,0.4431,0.7098
%   0.1294,0.4431,0.7098
%   0.0314,0.3176,0.6118
%   0.0314,0.3176,0.6118
%   0.0314,0.1882,0.4196
%   0.0314,0.1882,0.4196
% ];
% 
% cmap = [
%     0.9373,0.9529,1.0000
%     0.9373,0.9529,1.0000
% 	0.7412,0.8431,0.9059
% 	0.7412,0.8431,0.9059
% 	0.4196,0.6824,0.8392
% 	0.4196,0.6824,0.8392
% 	0.1922,0.5098,0.7412
% 	0.1922,0.5098,0.7412
% 	0.0314,0.3176,0.6118
% 	0.0314,0.3176,0.6118
% ];

%% Figures

figure
hold on
colormap(cmap)
m_proj(proj_name, 'lon', lonlim,'lat', latlim);
h=m_pcolor(lon_reg-0.25,lat_reg-0.25,r_pdsi); set(h,'LineStyle','none');
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
% Eastern Med
lonmin=20; lonmax=37; latmin=36; latmax=41; % smaller area
bndry_lon=[lonmin lonmax lonmax lonmin lonmin];bndry_lat=[latmin latmin latmax latmax latmin];
m_line(bndry_lon,bndry_lat,'linewidth',2.5,'color',[0 0 0],'linestyle','--');
caxis([min(L_color) max(L_color)]);
colorbar1 = colorbar('FontName','arial',...
                'FontSize',18,...
                'FontWeight','bold',...  
                'XLim',[-0.5 1.5],'LOCATION','EastOutside',...
                'Ytick',L_color(1:length(L_color)),'YTicklabel',L_color(1:length(L_color)));
titlestring=['r, PDSI vs ' telecon_name ' (' prec_mon_txt ')']; 
title(['\fontname{helvetica} \fontsize{30} \bf{' titlestring '}']);
set(gcf,'Renderer','painters')
set(gcf,'OuterPosition',[292   999   845   570])
set(gcf,'PaperPositionMode','auto')
if save_figure==1
  print('-depsc','-painters',['./figures_new/fig03/corr.' map_txt '.' telecon_name '.owda.' prec_mon_txt '.' num2str(min(yrs_corr)) '-' num2str(max(yrs_corr)) '.eps'])
end

figure
hold on
colormap(cmap)
m_proj(proj_name, 'lon', lonlim,'lat', latlim);
h=m_pcolor(lon_reg-0.25,lat_reg-0.25,r_prec); set(h,'LineStyle','none');
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
% Eastern Med
lonmin=20; lonmax=37; latmin=36; latmax=41; % smaller area
bndry_lon=[lonmin lonmax lonmax lonmin lonmin];bndry_lat=[latmin latmin latmax latmax latmin];
m_line(bndry_lon,bndry_lat,'linewidth',2.5,'color',[0 0 0],'linestyle','--'); 
caxis([min(L_color) max(L_color)]);
colorbar1 = colorbar('FontName','arial',...
                'FontSize',18,...
                'FontWeight','bold',...  
                'XLim',[-0.5 1.5],'LOCATION','EastOutside',...
                'Ytick',L_color(1:length(L_color)),'YTicklabel',L_color(1:length(L_color)));
titlestring=['r, PREC vs ' telecon_name ' (' prec_mon_txt ')']; 
title(['\fontname{helvetica} \fontsize{30} \bf{' titlestring '}']);
set(gcf,'Renderer','painters')
set(gcf,'OuterPosition',[292   999   845   570])
set(gcf,'PaperPositionMode','auto')
if save_figure==1
  print('-depsc','-painters',['./figures_new/fig03/corr.' telecon_name '.prec.' prec_mon_txt '.' num2str(min(yrs_corr)) '-' num2str(max(yrs_corr)) '.eps'])
end





















