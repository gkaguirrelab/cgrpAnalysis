function setDuration(obj,modulationDurSecs)

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

% Enter the frequency send state
writeline(obj.serialObj,'MD');
readline(obj.serialObj);

% Send the duration
writeline(obj.serialObj,num2str(modulationDurSecs,'%.4f'));
msg = readline(obj.serialObj);

if obj.verbose
    fprintf(['Modulation duration set to ' char(msg) '\n']);
end


end