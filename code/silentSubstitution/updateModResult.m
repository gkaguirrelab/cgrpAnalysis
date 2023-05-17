function modResult = updateModResult(modResult)

% Extract some information from the modResult
backgroundPrimary = modResult.settingsBackground;
modulationPrimary = modResult.settingsHigh;
T_receptors = modResult.meta.T_receptors;
B_primary = modResult.meta.B_primary; 
ambientSpd = modResult.ambientSpd;

% Get the contrast results
contrastReceptorsBipolar = calcBipolarContrastReceptors(modulationPrimary,backgroundPrimary,T_receptors,B_primary,ambientSpd);
contrastReceptorsUnipolar = calcUnipolarContrastReceptors(modulationPrimary,backgroundPrimary,T_receptors,B_primary,ambientSpd);

% Obtain the SPDs and wavelength support
positiveModulationSPD = B_primary*modulationPrimary;
negativeModulationSPD = B_primary*(backgroundPrimary-(modulationPrimary - backgroundPrimary));

% Update modResult
modResult.contrastReceptorsBipolar = contrastReceptorsBipolar;
modResult.contrastReceptorsUnipolar = contrastReceptorsUnipolar;
modResult.positiveModulationSPD = positiveModulationSPD;
modResult.negativeModulationSPD = negativeModulationSPD;

end




