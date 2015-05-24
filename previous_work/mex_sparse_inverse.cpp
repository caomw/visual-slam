/*--------------------
 
	P = mex_sparse_inverse(L)

/*--------------------*/

#include "mex.h"
extern "C" {
#include "sparse_inverse.h"
}

template <typename T>
void copy(const T* s, T* d, size_t N)
{
    while (N--)
        *d++ = *s++;
}

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )     
{
	// Check arguments
    if (nrhs != 1 || nlhs > 1) 
		mexErrMsgTxt("Usage: P = mex_sparse_inverse(L)\n\twhere L = chol(Y, 'lower');"); 
    if (mxIsSparse(prhs[0]) == 0)
		mexErrMsgTxt("Matrix L must be sparse");
    if (mxGetM(prhs[0]) != mxGetN(prhs[0]))
		mexErrMsgTxt("Matrix L must be square");
    if (mxGetPi(prhs[0]) != NULL)
        mexErrMsgTxt("Matrix L must be real");

	// Input data
	const int N = mxGetM(prhs[0]);
	const int Nz = mxGetNzmax(prhs[0]); 
    double *pr = mxGetPr(prhs[0]);
    mwIndex *ir = mxGetIr(prhs[0]);
    mwIndex *jc = mxGetJc(prhs[0]);
    SparseMatrix L = { N, Nz, ir, jc, pr };
    if (is_lower(&L) == 0)
        mexErrMsgTxt("Matrix L must be lower triangular");

    // Compute sparse inverse
    SparseMatrix *P = sparse_inverse(&L, NULL, NULL);

    // Copy to Matlab output
    plhs[0] = mxCreateSparse(N, N, P->nz, mxREAL);
    copy(P->x, mxGetPr(plhs[0]), P->nz);
    copy(P->i, mxGetIr(plhs[0]), P->nz);
    copy(P->j, mxGetJc(plhs[0]), P->N + 1);

    // Cleanup
    destroy_sparse_matrix(P);
}
