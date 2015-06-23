clear; close all; clc;

data = textread('China_North-South_Dipole.txt','','headerlines',4);

year = data(:,1);
ncpz = data(:,6);
jnaz = data(:,7);

rminus = data(:,8);
rplus = data(:,9);

%addpath('/Users/kja/matlab/toolbox/contrib/crosswavelet/')
%addpath('/Users/kja/matlab/toolbox/contrib/sowas_wavelet')

% WTC syntax
% [Rsq,period,scale,coi,sig95] = wtc([year ncpz],[year jnaz])

%% WCO syntax
% wco(ts1,ts2,s0,noctave,nvoice,w0,sw,tw,swabs,siglevel,arealsiglevel,kerne
% l,markt,marks,sqr,phase,plotvar,units,device,file,split,color,pwidth,phei
% ght,labsc,labtext,sigplot)

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
 
dipole = wco([year ncpz],[year jnaz],1,6,10,2*pi,0.5,1.5,0,0.95,0.90,0,-999,-999,0,1,1,'',0,1,2,'',3)

myColormap = whitecoolwarm;
myColormap(end-1:end,:) = [];
colormap((myColormap))
%printeps('dipolewco.eps',1)

%% 
set(0, 'DefaultAxesFontName', 'Helvetica','DefaultAxesFontWeight','bold')
set(0, 'DefaultTextFontName', 'Helvetica','DefaultTextFontWeight','bold')  
set(0,'defaultaxesfontsize',12); set(0,'defaulttextfontsize',12);

return

myColormap = [...
103,0,31
178,24,43
214,96,77
244,165,130
253,219,199
247,247,247
209,229,240
146,197,222
67,147,195
33,102,172
5,48,97]./255;

myColormap = interp1(1:max(size(myColormap)),myColormap,1:(1/3):max(length(myColormap)));

load madav2_32ensemble_avg_anomalies.mat
jja = pdsi
jja.pdsi = jja.anomalies;

clip = find(jja.year==800);
jja.pdsi = jja.pdsi(clip:end,:,:);
jja.year = jja.year(clip:end);

   [correlationMap,~,commonTime,] = fieldCorrelation(jja.pdsi,jja.lat,jja.lon,rminus,jja.year,year)
   
figure(2); clf;
set(gcf,'units','normalized','position',[0.3049    0.4633    0.6035    0.4233])

% corners
vlon1 = 105;
vlon2 = 122.5;
vlat1 = 35;
vlat2 = 40;

zlon1 = 105;
zlon2 = 122.5;
zlat1 = 25;
zlat2 = 30;

% plot the rectangle

subplot(1,2,1)
m_proj('Mollweide','lat',[-10 55],'lon',[60 150])
% [cs,h] = m_contourf(jja.lon,jja.lat,squeeze(correlationMap),[-1:0.2:1]); set(h,'edgecolor','none');
m_pcolor2(jja.lon,jja.lat,squeeze(correlationMap)); shading flat; hold on;
m_coast('color','k','linewidth',1.05)
m_line([vlon1 vlon2; vlon1 vlon2; vlon1 vlon1; vlon2 vlon2]',[vlat1 vlat1; vlat2 vlat2; vlat1 vlat2; vlat1 vlat2]','Color','k','LineWidth',1.5)
m_line([zlon1 zlon2; zlon1 zlon2; zlon1 zlon1; zlon2 zlon2]',[zlat1 zlat1; zlat2 zlat2; zlat1 zlat2; zlat1 zlat2]','Color','k','LineWidth',1.5)

m_grid('xtick',[70 90 110 130 150],'xticklabels',[],'ytick',[0 15 30 45],'xaxislocation','bottom','yaxislocation','left')
% m_grid('xtick',[],'ytick',[])
m_cleancontourf
title('NCP-JNA')
% drawPoliticalAsia;
colormap(flipud(myColormap))
shading flat
caxis([-1 1])
cb(1) = colorbar('horiz','location','south') %('peer',HH)

[correlationMap,~,commonTime] = fieldCorrelation(jja.pdsi,jja.lat,jja.lon,rplus,jja.year,year)

subplot(1,2,2)

% corners
vlon1 = 105;
vlon2 = 122.5;
vlat1 = 25;
vlat2 = 30;


m_proj('Mollweide','lat',[-10 55],'lon',[60 150])
% [cs,h] = m_contourf(jja.lon,jja.lat,squeeze(correlationMap),[-1:0.2:1]); set(h,'edgecolor','none');
m_pcolor2(jja.lon,jja.lat,squeeze(correlationMap)); shading flat; hold on;
m_coast('color','k','linewidth',1.05)
% m_line([vlon1 vlon2; vlon1 vlon2; vlon1 vlon1; vlon2 vlon2]',[vlat1 vlat1; vlat2 vlat2; vlat1 vlat2; vlat1 vlat2]','Color','k','LineWidth',1.5)
m_grid('xtick',[70 90 110 130 150],'xticklabels',[],'ytick',[0 15 30 45],'xaxislocation','bottom','yaxislocation','right')
% m_grid('xtick',[],'ytick',[])
m_cleancontourf
% drawPoliticalAsia;
colormap(flipud(myColormap))
shading flat
caxis([-1 1])
title('NCP+JNA')

cb(2) = colorbar('horiz','location','south') %('peer',HH)

set(cb([2]),'visible','off');

cp = [0.42 0.05 0.20 0.04];
set(cb(1),'position',cp);

packcols(1,2)

printeps('dipoilecorrpm.eps',2)


