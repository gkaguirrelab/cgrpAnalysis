% calibrateMouseLight
%
% Executive script for object-oriented-based monitor calibration.

% History:
%    03/27/2014  npc   Wrote it.
%    08/05/2014  npc   Added option to conduct PsychImaging - based calibration
%    03/02/2015  npc   Re-organized script so that settings and options are set in
%                      a single function.
%    08/30/2016  jar   Added calibration configuration for the InVivo Sensa Vue
%                      Flat panel monitor located at the Stellar Chance 3T Magnet.
%    10/18/2017  npc   Reset Radiometer before crashing
%    12/12/2017  ana   Added eye tracker LCD case
%    11/24/2021  smo   Delete the RadiometerOBJ and substitue it with SACC
%                      measurement codes. It works faster and fine.
%    12/15/2021  smo   Copied the object @PsychImagingCalibrator from BLTB
%                      and changed the name as @SACCPsychImagingCalibrator.
%                      This is for using our SACC functions (cf.
%                      measurement) in all calibrations.
%    02/05/2023  gka   Modified for the Prizmatix MouseLight
%    02/21/2023  gka&eak Modified for the rodent light panels

function calibrateMouseLight

% Set the save location for calibration files
calLocalData = fullfile(tbLocateProject('cgrpAnalysis'),'cal');
setpref('BrainardLabToolbox','CalDataFolder',calLocalData);

% Alert regarding the order of device connection
fprintf('Ensure that the MouseLight is not currently connected to the computer\n');

% Ask the user to provide a name for the calibration file
calFileName = GetWithDefault('Name for the cal file','fullPanel');

% Ask the user to pick a box and a panel
boxIdx = str2double(GetWithDefault('Which box? [1-4]','4'));
panelIdx = str2double(GetWithDefault('Which panel? [1-2]','1'));

% Generate calibration options and settings
[displaySettings, calibratorOptions] = generateConfigurationForMouseLight(calFileName);

% Open the spectroradiometer
OpenSpectroradiometer('measurementOption',false);

% Create the radiometer object
radiometerOBJ = OLOpenSpectroRadiometerObj('PR-670');

% Generate the calibrator object
calibratorOBJ = generateCalibratorObject(displaySettings, radiometerOBJ, mfilename,boxIdx,panelIdx);

% Set the calibrator options
calibratorOBJ.options = calibratorOptions;

% Alert the user to connect the MouseLight
fprintf('Power on and connect the MouseLight; return when ready\n')
pause;

% Calibrate
calibratorOBJ.calibrate();

% Shutdown DBLab_Calibrator
calibratorOBJ.shutDown();

% Shutdown spectroradiometer.
CloseSpectroradiometer;

end


%% LOCAL FUNCTIONS

function [displaySettings, calibratorOptions] = generateConfigurationForMouseLight(calFileName)

% Specify the @Calibrator's initialization params. Users should tailor
% these according to their hardware specs. These can be set once only, at
% the time the @Calibrator object is instantiated.
displayPrimariesNum = 3;
displaySettings = { ...
    'screenToCalibrate',        2, ...                          % which display to calibrate. main screen = 1, second display = 2
    'desiredScreenSizePixel',   [1 1], ...                      % pixels along the width and height of the display to be calibrated
    'desiredRefreshRate',       120, ...                        % refresh rate in Hz
    'displayPrimariesNum',      displayPrimariesNum, ...        % for regular displays this is always 3 (RGB)
    'displayDeviceType',        'monitor', ...                  % this should always be set to 'monitor' for now
    'displayDeviceName',        'MouseLight', ...                 % a name for the display been calibrated
    'calibrationFile',          calFileName, ...                % name of calibration file to be generated
    'comment',                  'The 3 channel MouseLight light' ... % some comment, could be anything
    };

% Specify the @Calibrator's optional params using a CalibratorOptions object
% To see what options are available type: doc CalibratorOptions
% Users should tailor these according to their experimental needs.
calibratorOptions = CalibratorOptions( ...
    'verbosity',                        0, ...
    'whoIsDoingTheCalibration',         'MouseLight user', ...
    'emailAddressForDoneNotification',  'aguirreg@upenn.edu', ...
    'blankOtherScreen',                 0, ...                          % whether to blank other displays attached to the host computer (1=yes, 0 = no), ...
    'whichBlankScreen',                 1, ...                          % screen number of the display to be blanked  (main screen = 1, second display = 2)
    'blankSettings',                    zeros(1,displayPrimariesNum), ...                 % color of the whichBlankScreen
    'bgColor',                          zeros(1,displayPrimariesNum), ...                 % color of the background
    'fgColor',                          zeros(1,displayPrimariesNum), ...                 % color of the foreground
    'meterDistance',                    0.1, ...                        % distance between radiometer and screen in meters
    'leaveRoomTime',                    60, ...                          % seconds allowed to leave room
    'nAverage',                         3, ...                          % number of repeated measurements for averaging
    'nMeas',                            10, ...                         % samples along gamma curve
    'nDevices',                         displayPrimariesNum, ...        % number of primaries
    'boxSize',                          1, ...                          % size of calibration stimulus in pixels
    'boxOffsetX',                       0, ...                          % x-offset from center of screen (neg: leftwards, pos:rightwards)
    'boxOffsetY',                       0, ...                          % y-offset from center of screen (neg: upwards, pos: downwards)
    'skipLinearityTest',                true, ...
    'skipAmbientLightMeasurement',      false, ...
    'skipBackgroundDependenceTest',     true ...
    );
end


% Function to generate the calibrator object.
function calibratorOBJ = generateCalibratorObject(displaySettings, radiometerOBJ, execScriptFileName,boxIdx,panelIdx)

% set init params
calibratorInitParams = displaySettings;

% add radiometerOBJ
calibratorInitParams{numel(calibratorInitParams)+1} = 'radiometerObj';
calibratorInitParams{numel(calibratorInitParams)+1} = radiometerOBJ;

% add executive script name
calibratorInitParams{numel(calibratorInitParams)+1} ='executiveScriptName';
calibratorInitParams{numel(calibratorInitParams)+1} = execScriptFileName;

% instantiate the calibrator object
calibratorOBJ = MouseLightcalibrator(calibratorInitParams,boxIdx,panelIdx);

end

