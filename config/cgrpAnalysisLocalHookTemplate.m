function cgrpAnalysisLocalHook

%  cgrpAnalysisLocalHook
%
% Configure things for working on the cgrpAnalysis project.
%
% For use with the ToolboxToolbox.
%
% If you 'git clone' cgrpAnalysis into your ToolboxToolbox "projectRoot"
% folder, then run in MATLAB
%   tbUseProject('cgrpAnalysis')
% ToolboxToolbox will set up cgrpAnalysis and its dependencies on
% your machine.
%
% As part of the setup process, ToolboxToolbox will copy this file to your
% ToolboxToolbox localToolboxHooks directory (minus the "Template" suffix).
% The defalt location for this would be
%   ~/localToolboxHooks/cgrpAnalysisLocalHook.m
%
% Each time you run tbUseProject('cgrpAnalysis'), ToolboxToolbox will
% execute your local copy of this file to do setup for cgrpAnalysis.
%
% You should edit your local copy with values that are correct for your
% local machine, for example the output directory location.
%


%% Say hello.
projectName = 'cgrpAnalysis';


%% Delete any old prefs
if (ispref(projectName))
    rmpref(projectName);
end

% Obtain the Dropbox path
[~,hostname] = system('hostname');
hostname = strtrim(lower(hostname));

% handle hosts with custom dropbox locations
switch hostname
    otherwise
        [~, userName] = system('whoami');
        userName = strtrim(userName);
        dropboxBaseDir = ...
            fullfile('/Users', userName, ...
            'Dropbox (Aguirre-Brainard Lab)');
end

%% Set preferences for project output
setpref(projectName,'dropboxBaseDir',dropboxBaseDir); % main directory path 

end