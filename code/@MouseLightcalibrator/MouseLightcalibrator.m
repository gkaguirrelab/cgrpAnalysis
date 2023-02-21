% Subclass of @Calibrator to work with the MouseLight
%
% 3/27/2014  npc   Wrote it.
% 2/02/2023  gka   Modified for the MouseLight
% 2/21/2023  gka & eak Modified for the MouseLight
%

classdef MouseLightcalibrator < Calibrator
    % Public properties (specific to the @MouseLightCalibrator class)
    properties

        boxIdx
        panelIdx

    end

    % --- PRIVATE PROPERTIES ----------------------------------------------
    properties (Access = private)

        % Holds the object for communication with the MouseLight
        displayObj

    end
    % --- END OF PRIVATE PROPERTIES ---------------------------------------

    % Public methods
    methods
        % Constructor
        function obj = MouseLightcalibrator(initParams,boxIdx,panelIdx)

            % Call the super-class constructor.
            obj = obj@Calibrator(initParams);

            % Note the graphics engine
            obj.graphicsEngine = 'MouseLight';

            % Store the box and pabel
            obj.boxIdx = boxIdx;
            obj.panelIdx = panelIdx;

            % Verify validity of screen params values
            obj.verifyScreenParamValues();

        end
    end % Public methods

    % Implementations of required -- Public -- Abstract methods defined in the @Calibrator interface
    methods

        % Method to set the initial state of the displays
        setDisplaysInitialState(obj, userPrompt);

        % Method to update the stimulus and conduct a single radiometric measurement by
        % calling the corresponding method of the attached @Radiometer object.
        [measurement, S] = updateStimulusAndMeasure(obj, bgSettings, targetSettings, useBitsPP);

        % Method to ensure that the parameters of the screen match those specified by the user
        obj = verifyScreenParamValues(obj);

        % Method to shutdown the Calibrator
        obj = shutdown(obj);

    end % Implementations of required -- Public -- Abstract methods defined in the @Calibrator interface

    % Protected methods that shadow functions from the calibration class
    methods (Access = protected)

        % Shadow the function from the calibrator class so that we can 
        % plot all  8 primaries
        obj = plotBasicMeasurements(obj);

        % Shadow the function from the calibrator class so that we can set
        % the number of input levels to 12 bit.
        obj = processRawData(obj)

    end  % Private methods

end % classdef