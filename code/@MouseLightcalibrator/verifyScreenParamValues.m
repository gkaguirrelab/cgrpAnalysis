% Method to ensure that the parameters of the screen match those specified by the user
function obj = verifyScreenParamValues(obj)


d = struct(...
    'isMain', [], ...
    'screenSizeMM', [], ...
    'screenSizePixel', [], ...
    'refreshRate', [], ...
    'openGLacceleration', 1, ...
    'unitNumber', [], ...
    'bitsPerPixel', [], ...
    'bitsPerSample', [], ...
    'samplesPerPixel', [], ...
    'gammaTableLength', [] ...
    );

mainScreen = d;
mainScreen.isMain = 1;
mainScreen.screenSizeMM = [60,20];
mainScreen.screenSizePixel = [1920 480];
mainScreen.refreshRate = 72;
mainScreen.unitNumber = '0';

% gammaTableLength & samplesPerPixel
mainScreen.gammaTableLength = 45; %size(obj.origLUT,1);
mainScreen.samplesPerPixel  = 8; %size(obj.origLUT,2);

% bitsPerSample, bitsPerPixel, samplesPerPixel
mainScreen.bitsPerSample     = 1;
mainScreen.bitsPerPixel      = 12;

% Update list of display structs
a(1) = mainScreen;

targetScreen = d;
targetScreen.isMain = 0;
targetScreen.screenSizeMM = [60,20];
targetScreen.screenSizePixel = [1920 480];
targetScreen.refreshRate = 72;
targetScreen.unitNumber = '0';

% gammaTableLength & samplesPerPixel
targetScreen.gammaTableLength = 45; %size(obj.origLUT,1);
targetScreen.samplesPerPixel  = 8; %size(obj.origLUT,2);

% bitsPerSample, bitsPerPixel, samplesPerPixel
targetScreen.bitsPerSample     = 1;
targetScreen.bitsPerPixel      = 12;

% Update list of display structs
a(2) = targetScreen;

obj.displaysDescription = a;
obj.screenInfo = a(2);

end