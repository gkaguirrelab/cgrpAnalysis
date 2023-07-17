function path = tbLocateProjectSilent(projectName)
% Shadows tbLocalteProject to return the path silently

prefs = tbParsePrefs([]);
prefs.verbose = false;
path = tbLocateProject(projectName,prefs);

end