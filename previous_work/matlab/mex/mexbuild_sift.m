function mexbuild_sift()

mex mex_sift.cpp ...
    -I'C:\Documents and Settings\tbailey\My Documents\Utilities\cpp_libraries\opencv\build\include' ...
    -L'C:\Documents and Settings\tbailey\My Documents\Utilities\cpp_libraries\opencv\build\x86\vc9\lib' ...
    -lopencv_highgui244d -lopencv_core244d -lopencv_features2d244d -lopencv_nonfree244d

% For reasons unknown to me, the SIFT algorithm core-dumps if I use the
% non-debug version of the library. Hence I am using all debug libraries

% Still core-dumps. Appears to be a memory exhaustion issue.
