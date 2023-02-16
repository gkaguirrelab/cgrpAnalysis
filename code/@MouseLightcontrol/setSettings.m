function setSettings(obj,modResult)

% Extract the background, hi, and low settings
settingsLow = modResult.settingsLow;
settingsHigh = modResult.settingsHigh;

% Check that the settings match the number of primaries
if size(settingsLow,1) ~= obj.nPrimaries
    warning('First dimension of settingsLow must match number of primaries')
    return
end
if size(settingsHigh,1) ~= obj.nPrimaries
    warning('First dimension of settingsHigh must match number of primaries')
    return
end

% Sanity check the settings range
mustBeInRange(settingsLow,0,1);
mustBeInRange(settingsHigh,0,1);

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

% Enter the settings send state
writeline(obj.serialObj,'ST');
readline(obj.serialObj);

% Send the settingsLow
report = 'settingsLow: [ ';
for ii = 1:obj.nPrimaries
    % Each setting is sent as an integer, in the range of 0 to 1e4.
    % This is a specification of the fractional settings with a
    % precision to the fourth decimal place
    valToSend = round(settingsLow(ii) * 1e4);
    writeline(obj.serialObj,num2str(valToSend));
    msg = readline(obj.serialObj);
    report = [report, char(msg), ' '];
end
report = [report,']\n'];
if obj.verbose
    fprintf(report);
end


% Send the settingsHigh
report = 'settingsHigh: [ ';
for ii = 1:obj.nPrimaries
    % Each setting is sent as an integer, in the range of 0 to 1e4.
    % This is a specification of the fractional settings with a
    % precision to the fourth decimal place
    valToSend = round(settingsHigh(ii) * 1e4);
    writeline(obj.serialObj,num2str(valToSend));
    msg = readline(obj.serialObj);
    report = [report, char(msg), ' '];
end
report = [report,']\n'];
if obj.verbose
    fprintf(report);
end

end