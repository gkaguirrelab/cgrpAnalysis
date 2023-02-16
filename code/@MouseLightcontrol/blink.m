function blink(obj)

% Check that we have an open connection
if isempty(obj.serialObj)
    warning('Serial connection not yet established');
end

% Check the CombiLED in Run Mode
switch obj.deviceState
    case 'RUN'
    case {'CONFIG','DIRECT'}
        return
end

% Send the blink
writeline(obj.serialObj,'BL');
readline(obj.serialObj);

% Say
if obj.verbose
    fprintf('blink\n');
end

end