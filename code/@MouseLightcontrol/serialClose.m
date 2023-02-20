function serialClose(obj)

% Close the serial port
clear obj.serialObj
obj.serialObj = [];

if obj.verbose
    fprintf('Serial port closed\n');
end

end