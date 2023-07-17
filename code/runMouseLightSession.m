% This is effectively demo code for controlling the mouse light system and
% passing settings to different boxes

% Define the background settings for the boxes
backgroundSettings = [0.5,0.5,0.5];

% Define how long the device will stay in the background state
waitTimeBackgroundMins = 10;
waitTimeStimulusMins = 10;

% Define the desired settings for the panels at the end of the wait time.
% There are four boxes, and two panels in each box. The settings variable
% organizes these values by [box, panel]. In this example, the first panel
% of each box is set to Mel low, and the second panel of each box is set to
% Mel High.
for bb = 1:4
    settings(bb,1) = [1.0000, 0.1880, 0.5011];
    settings(bb,2) = [0.0000, 0.8120, 0.4989];
end

% Instantiate the MouseLight object and setup the serial connection
displayObj = MouseLightcontrol();

% Give it 5 seconds for the firmware to boot
pause(5);

% Set all primaries to the background
for bb = 1:displayObj.nBoxes
    for pp = 1:displayObj.nPanels
        displayObj.settings(bb,pp).primariesLow = backgroundSettings;
        displayObj.settings(bb,pp).primariesHigh = backgroundSettings;
    end
end
displayObj.sendSettings();

% Define the wait period
nSecs = waitTimeBackgroundMins * 60;
pause(nSecs);

% Switch to the desired high and low settings in the panels. Because we are
% using steady lights here and not flickering, the low and high settings
% of the primaries are the same.
for bb = 1:displayObj.nBoxes
    for pp = 1:displayObj.nPanels
        displayObj.settings(bb,pp).frequency = 0;
        displayObj.settings(bb,pp).primariesLow = settings(bb,pp);
        displayObj.settings(bb,pp).primariesHigh = settings(bb,pp);
    end
end
displayObj.sendSettings();

% Define the wait period
nSecs = waitTimeStimulusMins * 60;
pause(nSecs);

% Turn the lights off and close the connection
for bb = 1:displayObj.nBoxes
    for pp = 1:displayObj.nPanels
        displayObj.settings(bb,pp).frequency = 0;
        displayObj.settings(bb,pp).primariesLow = [0, 0, 0];
        displayObj.settings(bb,pp).primariesHigh = [0, 0, 0];
    end
end
displayObj.sendSettings();

% Close the serial connection
displayObj.serialClose;



