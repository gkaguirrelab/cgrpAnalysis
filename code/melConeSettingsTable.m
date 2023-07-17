% Create a table of settings values that are used to produce contrast on
% the rodent mel, or (humanized) rodent cones, or their combination. The
% contrast here is expressed relative to the maximal available contrast
% for a given post-receptoral direction. The absolute photoreceptor
% contrast differs for the mel and L+S, but that is not of particular
% consequence.

photoreceptors = photoreceptorDictionary();
whichDirection = 'SplusHumanL';
coneModResult = designModulation(whichDirection,photoreceptors);

whichDirection = 'melSilentHumanL';
melModResult = designModulation(whichDirection,photoreceptors);

contrastLevels = [0.25, 0.5, 1];
nLevels = 3;

fprintf('Settings [red, blue, UV]:\n')
for ii = 1:nLevels
    bgd = coneModResult.settingsBackground;
    lowC = contrastLevels(ii).*(coneModResult.settingsLow - bgd);
    highC = contrastLevels(ii).*(coneModResult.settingsHigh - bgd);

    bgd = melModResult.settingsBackground;
    lowM = contrastLevels(ii).*(melModResult.settingsLow - bgd);
    highM = contrastLevels(ii).*(melModResult.settingsHigh - bgd);

    lowCM = lowC+lowM;
    highCM = highC+highM;

    fprintf('Contrast %2.2f, low mel [%2.4f, %2.4f, %2.4f], high mel [%2.4f, %2.4f, %2.4f]\n',contrastLevels(ii),lowM+bgd,highM+bgd);
    fprintf('Contrast %2.2f, low cone [%2.4f, %2.4f, %2.4f], high cone [%2.4f, %2.4f, %2.4f]\n',contrastLevels(ii),lowC+bgd,highC+bgd);
    fprintf('Contrast %2.2f, low M+C [%2.4f, %2.4f, %2.4f], high M+C [%2.4f, %2.4f, %2.4f]\n',contrastLevels(ii),lowCM+bgd,highCM+bgd);

end