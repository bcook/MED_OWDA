% This script will perform a cross wavelet analysis between the WestMED and
% EastMED time series.

% Start Clean
clear all
close all
clc

% If =1, save these figures
save_figure = 1;

%% Load the time series.
load ../data/pdsi.fix.MED_1.WESTMED.recenter1.mat; westmed=ave_pdsi;
load ../data/pdsi.fix.MED_1.EASTMED.recenter1.mat; eastmed=ave_pdsi;

dipole = wco([yr_owda_reg' westmed],[yr_owda_reg' eastmed],1,6,10,2*pi,0.5,1.5,0,0.95,0.90,0,-999,-999,0,1,1,'',0,1,2,'',3)


return

% optional input (has to appear in the right order, set -1 to obtain default):
%     s0(=1):          lowest calculated scale in units of the time series
%     noctave(=5):     number of octaves
%     nvoice(=10):     number of voices per octave
%     w0=(2*pi):       time/frequency resolution omega_0, parameter of Morlet Wavelet
%     sw(=0.5):        length of smoothing window in scale direction is 2*sw*nvoice+1
%     tw(=1.5):        length of smoothing window in time direction is 2*s*tw+1
%     swabs(=0)        length of smoothing window in scale direction at scale s is 2*swabs+1
%     siglevel(=0.95): vector of significance levels for pointwise test, e.g. [0.9 0.95], default 0.95.
%     arealsiglevel(=0.9): significance level of the areawise test; 
%                      currently only for siglevel=0.95 and for arealsiglevel=0.9 possible, 
%                      i.e. 90 percent of the area of false positive patches is sorted out
%     kernel(=0):      bitmap of the reproducing kernel; 
%                      if not provided, it will be calculated during the areawise test
%     markt(=-999):    vector of times to be marked by vertical dotted lines; when set to -999 (default), no lines are plotted.
%     marks(=-999):    vector of scales to be marked by horizontal dotted lines; when set to -999 (default), no lines are plotted.
%     sqr(=false):     if true, the squared coherency is given.
%     phase(=true):    true when phase calculation desired
%     plotvar(=true):  true when graphical output desired
%     units(=''):      character string giving units of the data sets.
%     split(=false):  when true, modulus and phase are splitted in two graphs.
%     color(=true):   true (default): color plot, false: gray scale
%     labsc(=1):      scale of labels, default: 1, for two-column manuscripts: 1.5, for presentations: >2
%     labtext(=''):   puts a label in upper left corner of the plot
%     sigplot(=3):    0: no significance test plotted, 1: results from pointwise test, 2: results from areawise test, 3: results from both tests

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

%colormap((cmap))

%myColormap = whitecoolwarm;
%myColormap(end-1:end,:) = [];
%colormap((myColormap))

return



%% Time series plot
%  Here, I am going to plot up both these time series on the same figure
%  for just a quick eyeball comparison. 

% Smooth the data to make it easier to compare. I use a 10-year lowess
% spline.
smooth_level=10;

% Create the figure
figure
hold on
plot(yr_owda_reg,smooth(westmed,smooth_level,'lowess'),'Color',[0.64 0.07 0.11],...
    'LineWidth',2,'LineStyle','-')
plot(yr_owda_reg,smooth(eastmed,smooth_level,'lowess'),'Color',[0 0 0],...
    'LineWidth',2,'LineStyle','-')
%set(gca,'FontSize',18,'FontName','helvetica','FontWeight','bold')
set(gca,'FontSize',24,'FontName','helvetica')
xlim([1100 2012])
%plot(yr_range(i_1934),ave_pdsi(i_1934),'Marker','.','MarkerSize',20,'Color',[0.54 0.33 0.16])
%plot(yr_range(i_1934),ave_pdsi(i_1934),'Marker','.','MarkerSize',20,'Color',[0.09 0.48 0.60],'LineStyle','none')
%ylim([0 1])
line(xlim,[0 0],'Color',[0 0 0],'LineWidth',2,'LineStyle','-')
box on
legend('West','East')
set(gcf,'OuterPosition',[53         321        1259         468])
%set(gcf,'OuterPosition',[213    40   965   616])
set(gcf,'PaperPositionMode','auto') 
if save_figure==1
    print('-depsc','-painters',['../figures/fig09/pdsi.seasaw.time.eps'])
end

%% MTM Spectra
%   Here, I calculate the MTM spectra for each time series. For
%   significance, I generate 10,000 red noise (lag one) time series), and
%   calculate the 90th and 95th confidence limits.

% East Med-----------------------------------------------------------------

% Calculate spectra (3 tapers)
[pxx_pc,pxx95,f_pc,nxx] = quickmtm(detrend(eastmed),3,0,0,0);

% Monte-carlo for significance (red noise null hypothesis, lag one)
[rho, wnoise_var, p_val] = lagone(detrend(eastmed)); % parameters for ar model

for i_mc = 1:10000
    
    % Generate synthetic time series
    [ar1] = arseries(rho, wnoise_var, length(eastmed)); % red noise
    
    % Calculate MTM spectra
    [pxx_mc(i_mc,:),pxx95,f_mc(i_mc,:),nxx] = quickmtm(ar1,3,0,0,0);

end

% 95th percentile
mtm_95 = prctile(pxx_mc,95);
mtm_90 = prctile(pxx_mc,90);

% Create EastMED Figure
figure
hold on
plot(f_pc,pxx_pc,'Color',[0 0 0],'LineWidth',1,'LineStyle','-')
plot(f_pc,mtm_95,'Color',[0.64 0.07 0.11],...
    'LineWidth',1,'LineStyle','--')
plot(f_pc,mtm_90,'Color',[0 0 0],...
    'LineWidth',1,'LineStyle','--')
set(gca,'FontSize',24,'FontName','helvetica')
xlim([f_pc(2) f_pc(end-1)])
line(xlim,[0 0],'Color',[0 0 0],'LineWidth',2,'LineStyle','-')
box on
set(gca,'xscale','log')
set(gcf,'OuterPosition',[377   353   669   518])
set(gcf,'PaperPositionMode','auto') 
if save_figure==1
    print('-depsc','-painters',['../figures/fig08/mtm_spectra_eastmed.eps'])
end

% Clear Monte-Carlo Results
clear pxx_mc

% WEST MED-----------------------------------------------------------------
% Calculate spectra (3 tapers
[pxx_pc,pxx95,f_pc,nxx] = quickmtm(detrend(westmed),3,0,0,0);

% Monte-carlo for significance (red noise null hypothesis, lag one)
[rho, wnoise_var, p_val] = lagone(detrend(westmed)); % parameters for ar model

for i_mc = 1:10000
    
    % Generate synthetic time series
    [ar1] = arseries(rho, wnoise_var, length(westmed)); % red noise
    
    % Calculate MTM spectra
    [pxx_mc(i_mc,:),pxx95,f_mc(i_mc,:),nxx] = quickmtm(ar1,3,0,0,0);

end

% 95th percentile
mtm_95 = prctile(pxx_mc,95);
mtm_90 = prctile(pxx_mc,90);

% Create WestMED Figure
figure
hold on
plot(f_pc,pxx_pc,'Color',[0 0 0],'LineWidth',1,'LineStyle','-')
plot(f_pc,mtm_95,'Color',[0.64 0.07 0.11],...
    'LineWidth',1,'LineStyle','--')
plot(f_pc,mtm_90,'Color',[0 0 0],...
    'LineWidth',1,'LineStyle','--')
set(gca,'FontSize',24,'FontName','helvetica')
xlim([f_pc(2) f_pc(end-1)])
line(xlim,[0 0],'Color',[0 0 0],'LineWidth',2,'LineStyle','-')
box on
set(gca,'xscale','log')
set(gcf,'OuterPosition',[377   353   669   518])
set(gcf,'PaperPositionMode','auto') 
if save_figure==1
    print('-depsc','-painters',['../figures/fig08/mtm_spectra_westmed.eps'])
end

% Clear Monte-Carlo Results
clear pxx_mc

%% Calculate and plot up the Coherency Spectra
% Ten gives me an approximate centennial scale bandwidth
figure
[s, c, ph, ci, phi, phu] = cmtm(detrend(eastmed),detrend(westmed),1,10,1,100,1);

% Create figure
figure
hold on
plot(s,c,'Color',[0 0 0],'LineWidth',1.25,'LineStyle','-')
plot(s,ci,'Color',[0.5 0.5 0.5],'LineWidth',0.75,'LineStyle','--')
xlim([0.003286 0.5])
box on
set(gca,'FontSize',24,'FontName','helvetica')
set(gca,'xscale','log')
set(gcf,'OuterPosition',[53         321        1259         468])
set(gcf,'PaperPositionMode','auto') 
if save_figure==1
    print('-depsc','-painters',['../figures/fig09/coherence.seasaw.time.eps'])
end











