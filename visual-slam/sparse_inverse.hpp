#ifndef SPARSE_INVERSE_HPP_
#define SPARSE_INVERSE_HPP_

#include <cassert>

class ColCompressedMatrix {
public:
	ColCompressedMatrix(int N_, int nnz_, const double *data_, const int *colstrt_, const int *rowidx_);
	int top(int i) { check(i, N); return colstrt[i]; } // top element of column i
	int bottom(int i) { check(i, N); return colstrt[i+1] - 1; }	// bottom element of column i
	const double* topptr(int i) { return data + top(i); }
	const double* bottomptr(int i) { return data + bottom(i); }

public:
	void check(int i, int N) { assert(i>=0 && i<N); }
	int N; // size of matrix
	int nnz; // number of nonzeros
	const double *data; // column compressed data
	const int *colstrt; // index of column start 
	const int *rowidx;  // row index
};

ColCompressedMatrix convert_from_Eigen(const Eigen::SparseMatrix<double> &m)
{
	assert(m.rows() == m.cols());
	assert(m.isCompressed());
	return ColCompressedMatrix(m.rows, m.nonZeros(), 
		m.valuePtr(), m.outerIndexPtr(), m.innerIndexPtr());
}

#endif
