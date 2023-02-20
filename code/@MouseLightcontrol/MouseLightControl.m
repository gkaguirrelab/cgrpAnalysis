% Object to support setting the LED levels directly of the Prizmatix
% CombiLED 8-channel light engine. This routine presumes that the
% prizModulationFirmware is installed on the device.

classdef MouseLightcontrol < handle

    properties (Constant)

        nPrimaries = 3;
        nBoxes = 4;
        nPanels = 2;
        maxPrimarySetting = 4095;
        baudrate = 57600;
    end

    % Private properties
    properties (GetAccess=private)

    end

    % Calling function can see, but not modify
    properties (SetAccess=private)

        serialObj

    end

    % These may be modified after object creation
    properties (SetAccess=public)

        % Verbosity
        verbose = false;

        % Settings structure
        settings

        % Duration on
        durationOnMins = 30;

        % Delay between turning on subsequent boxes
        boxOnsetDelay = 0;

    end

    methods

        % Constructor
        function obj = MouseLightcontrol(varargin)

            % input parser
            p = inputParser; p.KeepUnmatched = false;
            p.addParameter('verbose',true,@islogical);
            p.parse(varargin{:})

            % Store the verbosity
            obj.verbose = p.Results.verbose;

            % Open the serial port
            obj.serialOpen;

            % Define the default settings structure
            for bb=1:obj.nBoxes
                pp = 1;
                obj.settings(bb,pp).frequency = 0;
                obj.settings(bb,pp).primariesLow = ...
                    [obj.maxPrimarySetting, obj.maxPrimarySetting, obj.maxPrimarySetting];
                obj.settings(bb,pp).primariesHigh = ...
                    [obj.maxPrimarySetting, obj.maxPrimarySetting, obj.maxPrimarySetting];

                pp = 2;
                obj.settings(bb,pp).frequency = 0;
                obj.settings(bb,pp).primariesLow = [0, 0, 0];
                obj.settings(bb,pp).primariesHigh = [0, 0, 0];
            end

        end

        % Required methds
        serialOpen(obj)
        serialClose(obj)
        sendSettings(obj)

    end
end