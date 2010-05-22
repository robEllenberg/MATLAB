% Plots the IGES object

% Compile the c-file
makeIGESmex;

% Load parameter data from IGES-file.
[ParameterData,EntityType,numEntityType,unknownEntityType,numunknownEntityType]=iges2matlab('example.igs');

% Plot the IGES object
plotIGES(ParameterData,1);