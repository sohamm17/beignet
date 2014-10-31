#include "utest_helper.hpp"

struct hop { int x, y; };

void compiler_argument_structure(void)
{
  const size_t n = 2048;
  hop h = {3, 4};

  // Setup kernel and buffers
  OCL_CREATE_KERNEL("compiler_argument_structure");
  OCL_CREATE_BUFFER(buf[0], 0, n * sizeof(uint32_t), NULL);
  OCL_SET_ARG(0, sizeof(cl_mem), &buf[0]);
  OCL_SET_ARG(1, sizeof(hop), &h);

  // Run the kernel
  globals[0] = n;
  locals[0] = 16;
  OCL_NDRANGE(1);
  OCL_MAP_BUFFER(0);

  // Check results
  for (uint32_t i = 0; i < n; ++i)
    OCL_ASSERT(((uint32_t*)buf_data[0])[i] == 7);
}

MAKE_UTEST_FROM_FUNCTION(compiler_argument_structure);

