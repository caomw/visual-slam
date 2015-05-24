#include <stdio.h>
#include "sparse_inverse.h"

void print_matrix(const SparseMatrix *m, const char *mess)
{
    int i; 

    printf("%sN = %d, nz = %d", mess, m->N, m->nz);
    printf("\ni = ");
    for (i = 0; i < m->nz; ++i) printf("%d ", m->i[i]);
    printf("\nj = ");
    for (i = 0; i < m->N+1; ++i) printf("%d ", m->j[i]);
    printf("\nx = ");
    for (i = 0; i < m->nz; ++i) printf("%f ", m->x[i]);
    printf("\n");
}

void print_matrix_full(const SparseMatrix *m, const char *mess)
{
    int i, j, k;

    printf("%s\n", mess);
    for (i = 0; i < m->N; ++i) {
        for (j = 0; j < m->N; ++j) {
            for (k = m->j[j]; k < m->j[j+1]; ++k) {
                if (m->i[k] == i) {
                    printf("%f\t", m->x[k]);
                    break;
                }
            }
            if (k == m->j[j+1])
                printf("0\t\t");
        }
        printf("\n");
    }
}

int main(void)
{
    FILE *fp;
    int N, nz, i, j, k=0;
    SparseMatrix *L, *P;

    fp = fopen("test.txt", "r");
    if (fp == NULL) return -1;

    fscanf(fp, "%d%d", &N, &nz);
    L = create_sparse_matrix(N, nz);
    L->j[0] = 0;
    for (i = 0; i < nz; ++i) {
        fscanf(fp, "%d%d%lf", &L->i[i], &j, &L->x[i]);
        while (j != k) 
            L->j[++k] = i;
    }
    L->j[++k] = nz;
    print_matrix_full(L, "Matrix L:");

    P = allocate_symmetric(L, NULL);
//    print_matrix(P, "\nMatrix P:");

    P = sparse_inverse(L, P, NULL);
    print_matrix_full(P, "\nMatrix Ps:");
}
