
function contrastReceptors = calcUnipolarContrastReceptors(modulationPrimary,backgroundPrimary,T_receptors,B_primary,ambientSpd)

% For the unipolar case, the "background" is the negative primary
negativePrimary = (backgroundPrimary-(modulationPrimary - backgroundPrimary));

% Obtain the isomerization rate for the receptors by the background
negativeReceptors = T_receptors*(B_primary*negativePrimary + ambientSpd);

% Calculate the positive receptor contrast and the differences
% between the targeted receptor sets
modulationReceptors = T_receptors*B_primary*modulationPrimary;
contrastReceptors = modulationReceptors ./ negativeReceptors;

end