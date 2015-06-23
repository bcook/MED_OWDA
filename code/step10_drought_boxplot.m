% This script will be used to test whether recent droughts in the WestMED,
% Greece, and Levant time series are exceptional, compared to analogous
% periods in the past.
%
% The basic procedure is as follows. For each region, I will the driest
% period in the record with n yrs, where n is equal to the duration of the
% most recent 20th century drought I have identified. I will do the usual
% basic t-testing and ranksum testing to see if the recent period is drier
% than this earlier driest period. I will then resample (with replacement)
% from these two drought to see the possible effect of sampling
% uncertainties on these calculated drought differences.

% Start Clean
clear all
close all
clc

% New OWDA Version
map_txt2='MED_1'; 

% If =1, save figures
save_figure = 1;

%% Load Data
load(['../data/pdsi.fix.' map_txt2 '.WESTMED.recenter1.mat']);  westmed=ave_pdsi;
load(['../data/pdsi.fix.' map_txt2 '.greece2.recenter1.mat']);  greece=ave_pdsi;
load(['../data/pdsi.fix.' map_txt2 '.levant3.recenter1.mat']);  levant=ave_pdsi;
load(['../data/pdsi.fix.' map_txt2 '.MIDEAST.recenter1.mat']);  mideast=ave_pdsi;

% New Year Vector
yr_range = yr_owda_reg;

% Set some parameters for the figures
mark_size   = 55;
line_width  = 2.5;
line_range  = [0.97 1.03];

%% Levant Analysis
% Set years for this drought, and pull out the associated PDSI values.
drt_recent_years   = [1998:2012];
drt_recent_levant  = levant(find(yr_range>=drt_recent_years(1) & yr_range<=drt_recent_years(end)));

% Now, create Year vector to loop through in order to calculate moving window
% averages of PDSI of the same length as drt_period. These
% windows will NOT overlap at all with drt_period window.
yr1_window = 1100:(drt_recent_years(1)-length(drt_recent_years));

% Loop through and calculate moving window averages.
for i_yr = 1:length(yr1_window)
    
    % Index for years in current window
    i_wind = find(yr_range>=yr1_window(i_yr) & ...
        yr_range<=(yr1_window(i_yr)+length(drt_recent_years)-1));
     
    % Store the years from the current window
    window_yrs(i_yr,:)= [min(yr_range(i_wind)), max(yr_range(i_wind))];
    
    % Calculate Means
    mean_wind_levant(i_yr,1)  = nanmean(levant(i_wind));

    % Calculate Median
    median_wind_levant(i_yr,1)  = nanmedian(levant(i_wind));

end

% Find the Driest Period Before the most recent drought
i_loc_driest  = find(mean_wind_levant==min(mean_wind_levant));
yr1_driest    = window_yrs(i_loc_driest,1);
yr2_driest    = window_yrs(i_loc_driest,2);

% Pull out PDSI data from this dry period.
drt_past_levant = levant(find(yr_range>=yr1_driest & yr_range<=yr2_driest));

% Mean PDSI for these drought periods
mean_drt_recent = mean(drt_recent_levant);
mean_drt_past   = mean(drt_past_levant);

% Conduct a One Sided t-test to see if recent drought is drier
[H,p]=ttest2(drt_past_levant,drt_recent_levant,0.05,'right');

% Now, resample 10,000 times with replacement from each of these droughts,
% and then recalculate the means
for i_res = 1:10000
    
    % Most recent drought resample
    drt_recent_resamp = randsample(drt_recent_levant,length(drt_recent_levant),'true');

    % Past drought resample
    drt_past_resamp = randsample(drt_past_levant,length(drt_past_levant),'true');
    
    % Store the Means for each
    resamp_results(i_res,1) = mean(drt_past_resamp);
    resamp_results(i_res,2) = mean(drt_recent_resamp);
    
end

% Calculate the percentage of Monte-Carlo simulations with drier most
% recent period
pct_sims = length(find(resamp_results(:,2)<resamp_results(:,1)))./i_res;

% Summarize Some Results
disp('-----------------------------')
disp(['Levant Drought, Recent'])
disp(['Time:      ' num2str(drt_recent_years(1)) '-' num2str(drt_recent_years(end))])
disp(['Mean:      ' num2str(mean_drt_recent)])
disp('                             ')
disp('-----------------------------')
disp(['Levant Drought, Past'])
disp(['Time:      ' num2str(yr1_driest) '-' num2str(yr2_driest)])
disp(['Mean:      ' num2str(mean_drt_past)])
disp('                             ')
disp('-----------------------------')
disp(['Student''s t, One Sided:    '])
disp(['p-value =        ' num2str(p)])
disp('                             ')
disp('-----------------------------')
disp('Monte-Carlo Results          ')
disp(['Fraction of simulations where'])
disp(['mean PDSI is drier than the  '])
disp(['previous driest period: ' num2str(pct_sims)])
disp('                             ')
disp('                             ')

% Create Figure. 
% First is boxplot, the IQR for PDSI from all moving window periods.
figure
hold on
x=boxplot(mean_wind_levant,{'Levant'},'boxstyle','filled',...
    'color',[0.7 0.7 0.7],'widths',1);
% Clean Up The 
for i_mod=1:1:size(x,2)
    set(x(1,i_mod),'Visible','off');
    set(x(3,i_mod),'Visible','off');
    set(x(4,i_mod),'Visible','off');
    set(x(2,i_mod),'LineWidth',25);
end
xlim([0.8 1.2]),
ylim([-2 0.5])
line(xlim,[0 0],'Color',[0.5 0.5 0.5],'LineWidth',1,'LineStyle','--')
set(gca,'FontSize',24,'FontName','helvetica',...
    'XTick',[1],'XTickLabel',{'Levant'})
set(gcf,'OuterPosition',[892   878   490   505])

% Now plot the previous dry period, including whiskers representing the IQR
% from all 10,000 means calculated from the resampling
p=line(line_range,[prctile(resamp_results(:,1),75) prctile(resamp_results(:,1),75)],...
         'Marker','none','LineStyle','-','LineWidth',line_width,'Color',[0.7 0.7 0.7]);
p=line(line_range,[prctile(resamp_results(:,1),25) prctile(resamp_results(:,1),25)],...
         'Marker','none','LineStyle','-','LineWidth',line_width,'Color',[0.7 0.7 0.7]);
p=line([1 1],[prctile(resamp_results(:,1),25) prctile(resamp_results(:,1),75)],...
         'Marker','none','LineStyle','-','LineWidth',line_width,'Color',[0.7 0.7 0.7]);
% Plot mean PDSI for this past drought event 
p=plot(1,mean(mean_drt_past),'Marker','.','MarkerSize',mark_size,'Color',[0.7 0.7 0.7]);

% Now plot the most recent dry period, including whiskers representing the IQR
% from all 10,000 means calculated from the resampling
p=line(line_range,[prctile(resamp_results(:,2),75) prctile(resamp_results(:,2),75)],...
         'Marker','none','LineStyle','-','LineWidth',line_width,'Color',[0 0 0]);
p=line(line_range,[prctile(resamp_results(:,2),25) prctile(resamp_results(:,2),25)],...
         'Marker','none','LineStyle','-','LineWidth',line_width,'Color',[0 0 0]);
p=line([1 1],[prctile(resamp_results(:,2),25) prctile(resamp_results(:,2),75)],...
         'Marker','none','LineStyle','-','LineWidth',line_width,'Color',[0 0 0]);
% Plot mean PDSI for most recent drought 
p=plot(1,mean_drt_recent,'Marker','.','MarkerSize',mark_size,'Color',[0 0 0]);
titlestring=['Levant (' num2str(drt_recent_years(1)) '-' num2str(drt_recent_years(end)) ...
    ' vs ' num2str(yr1_driest) '-' num2str(yr2_driest) ')'];
title(['\fontname{helvetica} \fontsize{24} \bf{' titlestring '}']);
set(gcf,'PaperPositionMode','auto') 
if save_figure==1
   print('-depsc','-painters',['../figures/fig12/boxplot.levant.' map_txt2 ...
       '.' num2str(drt_recent_years(1)) '-' num2str(drt_recent_years(end)) '.eps'])
end

clear resamp_results

%% Greece Analysis
% Set years for this drought, and pull out the associated PDSI values.
drt_recent_years   = [1984:2002];
drt_recent_greece  = greece(find(yr_range>=drt_recent_years(1) & yr_range<=drt_recent_years(end)));

% Now, create Year vector to loop through in order to calculate moving window
% averages of PDSI of the same length as drt_period. These
% windows will NOT overlap at all with drt_period window.
yr1_window = 1100:(drt_recent_years(1)-length(drt_recent_years));

% Loop through and calculate moving window averages.
for i_yr = 1:length(yr1_window)
    
    % Index for years in current window
    i_wind = find(yr_range>=yr1_window(i_yr) & ...
        yr_range<=(yr1_window(i_yr)+length(drt_recent_years)-1));
     
    % Store the years from the current window
    window_yrs(i_yr,:)= [min(yr_range(i_wind)), max(yr_range(i_wind))];
    
    % Calculate Means
    mean_wind_greece(i_yr,1)  = nanmean(greece(i_wind));

    % Calculate Median
    median_wind_greece(i_yr,1)  = nanmedian(greece(i_wind));

end

% Find the Driest Period Before the most recent drought
i_loc_driest  = find(mean_wind_greece==min(mean_wind_greece));
yr1_driest    = window_yrs(i_loc_driest,1);
yr2_driest    = window_yrs(i_loc_driest,2);

% Pull out PDSI data from this dry period.
drt_past_greece = greece(find(yr_range>=yr1_driest & yr_range<=yr2_driest));

% Mean PDSI for these drought periods
mean_drt_recent = mean(drt_recent_greece);
mean_drt_past   = mean(drt_past_greece);

% Conduct a One Sided t-test to see if recent drought is drier
[H,p]=ttest2(drt_past_greece,drt_recent_greece,0.05,'right');

% Now, resample 10,000 times with replacement from each of these droughts,
% and then recalculate the means
for i_res = 1:10000
    
    % Most recent drought resample
    drt_recent_resamp = randsample(drt_recent_greece,length(drt_recent_greece),'true');

    % Past drought resample
    drt_past_resamp = randsample(drt_past_greece,length(drt_past_greece),'true');
    
    % Store the Means for each
    resamp_results(i_res,1) = mean(drt_past_resamp);
    resamp_results(i_res,2) = mean(drt_recent_resamp);
    
end

% Calculate the percentage of Monte-Carlo simulations with drier most
% recent period
pct_sims = length(find(resamp_results(:,2)<resamp_results(:,1)))./i_res;

% Summarize Some Results
disp('-----------------------------')
disp(['Greece Drought, Recent'])
disp(['Time:      ' num2str(drt_recent_years(1)) '-' num2str(drt_recent_years(end))])
disp(['Mean:      ' num2str(mean_drt_recent)])
disp('                             ')
disp('-----------------------------')
disp(['Greece Drought, Past'])
disp(['Time:      ' num2str(yr1_driest) '-' num2str(yr2_driest)])
disp(['Mean:      ' num2str(mean_drt_past)])
disp('                             ')
disp('-----------------------------')
disp(['Student''s t, One Sided:    '])
disp(['p-value =        ' num2str(p)])
disp('                             ')
disp('-----------------------------')
disp('Monte-Carlo Results          ')
disp(['Fraction of simulations where'])
disp(['mean PDSI is drier than the  '])
disp(['previous driest period: ' num2str(pct_sims)])
disp('                             ')
disp('                             ')

% Create Figure. 
% First is boxplot, the IQR for PDSI from all moving window periods.
figure
hold on
x=boxplot(mean_wind_greece,{'Greece'},'boxstyle','filled',...
    'color',[0.7 0.7 0.7],'widths',1);
% Clean Up The 
for i_mod=1:1:size(x,2)
    set(x(1,i_mod),'Visible','off');
    set(x(3,i_mod),'Visible','off');
    set(x(4,i_mod),'Visible','off');
    set(x(2,i_mod),'LineWidth',25);
end
xlim([0.8 1.2]),
ylim([-2 0.5])
line(xlim,[0 0],'Color',[0.5 0.5 0.5],'LineWidth',1,'LineStyle','--')
set(gca,'FontSize',24,'FontName','helvetica',...
    'XTick',[1],'XTickLabel',{'Greece'})
set(gcf,'OuterPosition',[892   878   490   505])

% Now plot the previous dry period, including whiskers representing the IQR
% from all 10,000 means calculated from the resampling
p=line(line_range,[prctile(resamp_results(:,1),75) prctile(resamp_results(:,1),75)],...
         'Marker','none','LineStyle','-','LineWidth',line_width,'Color',[0.7 0.7 0.7]);
p=line(line_range,[prctile(resamp_results(:,1),25) prctile(resamp_results(:,1),25)],...
         'Marker','none','LineStyle','-','LineWidth',line_width,'Color',[0.7 0.7 0.7]);
p=line([1 1],[prctile(resamp_results(:,1),25) prctile(resamp_results(:,1),75)],...
         'Marker','none','LineStyle','-','LineWidth',line_width,'Color',[0.7 0.7 0.7]);
% Plot mean PDSI for this past drought event 
p=plot(1,mean(mean_drt_past),'Marker','.','MarkerSize',mark_size,'Color',[0.7 0.7 0.7]);

% Now plot the most recent dry period, including whiskers representing the IQR
% from all 10,000 means calculated from the resampling
p=line(line_range,[prctile(resamp_results(:,2),75) prctile(resamp_results(:,2),75)],...
         'Marker','none','LineStyle','-','LineWidth',line_width,'Color',[0 0 0]);
p=line(line_range,[prctile(resamp_results(:,2),25) prctile(resamp_results(:,2),25)],...
         'Marker','none','LineStyle','-','LineWidth',line_width,'Color',[0 0 0]);
p=line([1 1],[prctile(resamp_results(:,2),25) prctile(resamp_results(:,2),75)],...
         'Marker','none','LineStyle','-','LineWidth',line_width,'Color',[0 0 0]);
% Plot mean PDSI for most recent drought 
p=plot(1,mean_drt_recent,'Marker','.','MarkerSize',mark_size,'Color',[0 0 0]);
titlestring=['Greece (' num2str(drt_recent_years(1)) '-' num2str(drt_recent_years(end)) ...
    ' vs ' num2str(yr1_driest) '-' num2str(yr2_driest) ')'];
title(['\fontname{helvetica} \fontsize{24} \bf{' titlestring '}']);
set(gcf,'PaperPositionMode','auto') 
if save_figure==1
   print('-depsc','-painters',['../figures/fig12/boxplot.greece.' map_txt2 ...
       '.' num2str(drt_recent_years(1)) '-' num2str(drt_recent_years(end)) '.eps'])
end

clear resamp_results

%% WestMED Analysis
% Set years for this drought, and pull out the associated PDSI values.
drt_recent_years   = [1980:2009];
drt_recent_westmed  = westmed(find(yr_range>=drt_recent_years(1) & yr_range<=drt_recent_years(end)));

% Now, create Year vector to loop through in order to calculate moving window
% averages of PDSI of the same length as drt_period. These
% windows will NOT overlap at all with drt_period window.
yr1_window = 1100:(drt_recent_years(1)-length(drt_recent_years));

% Loop through and calculate moving window averages.
for i_yr = 1:length(yr1_window)
    
    % Index for years in current window
    i_wind = find(yr_range>=yr1_window(i_yr) & ...
        yr_range<=(yr1_window(i_yr)+length(drt_recent_years)-1));
     
    % Store the years from the current window
    window_yrs(i_yr,:)= [min(yr_range(i_wind)), max(yr_range(i_wind))];
    
    % Calculate Means
    mean_wind_westmed(i_yr,1)  = nanmean(westmed(i_wind));

    % Calculate Median
    median_wind_westmed(i_yr,1)  = nanmedian(westmed(i_wind));

end

% Find the Driest Period Before the most recent drought
i_loc_driest  = find(mean_wind_westmed==min(mean_wind_westmed));
yr1_driest    = window_yrs(i_loc_driest,1);
yr2_driest    = window_yrs(i_loc_driest,2);

% Pull out PDSI data from this dry period.
drt_past_westmed = westmed(find(yr_range>=yr1_driest & yr_range<=yr2_driest));

% Mean PDSI for these drought periods
mean_drt_recent = mean(drt_recent_westmed);
mean_drt_past   = mean(drt_past_westmed);

% Conduct a One Sided t-test to see if recent drought is drier
[H,p]=ttest2(drt_past_westmed,drt_recent_westmed,0.05,'right');

% Now, resample 10,000 times with replacement from each of these droughts,
% and then recalculate the means
for i_res = 1:10000
    
    % Most recent drought resample
    drt_recent_resamp = randsample(drt_recent_westmed,length(drt_recent_westmed),'true');

    % Past drought resample
    drt_past_resamp = randsample(drt_past_westmed,length(drt_past_westmed),'true');
    
    % Store the Means for each
    resamp_results(i_res,1) = mean(drt_past_resamp);
    resamp_results(i_res,2) = mean(drt_recent_resamp);
    
end

% Calculate the percentage of Monte-Carlo simulations with drier most
% recent period
pct_sims = length(find(resamp_results(:,2)<resamp_results(:,1)))./i_res;

% Summarize Some Results
disp('-----------------------------')
disp(['Westmed Drought, Recent'])
disp(['Time:      ' num2str(drt_recent_years(1)) '-' num2str(drt_recent_years(end))])
disp(['Mean:      ' num2str(mean_drt_recent)])
disp('                             ')
disp('-----------------------------')
disp(['Westmed Drought, Past'])
disp(['Time:      ' num2str(yr1_driest) '-' num2str(yr2_driest)])
disp(['Mean:      ' num2str(mean_drt_past)])
disp('                             ')
disp('-----------------------------')
disp(['Student''s t, One Sided:    '])
disp(['p-value =        ' num2str(p)])
disp('                             ')
disp('-----------------------------')
disp('Monte-Carlo Results          ')
disp(['Fraction of simulations where'])
disp(['mean PDSI is drier than the  '])
disp(['previous driest period: ' num2str(pct_sims)])
disp('                             ')
disp('                             ')

% Create Figure. 
% First is boxplot, the IQR for PDSI from all moving window periods.
figure
hold on
x=boxplot(mean_wind_westmed,{'Westmed'},'boxstyle','filled',...
    'color',[0.7 0.7 0.7],'widths',1);
% Clean Up The 
for i_mod=1:1:size(x,2)
    set(x(1,i_mod),'Visible','off');
    set(x(3,i_mod),'Visible','off');
    set(x(4,i_mod),'Visible','off');
    set(x(2,i_mod),'LineWidth',25);
end
xlim([0.8 1.2]),
ylim([-2 0.5])
line(xlim,[0 0],'Color',[0.5 0.5 0.5],'LineWidth',1,'LineStyle','--')
set(gca,'FontSize',24,'FontName','helvetica',...
    'XTick',[1],'XTickLabel',{'Westmed'})
set(gcf,'OuterPosition',[892   878   490   505])

% Now plot the previous dry period, including whiskers representing the IQR
% from all 10,000 means calculated from the resampling
p=line(line_range,[prctile(resamp_results(:,1),75) prctile(resamp_results(:,1),75)],...
         'Marker','none','LineStyle','-','LineWidth',line_width,'Color',[0.7 0.7 0.7]);
p=line(line_range,[prctile(resamp_results(:,1),25) prctile(resamp_results(:,1),25)],...
         'Marker','none','LineStyle','-','LineWidth',line_width,'Color',[0.7 0.7 0.7]);
p=line([1 1],[prctile(resamp_results(:,1),25) prctile(resamp_results(:,1),75)],...
         'Marker','none','LineStyle','-','LineWidth',line_width,'Color',[0.7 0.7 0.7]);
% Plot mean PDSI for this past drought event 
p=plot(1,mean(mean_drt_past),'Marker','.','MarkerSize',mark_size,'Color',[0.7 0.7 0.7]);

% Now plot the most recent dry period, including whiskers representing the IQR
% from all 10,000 means calculated from the resampling
p=line(line_range,[prctile(resamp_results(:,2),75) prctile(resamp_results(:,2),75)],...
         'Marker','none','LineStyle','-','LineWidth',line_width,'Color',[0 0 0]);
p=line(line_range,[prctile(resamp_results(:,2),25) prctile(resamp_results(:,2),25)],...
         'Marker','none','LineStyle','-','LineWidth',line_width,'Color',[0 0 0]);
p=line([1 1],[prctile(resamp_results(:,2),25) prctile(resamp_results(:,2),75)],...
         'Marker','none','LineStyle','-','LineWidth',line_width,'Color',[0 0 0]);
% Plot mean PDSI for most recent drought 
p=plot(1,mean_drt_recent,'Marker','.','MarkerSize',mark_size,'Color',[0 0 0]);
titlestring=['Westmed (' num2str(drt_recent_years(1)) '-' num2str(drt_recent_years(end)) ...
    ' vs ' num2str(yr1_driest) '-' num2str(yr2_driest) ')'];
title(['\fontname{helvetica} \fontsize{24} \bf{' titlestring '}']);
set(gcf,'PaperPositionMode','auto') 
if save_figure==1
   print('-depsc','-painters',['../figures/fig12/boxplot.westmed.' map_txt2 ...
       '.' num2str(drt_recent_years(1)) '-' num2str(drt_recent_years(end)) '.eps'])
end

clear resamp_results

%% MIDEAST Analysis
% Set years for this drought, and pull out the associated PDSI values.
drt_recent_years   = [1994:2012];
drt_recent_mideast  = mideast(find(yr_range>=drt_recent_years(1) & yr_range<=drt_recent_years(end)));

% Now, create Year vector to loop through in order to calculate moving window
% averages of PDSI of the same length as drt_period. These
% windows will NOT overlap at all with drt_period window.
yr1_window = 1100:(drt_recent_years(1)-length(drt_recent_years));

% Loop through and calculate moving window averages.
for i_yr = 1:length(yr1_window)
    
    % Index for years in current window
    i_wind = find(yr_range>=yr1_window(i_yr) & ...
        yr_range<=(yr1_window(i_yr)+length(drt_recent_years)-1));
     
    % Store the years from the current window
    window_yrs(i_yr,:)= [min(yr_range(i_wind)), max(yr_range(i_wind))];
    
    % Calculate Means
    mean_wind_mideast(i_yr,1)  = nanmean(mideast(i_wind));

    % Calculate Median
    median_wind_mideast(i_yr,1)  = nanmedian(mideast(i_wind));

end

% Find the Driest Period Before the most recent drought
i_loc_driest  = find(mean_wind_mideast==min(mean_wind_mideast));
yr1_driest    = window_yrs(i_loc_driest,1);
yr2_driest    = window_yrs(i_loc_driest,2);

% Pull out PDSI data from this dry period.
drt_past_mideast = mideast(find(yr_range>=yr1_driest & yr_range<=yr2_driest));

% Mean PDSI for these drought periods
mean_drt_recent = mean(drt_recent_mideast);
mean_drt_past   = mean(drt_past_mideast);

% Conduct a One Sided t-test to see if recent drought is drier
[H,p]=ttest2(drt_past_mideast,drt_recent_mideast,0.05,'right');

% Now, resample 10,000 times with replacement from each of these droughts,
% and then recalculate the means
for i_res = 1:10000
    
    % Most recent drought resample
    drt_recent_resamp = randsample(drt_recent_mideast,length(drt_recent_mideast),'true');

    % Past drought resample
    drt_past_resamp = randsample(drt_past_mideast,length(drt_past_mideast),'true');
    
    % Store the Means for each
    resamp_results(i_res,1) = mean(drt_past_resamp);
    resamp_results(i_res,2) = mean(drt_recent_resamp);
    
end

% Calculate the percentage of Monte-Carlo simulations with drier most
% recent period
pct_sims = length(find(resamp_results(:,2)<resamp_results(:,1)))./i_res;

% Summarize Some Results
disp('-----------------------------')
disp(['Mideast Drought, Recent'])
disp(['Time:      ' num2str(drt_recent_years(1)) '-' num2str(drt_recent_years(end))])
disp(['Mean:      ' num2str(mean_drt_recent)])
disp('                             ')
disp('-----------------------------')
disp(['Mideast Drought, Past'])
disp(['Time:      ' num2str(yr1_driest) '-' num2str(yr2_driest)])
disp(['Mean:      ' num2str(mean_drt_past)])
disp('                             ')
disp('-----------------------------')
disp(['Student''s t, One Sided:    '])
disp(['p-value =        ' num2str(p)])
disp('                             ')
disp('-----------------------------')
disp('Monte-Carlo Results          ')
disp(['Fraction of simulations where'])
disp(['mean PDSI is drier than the  '])
disp(['previous driest period: ' num2str(pct_sims)])
disp('                             ')
disp('                             ')

% Create Figure. 
% First is boxplot, the IQR for PDSI from all moving window periods.
figure
hold on
x=boxplot(mean_wind_mideast,{'Mideast'},'boxstyle','filled',...
    'color',[0.7 0.7 0.7],'widths',1);
% Clean Up The 
for i_mod=1:1:size(x,2)
    set(x(1,i_mod),'Visible','off');
    set(x(3,i_mod),'Visible','off');
    set(x(4,i_mod),'Visible','off');
    set(x(2,i_mod),'LineWidth',25);
end
xlim([0.8 1.2]),
ylim([-2 0.5])
line(xlim,[0 0],'Color',[0.5 0.5 0.5],'LineWidth',1,'LineStyle','--')
set(gca,'FontSize',24,'FontName','helvetica',...
    'XTick',[1],'XTickLabel',{'Mideast'})
set(gcf,'OuterPosition',[892   878   490   505])

% Now plot the previous dry period, including whiskers representing the IQR
% from all 10,000 means calculated from the resampling
p=line(line_range,[prctile(resamp_results(:,1),75) prctile(resamp_results(:,1),75)],...
         'Marker','none','LineStyle','-','LineWidth',line_width,'Color',[0.7 0.7 0.7]);
p=line(line_range,[prctile(resamp_results(:,1),25) prctile(resamp_results(:,1),25)],...
         'Marker','none','LineStyle','-','LineWidth',line_width,'Color',[0.7 0.7 0.7]);
p=line([1 1],[prctile(resamp_results(:,1),25) prctile(resamp_results(:,1),75)],...
         'Marker','none','LineStyle','-','LineWidth',line_width,'Color',[0.7 0.7 0.7]);
% Plot mean PDSI for this past drought event 
p=plot(1,mean(mean_drt_past),'Marker','.','MarkerSize',mark_size,'Color',[0.7 0.7 0.7]);

% Now plot the most recent dry period, including whiskers representing the IQR
% from all 10,000 means calculated from the resampling
p=line(line_range,[prctile(resamp_results(:,2),75) prctile(resamp_results(:,2),75)],...
         'Marker','none','LineStyle','-','LineWidth',line_width,'Color',[0 0 0]);
p=line(line_range,[prctile(resamp_results(:,2),25) prctile(resamp_results(:,2),25)],...
         'Marker','none','LineStyle','-','LineWidth',line_width,'Color',[0 0 0]);
p=line([1 1],[prctile(resamp_results(:,2),25) prctile(resamp_results(:,2),75)],...
         'Marker','none','LineStyle','-','LineWidth',line_width,'Color',[0 0 0]);
% Plot mean PDSI for most recent drought 
p=plot(1,mean_drt_recent,'Marker','.','MarkerSize',mark_size,'Color',[0 0 0]);
titlestring=['Mideast (' num2str(drt_recent_years(1)) '-' num2str(drt_recent_years(end)) ...
    ' vs ' num2str(yr1_driest) '-' num2str(yr2_driest) ')'];
title(['\fontname{helvetica} \fontsize{24} \bf{' titlestring '}']);
set(gcf,'PaperPositionMode','auto') 
if save_figure==1
   print('-depsc','-painters',['../figures/fig12/boxplot.mideast.' map_txt2 ...
       '.' num2str(drt_recent_years(1)) '-' num2str(drt_recent_years(end)) '.eps'])
end

clear resamp_results










