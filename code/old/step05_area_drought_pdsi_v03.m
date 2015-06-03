% Calculate land area in drought

%% Start Clean
clear all
close all
clc

%map_txt2='MED';	 % Old OWDA Version
map_txt2='MED_1'; % New OWDA Version

save_figure=0;

%% Parameters
% Temporal
yr_range=[1100 2012]';

% Thresholds for area calculation
pdsi_thresh = 1; drt_thresh=1;

% NEW REGIONS
lonmin=-10; lonmax=45; latmin=30; latmax=47; map_txt='ALLMED'; recenter = 0; ave_bnds = [-1.5 2]; frac_bnds = [0 0.7];
%lonmin=-10; lonmax=0; latmin=32; latmax=42; map_txt = 'WESTMED'; recenter = 1; ave_bnds = [-5 4.5]; frac_bnds = [0 0.7];
%lonmin=20; lonmax=37; latmin=36; latmax=41; map_txt = 'EASTMED'; recenter = 1; ave_bnds = [-5 4.5]; frac_bnds = [0 0.7];
%lonmin=19; lonmax=26; latmin=36; latmax=43;  map_txt = 'greece2'; recenter = 1; ave_bnds = [-5 4.5]; frac_bnds = [0 0.7];
lonmin=33; lonmax=40; latmin=30; latmax=37;  map_txt = 'levant3'; recenter = 1; ave_bnds = [-5 4.5]; frac_bnds = [0 0.7];

% Set Output Directory
if strcmp(map_txt,'ALLMED')==1
    out_dir = 'fig04';
    patch_flag=1; patch_col = [0.85 0.85 0.85];
else
    out_dir = 'fig10_11'; 
    patch_flag=0;
end


% Region
%lonmin=-10; lonmax=45; latmin=30; latmax=47; map_txt='ALLMED'; recenter = 0; ave_bnds = [-1.5 2]; frac_bnds = [0 0.7];
%lonmin=-10; lonmax=0; latmin=32; latmax=42; map_txt = 'WESTMED'; recenter = 1; ave_bnds = [-4 4]; frac_bnds = [0 0.7];
%lonmin=20; lonmax=37; latmin=36; latmax=41; map_txt = 'EASTMED'; recenter = 1; ave_bnds = [-5 4]; frac_bnds = [0 0.7];

% subregions
%lonmin=19; lonmax=26; latmin=36; latmax=42;  map_txt = 'greece'; recenter = 1; ave_bnds = [-5 5]; frac_bnds = [0 0.7];
%lonmin=19; lonmax=26; latmin=36; latmax=43;  map_txt = 'greece2'; recenter = 1; ave_bnds = [-5 5]; frac_bnds = [0 0.7];

%lonmin=35; lonmax=45; latmin=31; latmax=37;  map_txt = 'levant'; recenter = 1; ave_bnds = [-5 4]; frac_bnds = [0 0.7];
%lonmin=35; lonmax=40; latmin=31; latmax=37;  map_txt = 'levant2'; recenter = 1; ave_bnds = [-5 4]; frac_bnds = [0 0.7];
%lonmin=33; lonmax=40; latmin=30; latmax=37;  map_txt = 'levant3'; recenter = 1; ave_bnds = [-5 4]; frac_bnds = [0 0.7];

%% Load OWDA Subset for Mediterranean and Land Sea Mask
%load('subset.owda.fix.MED.1000-2012.mat','lon_reg','lat_reg','yr_export','owda_region');
%load('subset.owda.fix.MED_1.1000-2012.mat','lon_reg','lat_reg','yr_export','owda_region');

load(['subset.owda.fix.' map_txt2 '.1000-2012.mat'],'lon_reg','lat_reg','yr_export','owda_region');

%owda = load('subset.owda.fix.MED.1000-2012.mat');
lon = lon_reg; lat = lat_reg;

yr_vect = yr_export;

% Load Land Area data
land_area = rot90(ncread('/Users/bcook/Documents/GEODATA/OWDA/land_area_0.50x0.50.nc','data'));
lon_land  = ncread('/Users/bcook/Documents/GEODATA/OWDA/land_area_0.50x0.50.nc','longitude');
lat_land  = flipud(ncread('/Users/bcook/Documents/GEODATA/OWDA/land_area_0.50x0.50.nc','latitude'));

% Make Ocean Cells NaN
land_area(find(land_area>=8e20))=nan;

%% Trim OWDA and land/sea mask to same area

% OWDA Indices
i_lat = find(lat_reg>=latmin & lat_reg<=latmax); i_lon = find(lon_reg>=lonmin & lon_reg<=lonmax);
i_years = find(yr_export>=yr_range(1) & yr_export<=yr_range(end)); 

% OWDA Variables
yr_owda_reg  = yr_export(i_years);
lat_owda_reg = lat_reg(i_lat); 
lon_owda_reg = lon_reg(i_lon);
owda_reg = owda_region(i_years,i_lat,i_lon); clear owda_region;

% Land Area Indices
i_lat = find(lat_land>=latmin & lat_land<=latmax); i_lon = find(lon_land>=lonmin & lon_land<=lonmax);
lat_land_reg = lat_land(i_lat); 
lon_land_reg = lon_land(i_lon);
land_reg = land_area(i_lat,i_lon);

% Mask land mask based on missing cells in OWDA
testpdsiyr = squeeze(owda_reg(1,:,:));
missvals = find(isnan(testpdsiyr)==1);
land_reg(missvals)=nan;

% debugging
% figure
% subplot(2,1,1)
% pcolor(lon_land_reg,lat_land_reg,land_reg),colorbar,caxis([0 3000]), shading flat
% title('LAND AREA')
% subplot(2,1,2)
% pcolor(lon_owda_reg,lat_owda_reg,testpdsiyr),colorbar,caxis([-5 5]), shading flat
% title('PDSI')

%% Now, loop through each year and calculate area average/area under drought

% Load each year individually.
for i_yr=1:length(yr_owda_reg);

    % Load current year and mask out missing values from first year
    current_yr(:,:) = owda_reg(i_yr,:,:); current_yr(missvals)=nan;
    
    % debug
    %size(find(current_yr>-10000))
    
    % Area Average
    [cosmean,cosgrid,datagrid,new_lon,new_lat] = coswt(current_yr,lat_owda_reg,lon_owda_reg,lonmin,lonmax,latmin,latmax);
    ave_pdsi(i_yr,1) = cosmean;
    
    % debug
    %figure,pcolor(lon_owda_reg,lat_owda_reg,current_yr),shading flat,colorbar,caxis([-3 3])
    
    % Calculate area for threshold
    if drt_thresh==1;
        i_pdsi_mask = find(current_yr>(-1.*pdsi_thresh));
    elseif drt_thresh==0;
        i_pdsi_mask = find(current_yr<(1.*pdsi_thresh));
    end
    
    % Temp land mask for summing land areas under drought
    land_nada_curr = land_reg;
    land_nada_curr(i_pdsi_mask) = nan;
      
    % debug
    %figure,pcolor(lon_owda_reg,lat_owda_reg,land_nada_curr),shading flat,colorbar,caxis([0 3000])
    
    % debug
    %size(find(land_reg>-10000))
    
    % Sum land areas under drought
    frac_drought(i_yr,1) = nansum(land_nada_curr(:))./nansum(land_reg(:));
        
    clear current_yr
    clear land_nada_curr

    
end  % year loop

%% Create Plots

% For some, I want to recenter to zero over the entire time period
if recenter==1
    ave_pdsi = detrend(ave_pdsi,'constant')
end

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
%set(gca,'FontSize',18,'FontName','helvetica','FontWeight','bold','YTick',[-5:0.5:5])
set(gca,'FontSize',24,'FontName','helvetica','YTick',[-5:0.5:5])
xlim([1100 2012])
%plot(yr_range(i_1934),ave_pdsi(i_1934),'Marker','.','MarkerSize',20,'Color',[0.54 0.33 0.16])
%plot(yr_range(i_1934),ave_pdsi(i_1934),'Marker','.','MarkerSize',20,'Color',[0.09 0.48 0.60],'LineStyle','none')
%ylim([-5 4.5])
ylim(ave_bnds)
line(xlim,[0 0],'Color',[0 0 0],'LineWidth',2,'LineStyle','-')
box on
set(gcf,'OuterPosition',[53         321        1259         468])
%set(gcf,'OuterPosition',[213    40   965   616])
set(gcf,'PaperPositionMode','auto') 
if save_figure==1
    print('-depsc','-painters',['./figures_new/' out_dir '/ave.pdsi.' map_txt2 '.' map_txt '.recenter' num2str(recenter) '.drt.eps'])
end


figure
i_pos = find(ave_pdsi>0);
i_neg = find(ave_pdsi<=0);
hold on
%b=bar(yr_owda_reg(i_pos),ave_pdsi(i_pos),'FaceColor',[50	134	177	]/255,'BarWidth',1)
b=bar(yr_owda_reg(i_pos),ave_pdsi(i_pos),'FaceColor',[24	108	152		]/255,'BarWidth',1)
b=bar(yr_owda_reg(i_neg),ave_pdsi(i_neg),'FaceColor',[177	111	52	]./255,'BarWidth',1)
plot(yr_owda_reg,smooth(ave_pdsi,10,'lowess'),'Color',[0.64 0.07 0.11],...
    'LineWidth',3,'LineStyle','-')
%set(gca,'FontSize',24,'FontName','helvetica','FontWeight','bold','YTick',[-5:1:5])
set(gca,'FontSize',24,'FontName','helvetica','YTick',[-5:1:5])

xlim([1100 2012])
%plot(yr_range(i_1934),ave_pdsi(i_1934),'Marker','.','MarkerSize',20,'Color',[0.54 0.33 0.16])
%plot(yr_range(i_1934),ave_pdsi(i_1934),'Marker','.','MarkerSize',20,'Color',[0.09 0.48 0.60],'LineStyle','none')
ylim([-5 4.5])
%ylim(ave_bnds)
xlim([1949.5 2012.5])
xlim([1899.5 2012.5])
line(xlim,[0 0],'Color',[0 0 0],'LineWidth',2,'LineStyle','-')
box on
set(gcf,'OuterPosition',[666    26   742   585])
%set(gcf,'OuterPosition',[213    40   965   616])
set(gcf,'PaperPositionMode','auto') 
if save_figure==1
    print('-depsc','-painters',['./figures_new/' out_dir '/bar.pdsi.' map_txt2 '.' map_txt '.recenter' num2str(recenter) '.drt.eps'])
end

%%
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
%set(gca,'FontSize',18,'FontName','helvetica','FontWeight','bold')
set(gca,'FontSize',24,'FontName','helvetica','YTick',0:.1:0.7)
xlim([1100 2012])
ylim([frac_bnds])
line(xlim,[mean(frac_drought) mean(frac_drought)],'Color',[0 0 0],'LineWidth',2,'LineStyle','-')
box on
set(gcf,'OuterPosition',[53         321        1259         468])
%set(gcf,'OuterPosition',[213    40   965   616])
set(gcf,'PaperPositionMode','auto') 
if save_figure==1
    print('-depsc','-painters',['./figures_new/' out_dir '/area.pdsi.fracdrt.' map_txt2 '.' num2str(pdsi_thresh) '.' map_txt '.recenter' num2str(recenter) '.drt.eps'])
end

% Save Time Series
if save_figure==1
    save(['./pdsi_series/pdsi.fix.' map_txt2 '.' map_txt '.recenter' num2str(recenter) '.mat'],'frac_drought','ave_pdsi','yr_owda_reg',...
        'lonmin','latmin','lonmax','latmax')
end


if strcmp(map_txt,'ALLMED')==1
    yrs_drt_40 = yr_owda_reg(find(frac_drought>=0.4));
    yrs_drt_50 = yr_owda_reg(find(frac_drought>=0.5));

    save(['yrs_drt_fix_' map_txt2 '.' map_txt '.mat'],'yrs_drt_40','yrs_drt_50','latmin','latmax','lonmin','lonmax');
end


return



% Find Years with widespread drought
yrs_drt_40 = yr_owda_reg(find(frac_drought>=0.4));
yrs_drt_50 = yr_owda_reg(find(frac_drought>=0.5));

save(['yrs_drt_fix_' map_txt '.mat'],'yrs_drt_40','yrs_drt_50','latmin','latmax','lonmin','lonmax');




%% Trim Land Area to the same size
% Trim Land Area
[c,ilon_land,ilon_nada] = intersect(lon_land,lon);
[c,ilat_land,ilat_nada] = intersect(lat_land,lat);

land_nada = land_area(ilat_land,ilon_land);
land_nada(find(land_nada>9e19))=nan;

% Initialize mask. I want to make sure each year has the same missing
% values, since the coverage increases over time.
mask_vals=nan([length(lat) length(lon)]);

trim_lat = find(lat<=latmax & lat>=latmin);
trim_lon = find(lon<=lonmax & lon>=lonmin);

return

% Load each year individually.
for i_yr=1:length(yr_range);
    
    % Index location for current year
    yr_loc=find(yr_vect==yr_range(i_yr));
        
    % Pull out current year
    current_yr(:,:)=nada.owda_region(yr_loc,:,:);
    
    % Mask out missing values -99
    current_yr(find(current_yr<=-99))=nan;
    
    % If this is the first year, then make the mask
    if i_yr==1
       mask_locs=find(isnan(current_yr)==1);  
       
       % Generate land Mask
       land_nada(mask_locs)=nan;
       land_nada = land_nada(trim_lat,trim_lon);
       sum_land = nansum(land_nada(:)); % total land area  
       
    end
    
    % Current land mask
    land_nada_curr = land_nada;
    
    % Now, mask everything
    current_yr(mask_locs)=nan;
        
    % Area Average
    [cosmean,cosgrid,datagrid,new_lon,new_lat] = coswt(current_yr,lat,lon,lonmin,lonmax,latmin,latmax);
    ave_pdsi(i_yr,1) = cosmean;
            
    % Calculate area for threshold
    current_yr = current_yr(trim_lat,trim_lon);
    if drt_thresh==1;
        i_pdsi_mask = find(current_yr>(-1.*pdsi_thresh));
    elseif drt_thresh==0;
        i_pdsi_mask = find(current_yr<(1.*pdsi_thresh));
    end
    
    land_nada_curr(i_pdsi_mask)=nan;
    
    frac_drought(i_yr,1) = nansum(land_nada_curr(:))./sum_land;
        
    clear current_yr
    clear land_nada_curr
end

i_1934 = find(yr_range>=1314 & yr_range<=1317);

%ave_pdsi = detrend(ave_pdsi,'constant')

figure
hold on
plot(yr_range,smooth(ave_pdsi,1),'Color',[0 0 0],'LineWidth',0.5,'LineStyle','-')
plot(yr_range,smooth(ave_pdsi,10,'lowess'),'Color',[0.64 0.07 0.11],...
    'LineWidth',2,'LineStyle','-')
set(gca,'FontSize',18,'FontName','helvetica','FontWeight','bold')
xlim([1100 2012])
%plot(yr_range(i_1934),ave_pdsi(i_1934),'Marker','.','MarkerSize',20,'Color',[0.54 0.33 0.16])
%plot(yr_range(i_1934),ave_pdsi(i_1934),'Marker','.','MarkerSize',20,'Color',[0.09 0.48 0.60],'LineStyle','none')
%ylim([0 1])
line(xlim,[0 0],'Color',[0 0 0],'LineWidth',2,'LineStyle','-')
box on
set(gcf,'OuterPosition',[53         321        1259         468])
%set(gcf,'OuterPosition',[213    40   965   616])
set(gcf,'PaperPositionMode','auto') 
if save_figure==1
    print('-depsc','-painters',['./figures/figure03/ave.pdsi.' map_txt '.drt.eps'])
end

figure
hold on
plot(yr_range,smooth(frac_drought,1),'Color',[0 0 0],'LineWidth',0.5,'LineStyle','-')
plot(yr_range,smooth(frac_drought,10,'lowess'),'Color',[0.64 0.07 0.11],...
    'LineWidth',2,'LineStyle','-')
set(gca,'FontSize',18,'FontName','helvetica','FontWeight','bold')
xlim([1100 2012])
%ylim([0 0.7])
line(xlim,[mean(frac_drought) mean(frac_drought)],'Color',[0 0 0],'LineWidth',2,'LineStyle','-')
box on
set(gcf,'OuterPosition',[53         321        1259         468])
%set(gcf,'OuterPosition',[213    40   965   616])
set(gcf,'PaperPositionMode','auto') 
if save_figure==1
    print('-depsc','-painters',['./figures/figure03/area.pdsi.frac.' num2str(pdsi_thresh) '.' map_txt '.drt.eps'])
end

% Save Time Series
if save_figure==1
    save(['./pdsi_series/pdsi.fix.' map_txt '.mat'],'frac_drought','ave_pdsi','yr_range',...
        'lonmin','latmin','lonmax','latmax')
end

% Find Years with widespread drought
yrs_drt_40 = yr_range(find(frac_drought>=0.4));
yrs_drt_50 = yr_range(find(frac_drought>=0.5));

save(['yrs_drt_fix_' map_txt '.mat'],'yrs_drt_40','yrs_drt_50','latmin','latmax','lonmin','lonmax');


