function setWaveformIndex(obj,waveformIndex)

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

% Set the waveform to index
writeline(obj.serialObj,'WF');
readline(obj.serialObj);
writeline(obj.serialObj,num2str(waveformIndex));
msg=readline(obj.serialObj);

if obj.verbose
    fprintf(['Waveform index set to ' char(msg) '\n']);
end

end