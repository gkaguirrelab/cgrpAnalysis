function sendSettings(obj)

% Assemble a command string
str = '<';

% Add the overall duration and sequential box delay values
msecsInMin = 60*1000;
str = [str num2str(obj.durationOnMins*msecsInMin) ',' num2str(obj.boxOnsetDelay) ','];

% Now loop through boxes and panels
for bb=1:obj.nBoxes
    for pp=1:obj.nPanels

        % Write frequency for this panel
        frequency = obj.settings(bb,pp).frequency;
        if frequency > 100
            warning('Max frequency setting = 100 Hz; setting to this value');
            frequency = 100;           
        end
        if frequency == 0
            dutyCycle = [1000,0];
        else
            dutyCycle = [round((1000/frequency)/2), round((1000/frequency)/2)];
        end
        str = [str num2str(dutyCycle(1)) ',' num2str(dutyCycle(2)) ',' ];

        % Loop over primaries
        for rr=1:obj.nPrimaries
            low = obj.settings(bb,pp).primariesLow(rr);
            high = obj.settings(bb,pp).primariesHigh(rr);

            % Convert from 0-1 float to 12 bit integer
            low = round(low * obj.maxPrimarySetting);
            high = round(high * obj.maxPrimarySetting);

            % Add to the string
            str = [str num2str(low) ',' num2str(high) ',' ];

        end
    end
end

% Remove the trailing comma and add a closing chevron
str = [str(1:end-1) '>'];

% Send the command
writeline(obj.serialObj,str);

if obj.verbose
    fprintf([str '\n']);
    fprintf('Settings sent\n');
end

end