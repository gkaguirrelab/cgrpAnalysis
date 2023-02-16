function setFrequency(obj,frequency)

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
writeline(obj.serialObj,'FQ');
readline(obj.serialObj);

% Send the frequency
writeline(obj.serialObj,num2str(frequency,'%.4f'));
msg = readline(obj.serialObj);

if obj.verbose
    fprintf(['Frequency set to ' char(msg) '\n']);
end


end