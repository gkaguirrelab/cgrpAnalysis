function setPrimaries(obj,settings)

% Check that the settings match the number of primaries
if length(settings) ~= obj.nPrimaries
    warning('Length of settings must match number of primaries')
    return
end

% Sanity check the settings range
mustBeInRange(settings,0,1);

% Check that we have an open connection
if isempty(obj.serialObj)
    warning('Serial connection not yet established');
    return
end

% Flush the serial port IO
flush(obj.serialObj);

% Place the CombiLED in Direct Mode
switch obj.deviceState
    case 'DIRECT'
    case {'RUN','CONFIG'}
        writeline(obj.serialObj,'DM');
        readline(obj.serialObj);
        obj.deviceState = 'DIRECT';
end

% Prepare to send settings
writeline(obj.serialObj,'LL');
readline(obj.serialObj);

% Loop over the primaries and write the values
for ii=1:length(settings)
    % Each setting is sent as an integer, in the range of 0 to 1e4.
    % This is a specification of the fractional settings with a
    % precision to the fourth decimal place
    valToSend = round(settings(ii) * 1e4);
    writeline(obj.serialObj,num2str(valToSend));
    readline(obj.serialObj);
end

if obj.verbose
    fprintf('Primaries set\n');
end

end