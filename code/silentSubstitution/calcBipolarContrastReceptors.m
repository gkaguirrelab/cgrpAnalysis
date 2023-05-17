function contrastReceptors = calcBipolarContrastReceptors(modulationPrimary,backgroundPrimary,T_receptors,B_primary,ambientSpd)

% Obtain the isomerization rate for the receptors by the background
backgroundReceptors = T_receptors*(B_primary*backgroundPrimary + ambientSpd);

% Calculate the positive receptor contrast and the differences
% between the targeted receptor sets
modulationReceptors = T_receptors*B_primary*(modulationPrimary - backgroundPrimary);
contrastReceptors = modulationReceptors ./ backgroundReceptors;

end