/*
According to the OpenCL v2.0 chapter 6.13.1
Now define local and global size as following:
  globals[0] = 4;
  globals[1] = 9;
  globals[2] = 16;
  locals[0] = 2;
  locals[1] = 3;
  locals[2] = 4;

Kernel:
  int id = get_local_linear_id() + (get_group_id(0) + \
           get_group_id(1) * 2 + get_group_id(2) * 2 * 3) * \
           get_local_size(0) * get_local_size(1) * get_local_size(2);

dimension:1
 0  1  2  3
dimension:2
 0  1  2  3  4  5  6  7  8  9 10 11
12 13 14 15 16 17 18 19 20 21 22 23
24 25 26 27 28 29 30 31 32 33 34 35
dimension:3
 0  1  2  3  4  5  6  7 ... 139 140 141 142 143
...
...
429 430 431 432 433 434 ... 571 572 573 574 575
*/

#define udebug 0
#include "utest_helper.hpp"
static void builtin_local_linear_id(void)
{
  if (!cl_check_ocl20())
    return;

  // Setup kernel and buffers
  int dim, i, buf_len=1;
  OCL_CREATE_KERNEL("builtin_local_linear_id");

  OCL_CREATE_BUFFER(buf[0], CL_MEM_READ_WRITE, sizeof(int)*576, NULL);
  OCL_SET_ARG(0, sizeof(cl_mem), &buf[0]);

  for( dim=1; dim <= 3; dim++ )
  {
    buf_len = 1;
    for(i=1; i <= dim; i++)
    {
      locals[i - 1] = i + 1;
      globals[i - 1] = (i + 1) * (i + 1);
      buf_len *= ((i + 1) * (i + 1));
    }
    for(i = dim+1; i <= 3; i++)
    {
      globals[i - 1] = 0;
      locals[i - 1] = 0;
    }

    // Run the kernel
    OCL_NDRANGE( dim );
    clFinish(queue);

    OCL_MAP_BUFFER(0);
#if udebug
    for(i = 0; i < buf_len; i++)
    {
      printf("%2d ", ((int*)buf_data[0])[i]);
      if ((i + 1) % 4  == 0) printf("\n");
    }
#endif

    for( i = 0; i < buf_len; i++)
      OCL_ASSERT( ((int*)buf_data[0])[i] == i);
    OCL_UNMAP_BUFFER(0);
  }
}

MAKE_UTEST_FROM_FUNCTION(builtin_local_linear_id);
