
[~, userName] = system('whoami');
userName = strtrim(userName);
dropboxBaseDir = ...
    fullfile('/Users', userName,'Dropbox (Aguirre-Brainard Lab)');
dataDir = fullfile(dropboxBaseDir,'CGRP_data','Analysis of Light Dark Box Data');
filePath = fullfile(dataDir,'Compiled WT_PreTx_5-100Intensity_02.09.2023.csv');

opts = detectImportOptions(filePath);

T = readtable(filePath,opts);

% Each animal is in a column. The animal is identified by an ID, for which
% the integer part of the ID is the light level (% itensity), and the
% decimal portion is the unique ID. Starting on the 3rd row we have time in
% minutes (5:5:60)
lightLevels = [100, 50, 25, 15, 5];
nLevels = length(lightLevels);
timePoints = 5:5:60;
nPoints = length(timePoints);

meanVals = nan(nPoints,nLevels);
semVals = nan(nPoints,nLevels);
nVals = nan(nPoints,nLevels);

% Load up the data and gets means and SEMs
for ll = 1:nLevels
    for tt = 1:nPoints
        colIdx = find(floor(T{2,2:end}) == lightLevels(ll));
        vals = T{tt+2,colIdx+1};
        nVals(tt,ll) = length(vals);
        meanVals(tt,ll) = mean(vals);
        semVals(tt,ll) = std(vals)/sqrt(nVals(tt,ll));
    end
end

% Create a set of timepoints relative to light onset
postLightTime = timePoints(6:end)-timePoints(6);
interpTime = timePoints(6):0.1:timePoints(end);

% Define an exponential function of post-light time
myExpFunc = @(p,x) (exp(-x./p(1))+p(2)) ./ (1+p(2));

lb = [6, 0];

params = [];
options = optimset('fmincon');
options.Display = 'off';

figure
for ll=1:nLevels
    myObj = @(tau) norm((meanVals(6:end,ll) - myExpFunc(tau,postLightTime))); % .* (1./semVals(6:end,ll)));
    params(ll,:) = fmincon(myObj,[10,0.2],[],[],[],[],lb,[],[],options);
    subplot(5,1,ll)
    plot(timePoints,meanVals(:,ll),'ok');    
    hold on
    for tt=1:nPoints
        plot([timePoints(tt) timePoints(tt)],[meanVals(tt,ll)-semVals(tt,ll), meanVals(tt,ll)+semVals(tt,ll)],'-','Color',[0.5 0.5 0.5],'LineWidth',1.5);
    end
    plot([0 30],[1 1],'-r','LineWidth',2);
    plot(interpTime,myExpFunc(params(ll,:),interpTime-timePoints(6)),'-r','LineWidth',2);
    ylim([0 1.25]);
    if ll==3
        ylabel('Change in proportion time in light zone')
    end
    if ll==nLevels
        xlabel('time [minutes]')
    end
end

weibullCDF = @(x,p) p(1) + p(2) - p(2)*exp( - (x./p(3)).^p(4) ) ;

figure
subplot(1,2,1)
plot(log10(lightLevels),params(:,1),'-ok');
ylabel('tau param exp decay');
xlabel('log light level');
% myObj = @(p) norm(params(:,1) - weibullCDF(log10(lightLevels),p) );
% pVals = fmincon(myObj,[6 10 1 15]);
% hiResX = log10(1:100);
% hold on
% plot(hiResX,weibullCDF(hiResX,pVals))

subplot(1,2,2)
plot(log10(lightLevels),params(:,2),'-ok');
ylabel('asymptote of light avoidance');
xlabel('log light level');

