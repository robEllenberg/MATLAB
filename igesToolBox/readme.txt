


			             IGES TOOLBOX FOR MATLAB
			             =======================


This is a version of the free IGES toolbox for MATLAB. It can be downloaded at Mathworks file exchange community site.

http://www.mathworks.com/matlabcentral/fileexchange/13253-iges-toolbox

This version cannot handle all IGES entity types but I hope this toolbox will be of great help for you to do
calculations on IGES entities. To add more entities in iges2matlab, read and understand
the IGES Specification version5x.pdf found at

http://www.iges5x.org/archives/version5x/version5x.pdf

If you would like to share your upgraded version with other, please send it to
me, per.bergstrom@ltu.se. 

In this version the source file "nrbevalIGES.c" and "closestNrbLinePointIGES.c" are submitted.
Compile it in MATLAB by running "makeIGESmex" in the Command window. Precompiled Windows versions
are submitted but non Windows user must first compile the source-code before they can use it.
See "help mex" in MATLAB for more information.

Run "example", "exampleProjection" or "example2" in MATLAB's Command window for examples.

Mesh2d v2.3 by Darren Engwirda;

http://www.mathworks.com/matlabcentral/fileexchange/25555-mesh2d-automatic-mesh-generation

is used for meshing the surfaces.



				            MAIN FUNCTIONS
				            ==============


iges2matlab
-----------

Function for converting IGES-file data to a Matlab-object. Cannot handle all IGES-entity types.



plotIGES
--------

Plots lines, curves, points and surfaces in the IGES-file.



transformIGES
-------------

Transform the parameter data in the IGES-file with a rotation/reflection matrix and a translation vector.



projIGES
--------

Returns points of projections on surfaces from an IGES-file.



projpartIGES
------------

Returns points of projections on part of surfaces from an IGES-file.
See "exampleProjection.m" for help of usage.



				             SUBFUNCTIONS
				             ============


retSrfCrvPnt
------------

Returns values from surfaces, curves and points. No complete documentation is
given.



nrbevalIGES (mex function)
--------------------------

Evaluates NURBS and derivatives of NURBS.



nrbDerivativesIGES
------------------

Returns first and second derivative of NURBS.



closestNrbLinePointIGES (mex function)
--------------------------------------

Returns the closest point to a NURBS patch and line/point.



makeIGESmex
-----------

m-file for compiling mex files.



For more documentation about the functions above, see the help for each function in Matlab.

If you like this toolbox and have use of it, please let me know that.



More documentation for nrbevalIGES
----------------------------------

/**************************************************************************
 *
 * function [P,Pu,Pv,Puu,Puv,Pvv]=nrbevalIGES(nurbs,UV,dnurbs,d2nurbs)
 *
 * Evaluates NURBS (and its derivatives) at given parametric values in Matlab.
 *
 * Usage 1 in Matlab (NURBS curve):
 *
 * P=nrbevalIGES(nurbs,UV)
 * [P,Pu]=nrbevalIGES(nurbs,UV,dnurbs)
 * [P,Pu,Puu]=nrbevalIGES(nurbs,UV,dnurbs,d2nurbs)
 *
 * UV - 1xN matrix, N number of u-parameters
 *
 * Usage 2 in Matlab (NURBS surface):
 *
 * P=nrbevalIGES(nurbs,UV)
 * [P,Pu,Pv]=nrbevalIGES(nurbs,UV,dnurbs)
 * [P,Pu,Pv,Puu,Puv,Pvv]=nrbevalIGES(nurbs,UV,dnurbs,d2nurbs)
 *
 * UV - 2xN matrix, N number of (u,v)-parameters
 *
 * Input:
 * nurbs - NURBS structure
 * UV - Parameter values
 * dnurbs,d2nurbs - NURBS derivatives (output from nrbDerivativesIGES).
 *
 * Output:
 * P - Points (evaluated NURBS).
 * Pu,Pv - First derivatives.
 * Puu,Puv,Pvv - Second derivatives.
 *
 * c-file can be downloaded for free at
 *
 * http://www.mathworks.com/matlabcentral/fileexchange/13253-iges-toolbox
 *
 * compile in Matlab by using the command  "mex nrbevalIGES.c"
 *
 * See "help mex" for more information
 *
 * written by Per Bergström 2009-12-04
 * per.bergstrom at ltu.se
 *
 **************************************************************************/


More documentation for closestNrbLinePointIGES
----------------------------------------------

/**************************************************************************
 *
 * function [P,UV]=closestNrbLinePointIGES(nurbs,dnurbs,d2nurbs,UV0,r0,v)
 *
 * Closest points of NURBS patch and line/point using Newton's Method.
 *
 * Line (3D):  r=r0+t*v
 * Point (3D): r0
 *
 * Usage in Matlab:
 *
 * § Closest NURBS-point to line
 * [P,UV]=closestNrbLinePointIGES(nurbs,dnurbs,d2nurbs,UV0,r0,v)
 *
 * § Closest NURBS-point to point
 * [P,UV]=closestNrbLinePointIGES(nurbs,dnurbs,d2nurbs,UV0,r0)
 *
 * Input:
 * nurbs - NURBS structure
 * dnurbs,d2nurbs - NURBS derivatives (output from nrbDerivativesIGES).
 * UV0 - Initial start Parameter values
 * r0,(v) - See Line/Point (3D) above. r0 (and v) must have the dimension (3x{1 or N})
 *          If size (3x1) - same point/line is used, if size (3xN) - different point/lines are used.
 *
 * Curve
 * UV0 - 1xN matrix, N number of u-parameters
 *
 * Surface
 * UV0 - 2xN matrix, N number of (u,v)-parameters
 *
 * Output:
 * P - Closest points on NURBS patch.
 * UV - NURBS Parameter values at closest point. (same dimension as UV0)
 *
 * c-file can be downloaded for free at
 *
 * http://www.mathworks.com/matlabcentral/fileexchange/13253-iges-toolbox
 *
 * compile in Matlab by using the command  "mex closestNrbLinePointIGES.c"
 *
 * See "help mex" for more information
 *
 * written by Per Bergström 2009-12-04
 * per.bergstrom at ltu.se
 *
 **************************************************************************/

The folder OLD contains old m-files of non mex-files and the folder mexSourceFiles
contains source code for subfunctions of the mex-files.

/ Per Bergström

per.bergstrom@ltu.se




 
