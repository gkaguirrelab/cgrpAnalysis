function serialOpen(obj)

% Get the list of available serial connections
portList = serialportlist("available");

% Look for the two possible string patterns
arduinoPortIdx = find((contains(serialportlist("available"),'tty.usbserial')));
arduinoPort = portList(arduinoPortIdx);
if isempty(arduinoPort)
    arduinoPortIdx = find((contains(serialportlist("available"),'tty.usbmodem')));
    arduinoPort = portList(arduinoPortIdx);
end
if isempty(arduinoPort)
    arduinoPortIdx = find((contains(serialportlist("available"),'tty.usbmodem')));
    arduinoPort = portList(arduinoPortIdx);
end

% We can't find a port
if isempty(arduinoPort)
    error('Unable to find a connected and available arduino board');
end

% Open the serial port
obj.serialObj = serialport(arduinoPort,obj.baudrate);

% Use CR and LF as a terminator
configureTerminator(obj.serialObj,"CR/LF");

% Announce it
if obj.verbose
    fprintf('Serial port open\n');
end


end