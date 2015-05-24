#include "mex.h"
#include <opencv2/highgui/highgui.hpp>  
#include "opencv2/nonfree/nonfree.hpp"
using namespace cv;

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])     
{
    cv::Mat img1 = imread("./test.png", CV_LOAD_IMAGE_GRAYSCALE);
    if (img1.empty()) mexErrMsgTxt("Couldn't open image"); 
    cv::SIFT sift(400);
    vector<cv::KeyPoint> kpntsd; 
    cv::Mat descd;
//return;
    sift(img1, noArray(), kpntsd, descd, 0);
}
