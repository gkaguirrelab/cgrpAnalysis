function xy_distance = chromaDistance(spdA,spdB,wavelengthsNm)

% Load the XYZ fundamentals
load('T_xyz1931.mat','T_xyz1931','S_xyz1931');
S = WlsToS(wavelengthsNm);
T_xyz = SplineCmf(S_xyz1931,683*T_xyz1931,S);

% Calculate the luminance and the chromaticities
spdB_xy = (T_xyz(1:2,:)*spdB/sum(T_xyz*spdB));
for ii = 1:size(spdA,2)
    spdA_xy = (T_xyz(1:2,:)*spdA(:,ii)/sum(T_xyz*spdA(:,ii)));
    xy_distance(1,ii) = norm(spdA_xy-spdB_xy);
end

end