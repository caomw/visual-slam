#ifndef READ_SPARSE_MATRIX_HPP_
#define READ_SPARSE_MATRIX_HPP_

#include <fstream>
#include <Eigen/Sparse>


void read_matrix_file(std::ifstream &fin, vector<Eigen::Triplet<double> > &triplets);

#endif
