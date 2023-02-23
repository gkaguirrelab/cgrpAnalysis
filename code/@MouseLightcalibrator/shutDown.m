% Method to shutdown the device
function obj = shutDown(obj)

if (obj.options.verbosity > 9)
    fprintf('In CombiLEDcalibrator.shutDown() method\n');
end

% Get the display obj
displayObj = obj.displayObj;

% Close the serial connection
displayObj.serialClose;

end
