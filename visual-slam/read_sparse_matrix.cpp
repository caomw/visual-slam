// Read sparse matrix from text file. Using Matrix Market format.
// Matrices obtained from http://www.cise.ufl.edu/research/sparse/matrices/list_by_symmetry.html

#include <iostream>
#include <sstream> // for istringstream
#include "read_sparse_matrix.hpp"

using namespace std;
typedef Eigen::Triplet<double> T;

void read_matrix_file(ifstream &fin, vector<T> &triplets)
{
	// Get comment lines
	string line;
	while (1) { 
		std::getline(fin, line);
		if (line[0] != '%') // FIXME: expects no preceeding white-space: http://stackoverflow.com/questions/2346737/how-to-find-the-first-character-in-a-c-string
			break;
	}

	// Extract matrix dimensions and number of non-zeros
	istringstream iss(line);
	int M, N, nnz;
	if (!(iss >> M >> N >> nnz))
		throw "Invalid file"; // FIXME: Use exception classes, not strings
	if (M != N)
		throw "Matrix must be square";

	// Allocate space for sparse matrix
	triplets.reserve(nnz);

	// Read data
	int i, j;
	double val;
	while (fin >> i >> j >> val)
		triplets.push_back(T(i, j, val));

	if (triplets.size() != nnz)
		throw "Mismatch in number of non-zeros";
}

#if 0

int main()
{
	ifstream f("C:\\Users\\tbailey\\Documents\\Work\\code\\sparse_matrix\\benchmark_matrices\\bcsstk02.mtx");
	if (!f) {
		cout << "Could not open file" << endl;
		exit(-1);
	}

	vector<T> triplets;
	read_matrix_file(f, triplets);

	for(vector<T>::const_iterator i = triplets.begin(); i != triplets.end(); ++i)
		cout << i->row() << ' ' << i->col() << ' ' << i->value() << endl;
}

#endif
