#include "mex.h"
#include <opencv2/highgui/highgui.hpp>  
using namespace cv;

class VidHandle {
    VideoCapture *vid;
public:
    VidHandle() { vid = new VideoCapture; }
    ~VidHandle() { // workaround: fixes OpenCV's dodgy lack of memory management
        mexPrintf("Releasing");
        if (vid->isOpened()) vid->release();
        delete vid;
    }
    VideoCapture &get() { return *vid; }
};

static VidHandle vidhandle;

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
    VideoCapture &vid = vidhandle.get();

    // Initialise video
    if (nlhs == 0 && nrhs == 1 && mxIsChar(prhs[0])) {
        // if (vidhandle.isOpened()) vidhandle.release();  // automatically called on VideoCapture::open()
        std::string fname = mxArrayToString(prhs[0]);
        vid.open(fname);
        if (!vid.isOpened())
            mexErrMsgTxt("Could not open video file"); 
    }
    // Get next image
    else if (nlhs == 3 && nrhs == 0) {
        if (!vid.isOpened())
            mexErrMsgTxt("No open video file"); 

        Mat frame;    
        vid >> frame;

        int N = frame.dataend - frame.datastart;
        if (N == 0) { // end of file 
            vid.release();
            N = 1;       
        }
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
