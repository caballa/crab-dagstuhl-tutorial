#include <stdlib.h>
#include "clam/clam.h"

extern bool __CRAB_intrinsic_is_dereferenceable(const void *ptr, intptr_t offset);
#define sassert __CRAB_assert
#define assume __CRAB_assume
#define sassert_is_dereferenceable(PTR,SIZE) sassert(__CRAB_intrinsic_is_dereferenceable(PTR, SIZE))

// malloc that cannot fail
void* xmalloc(size_t sz) {
  void* p = malloc(sz);
  assume(p > 0);
  return p;
}

// return different sizes based on a non-deterministic input
int nondet_size(int lb, int ub) {
  int sz = nd_int();
  assume(sz >= lb && sz <= ub);
  return sz;
}

int main() {
  int N = nondet_size(10, 1000);

  // dynamic array allocation
  int* array = (int*)xmalloc(sizeof(int) * N);

  // array initialization
  int i;
  for (i=0; i<N;i++) {
    int val = nd_int();
    assume(val >= 0 && val < 100);
    array[i] = val;
  }

  // array check
  int j;					
  for (j=0; j<N;++j) {
    sassert(array[j] < 100);
  }
  return 0;
}

