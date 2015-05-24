#include "mex.h"
#include <opencv2/highgui/highgui.hpp>  
#include "opencv2/nonfree/nonfree.hpp"
using namespace cv;

//#define DESCRIPT_FLAGS 0x42ff4005
#define NUM_KEYPOINT_TERMS 7

void matrix2keypoints(vector<KeyPoint> &kpnts, const double *kmat)
{
    for (unsigned i = 0; i < kpnts.size(); ++i) {
        KeyPoint &ki = kpnts[i];
        ki.pt.x = static_cast<float>(*kmat++);
        ki.pt.y = static_cast<float>(*kmat++);
        ki.size = static_cast<float>(*kmat++);
        ki.angle = static_cast<float>(*kmat++);
        ki.response = static_cast<float>(*kmat++);
        ki.octave = static_cast<int>(*kmat++);
        ki.class_id = static_cast<int>(*kmat++);
    }
}

void keypoints2matrix(double *kmat, const vector<KeyPoint> &kpnts)
{
    for (unsigned i = 0; i < kpnts.size(); ++i) {
        const KeyPoint &ki = kpnts[i];
        *kmat++ = ki.pt.x;
        *kmat++ = ki.pt.y;
        *kmat++ = ki.size;
        *kmat++ = ki.angle;
        *kmat++ = ki.response;
        *kmat++ = ki.octave;
        *kmat++ = ki.class_id;
    }
}

void array2image(Mat &im, const unsigned char *parr)
{
    unsigned char *p = im.data;
    while(p != im.dataend)
        *p++ = *parr++;
}

void usage() 
{
    const char *message = 
        "Extract SIFT keypoints and descriptors.\n"
        "Usage: [keys, descrpt] = mex_sift(imgray, rows, cols, imask, keys, nfeat, noctaves, contrast, edge, sigma); \n";
	mexErrMsgTxt(message); 
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])     
{
    // Check arguments
    if (nrhs != 10)
        usage();

    // Get grayscale image
    unsigned char *pim = reinterpret_cast<unsigned char *>(mxGetPr(prhs[0]));
    int rows = static_cast<int>(*mxGetPr(prhs[1]));
    int cols = static_cast<int>(*mxGetPr(prhs[2]));
    if (mxGetM(prhs[0])*mxGetN(prhs[0]) != rows*cols)
        mexErrMsgTxt("Image data does not match expected rows and columns");
    Mat im(rows, cols, CV_8U);
    array2image(im, pim);
/*
char *window_name = "mex_image_read";
namedWindow(window_name, CV_WINDOW_AUTOSIZE);
imshow(window_name, im);
//*/

    // Get mask
    unsigned char *pmask = reinterpret_cast<unsigned char *>(mxGetPr(prhs[3]));
    Mat mask; 
    if (pmask) {
        if (mxGetM(prhs[3])*mxGetN(prhs[3]) != rows*cols)
            mexErrMsgTxt("Mask data does not match expected rows and columns");
        mask = Mat(rows, cols, CV_8U);
        array2image(mask, pmask);
    }

    // Get keypoints
    vector<KeyPoint> kpnts; 
    double *kpnts_in = mxGetPr(prhs[4]);
    if (kpnts_in) {
        if (mxGetM(prhs[4]) != NUM_KEYPOINT_TERMS)
            mexErrMsgTxt("Invalid format for input keypoints");
        int N = mxGetN(prhs[4]);
        kpnts.resize(N);
        matrix2keypoints(kpnts, kpnts_in);
    }

    // Get feature options
    int nfeat = static_cast<int>(*mxGetPr(prhs[5]));
    int noctaves = static_cast<int>(*mxGetPr(prhs[6]));
    double contrast = *mxGetPr(prhs[7]);
    double edge = *mxGetPr(prhs[8]);
    double sigma = *mxGetPr(prhs[9]);
mexPrintf("%d %d %f %f %f\n", nfeat, noctaves, contrast, edge, sigma);

    // Do SIFT extraction
    SIFT detector(nfeat, noctaves, contrast, edge, sigma);
    Mat desc;
    InputArray maskin = (pmask) ? mask : noArray();
    OutputArray descout = (nlhs == 2) ? desc : noArray();
    try {
        detector(im, maskin, kpnts, descout, kpnts.size() > 0);
    }
    catch (...) {
        mexErrMsgTxt("SIFT failed. Probably memory exhaustion");
    }
// detector(im, noArray(), kpnts, desc, 0);

    // Convert results
    plhs[0] = mxCreateDoubleMatrix(NUM_KEYPOINT_TERMS, kpnts.size(), mxREAL);
    keypoints2matrix(mxGetPr(plhs[0]), kpnts);
    if (nlhs == 2) {
        plhs[1] = mxCreateDoubleMatrix(desc.cols, desc.rows, mxREAL);
        double *p = mxGetPr(plhs[1]);
        float *pdesc = reinterpret_cast<float*>(desc.data);
        float *pend = reinterpret_cast<float*>(desc.dataend);
        while (pdesc != pend)
            *p++ = *pdesc++;
    }
}
