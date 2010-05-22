/* HIGH ACCURACY TIMER
 *
 * compile command (needs windows SDK):
 * mex -O -inline hat.c
 *
 * Ivo Houtzager
 */

#include "windows.h"
#include "mex.h"


void hightimer( double *hTimePtr )
{
    LARGE_INTEGER counter, frequency;
    double sec_per_tick, total_ticks;

	/* retrieves the frequency of the high-resolution performance counter */
    QueryPerformanceFrequency( &frequency );
    sec_per_tick = ( double )1 / ( double )frequency.QuadPart;

    /* retrieves the current value of the high-resolution performance counter */
    QueryPerformanceCounter( &counter );
    total_ticks = ( double )counter.QuadPart;

	/* time in seconds */
    *hTimePtr = sec_per_tick * total_ticks;

    return;
}	/* end hightimer */


void mexFunction( int nlhs, mxArray *plhs[], int nrhs,
                  const mxArray *prhs[] )
{
    double hTime;

    /* check for proper number of arguments */
    if ( nrhs != 0 ) {
        mexErrMsgTxt( "No arguments required." );
    }

    /* do the actual computations in a subroutine */
	hightimer( &hTime );

	/* create a matrix for the return argument */
    plhs[0] = mxCreateDoubleScalar( hTime );

    return;
}	/* end mexFunction */