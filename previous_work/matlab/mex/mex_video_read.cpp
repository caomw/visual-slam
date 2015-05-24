#include "mex.h"
#include <opencv2/highgui/highgui.hpp>  
using namespace cv;

static VideoCapture vidhandle;

void usage() 
{
    const char *message = 
        "Read images from video file.\n"
        "Usage: mex_video_read(fname); \n"
        "       [data, rows, cols] = mex_video_read; \n";
	mexErrMsgTxt(message); 
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])     
{
    // Initialise video
    if (nlhs == 0 && nrhs == 1 && mxIsChar(prhs[0])) {
        if (vidhandle.isOpened()) vidhandle.release(); 
        std::string fname = mxArrayToString(prhs[0]);
        if (fname != "") {
            vidhandle.open(fname);
            if (!vidhandle.isOpened()) mexErrMsgTxt("Could not open video file");             
        }
    }
    // Get next image
    else if (nlhs == 3 && nrhs == 0) {
        if (!vidhandle.isOpened())
            mexErrMsgTxt("No open video file"); 

        Mat frame;    
        vidhandle >> frame;

        int N = frame.dataend - frame.datastart;
        if (N == 0) // end of file 
            vidhandle.release(); 
        else if (N / (frame.rows*frame.cols) != 3)
            mexErrMsgTxt("Video frames must be 8-bit colour");

        plhs[0] = mxCreateNumericMatrix(N, 1, mxUINT8_CLASS, mxREAL);
        plhs[1] = mxCreateDoubleMatrix(1, 1, mxREAL);
        plhs[2] = mxCreateDoubleMatrix(1, 1, mxREAL);
        *mxGetPr(plhs[1]) = frame.rows;
        *mxGetPr(plhs[2]) = frame.cols;

        unsigned char *p = reinterpret_cast<unsigned char *>(mxGetPr(plhs[0]));
        unsigned char *pc = frame.datastart;
        while (pc != frame.dataend)
            *p++ = *pc++;
    }
    else
        usage();
}
