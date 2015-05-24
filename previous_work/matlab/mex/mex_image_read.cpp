#include "mex.h"
#include <opencv2/highgui/highgui.hpp>  
using namespace cv;

void usage() 
{
    const char *message = 
        "Read image from file.\n"
        "Usage: [data, rows, cols] = mex_image_read(fname); \n";
	mexErrMsgTxt(message); 
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])     
{
	// check arguments
    if (nrhs != 1 || mxIsChar(prhs[0]) == 0) 
        usage();

    std::string fname = mxArrayToString(prhs[0]);
//mexPrintf(&fname[0]);

    Mat im; 
    im = imread(fname, 1);
    if (!im.data)
        mexErrMsgTxt("Could not open image");
/*
char *window_name = "mex_image_read";
namedWindow(window_name, CV_WINDOW_AUTOSIZE);
imshow(window_name, im);
// */

    int N = im.dataend - im.datastart;
//mexPrintf("%d ", N);
    if (N / (im.rows*im.cols) != 3)
        mexErrMsgTxt("This function currently only works for colour images with (3 x 8-bit) pixels");

    plhs[0] = mxCreateNumericMatrix(N, 1, mxUINT8_CLASS, mxREAL);
    plhs[1] = mxCreateDoubleMatrix(1, 1, mxREAL);
    plhs[2] = mxCreateDoubleMatrix(1, 1, mxREAL);
    *mxGetPr(plhs[1]) = im.rows;
    *mxGetPr(plhs[2]) = im.cols;

    unsigned char *p = reinterpret_cast<unsigned char *>(mxGetPr(plhs[0]));
    unsigned char *pc = im.datastart;
    while (pc != im.dataend)
        *p++ = *pc++;
}
