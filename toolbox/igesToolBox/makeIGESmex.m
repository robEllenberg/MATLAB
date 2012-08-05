function makeIGESmex()
% Makefile
% run
% >> makeIGESmex
% in MATLAB for compiling the source code in the iges2matlab toolbox.

try
    mex -v nrbevalIGES.c
end

try
    mex -v closestNrbLinePointIGES.c
end