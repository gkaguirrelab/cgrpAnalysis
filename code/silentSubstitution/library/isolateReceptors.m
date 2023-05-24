function modulationPrimary = isolateReceptors(...
    whichReceptorsToTarget,whichReceptorsToIgnore,desiredContrast,...
    T_receptors,B_primary,ambientSpd,backgroundPrimary,primaryHeadRoom,matchConstraint)
% Non-linear search to identify a modulation that isolates photoreceptors
%
% Syntax:
%   modulationPrimary = isolateReceptors(...
%      whichReceptorsToTarget,whichReceptorsToIgnore,desiredContrast,...
%       T_receptors,B_primary,ambientSpd,backgroundPrimary,primaryHeadRoom,matchConstraint)
%
% Description:
%   Given the spectral sensitivities of a set of photoreceptors and the
%   spectral power distributions of the set of primaries of a device, this
%   routine searches for a modulation of the primaries (around a specified
%   background) that maximizes contrast on a set of targeted primaries
%   while producing zero contrast on a set of isolated primaries.
%
%   Derived from a function of the same name in the SilentSubstitution
%   toolbox, authored by MS and DHB.
%
% Inputs:
%   whichReceptorsToTarget - Index vector in the range of 1-P that 
%                           indicates which receptors we wish to modulate.
%   whichReceptorsToIgnore - Index vector in the range of 1-P that 
%                           indicates which receptors we will ignore in the
%                           search.
%   desiredContrast       - Vector (equivalent in length to 
%                           whichReceptorsToTarget) that gives the desired
%                           relative contrast on each photoreceptor class.
%                           An L-M modulation, for example, might have the
%                           desired contrast of [1, -1].
%   T_receptors           - RxS matrix of R photoreceptors measured at S
%                           wavelengths. These are the spectral
%                           sensitivities of all receptors being
%                           considered, in standard PTB format.
%   B_primary             - SxP matrix of power at S wavelengths for the P
%                           primaries. This is a set of basis vectors for 
%                           the lights that the device can produce, scaled
%                           such that the gamut is for the range [0-1] on 
%                           each primary.
%   ambientSpd            - Sx1 vector of spectral power of the ambient.
%   backgroundPrimary     - Px1 vector of the settings of the primaries, 
%                           in the range [0-1], that constitutes the
%                           background for the modulation.
%   primaryHeadRoom       - Scalar, in the range [0-1]. This constrains the
%                           primary settings to be within
%                           [0+primaryHeadRoom,1-primaryHeadRoom]. This can
%                           be useful for anticipating the fact that the
%                           device may get dimmer over time, or if the
%                           device gamma is poorly behaved at the edge of
%                           the device gamut.
%   matchConstraint       - Scalar. Used to implement a penalty in the
%                           search on differential contrast on the targeted
%                           photoreceptors. Differences in contrast are
%                           multiplied by the log of this value and added
%                           to the optimization fVal.
%
% Outputs:
%   none
%   modulationPrimary     - Px1 vector of the settings of the primaries, 
%                           in the range [0-1], that defines a positive 
%                           modulation from the background.
%


% Set up the linear constraint for the receptors to silence
whichReceptorsToZero = setdiff(1:size(T_receptors,1),[whichReceptorsToTarget whichReceptorsToIgnore]);
backgroundReceptors = T_receptors*B_primary*backgroundPrimary;
backgroundReceptorsZero = backgroundReceptors(whichReceptorsToZero);
Aeq = T_receptors(whichReceptorsToZero,:)*B_primary;
beq = backgroundReceptorsZero;

% Since our modulations are symmetric, we need to make sure that we're not
% out of gamut if our background is not constant across wl band. For a
% half-on background, both the positive and the negative poles of a
% modulation will be in gamut, but that's not necessary the case if the
% background is not 0.5 for all wl bands.
primaryHeadRoomTolerance = 1e-7;
if (any(backgroundPrimary < primaryHeadRoom - primaryHeadRoomTolerance))
    error('Cannot work if background primary is less than specified headroom');
end
if (any(backgroundPrimary > 1-primaryHeadRoom+primaryHeadRoomTolerance))
    error('Cannot work if background primary is greater than 1 minus specified headroom');
end
for b = 1:size(backgroundPrimary, 1)
    if backgroundPrimary(b) > 0.5
        vub(b) = 1-primaryHeadRoom;
        vlb(b) = backgroundPrimary(b)-(1-primaryHeadRoom-backgroundPrimary(b));
    elseif backgroundPrimary(b) < 0.5
        vub(b) = backgroundPrimary(b)+(backgroundPrimary(b)-primaryHeadRoom);
        vlb(b) = primaryHeadRoom;
    elseif backgroundPrimary(b) == 0.5
        vub(b) = 1-primaryHeadRoom;
        vlb(b) = primaryHeadRoom;
    end
end

% Fix numerical issues with vlb > vub that can sometimes come up.
vlbTolerance = 1e-6;
for ii = 1:length(vub)
    if (vlb(ii) > vub(ii) - vlbTolerance)
        vlb(ii) = vub(ii) - vlbTolerance;
    end
end

% We will start the search from the background
x0 = backgroundPrimary;

% fmincon options. Not sure all these settings are necessary
options = optimset('fmincon');
options = optimset(options,'Diagnostics','off','Display','off',...
    'LargeScale','off','Algorithm','interior-point',...
    'MaxFunEvals', 100000, 'TolFun', 1e-10, 'TolCon', 1e-10, 'TolX', 1e-10);

% Turn off a warning that can occur within the optimization function
warningState = warning;
warning('off','MATLAB:rankDeficientMatrix');

% Set up the objective
myObj = @(x) isolateObjective(x,B_primary,backgroundPrimary,ambientSpd,...
    T_receptors,whichReceptorsToTarget,desiredContrast,matchConstraint);

% Perform the search
modulationPrimary = fmincon(myObj,x0,[],[],Aeq,beq,vlb,vub,[],options);

% Restore the warning state
warning(warningState);

% Extract the output arguments to be passed back.
% This enforces a sanity check on the primaries.
primaryTolerance = 2*vlbTolerance;
modulationPrimary(modulationPrimary > 1 - primaryHeadRoom & modulationPrimary < 1 - primaryHeadRoom + primaryTolerance) = 1 - primaryHeadRoom ;
modulationPrimary(modulationPrimary < primaryHeadRoom & modulationPrimary > primaryHeadRoom-primaryTolerance) = primaryHeadRoom;
if (any(modulationPrimary > 1 - primaryHeadRoom))
    error('Primary greater than 1 minus headroom');
end
if (any(modulationPrimary < primaryHeadRoom))
    error('Primeary less than primary headroom');
end

end

%% LOCAL FUNCTIONS


% Maximize the mean contrast on the targeted receptors, while imposing a
% regularization that reflects the deviation of contrasts from the desired
% contrasts.
function [fVal,isolateContrasts] = isolateObjective(x,B_primary,backgroundPrimary,ambientSpd,T_receptors,whichReceptorsToTarget,desiredContrasts,matchConstraint)

% Compute background including ambient
backgroundSpd = B_primary*backgroundPrimary + ambientSpd;

% Compute contrasts for receptors we want to isolate
modulationSpd = B_primary*(x-backgroundPrimary);
isolateContrasts = T_receptors(whichReceptorsToTarget,:)*modulationSpd ./ (T_receptors(whichReceptorsToTarget,:)*backgroundSpd);

% The starting point of the fVal is the negative of the contrast on the
% targeted photoreceptors. Note that we multiple this vector by the desired
% contrast vector to correct for differences in the sign of the desired
% contrasts
fVal = -mean(isolateContrasts.*desiredContrasts');

% Now calculate how much the set of contrasts differs from one another, and
% adjust this regularization penalty by the matchConstraint
beta = isolateContrasts\desiredContrasts';
if ~isinf(beta)
    scaledContrasts = beta*isolateContrasts;
    fVal = fVal + (10^matchConstraint)*sum((scaledContrasts-desiredContrasts').^4);
end

end

