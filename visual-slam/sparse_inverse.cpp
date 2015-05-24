#include "sparse_inverse.hpp"

#define ASSERTION_MAX_COST 1
#define ASSERTION(expr, cost) if (cost <= ASSERTION_MAX_COST) assert(expr)

