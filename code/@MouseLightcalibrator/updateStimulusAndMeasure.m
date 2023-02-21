% Method to update the stimulus and conduct a single radiometric measurement by
% calling the corresponding method of the attached @Radiometer object.
function [measurement, S] = updateStimulusAndMeasure(obj, ~, targetSettings, ~)
%
if (obj.options.verbosity > 1)
    fprintf('        Target settings    : %2.3f %2.3f %2.3f\n\n', targetSettings);
end

% Get the displayObj
displayObj = obj.displayObj;

% Set the settings for the box and panel we are calibrating
displayObj.settings(obj.boxIdx,obj.panelIdx).frequency = 0;
displayObj.settings(obj.boxIdx,obj.panelIdx).primariesLow = targetSettings;
displayObj.settings(bb,pp).primariesHigh = targetSettings;
displayObj.sendSettings();

% Measure
obj.radiometerObj.measure();
measurement = obj.radiometerObj.measurement.energy;
S = WlsToS((obj.radiometerObj.measurement.spectralAxis)');

end