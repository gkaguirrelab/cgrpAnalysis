function photoreceptors = photoreceptorDictionary(varargin)

p = inputParser;
p.parse(varargin{:});

% The set of photoreceptor classes
photoreceptorClassNames = {'rodentS','rodentMel','rodentRod','rodentML','humanL'};

for ii = 1:length(photoreceptorClassNames)

    % assign the name of the photoreceptor
    photoreceptors(ii).name = photoreceptorClassNames{ii};

    switch photoreceptors(ii).name
        case 'rodentS'
            photoreceptors(ii).whichReceptor = 'sc';
            photoreceptors(ii).plotColor = SSTDefaultReceptorColors('SCone');
        case 'rodentMel'
            photoreceptors(ii).whichReceptor = 'mel';
            photoreceptors(ii).plotColor = SSTDefaultReceptorColors('Mel');
        case 'rodentRod'
            photoreceptors(ii).whichReceptor = 'rh';
            photoreceptors(ii).plotColor = SSTDefaultReceptorColors('SCone');
        case 'rodentML'
            photoreceptors(ii).whichReceptor = 'mc';
            photoreceptors(ii).plotColor = SSTDefaultReceptorColors('MCone');
        case 'humanL'
            photoreceptors(ii).whichReceptor = 'L';
            photoreceptors(ii).plotColor = SSTDefaultReceptorColors('LCone');
        otherwise
            error('Not a recognized photoreceptor')

    end

end


end