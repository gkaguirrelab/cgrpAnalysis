function T_energyNormalized = returnRodentSpectralSensitivity(photoreceptorStruct,S)
% Provides the spectral sensitivity function for a specified photoreceptor
%
% Syntax:
%  T_energyNormalized = returnRodentSpectralSensitivity(photoreceptorStruct,S)
%
% Description:
%   Provides the spectral sensitivity of a specified rodent photoreceptors at
%   the wavelengths specified by S. The sensitivity is expressed as energy 
%   (isomerizations-per-second as a function of radiance expressed in
%   Watts), normalized to a max of 1. The spectral sensitivity is expressed
%   relative to light arriving at the cornea.
%
%   The values used are derived from the Lucas lab (see README.txt file in
%   the data directory). Additionally, we generate a human L cone class and
%   subject it to rodent pre-receptoral filtering (WORK IN PROGRESS).
%
%   The properties of the photoreceptor are specified in the passed
%   photoreceptorStruct. The required fields are:
%       whichReceptor     - Char vector with one of these values:
%                               {'sc','mel','rh','mc','L'}
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

% Load the Lucas data
rodentFileName = fullfile(tbLocateProject('cgrpAnalysis'),'data','rodent_action_spectra.csv');
rodentTable = readtable(rodentFileName);

% Obtain the quantal isomerizations for the specified receptor class
switch photoreceptorStruct.whichReceptor
    case 'sc'
        T_energyNormalized = rodentTable.sc;
        wavelenghtsIn = rodentTable.Wavelength;
        T_energyNormalized = interp1(wavelenghtsIn,T_energyNormalized,SToWls(S));        
    case 'mel'
        T_energyNormalized = rodentTable.mel;
        wavelenghtsIn = rodentTable.Wavelength;
        T_energyNormalized = interp1(wavelenghtsIn,T_energyNormalized,SToWls(S));        
    case 'rh'
        T_energyNormalized = rodentTable.rh;
        wavelenghtsIn = rodentTable.Wavelength;
        T_energyNormalized = interp1(wavelenghtsIn,T_energyNormalized,SToWls(S));        
    case 'mc'
        T_energyNormalized = rodentTable.mc;
        wavelenghtsIn = rodentTable.Wavelength;    
        T_energyNormalized = interp1(wavelenghtsIn,T_energyNormalized,SToWls(S));        
    case 'L'
        % Hard code some human pre-receptoral filtering properties
        idx = 1;
        fieldSizeDegrees = 10;
        observerAgeInYears = 20;
        pupilDiameterMm = 2;
        % Call out to ComputeCIEConeFundamentals
        [~,~,T_quantalIsomerizations] = ...
            ComputeCIEConeFundamentals(S,fieldSizeDegrees,observerAgeInYears,pupilDiameterMm,[],[],[],[],[],[],[]);
        % Convert to energy fundamentals
        T_energy = EnergyToQuanta(S,T_quantalIsomerizations(idx,:)')';
        % And normalize the energy fundamentals
        T_energyNormalized = bsxfun(@rdivide,T_energy,max(T_energy, [], 2));
end



end