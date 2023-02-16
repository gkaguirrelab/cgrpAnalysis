function setBackground(obj,settingsBackground)

% Check that the background match the number of primaries
if length(settingsBackground) ~= obj.nPrimaries
    warning('The background vector must match number of primaries')
    return
end

% Sanity check the background range
mustBeInRange(settingsBackground,0,1);

% Check that we have an open connection
if isempty(obj.serialObj)
    warning('Serial connection not yet established');
    return
end

% Place the CombiLED in Config Mode
switch obj.deviceState
    case 'CONFIG'
    case {'RUN','DIRECT'}
        writeline(obj.serialObj,'CM');
        readline(obj.serialObj);
        obj.deviceState = 'CONFIG';
end

% Enter the background send state
writeline(obj.serialObj,'BG');
readline(obj.serialObj);

% Loop over the primaries and send the settings
report = 'settingsBackground: [ ';
for ii = 1:obj.nPrimaries
    % Each setting is sent as an integer, in the range of 0 to 1e4.
    % This is a specification of the fractional settings with a
    % precision to the fourth decimal place
    valToSend = round(settingsBackground(ii) * 1e4);
    writeline(obj.serialObj,num2str(valToSend));
    msg = readline(obj.serialObj);
    report = [report, char(msg), ' '];
end
report = [report,']\n'];
if obj.verbose
    fprintf(report);
end


end