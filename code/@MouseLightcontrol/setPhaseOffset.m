function setPhaseOffset(obj,phaseOffset)

% Check that we have an open connection
if isempty(obj.serialObj)
    warning('Serial connection not yet established');
    return
end

% Sanity check the input
mustBeInRange(phaseOffset,0,2*pi);

% Place the CombiLED in Config Mode
switch obj.deviceState
    case 'CONFIG'
    case {'RUN','DIRECT'}
        writeline(obj.serialObj,'CM');
        readline(obj.serialObj);
        obj.deviceState = 'CONFIG';
end

% Enter the phaseOffset send state
writeline(obj.serialObj,'PH');
readline(obj.serialObj);

% Send the phaseOffset
writeline(obj.serialObj,num2str(phaseOffset,'%.4f'));
msg = readline(obj.serialObj);

if obj.verbose
    fprintf(['phaseOffset set to ' char(msg) '\n']);
end


end