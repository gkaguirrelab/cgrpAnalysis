function setGamma(obj,gammaTable)

% Check that the gamma table matches the number of primaries
if size(gammaTable,2) ~= obj.nPrimaries
    warning('First dimension of settings must match number of primaries')
    return
end

% Truncate any values above 1
gammaTable(gammaTable>1)=1;

% Check the input range
mustBeInRange(gammaTable,0,1);

% Check that we have an open connection
if isempty(obj.serialObj)
    warning('Serial connection not yet established');
    return
end

if obj.verbose
    fprintf('Creating and sending gamma parameters\n');
end

% Loop through the gamma table and calculate a 5th-degree polynomial fit.
% We want the inverse of the gammaTable relationship, so the y values are
% the desired (linear) input settings, and the x values are the observed
% output.
y = linspace(0,1,size(gammaTable,1)+1);
for ii=1:obj.nPrimaries
    x = [0; gammaTable(:,ii)];
    gammaParams(ii,:) = polyfit(x,y,obj.nGammaParams-1);
    % Check the quality of the fit
    fitY = polyval(gammaParams(ii,:),x);
    fitErr = norm(y-fitY');
    if fitErr>obj.gammaFitTol
        warning('LED%d (index 0) has gamma fit error of %2.2f (thresh %2.2f)',ii-1,fitErr,obj.gammaFitTol);
    end
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
writeline(obj.serialObj,'GP');
readline(obj.serialObj);

% Loop over the primaries and send the settings
for ii = 1:obj.nPrimaries
    report = sprintf('gammaParams led%d: [ ',ii-1);
    for jj= 1:obj.nGammaParams
        % Send value as 0-1e4 int
        val = gammaParams(ii,jj);
        writeline(obj.serialObj,num2str(val,'%.4f'));
        msg = readline(obj.serialObj);        
        report = [report, char(msg), ' '];
    end
    report = [report,']\n'];
    if obj.verbose
        fprintf(report);
    end
end


end