/* TODO: 
 1. Compute sparse P at any given locations, not just the non-zero locations in L.
 1a. Permit early termination of computation if only lower-right part of P required.
 2. Check symbolic pattern of L is okay (not broken by Matlab). Can this be done without reference to Y?
 3. Faster element calculation for L with many zeros
 4. Implement LDL form 
 */

/* There is tricky indexing code in here. Modify at own risk. */

#include "sparse_inverse.h"
#include <assert.h>
#include <stdlib.h>
#define EXPENSIVE_ASSERT(x) assert(x) /* enable separate turn-off of expensive assertions */
#define NZ_SYM(lnz,N) (2*(lnz) - (N)) /* convert nz for triangular to nz for symmetric */
#define NZ_TRI(snz,N) (((snz)+(N))/2) /* convert nz for symmetric to nz for triangular */

#define CREATE 2
#if CREATE == 1

SparseMatrix* create_sparse_matrix(int N, int nz)
{
    SparseMatrix *m = (SparseMatrix*) malloc(sizeof(SparseMatrix));
    if (m == NULL) return m;
    m->N = N;
    m->nz = nz;
    m->i = (int*) malloc(nz * sizeof(int));
    m->j = (int*) malloc((N+1) * sizeof(int));
    m->x = (double*) malloc(nz * sizeof(double));
    return (m->i && m->j && m->x) ? m : NULL;
}

void destroy_sparse_matrix(SparseMatrix *m)
{
    free(m->i);
    free(m->j);
    free(m->x);
    free(m);
}

#else

SparseMatrix* create_sparse_matrix(int N, int nz)
{
    char *a;
    SparseMatrix *m;

    a = (char*) malloc(sizeof(SparseMatrix) + (nz+N+1)*sizeof(int) + nz*sizeof(double));
    m = (SparseMatrix*) a;

    if (m != NULL) { // FIXME: are there any alignment issues here?
        a += sizeof(SparseMatrix);
        m->x = (double*) a;
        a += nz * sizeof(double);
        m->i = (int*) a;
        a += nz * sizeof(int);
        m->j = (int*) a;
        m->N = N;
        m->nz = nz;
    }
    return m;
}

void destroy_sparse_matrix(SparseMatrix *m)
{
    free(m);
}

#endif

/* Check matrix is lower diagonal.
   Returns 1 if is lower, otherwise 0. */
int is_lower(const SparseMatrix *L)
{
    int i, k;

    for (i = 0, k = 0; i < L->nz; ++i) {
        if (i >= L->j[k+1]) /* move to next column */
            ++k;
        if (L->i[i] < k)    /* col indices may not exceed row indices */
            return 0;
    }
    return 1;
}

/* Check matrix is symmetric. */
int is_symmetric(const SparseMatrix *S)
{
    int i, k, okay=1, *w;

    /* Allocate workspace */
    w = (int*) malloc((S->N) * sizeof(int));
    for (i = 0; i < S->N; ++i)
        w[i] = S->j[i];

    /* Check symmetry */
    for (i = 0; i < S->N; ++i) {
        for (k = w[i]; k < S->j[i+1]; ++k) {
            int wc = w[S->i[k]]++;              
            assert(wc < S->j[S->i[k]+1]);
            if (i != S->i[wc]) okay = 0;       /* col (i) must equal row (S->i[wc]) */
            if (S->x[k] != S->x[wc]) okay = 0; /* values must match */
        }
    }

    free(w);
    return okay;
}

/* A Cholesky lower triangular matrix must include all symbolic terms, 
   including those that are numerically zero. */
int check_symbolic_zeros(const SparseMatrix *L)
{
    return 1;
}

static void validate_matrices(const SparseMatrix *L, const SparseMatrix *P)
{
    EXPENSIVE_ASSERT(is_lower(L));
    EXPENSIVE_ASSERT(check_symbolic_zeros(L));
    EXPENSIVE_ASSERT(is_symmetric(P));

    assert(L->N == P->N);
    assert(P->nz == NZ_SYM(L->nz, L->N));
}

/* Davis' transpose algorithm, but avoids internal memory management. */
SparseMatrix* transpose(SparseMatrix *m, int *w)
{
    return 0;
}

/* Allocate a sparse matrix with non-zero pattern equal to L+L', but without
   initialising any values. */
SparseMatrix* allocate_symmetric(const SparseMatrix *L, SparseMatrix *P)
{
    int i, k, sum;
    int *jL, *jP;

    if (P == NULL)
        P = create_sparse_matrix(L->N, NZ_SYM(L->nz, L->N));
    validate_matrices(L, P);

    /* Initialise P->j with zeros */
    for (i = 0; i < P->N+1; ++i)
        P->j[i] = 0;

    /* Count number of non-zeros per column, store in P->j */
    jL = L->j;
    jP = P->j + 1; /* offset by 1 to allow in-place calculations later */
    for (i = 0, k = 0; i < L->nz; ++i) {
        if (i >= jL[k+1]) ++k;  /* if (i) in new column, shift (k) to next col */
        ++jP[k];                /* increment count for current column */
        if (k != L->i[i])       /* if non-diagonal term */
            ++jP[L->i[i]];      /* increment count for symmetric column */
    }

    /* Cumulative sum on jP, starting from 0 */
    for (i = 0, sum = 0; i < P->N; ++i) {
        int tmp = jP[i];
        jP[i] = sum;
        sum += tmp;
    }

    /* Compute P->i, using jP for cunning in-place calculation of P->j */
    for (i = 0; i < L->N; ++i) /* for each column (i) in L */
        for (k = jL[i]; k < jL[i+1]; ++k) { 
            int j = L->i[k];        /* get k-th row index (j) */
            P->i[jP[i]++] = j;      /* store row index (j) into col (i) in P */
            if (i != j)             /* if not a diagonal term, make symmetry */
                P->i[jP[j]++] = i;  /* store row index (i) into col (j) in P */
        }

    return P;
}

/* Basic sparse inverse, aka Takahashi inverse. */
SparseMatrix* sparse_inverse_a(const SparseMatrix *L, SparseMatrix *P, int *w)
{
    int i, j, k, ks, kL, kP; 
    int delw = 0;
    double dinv;

    if (P == NULL) P = allocate_symmetric(L, NULL);
    if (w == NULL) { delw = 1; w = (int*) malloc(P->N * sizeof(int)); }
    validate_matrices(L, P);

    /* Initialise workspace to index diagonal element of each column */
    for (i = 0; i < P->N; ++i) {
        k = P->j[i];         /* get column-start index from j */
        while (P->i[k] != i) /* find diagonal element */
            ++k;                  
        w[i] = k;   
    }

    /* Compute sparse P */
    j = L->N; /* column index, initialised at one-past-end */
    for (k = L->nz-1; k >= 0; --k, --ks) { /* compute entries in reverse order */

        /* If element (k) is at bottom of column (j-1) in L */
        if (k == L->j[j]-1) {
            ks = P->j[j]-1; /* get index (ks) of bottom of column (j-1) in P */
            dinv = 1.0 / L->x[L->j[--j]]; /* shift to col (--j), and compute dinv */
            assert(j == L->i[L->j[j]]);   /* check entry L->j[j] is the diagonal */
        }

        /* If current element (k) is on diagonal, initialise with dinv, otherwise 0. */
        if (k == L->j[j]) P->x[ks] = dinv;
        else P->x[ks] = 0;

        /* Compute summation part. */
        i = L->i[k];        /* get row index (i) of element (k) */
        kL = L->j[j+1] - 1; /* get bottom row of column (j) in L */
        kP = P->j[i+1] - 1; /* get bottom row of column (i) in P */
        while (L->i[kL] > j && kP > P->j[i]) { /* iterate upwards */
            if (L->i[kL] == P->i[kP])
                P->x[ks] -= L->x[kL--] * P->x[kP--];
            else if (L->i[kL] < P->i[kP])
                --kP;
            else 
                --kL;
        }

        /* Multiply by dinv. */
        P->x[ks] *= dinv;

        /* Store symmetric entry. */
        assert(w[i] >= P->j[i]); /* index must remain inside column (i) of P */
        assert(P->i[w[i]] == j); /* symmetric row index must equal column index (j) */
        P->x[w[i]--] = P->x[ks];
    }

    if (delw) free(w);
    return P;
}

SparseMatrix* sparse_inverse(const SparseMatrix *L, SparseMatrix *P, int *w)
{
	sparse_inverse_a(L, P, w);
}

#if 0

/* Using pointers rather than indexing, but still computing P in column order */
SparseMatrix* sparse_inverse_b(const SparseMatrix *L, SparseMatrix *P, int *w)
{
    int i, j, kL, kP;
    int freew = 0;
    double dinv;
	const double *pLt, *pLb, *pPt, *pPb;

    /* Allocate memory, if necessary */
    if (P == NULL) P = allocate_symmetric(L, NULL);
    validate_matrices(L, P);
    if (w == NULL) {
        freew = 1;
        w = (int*) malloc(P->N * sizeof(int));
    }

    /* Initialise workspace to index diagonal element for each column */
    for (j = 0; j < P->N; ++j) {
        kP = P->j[j];         /* get start index for col (j) in P */
        while (P->i[kP] != j) /* find diagonal element in col (j) */
            ++kP;                  
        w[j] = kP;
    }

    /* Compute sparse P */
    j = L->N; /* column index, initialised at one-past-end */
    for (kL = L->nz-1; kL >= 0; --kL, --kP) { /* compute entries in reverse order */

        /* Check if element (k) starts new column, ie, k indexes bottom of column (j-1) in L */
        if (kL == L->j[j]-1) {
			kP = P->j[j]-1; /* get index of bottom of column (j-1) in P */
			--j;			/* shift one column left (ie, j = j-1) */

			/* Get pointers for */




            kPj = P->j[j]-1; /* get index of bottom of column (j-1) in P */
            --j; /* shift one column left (ie, j = j-1) */

            /* Cache indices for top and one-past-bottom of column (j) in L */
            kLb = k+1;
            kLt = L->j[j]; 

            /* Compute diagonal term for column j */
            dinv = 1.0 / L->x[kLt];
        }

        /* Column summation part */
        i = L->i[k];       /* get row index (i) of element (k) */
        kPt = P->j[i]+1;   /* get next-after-diagonal in column (i) in P */
        kPb = P->j[i+1];   /* get one-past-bottom of column (i) in P */
        for (kL = kLt+1; kL < kLb; ++kL, ++kPt) {
        }

        /* Multiply by dinv. */
        P->x[kPj] *= dinv;

		/* Store symmetric entry in P */
        P->x[w[i]--] = P->x[kPj]; 
        /* We shift w[i] up by one, ready for next symmetric entry */
    }

    /* Work complete, free workspace if it was created locally */
    if (freew) free(w);
    return P;
}

/* Same as sparse_inverse_b(), but computing P in row order */
SparseMatrix* sparse_inverse_c(const SparseMatrix *L, SparseMatrix *P, int *w)
{
}

#endif
