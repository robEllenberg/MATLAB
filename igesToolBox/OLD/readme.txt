


			             IGES TOOLBOX FOR MATLAB
			             =======================


This is a version of the free IGES toolbox for MATLAB. It can be downloaded at 
Mathworks file exchange community site. This version can not handle all IGES entity types
but I hope this toolbox will be of great help to do calculations on entities for
you in your IGES file. To add more entities in iges2matlab, read and understand
the IGES Specification version5x.pdf found at

http://www.iges5x.org/archives/version5x/version5x.pdf

If you would like to share your upgraded version with other, please send it to
me, per.bergstrom@ltu.se. 

In this version the source file "bspeval.c" is submited. To compile it in MATLAB. type "mex bspeval.c"
in MATLAB Command Window. A precompiled Windows version (bspeval.dll(.old)/bspeval.mexw32) is submited but
non Windows user must first compile the C-code before they can use it.
See "help mex" in MATLAB for more information.
Run "example", "exampleProjection" or "example2" in MATLAB's command window for examples.
If you are using Windows and have troubles with the bspeval.mexw32 and cannot
compile the bspeval.c, use bspeval.dll after removing the ending ".old".

Mesh2d v2.3 by Darren Engwirda (http://www.mathworks.com/matlabcentral/fileexchange/10307)
is used for meshing the surfaces.



				            MAIN FUNCTIONS
				            ==============


IGES2MATLAB
-----------

Function for converting IGES file data to a Matlab object. Can not handle all IGES entity types.



PLOTIGES
--------

Plots lines, curves, points and surfaces from IGES file.



TRANSFORMIGES
-------------

Transform the parameter data in IGES file with a rotation/reflection matrix and a translation vector.



PROJIGES
--------

Returns points of projections on surfaces from an IGES-file.



PROJPARTIGES
------------

Returns points of projections on part of surfaces from an IGES-file.
See "exampleProjection.m" for help of usage.



				             SUBFUNCTIONS
				             ============


RETSRFCRVPNT
------------

Returns values from surfaces, curves and points. No complete documentation is
given.



NRBEVALIGES
-----------

Evaluates NURBS and derivatives of NURBS.



NRBDERIVATIVESIGES
------------------

Returns first and second derivative of NURBS.



CLOSESTNRBLINEPOINTIGES
-----------------------

Returns the closest point to a NURBS patch and line/point.



BSPEVAL.DLL (MEX)
-----------------

Evaluates points on a B-spline curve at given parametric values. 




For more documentation about the functions above, see the help for each function in Matlab.

If you like this toolbox and have use of it, please let me know that.




/ Per Bergström

per.bergstrom@ltu.se




 