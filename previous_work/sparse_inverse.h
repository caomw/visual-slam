/* Sparse inverse for column compressed matrices */
typedef struct {
    int N;
    int nz;
    int *i;
    int *j;
    double *x;
} SparseMatrix;

SparseMatrix* create_sparse_matrix(int N, int nz);
void destroy_sparse_matrix(SparseMatrix *m);

int is_lower(const SparseMatrix *L);
int is_symmetric(const SparseMatrix *S);

SparseMatrix* allocate_symmetric(const SparseMatrix *L, SparseMatrix *P);
SparseMatrix* sparse_inverse(const SparseMatrix *L, SparseMatrix *P, int *w);

