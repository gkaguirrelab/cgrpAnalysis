% Create a table of settings values that are used to produce contrast on
% the rodent mel, or (humanized) rodent cones, or their combination. The
% contrast here is expressed relative to the maximal available contrast
% for a given post-receptoral direction.

whichDirection = 'L';
photoreceptors = photoreceptorDictionary();
SconeModResult = designModulation(whichDirection,photoreceptors);

contrastLevels = [0.25, 0.5, 0.75, 1];
nLevels = length(contrastLevels);

fprintf([whichDirection ': settings [red, blue, UV]:\n'])
for ii = 1:nLevels
    bgd = SconeModResult.settingsBackground;
    lowC = contrastLevels(ii).*(SconeModResult.settingsLow - bgd);
    highC = contrastLevels(ii).*(SconeModResult.settingsHigh - bgd);

    fprintf('Relative Contrast %2.2f, low [%2.4f, %2.4f, %2.4f], high [%2.4f, %2.4f, %2.4f]\n',contrastLevels(ii),lowC+bgd,highC+bgd);

end