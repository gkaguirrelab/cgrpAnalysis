function [T_energyNormalized,T_energy,adjIndDiffParams] = returnHumanSpectralSensitivity(photoreceptorStruct,S)
% Provides the spectral sensitivity function for a specified photoreceptor
%
% Syntax:
%  [T_energyNormalized,T_energy,adjIndDiffParams] = returnHumanSpectralSensitivity(photoreceptorStruct,S)
%
% Description:
%   Provides the spectral sensitivity of a specified human photoreceptor at
%   the wavelengths specified by S. The sensitivity is expressed as energy 
%   (isomerizations-per-second as a function of radiance expressed in
%   Watts), normalized to a max of 1. The spectral sensitivity is expressed
%   relative to light arriving at the cornea.
%
%   This routine is a simplified version of code written by David Brainard
%   and Manuel Spitchan in the SilentSubstitutionToolbox.
%
%   The properties of the photoreceptor are specified in the passed
%   photoreceptorStruct. The required fields are:
%       whichReceptor     - Char vector with one of these values:
%                               {'L','M','S','Rod','Mel'}
%       fieldSizeDegrees  - Scalar. The eccentricity of the photoreceptor
%                           (Essentially; the field size specification is a
%                           bit complicated for historical reasons)
%       observerAgeInYears - Scalar. The observer age adjusts the spectral
%                           transmittance of the lens.
%       pupilDiameterMm   - Scalar. Has a small effect on lens
%                           transmittance.
%       returnPenumbralFlag - Logical. If set to true, the spectral
%                           sensitivity is adjusted to account for the
%                           filtering effects of hemoglobin in retinal
%                           blood vessels.
%       dphotopigment, dlens, dmac - Scalar in percentage units. These are
%                           parameters of the Asano individual difference
%                           model of variation in photoreceptor sensitivity
%       lambdaMaxShift - Scalar in nm units. Another element of the Asano
%                           model.
%       shiftType         - Char vector of either 'linear', or 'log'.
%                           Controls the manner in which the lambda max of
%                           the spectral sensitivity function is shifted.
%
% Inputs:
%   photoreceptorStruct   - Structure. Contents described above.
%   S                     - 1x3 vector, specifiying the wavelengths at
%                           which to return the spectal sensitivity.
%
% Outputs:
%   T_energyNormalized
%   T_energy
%   adjIndDiffParams
%


% Extract fields from the photoreceptorStruct into variables
fieldSizeDegrees = photoreceptorStruct.fieldSizeDegrees;
observerAgeInYears = photoreceptorStruct.observerAgeInYears;
pupilDiameterMm = photoreceptorStruct.pupilDiameterMm;
returnPenumbralFlag = photoreceptorStruct.returnPenumbralFlag;

% Get the standard structure form of the individual difference params
indDiffParams = SSTDefaultIndDiffParams();

% Extract fields from the photoreceptorStruct for pre-receptoral individual
% differences
indDiffParams.shiftType = photoreceptorStruct.shiftType;
indDiffParams.dlens = photoreceptorStruct.dlens;
indDiffParams.dmac = photoreceptorStruct.dmac;

% Obtain the quantal isomerizations for the specified receptor class
switch photoreceptorStruct.whichReceptor
    case 'L'
        idx = 1;
        % Update the indDiffParams
        indDiffParams.dphotopigment(idx) = photoreceptorStruct.dphotopigment;
        indDiffParams.lambdaMaxShift(idx) = photoreceptorStruct.lambdaMaxShiftNm;
        % Call out to ComputeCIEConeFundamentals
        [~,~,T_quantalIsomerizations,adjIndDiffParams] = ...
            ComputeCIEConeFundamentals(S,fieldSizeDegrees,observerAgeInYears,pupilDiameterMm,[],[],[],[],[],[],indDiffParams);
    case 'M'
        idx = 2;
        % Update the indDiffParams
        indDiffParams.dphotopigment(idx) = photoreceptorStruct.dphotopigment;
        indDiffParams.lambdaMaxShift(idx) = photoreceptorStruct.lambdaMaxShiftNm;
        % Call out to ComputeCIEConeFundamentals
        [~,~,T_quantalIsomerizations,adjIndDiffParams] = ...
            ComputeCIEConeFundamentals(S,fieldSizeDegrees,observerAgeInYears,pupilDiameterMm,[],[],[],[],[],[],indDiffParams);
    case 'S'
        idx = 3;
        % Update the indDiffParams
        indDiffParams.dphotopigment(idx) = photoreceptorStruct.dphotopigment;
        indDiffParams.lambdaMaxShift(idx) = photoreceptorStruct.lambdaMaxShiftNm;
        % Call out to ComputeCIEConeFundamentals
        [~,~,T_quantalIsomerizations,adjIndDiffParams] = ...
            ComputeCIEConeFundamentals(S,fieldSizeDegrees,observerAgeInYears,pupilDiameterMm,[],[],[],[],[],[],indDiffParams);
    case 'Mel'
        idx = 1;
        indDiffParams.dphotopigment = photoreceptorStruct.dphotopigment;
        indDiffParams.lambdaMaxShift = photoreceptorStruct.lambdaMaxShiftNm;
        % Call out to ComputeCIEConeFundamentals
        [~,~,T_quantalIsomerizations,adjIndDiffParams] = ComputeCIEMelFundamental(S,fieldSizeDegrees,observerAgeInYears,pupilDiameterMm,indDiffParams);
    case 'Rod'
        idx = 1;
        indDiffParams.dphotopigment = photoreceptorStruct.dphotopigment;
        indDiffParams.lambdaMaxShift = photoreceptorStruct.lambdaMaxShiftNm;
        % Call out to ComputeCIEConeFundamentals
        [~,~,T_quantalIsomerizations,adjIndDiffParams] = ComputeCIERodFundamental(S,fieldSizeDegrees,observerAgeInYears,pupilDiameterMm,indDiffParams);
end

% Retain just the requested photoreceptor (the cone routine returns all 3)
T_quantalIsomerizations = T_quantalIsomerizations(idx,:);
adjIndDiffParams.absorbance = adjIndDiffParams.absorbance(idx,:);
adjIndDiffParams.absorptance = adjIndDiffParams.absorptance(idx,:);
adjIndDiffParams.dphotopigment = adjIndDiffParams.dphotopigment(idx);

% Calculate penumbral variant
if returnPenumbralFlag

    % We assume standard parameters here to calculate the transmittance of
    % hemoglobin in retinal veins
    source = 'Prahl';
    vesselOxyFraction = 0.85;
    vesselOverallThicknessUm = 5;
    trans_Hemoglobin = GetHemoglobinTransmittance(S, vesselOxyFraction, vesselOverallThicknessUm, source);

    T_quantalIsomerizations = T_quantalIsomerizations .* trans_Hemoglobin';
end

% Convert to energy fundamentals
T_energy = EnergyToQuanta(S,T_quantalIsomerizations')';

% And normalize the energy fundamentals
T_energyNormalized = bsxfun(@rdivide,T_energy,max(T_energy, [], 2));

end