% Calculate area average PDSI and Fractional Area in Drought.

% THIS VERSION: Calculate these time series over entire Mediterranean
% domain

%% Start Clean
clear all
close all
clc

% New OWDA Version
map_txt2='MED_1'; 

% If 1, save figure to eps file
save_figure=1;

%% Parameters
% Temporal
yr_range=[1100 2012]';

% PDSI threshold for drought: any gridcell whose PDSI in a given year is
% less than or equal to this value will go into calculating the total
% drought area.
pdsi_thresh = -1; 

% Lat/Lon Bounds. Because I am doing 20th century comparisons later for the
% regional time series, I will recenter these to a mean of zero over the full 
% time period I will be analyzing (1100-2012). I am not going to recenter
% the ALLMED pan-basin index.
lonmin=-10; lonmax=0; latmin=32; latmax=42; map_txt = 'WESTMED'; recenter = 1; ave_bnds = [-5 4.5]; frac_bnds = [0 0.7];

% Set Output Directory, and patch flag. The patch flag is just used to
% highlight major drought/pluvial periods in the ALLMED series.
if strcmp(map_txt,'ALLMED')==1
    out_dir = 'fig04';
    patch_flag=1; patch_col = [0.85 0.85 0.85];
else
    out_dir = 'fig10_11'; 
    patch_flag=0;
end

%% Load OWDA Subset for Mediterranean and Land Sea Mask

% Load lat/lon/year/owda data
load(['../data/subset.owda.fix.' map_txt2 '.1000-2012.mat'],'lon_reg','lat_reg','yr_export','owda_region');

% Use regional lon/lat as the new lat/lon coordinates
lon = lon_reg; lat = lat_reg;

% Load Land Area data (used to calculate land area in drought)
land_area = rot90(ncread('/Users/bcook/Documents/GEODATA/OWDA/land_area_0.50x0.50.nc','data'));
lon_land  = ncread('/Users/bcook/Documents/GEODATA/OWDA/land_area_0.50x0.50.nc','longitude');
lat_land  = flipud(ncread('/Users/bcook/Documents/GEODATA/OWDA/land_area_0.50x0.50.nc','latitude'));

% Make Ocean Cells in the land mask NaN
land_area(find(land_area>=8e20))=nan;

%% Trim OWDA and land/sea mask to same area

% OWDA Indices
i_lat = find(lat_reg>=latmin & lat_reg<=latmax); 
i_lon = find(lon_reg>=lonmin & lon_reg<=lonmax);
i_years = find(yr_export>=yr_range(1) & yr_export<=yr_range(end)); 

% OWDA Variables
yr_owda_reg  = yr_export(i_years);
lat_owda_reg = lat_reg(i_lat); 
lon_owda_reg = lon_reg(i_lon);
owda_reg     = owda_region(i_years,i_lat,i_lon); 

clear owda_region;

% Land Area Indices
i_lat        = find(lat_land>=latmin & lat_land<=latmax); i_lon = find(lon_land>=lonmin & lon_land<=lonmax);
lat_land_reg = lat_land(i_lat); 
lon_land_reg = lon_land(i_lon);
land_reg     = land_area(i_lat,i_lon);

%% Mask land mask based on missing cells in OWDA

% Over time, some gridcells drop out as the proxy coverage deteriorates.
% I take a conservative approach, where I mask out any gridcell in
% subsequent years that is not available in the first year.

% Pull out the first year (1100 CE) to find missing values.
testpdsiyr = squeeze(owda_reg(1,:,:));

% Set the missing values location, and convert to NAN in the land mask
missvals = find(isnan(testpdsiyr)==1);
land_reg(missvals)=nan;

% Now, generate a quick figure to make sure the missing values look the
% same in both the PDSI data and the land mask.
figure
subplot(2,1,1)
pcolor(lon_land_reg,lat_land_reg,land_reg),colorbar,caxis([0 3000]), shading flat
title('LAND AREA')
subplot(2,1,2)
pcolor(lon_owda_reg,lat_owda_reg,testpdsiyr),colorbar,caxis([-5 5]), shading flat
title('PDSI')

%% Now, loop through each year and calculate area average and fractional 
%  land area under drought.

% Variable representing total land area, including masking of missing PDSI
% values from the first year of PDSI.
total_land = nansum(land_reg(:));

% Load each year individually.
for i_yr=1:length(yr_owda_reg);
   
    % Load current year and mask out missing values from first year
    current_yr(:,:) = owda_reg(i_yr,:,:); 
    current_yr(missvals)=nan;
    
    % Keep track of missing cells in each year. If done correctly, this
    % should now be the SAME VALUE each year of data.
    num_misscell(i_yr) = length(find(isnan(current_yr)==1));

    % Calculate cosine latitude area weighted average
    [cosmean,cosgrid,datagrid,new_lon,new_lat] = coswt(current_yr,lat_owda_reg,lon_owda_reg,lonmin,lonmax,latmin,latmax);
    ave_pdsi(i_yr,1) = cosmean;
        
    % Find gridcells that are wetter than the drought threshold I setup.
    i_pdsi_mask = find(current_yr>(pdsi_thresh));

    % Copy the land mask, and then mask out these wet grid cells.
    land_nada_curr = land_reg;
    land_nada_curr(i_pdsi_mask) = nan;
    
    % Sum land areas under drought, and divide by total land area.
    frac_drought(i_yr,1) = nansum(land_nada_curr(:))./total_land;
        
    % Clear some variables so that we don't accidentally reuse old values
    % in the next iteration.
    clear current_yr
    clear land_nada_curr
  
end  % year loop

% If I want to recenter the average PDSI time series, here is where I will
% do it.
if recenter==1
    ave_pdsi = detrend(ave_pdsi,'constant')
end

%% Regional Average PDSI Figure: Line Plot, 1100-2012
%  If this is the ALLMED Series, I will also put some patches on to
%  highlight some periods of persistent pluvial conditions/drought.
figure
hold on
if patch_flag==1
    p=patch([1125 1142 1142 1125],[ave_bnds(1) ave_bnds(1) ave_bnds(2) ave_bnds(2)],...
        patch_col,'LineStyle','none')
    p=patch([1237 1253 1253 1237],[ave_bnds(1) ave_bnds(1) ave_bnds(2) ave_bnds(2)],...
        patch_col,'LineStyle','none')
    p=patch([1312 1329 1329 1312],[ave_bnds(1) ave_bnds(1) ave_bnds(2) ave_bnds(2)],...
        patch_col,'LineStyle','none')
    p=patch([1351 1366 1366 1351],[ave_bnds(1) ave_bnds(1) ave_bnds(2) ave_bnds(2)],...
        patch_col,'LineStyle','none')
    p=patch([1856 1881 1881 1856],[ave_bnds(1) ave_bnds(1) ave_bnds(2) ave_bnds(2)],...
        patch_col,'LineStyle','none')
    p=patch([1942 1953 1953 1942],[ave_bnds(1) ave_bnds(1) ave_bnds(2) ave_bnds(2)],...
        patch_col,'LineStyle','none')
end
plot(yr_owda_reg,smooth(ave_pdsi,1),'Color',[0 0 0],'LineWidth',0.5,'LineStyle','-')
plot(yr_owda_reg,smooth(ave_pdsi,10,'lowess'),'Color',[0.64 0.07 0.11],...
    'LineWidth',2,'LineStyle','-')
set(gca,'FontSize',24,'FontName','helvetica','YTick',[-5:0.5:5])
xlim([1100 2012])
ylim(ave_bnds)
line(xlim,[0 0],'Color',[0 0 0],'LineWidth',2,'LineStyle','-')
box on
set(gcf,'OuterPosition',[53         321        1259         468])
set(gcf,'PaperPositionMode','auto') 
if save_figure==1
    print('-depsc','-painters',['../figures/' out_dir '/ave.pdsi.' map_txt2 '.' map_txt '.recenter' num2str(recenter) '.drt.eps'])
end

%% Regional Average PDSI Figure:
%  Bar plot, designed to show off the second half of the 20th Century
figure
i_pos = find(ave_pdsi>0);
i_neg = find(ave_pdsi<=0);
hold on
b=bar(yr_owda_reg(i_pos),ave_pdsi(i_pos),'FaceColor',[24	108	152		]/255,'BarWidth',1)
b=bar(yr_owda_reg(i_neg),ave_pdsi(i_neg),'FaceColor',[177	111	52	]./255,'BarWidth',1)
plot(yr_owda_reg,smooth(ave_pdsi,10,'lowess'),'Color',[0.64 0.07 0.11],...
    'LineWidth',3,'LineStyle','-')
set(gca,'FontSize',24,'FontName','helvetica','YTick',[-5:1:5])
ylim(ave_bnds)
xlim([1949.5 2012.5])
%xlim([1899.5 2012.5])
line(xlim,[0 0],'Color',[0 0 0],'LineWidth',2,'LineStyle','-')
box on
set(gcf,'OuterPosition',[666    26   742   585])
set(gcf,'PaperPositionMode','auto') 
if save_figure==1
    print('-depsc','-painters',['../figures/' out_dir '/bar.pdsi.' map_txt2 '.' map_txt '.recenter' num2str(recenter) '.drt.eps'])
end

%% Drought Area Plot.
%  I only make this for the ALLMED region and I, again, highlight major
%  drought/pluvial periods.
if strcmp(map_txt,'ALLMED')==1

    figure
    hold on
    if patch_flag==1
        p=patch([1125 1142 1142 1125],[frac_bnds(1) frac_bnds(1) frac_bnds(2) frac_bnds(2)],...
            patch_col,'LineStyle','none')
        p=patch([1237 1253 1253 1237],[frac_bnds(1) frac_bnds(1) frac_bnds(2) frac_bnds(2)],...
            patch_col,'LineStyle','none')
        p=patch([1312 1329 1329 1312],[frac_bnds(1) frac_bnds(1) frac_bnds(2) frac_bnds(2)],...
            patch_col,'LineStyle','none')
        p=patch([1351 1366 1366 1351],[frac_bnds(1) frac_bnds(1) frac_bnds(2) frac_bnds(2)],...
            patch_col,'LineStyle','none')
        p=patch([1856 1881 1881 1856],[frac_bnds(1) frac_bnds(1) frac_bnds(2) frac_bnds(2)],...
            patch_col,'LineStyle','none')
        p=patch([1942 1953 1953 1942],[frac_bnds(1) frac_bnds(1) frac_bnds(2) frac_bnds(2)],...
            patch_col,'LineStyle','none')
    end
    plot(yr_owda_reg,smooth(frac_drought,1),'Color',[0 0 0],'LineWidth',0.5,'LineStyle','-')
    plot(yr_owda_reg,smooth(frac_drought,10,'lowess'),'Color',[0.64 0.07 0.11],...
        'LineWidth',2,'LineStyle','-')
    set(gca,'FontSize',24,'FontName','helvetica','YTick',0:.1:0.7)
    xlim([1100 2012])
    ylim([frac_bnds])
    line(xlim,[mean(frac_drought) mean(frac_drought)],'Color',[0 0 0],'LineWidth',2,'LineStyle','-')
    box on
    set(gcf,'OuterPosition',[53         321        1259         468])
    set(gcf,'PaperPositionMode','auto') 
    if save_figure==1
        print('-depsc','-painters',['../figures/' out_dir '/area.pdsi.fracdrt.' map_txt2 '.thresh.' num2str(pdsi_thresh) '.' map_txt '.recenter' num2str(recenter) '.drt.eps'])
    end

end

%% FINAL TASKS

% Save the average PDSI and fractional drought area time series so that I 
% can do some analyses with them later.
if save_figure==1
    save(['../data/pdsi.fix.' map_txt2 '.' map_txt '.recenter' num2str(recenter) '.mat'],'frac_drought','ave_pdsi','yr_owda_reg',...
        'lonmin','latmin','lonmax','latmax')
end

% For ALLMED, identify and save the years where >40% and >50% of the basin
% is in drought.
if strcmp(map_txt,'ALLMED')==1
    yrs_drt_40 = yr_owda_reg(find(frac_drought>=0.4));
    yrs_drt_50 = yr_owda_reg(find(frac_drought>=0.5));

    save(['../data/yrs_drt_fix_' map_txt2 '.' map_txt '.mat'],'yrs_drt_40','yrs_drt_50','latmin','latmax','lonmin','lonmax');
end



