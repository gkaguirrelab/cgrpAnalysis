function setCompoundModulation(obj,compoundHarmonics,compoundAmplitudes,compoundPhases)

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

% Set the waveform to index 5
writeline(obj.serialObj,'WF');
readline(obj.serialObj);
writeline(obj.serialObj,'5');
readline(obj.serialObj);

% Send the compound harmonics
writeline(obj.serialObj,'CH');
readline(obj.serialObj);
report = 'compoundHarmonics: [ ';
for ii = 1:5
    writeline(obj.serialObj,num2str(compoundHarmonics(ii),'%.4f'));
    msg = readline(obj.serialObj);
    report = [report, char(msg), ' '];
end
report = [report,']\n'];
if obj.verbose
    fprintf(report);
end

% Send the compound amplitudes
writeline(obj.serialObj,'CA');
readline(obj.serialObj);
report = 'compoundAmplitudes: [ ';
for ii = 1:5
    writeline(obj.serialObj,num2str(compoundAmplitudes(ii),'%.4f'));
    msg = readline(obj.serialObj);
    report = [report, char(msg), ' '];
end
report = [report,']\n'];
if obj.verbose
    fprintf(report);
end


% Send the compound phases
writeline(obj.serialObj,'CP');
readline(obj.serialObj);
report = 'compoundPhases: [ ';
for ii = 1:5
    writeline(obj.serialObj,num2str(compoundPhases(ii),'%.4f'));
    msg = readline(obj.serialObj);
    report = [report, char(msg), ' '];
end
report = [report,']\n'];
if obj.verbose
    fprintf(report);
end


if obj.verbose
    fprintf('Compound modulation values sent\n');
end

end