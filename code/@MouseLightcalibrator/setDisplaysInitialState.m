function setDisplaysInitialState(obj, userPrompt)
    
    % Make a local copy of obj.cal so we do not keep calling it and regenerating it
    calStruct = obj.cal;
    
    % Instantiate the MouseLight object and setup the serial connection
    displayObj = MouseLightcontrol();
    displayObj.serialOpen;

    % Give it 5 seconds for the firmware to boot
    pause(5);

    % Set all primaries to off
    for bb = 1:displayObj.nBoxes
        for pp = 1:displayObj.nPanels
            displayObj.settings(bb,pp).primariesLow = [0, 0, 0];
            displayObj.settings(bb,pp).primariesHigh = [0, 0, 0];
        end
    end
    displayObj.sendSettings();

    % Store the object
    obj.displayObj = displayObj;

    disp('Position radiometer and hit enter when ready');
    pause

    % Wait for user
    if (userPrompt) 
        fprintf('Pausing for %d seconds ...', calStruct.describe.leaveRoomTime);
        FlushEvents;
        % GetChar;
        pause(calStruct.describe.leaveRoomTime);
        fprintf(' done\n\n\n');
    end

end