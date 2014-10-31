#include "utest_helper.hpp"

void compiler_mad_hi(void)
{
  const int n = 32;
  int src1[n], src2[n], src3[n];

  // Setup kernel and buffers
  OCL_CREATE_KERNEL("compiler_mad_hi");
  OCL_CREATE_BUFFER(buf[0], 0, n * sizeof(int), NULL);
  OCL_CREATE_BUFFER(buf[1], 0, n * sizeof(int), NULL);
  OCL_CREATE_BUFFER(buf[2], 0, n * sizeof(int), NULL);
  OCL_CREATE_BUFFER(buf[3], 0, n * sizeof(int), NULL);
  OCL_SET_ARG(0, sizeof(cl_mem), &buf[0]);
  OCL_SET_ARG(1, sizeof(cl_mem), &buf[1]);
  OCL_SET_ARG(2, sizeof(cl_mem), &buf[2]);
  OCL_SET_ARG(3, sizeof(cl_mem), &buf[3]);
  globals[0] = n;
  locals[0] = 16;

  OCL_MAP_BUFFER(0);
  OCL_MAP_BUFFER(1);
  OCL_MAP_BUFFER(2);
  for (int i = 0; i < n; ++i) {
    src1[i] = ((int*)buf_data[0])[i] = rand();
    src2[i] = ((int*)buf_data[1])[i] = rand();
    src3[i] = ((int*)buf_data[2])[i] = rand();
  }
  OCL_UNMAP_BUFFER(0);
  OCL_UNMAP_BUFFER(1);
  OCL_UNMAP_BUFFER(2);

  OCL_NDRANGE(1);

  OCL_MAP_BUFFER(3);
  for (int i = 0; i < n; ++i) {
    long long a = src1[i];
    a *= src2[i];
    a >>= 32;
    a += src3[i];
    OCL_ASSERT(((int*)buf_data[3])[i] == (int)a);
  }
  OCL_UNMAP_BUFFER(3);
}

MAKE_UTEST_FROM_FUNCTION(compiler_mad_hi);
