function [newS,newB_primary,newAmbientSPD] = addSynthesizedUVSPD(cal)

% We are not able to directly measure the SPD of the 365 nm LED. Instead,
% we digitized the SPD from the spec sheet "LED 365 nm Spectral Plot.pdf"
% which is stored in the data directory.
%
% We then fit the sampled points with a cubic spline, define a desired S,
% and then return the spline-interpolated SPD
%
% Further, we believe that the max power of the UV LEDs is 50% of the max
% power of the "blue" (460 nm) LED. We base this upon the following:
%
%  The Wall Plug Efficiency (wpe) of the 460 nm LED is 33%, implying that
%  33% of electrical power is converted to optical power. The power draw /
%  foot of LED for the 460 nm LED is 4.5 Watts, resulting in 1.485 optical
%  watts / foot of peak output.
%
%  The wpe of the 365 nm LED is 15%, and the power draw is 4.8 W/foot,
%  resulting in 0.72 optical watts / foot. This is just about half of the
%  blue LED value.
% 

% Define the scale factor that relates the power of the 365 LED to the
% power of the 460 nm LED
scaleFactor = 0.5;

% Extract some things from the passed cal
S = cal.rawData.S;
B_primary = cal.processedData.P_device;
ambientSpd = cal.processedData.P_ambient;
nPrimaries = size(B_primary,2);
wavelengthsNm = SToWls(S);

% Hard code the identity of the two relevant primaries
uvPrimaryIdx = 3;
bluePrimaryIdx = 2;

% Define an S
newS = [300 2 241];
newWavelengthsNm = SToWls(newS);

% Spectral power distribution digitized for 365 LED from spec sheet
spdRaw = [334.56310679611653, 0.0066006600660066805
340.58252427184465, 0.0066006600660066805
346.79611650485435, 0.00990099009900991
351.84466019417476, 0.01980198019801982
354.75728155339806, 0.04950495049504955
356.8932038834951, 0.10561056105610578
358.252427184466, 0.17161716171617147
359.02912621359224, 0.22442244224422447
360, 0.32013201320132023
361.1650485436893, 0.44884488448844884
362.13592233009706, 0.5643564356435643
362.9126213592233, 0.6864686468646864
363.68932038834953, 0.8151815181518152
364.8543689320388, 0.9339933993399341
365.63106796116506, 0.9801980198019802
366.9902912621359, 0.976897689768977
368.15533980582524, 0.8976897689768977
368.7378640776699, 0.8283828382838284
369.90291262135923, 0.7260726072607261
371.06796116504853, 0.5610561056105611
372.81553398058253, 0.41254125412541254
375.1456310679612, 0.250825082508251
377.86407766990294, 0.13531353135313529
381.3592233009709, 0.06270627062706269
390.4854368932039, 0.013201320132013361
400, 0.0033003300330032292
407.96116504854365, 0.0033003300330032292
420.77669902912623, 0
453.20388349514565, 0.0033003300330032292
];

% Fit a spline to the raw spd data
spdPortion = spline(spdRaw(:,1),spdRaw(:,2),340:2:400);

% Place the splined portion into a zero array
spd = zeros(size(newWavelengthsNm));
[~,idx1] = min(abs(newWavelengthsNm-340));
[~,idx2] = min(abs(newWavelengthsNm-400));
spd(idx1:idx2) = spdPortion;

% Scale by the max value
B_365LED = spd / max(spd);

% Scale the 365 LED by the scaleFactor for power
B_365LED = B_365LED * max(B_primary(:,bluePrimaryIdx)) * scaleFactor;

% Create a transmittance spectrum for the SUVT acrylic. The light from the
% UV LED passes through this.
suvtFileName = fullfile(tbLocateProjectSilent('cgrpAnalysis'),'data','SUVT_Acryilic_transmittance.csv');
suvtTable = readtable(suvtFileName);

minWl = floor(min(suvtTable{:,1})/2)*2;
maxWl = ceil(max(suvtTable{:,1})/2)*2;

transmitPortion = spline(suvtTable{:,1},suvtTable{:,2},minWl:2:maxWl);
transmittance = zeros(size(newWavelengthsNm))+max(transmitPortion);
idx1 = find((minWl:2:maxWl)==newWavelengthsNm(1));
[~,idx2] = min(abs(newWavelengthsNm-maxWl));
transmittance(1:idx2) = transmitPortion(idx1:end);

% Apply the diffusion filter
B_365LED = B_365LED.*(transmittance/100);

% Now expand the original B_primary matrix to the newS range
newB_primary = zeros(length(newWavelengthsNm),nPrimaries);

% populate the new ambient with the mean ambient from the first 50
% wavelengths measured
newAmbientSPD = zeros(length(newWavelengthsNm),1) + mean(ambientSpd(1:50));

[~,idx1] = min(abs(newWavelengthsNm-min(wavelengthsNm)));
[~,idx2] = min(abs(newWavelengthsNm-max(wavelengthsNm)));

% Copy over the old B_primary into the new B_primary
newB_primary(idx1:idx2,:) = B_primary;
newAmbientSPD(idx1:idx2) = ambientSpd;

% Now sub in the synthesized UV
newB_primary(:,uvPrimaryIdx) = B_365LED;

end
