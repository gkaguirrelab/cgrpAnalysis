function modResult = designModulation(whichDirection,photoreceptors,varargin)
% Nominal primaries and SPDs for isolating post-receptoral mechanisms
%
% Syntax:
%	modResult = designModulation(whichDirection,photoreceptors);
%
% Description:
%   This routine loads a calibration file for the CombiLED device and
%   identifies the settings on the LEDs that provides maximal contrast
%   along a specified post-receptoral direction.
%
% Inputs:
%	whichDirection        - Char. An entry in the modDirectionDictionary.
%	photoreceptors        - Struct. A struct returned by
%	                        photoreceptorDictionary
%
% Outputs:
%	modResult             - Struct. The primaries and SPDs.
%
% Optional key/value pairs:
%  'calLocalData'         - Char. Path to the calibration file that
%                           describes the device that will be used to
%                           create the modulations.
%  'primaryHeadRoom'      - Scalar. We can enforce a constraint that we
%                           don't go right to the edge of the gamut.  The
%                           head room parameter is defined in the [0-1]
%                           device primary space. Using a little head room
%                           keeps us a bit away from the hard edge of the
%                           device.
%  'verbose'              - Logical. Verbosity.
%
% Examples:
%{
    photoreceptors = photoreceptorDictionary();
    whichDirection = 'humanizedCone';
    modResult = designModulation(whichDirection,photoreceptors);
    plotModResult(modResult);
%}
%{
    photoreceptors = photoreceptorDictionary();
    whichDirection = 'humanizedMel';
    modResult = designModulation(whichDirection,photoreceptors);
    plotModResult(modResult);
%}


%% Parse input
p = inputParser;
p.addRequired('whichDirection',@ischar);
p.addRequired('photoreceptors',@isstruct);
p.addParameter('calLocalData',fullfile(tbLocateProject('cgrpAnalysis'),'cal','fullPanel.mat'),@ischar);
p.addParameter('primaryHeadRoom',0.00,@isscalar)
p.addParameter('verbose',false,@islogical)
p.parse(whichDirection,photoreceptors,varargin{:});

% Pull some variables out of the Results for code clarity
primaryHeadRoom = p.Results.primaryHeadRoom;
verbose = p.Results.verbose;

% Load the calibration
load(p.Results.calLocalData,'cals');
cal = cals{end};

% Modify the cal file to expand the S range and add in the synthesized 365
% nm LED SDP
[S,B_primary,ambientSpd] = addSynthesizedUVSPD(cal);

% Pull out some information from the calibration
nPrimaries = size(B_primary,2);
wavelengthsNm = SToWls(S);

% Here we hack in the synthesized B_primary for the UV light. For details
% see returnSynthesizedUVSPD.m

% Create the spectral sensitivities in the photoreceptor structure for our
% given set of wavelengths (S). Also assemble the T_receptors matrix.
for ii = 1:length(photoreceptors)
    photoreceptors(ii).T_energyNormalized = ...
        returnRodentSpectralSensitivity(photoreceptors(ii),S);
    T_receptors(ii,:) = photoreceptors(ii).T_energyNormalized;
end

% Get the design parameters from the modulation dictionary
[whichReceptorsToTarget,whichReceptorsToIgnore,...
    desiredContrast,x0Background,matchConstraint,searchBackground,xyBound] = ...
    modDirectionDictionary(whichDirection,photoreceptors);

% Define the isolation operation as a function of the background
modulationPrimaryFunc = @(backgroundPrimary) isolateReceptors(...
    whichReceptorsToTarget,whichReceptorsToIgnore,desiredContrast,...
    T_receptors,B_primary,ambientSpd,backgroundPrimary,primaryHeadRoom,matchConstraint);

% Define a function that returns the contrast on all photoreceptors
contrastReceptorsFunc = @(modulationPrimary,backgroundPrimary) ...
    calcBipolarContrastReceptors(modulationPrimary,backgroundPrimary,T_receptors,B_primary,ambientSpd);

% And a function that returns the contrast on just the targeted
% photoreceptors
contrastOnTargeted = @(contrastReceptors) contrastReceptors(whichReceptorsToTarget);

% Set the bounds within the primary headroom
lb = zeros(1,nPrimaries)+primaryHeadRoom;
plb = zeros(1,nPrimaries)+primaryHeadRoom;
pub = ones(1,nPrimaries)-primaryHeadRoom;
ub = ones(1,nPrimaries)-primaryHeadRoom;

% Set BADS verbosity
if p.Results.verbose
    optionsBADS.Display = 'iter';
else
    optionsBADS.Display = 'off';
end

% The optimization toolbox is currently not available for Matlab
% running under Apple silicon. Detect this case and tell BADS so that
% it doesn't issue a warning
V = ver;
if ~any(strcmp({V.Name}, 'Optimization Toolbox'))
    optionsBADS.OptimToolbox = 0;
end

% Handle searching over backgrounds
if searchBackground
    % Alert the user if requested
    if verbose
        fprintf(['Searching over background for ' whichDirection ' modulation...\n'])
    end
    % Set up an objective, which is just the negative of the mean contrast
    % on the targeted photoreceptors, accounting for the sign of the
    % desired contrast
    myObj = @(x) -mean(contrastOnTargeted(contrastReceptorsFunc(modulationPrimaryFunc(x'),x')).*(desiredContrast'));
    myNonlcon = @(x) nonlcon(x',repmat(0.5,nPrimaries,1),B_primary,wavelengthsNm,xyBound);
    backgroundPrimary = bads(myObj,x0Background',lb,ub,plb,pub,myNonlcon,optionsBADS)';
else
    if verbose
        fprintf(['Searching for ' whichDirection ' modulation\n'])
    end
    % If we are not searching across backgrounds, use the half-on
    backgroundPrimary = repmat(0.5,nPrimaries,1);
end

% Perform the search with resulting background background
modulationPrimary = modulationPrimaryFunc(backgroundPrimary);

% Get the contrast results
contrastReceptorsBipolar = contrastReceptorsFunc(modulationPrimary,backgroundPrimary);
contrastReceptorsUnipolar = calcUnipolarContrastReceptors(modulationPrimary,backgroundPrimary,T_receptors,B_primary,ambientSpd);

% Obtain the SPDs and wavelength support
backgroundSPD = B_primary*backgroundPrimary;
positiveModulationSPD = B_primary*modulationPrimary;
negativeModulationSPD = B_primary*(backgroundPrimary-(modulationPrimary - backgroundPrimary));

% Create vectors of the primaries with informative names
settingsLow = backgroundPrimary+(-(modulationPrimary-backgroundPrimary));
settingsHigh = modulationPrimary;
settingsBackground = backgroundPrimary;

% Create a structure to return the results
modResult.meta.whichDirection = whichDirection;
modResult.meta.x0Background = x0Background;
modResult.meta.matchConstraint = matchConstraint;
modResult.meta.searchBackground = searchBackground;
modResult.meta.xyBound = xyBound;
modResult.meta.B_primary = B_primary;
modResult.meta.T_receptors = T_receptors;
modResult.meta.photoreceptors = photoreceptors;
modResult.meta.whichReceptorsToTarget = whichReceptorsToTarget;
modResult.meta.whichReceptorsToIgnore = whichReceptorsToIgnore;
modResult.meta.desiredContrast = desiredContrast;
modResult.meta.p = p.Results;
modResult.ambientSpd = ambientSpd;
modResult.backgroundSPD = backgroundSPD;
modResult.contrastReceptorsBipolar = contrastReceptorsBipolar;
modResult.contrastReceptorsUnipolar = contrastReceptorsUnipolar;
modResult.positiveModulationSPD = positiveModulationSPD;
modResult.negativeModulationSPD = negativeModulationSPD;
modResult.wavelengthsNm = wavelengthsNm;
modResult.settingsBackground = settingsBackground;
modResult.settingsLow = settingsLow;
modResult.settingsHigh = settingsHigh;

end


%% LOCAL FUNCTIONS

function c = nonlcon(x,x0,B_primary,wavelengthsNm,xyBound)

% Expand x0 to have the same number of columns as x


xy_distance = chromaDistance(B_primary*x,B_primary*x0,wavelengthsNm);

c = double(xy_distance>xyBound)';
c(isnan(xy_distance)) = 1;

end
