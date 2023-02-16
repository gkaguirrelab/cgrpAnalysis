function serialClose(obj)

% Place the CombiLED in Run Mode
switch obj.deviceState
    case 'RUN'
    case {'CONFIG','DIRECT'}
        writeline(obj.serialObj,'RM');
        readline(obj.serialObj);
        obj.deviceState = 'RUN';
end

% Set the LEDs to off
writeline(obj.serialObj,'DK');
readline(obj.serialObj);

% Close the serial port
clear obj.serialObj
obj.serialObj = [];

if obj.verbose
    fprintf('Serial port closed\n');
end

end