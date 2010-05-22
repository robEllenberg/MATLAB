% Plots the IGES object

% Compile the c-file
makeIGESmex;

% Load parameter data from IGES-file.
[ParameterData,EntityType,numEntityType,unknownEntityType,numunknownEntityType]=iges2matlab('example2.igs');

% There are unknown entity types for iges2matlab in example2.igs

% Plot the IGES object
plotIGES(ParameterData,2,1,30);