#include "mex.h"
#include <opencv2/calib3d/calib3d.hpp>
using namespace cv;

StereoSGBM default_sgbm(int cn)
{
	StereoSGBM sgbm;
	sgbm.minDisparity = 0;
	sgbm.numberOfDisparities = 80; // must be divisible by 16.
	sgbm.SADWindowSize = 5;
    int M = cn*sgbm.SADWindowSize*sgbm.SADWindowSize;
	sgbm.P1 = 8*M;  
	sgbm.P2 = 32*M; 
	sgbm.disp12MaxDiff = 1;
	sgbm.preFilterCap = 63; 
	sgbm.uniquenessRatio = 10; 
	sgbm.speckleWindowSize = 200; 
	sgbm.speckleRange = 2; 
	sgbm.fullDP = true; 
    return sgbm;
}

void usage() 
{
    const char *message = 
        "Compute SGBM disparity from rectified stereo image pairs.\n"
        "Usage: disparity = mex_image_read(rows, cols, imleft, imright); \n";
        //"Usage: disparity = mex_image_read(rows, cols, imleft, imright, options); \n";
	mexErrMsgTxt(message); 
}

template <typename T1, typename T2>
void copy_array(T1 *pout, const T2 *begin, const T2 *end)
{
    while (begin != end)
        *pout++ = *begin++;
}

Mat get_image(int rows, int cols, const mxArray *pim)     
{
    // Get image dimensions
    int len = mxGetM(pim)*mxGetN(pim);
    int dim = len/(rows*cols);
    if (dim != 1 && dim != 3)
        mexErrMsgTxt("Image must be 8-bit colour or grayscale.");
    
    // Get image
    int type = (dim == 1) ? CV_8U : CV_8UC3;
    Mat im(rows, cols, type); 
    unsigned char *begin = reinterpret_cast<unsigned char*>(mxGetPr(pim));
    copy_array(im.data, begin, begin+len);
    return im;
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])     
{
	// Check arguments
    if (nrhs == 5) mexErrMsgTxt("Options for SGBM not yet implemented");
    if (nrhs != 4) 
        usage();

    // Get images 
    int rows = static_cast<int>(*mxGetPr(prhs[0]));
    int cols = static_cast<int>(*mxGetPr(prhs[1]));
    Mat im1 = get_image(rows, cols, prhs[2]);
    Mat im2 = get_image(rows, cols, prhs[3]);

    // Compute disparity
    StereoSGBM sgbm = default_sgbm(im1.channels());
    Mat disparity; 
    sgbm(im1, im2, disparity);

    // Copy image to output
    plhs[0] = mxCreateNumericMatrix(rows*cols, 1, mxINT16_CLASS, mxREAL);
    copy_array(reinterpret_cast<unsigned char*>(mxGetPr(plhs[0])), disparity.data, disparity.dataend);
}
