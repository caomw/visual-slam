#include "mex.h"
#include <opencv2/highgui/highgui.hpp>  
#include <opencv2/imgproc/imgproc.hpp>
using namespace cv;

void usage() 
{
    const char *message = 
        "Remap an image with linear interpolation.\n"
        "Usage: im = mex_remap(im, rows, cols, mapx, mapy); \n";
	mexErrMsgTxt(message); 
}

template <typename T1, typename T2>
void copy_array(T1 *pout, const T2 *begin, const T2 *end)
{
    while (begin != end)
        *pout++ = *begin++;
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])     
{
	// check arguments
    if (nrhs != 5) 
        usage();

    // Get image dimensions
    int rows = static_cast<int>(*mxGetPr(prhs[1]));
    int cols = static_cast<int>(*mxGetPr(prhs[2]));
    int len = mxGetM(prhs[0]); // note, im must be a column vector
    int dim = len / (rows*cols);
    if (dim != 1 && dim != 3)
        mexErrMsgTxt("Image must be 8-bit colour or grayscale.");
    
    // Get image
    int type = (dim == 1) ? CV_8U : CV_8UC3;
    Mat im(rows, cols, type); 
    unsigned char *begin = reinterpret_cast<unsigned char*>(mxGetPr(prhs[0]));
    copy_array(im.data, begin, begin+len);

    // Get mapping matrices
    Mat mapx(rows, cols, CV_32F);
    Mat mapy(rows, cols, CV_32F); 
    copy_array(reinterpret_cast<float*>(mapx.data), mxGetPr(prhs[3]), mxGetPr(prhs[3])+mxGetM(prhs[3]));
    copy_array(reinterpret_cast<float*>(mapy.data), mxGetPr(prhs[4]), mxGetPr(prhs[4])+mxGetM(prhs[4]));

    // Do remap
#if 0
    remap(im, im, mapx,  mapy,  INTER_LINEAR); // Seems to work, but OpenCV documentation says remap cannot operate inplace (p254)
#else
    Mat dest(rows, cols, type); // Non-inplace operation
    remap(im, dest, mapx,  mapy,  INTER_LINEAR);
    im = dest;
#endif        

    // Copy image to output
    plhs[0] = mxCreateNumericMatrix(len, 1, mxUINT8_CLASS, mxREAL);
    copy_array(reinterpret_cast<unsigned char*>(mxGetPr(plhs[0])), im.data, im.dataend);
}
