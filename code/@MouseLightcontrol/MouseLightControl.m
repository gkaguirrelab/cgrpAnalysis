% Object to support setting the LED levels directly of the Prizmatix
% CombiLED 8-channel light engine. This routine presumes that the
% prizModulationFirmware is installed on the device.

classdef MouseLightControl < handle

    properties (Constant)

        nPrimaries = 3;
        nDiscreteLevels = 51;
        baudrate = 57600;
        refreshRate = 10; % Hz
        nGammaParams = 6;
    end

    % Private properties
    properties (GetAccess=private)

    end

    % Calling function can see, but not modify
    properties (SetAccess=private)

        serialObj
        deviceState

    end

    % These may be modified after object creation
    properties (SetAccess=public)

        % Verbosity
        verbose = false;

        % Properties of the gamma correction
        gammaFitTol = 0.03;

    end

    methods

        % Constructor
        function obj = MouseLightControl(varargin)

            % input parser
            p = inputParser; p.KeepUnmatched = false;
            p.addParameter('verbose',true,@islogical);
            p.parse(varargin{:})

            % Store the verbosity
            obj.verbose = p.Results.verbose;

            % Open the serial port
            obj.serialOpen;

            % Send the default gammaTable
            gammaTableFileName = fullfile(fileparts(mfilename('fullpath')),'defaultGammaTable.mat');
            load(gammaTableFileName,'gammaTable');
            obj.setGamma(gammaTable);

        end

        % Required methds
        serialOpen(obj)
        serialClose(obj)
        setPrimaries(obj,settings)
        startModulation(obj)
        stopModulation(ob)
        setFrequency(obj,frequency)
        setContrast(obj,contrast)
        setPhaseOffset(obj,phaseOffset)
        setSettings(obj,modResult)
        setBackground(obj,settingsBackground)
        setAMIndex(obj,amplitudeIndex)
        setAMValues(obj,amplitudeVals)
        setCompoundModulation(obj,compoundHarmonics,compoundAmplitudes,compoundPhases)
        setWaveformIndex(obj,waveformIndex)
        setGamma(obj,gammaTable)

    end
end