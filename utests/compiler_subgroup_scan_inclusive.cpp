#include <cstdint>
#include <cstring>
#include <iostream>
#include <cstdlib>
#include <iomanip>
#include <algorithm>
#include <cmath>

#include "utest_helper.hpp"

using namespace std;

/* set to 1 for debug, output of input-expected data */
#define DEBUG_STDOUT    0

/* NDRANGE */
#define WG_GLOBAL_SIZE  30
#define WG_LOCAL_SIZE   30

enum WG_FUNCTION
{
  WG_SCAN_INCLUSIVE_ADD,
  WG_SCAN_INCLUSIVE_MAX,
  WG_SCAN_INCLUSIVE_MIN
};

/*
 * Generic compute-expected function for op SCAN INCLUSIVE type
 * and any variable type
 */
template<class T>
static void compute_expected(WG_FUNCTION wg_func,
                    T* input,
                    T* expected,
                    size_t SIMD_SIZE)
{
  if(wg_func == WG_SCAN_INCLUSIVE_ADD)
  {
    expected[0] = input[0];
    for(uint32_t i = 1; i < SIMD_SIZE; i++)
      expected[i] = input[i] + expected[i - 1];
  }
  else if(wg_func == WG_SCAN_INCLUSIVE_MAX)
  {
    expected[0] = input[0];
    for(uint32_t i = 1; i < SIMD_SIZE; i++)
      expected[i] = max(input[i], expected[i - 1]);
  }
  else if(wg_func == WG_SCAN_INCLUSIVE_MIN)
  {
    expected[0] = input[0];
    for(uint32_t i = 1; i < SIMD_SIZE; i++)
      expected[i] = min(input[i], expected[i - 1]);
  }
}

/*
 * Generic input-expected generate function for op SCAN INCLUSIVE type
 * and any variable type
 */
template<class T>
static void generate_data(WG_FUNCTION wg_func,
                   T* &input,
                   T* &expected,
                   size_t SIMD_SIZE)
{
  input = new T[WG_GLOBAL_SIZE];
  expected = new T[WG_GLOBAL_SIZE];

  /* base value for all data types */
  T base_val = (long)7 << (sizeof(T) * 5 - 3);

  /* seed for random inputs */
  srand (time(NULL));

  /* generate inputs and expected values */
  for(uint32_t gid = 0; gid < WG_GLOBAL_SIZE; gid += SIMD_SIZE)
  {
#if DEBUG_STDOUT
    cout << endl << "IN: " << endl;
#endif
    SIMD_SIZE = (gid + SIMD_SIZE) > WG_GLOBAL_SIZE ? WG_GLOBAL_SIZE - gid : SIMD_SIZE;

    /* input values */
    for(uint32_t lid = 0; lid < SIMD_SIZE; lid++)
    {
      /* initially 0, augment after */
      input[gid + lid] = 0;

      /* check all data types, test ideal for QWORD types */
      input[gid + lid] += ((rand() % 2 - 1) * base_val);
      /* add trailing random bits, tests GENERAL cases */
      input[gid + lid] += (rand() % 112);

#if DEBUG_STDOUT
      /* output generated input */
      cout << setw(4) << input[gid + lid] << ", " ;
      if((lid + 1) % 8 == 0)
        cout << endl;
#endif
    }

    /* expected values */
    compute_expected(wg_func, input + gid, expected + gid, SIMD_SIZE);

#if DEBUG_STDOUT
    /* output expected input */
    cout << endl << "EXP: " << endl;
    for(uint32_t lid = 0; lid < SIMD_SIZE; lid++) {
      cout << setw(4) << expected[gid + lid] << ", " ;
      if((lid + 1) % 8 == 0)
        cout << endl;
    }
    cout << endl;
#endif

  }
}

/*
 * Generic subgroup utest function for op SCAN INCLUSIVE type
 * and any variable type
 */
template<class T>
static void subgroup_generic(WG_FUNCTION wg_func,
                       T* input,
                       T* expected)
{
  /* get simd size */
  globals[0] = WG_GLOBAL_SIZE;
  locals[0] = WG_LOCAL_SIZE;
  size_t SIMD_SIZE = 0;
  OCL_CALL(utestclGetKernelSubGroupInfoKHR,kernel,device,CL_KERNEL_MAX_SUB_GROUP_SIZE_FOR_NDRANGE_KHR,sizeof(size_t)*1,locals,sizeof(size_t),&SIMD_SIZE,NULL);

  /* input and expected data */
  generate_data(wg_func, input, expected, SIMD_SIZE);

  /* prepare input for data type */
  OCL_CREATE_BUFFER(buf[0], 0, WG_GLOBAL_SIZE * sizeof(T), NULL);
  OCL_CREATE_BUFFER(buf[1], 0, WG_GLOBAL_SIZE * sizeof(T), NULL);
  OCL_SET_ARG(0, sizeof(cl_mem), &buf[0]);
  OCL_SET_ARG(1, sizeof(cl_mem), &buf[1]);

  /* set input data for GPU */
  OCL_MAP_BUFFER(0);
  memcpy(buf_data[0], input, WG_GLOBAL_SIZE * sizeof(T));
  OCL_UNMAP_BUFFER(0);

  /* run the kernel on GPU */
  OCL_NDRANGE(1);

  /* check if mismatch */
  OCL_MAP_BUFFER(1);
  uint32_t mismatches = 0;

  for (uint32_t i = 0; i < WG_GLOBAL_SIZE; i++)
    if(((T *)buf_data[1])[i] != *(expected + i))
    {
      /* found mismatch on integer, increment */
      if(numeric_limits<T>::is_integer){
        mismatches++;

#if DEBUG_STDOUT
        /* output mismatch */
        cout << "Err at " << i << ", " <<
          ((T *)buf_data[1])[i] << " != " << *(expected + i) << endl;
#endif
      }
      /* float error is tolerable though */
      else {
          float num_computed = ((T *)buf_data[1])[i];
          float num_expected = *(expected + i);
          float num_diff = abs(num_computed - num_expected) / abs(num_expected);
          if(num_diff > 0.01f){
            mismatches++;

#if DEBUG_STDOUT
          /* output mismatch */
          cout << "Err at " << i << ", " <<
            ((T *)buf_data[1])[i] << " != " << *(expected + i) << endl;
#endif
        }
      }
    }

#if DEBUG_STDOUT
  /* output mismatch count */
  cout << "mismatches " << mismatches << endl;
#endif

  OCL_UNMAP_BUFFER(1);

  OCL_ASSERT(mismatches == 0);
}

/*
 * Workgroup scan_inclusive add utest functions
 */
void compiler_subgroup_scan_inclusive_add_int(void)
{
  if(!cl_check_subgroups())
    return;
  cl_int *input = NULL;
  cl_int *expected = NULL;
  OCL_CREATE_KERNEL_FROM_FILE("compiler_subgroup_scan_inclusive",
                              "compiler_subgroup_scan_inclusive_add_int");
  subgroup_generic(WG_SCAN_INCLUSIVE_ADD, input, expected);
}
MAKE_UTEST_FROM_FUNCTION(compiler_subgroup_scan_inclusive_add_int);
void compiler_subgroup_scan_inclusive_add_uint(void)
{
  if(!cl_check_subgroups())
    return;
  cl_uint *input = NULL;
  cl_uint *expected = NULL;
  OCL_CREATE_KERNEL_FROM_FILE("compiler_subgroup_scan_inclusive",
                              "compiler_subgroup_scan_inclusive_add_uint");
  subgroup_generic(WG_SCAN_INCLUSIVE_ADD, input, expected);
}
MAKE_UTEST_FROM_FUNCTION(compiler_subgroup_scan_inclusive_add_uint);
void compiler_subgroup_scan_inclusive_add_long(void)
{
  if(!cl_check_subgroups())
    return;
  cl_long *input = NULL;
  cl_long *expected = NULL;
  OCL_CREATE_KERNEL_FROM_FILE("compiler_subgroup_scan_inclusive",
                              "compiler_subgroup_scan_inclusive_add_long");
  subgroup_generic(WG_SCAN_INCLUSIVE_ADD, input, expected);
}
MAKE_UTEST_FROM_FUNCTION_WITH_ISSUE(compiler_subgroup_scan_inclusive_add_long);
void compiler_subgroup_scan_inclusive_add_ulong(void)
{
  if(!cl_check_subgroups())
    return;
  cl_ulong *input = NULL;
  cl_ulong *expected = NULL;
  OCL_CREATE_KERNEL_FROM_FILE("compiler_subgroup_scan_inclusive",
                              "compiler_subgroup_scan_inclusive_add_ulong");
  subgroup_generic(WG_SCAN_INCLUSIVE_ADD, input, expected);
}
MAKE_UTEST_FROM_FUNCTION_WITH_ISSUE(compiler_subgroup_scan_inclusive_add_ulong);
void compiler_subgroup_scan_inclusive_add_float(void)
{
  if(!cl_check_subgroups())
    return;
  cl_float *input = NULL;
  cl_float *expected = NULL;
  OCL_CREATE_KERNEL_FROM_FILE("compiler_subgroup_scan_inclusive",
                              "compiler_subgroup_scan_inclusive_add_float");
  subgroup_generic(WG_SCAN_INCLUSIVE_ADD, input, expected);
}
MAKE_UTEST_FROM_FUNCTION(compiler_subgroup_scan_inclusive_add_float);

/*
 * Workgroup scan_inclusive max utest functions
 */
void compiler_subgroup_scan_inclusive_max_int(void)
{
  if(!cl_check_subgroups())
    return;
  cl_int *input = NULL;
  cl_int *expected = NULL;
  OCL_CREATE_KERNEL_FROM_FILE("compiler_subgroup_scan_inclusive",
                              "compiler_subgroup_scan_inclusive_max_int");
  subgroup_generic(WG_SCAN_INCLUSIVE_MAX, input, expected);
}
MAKE_UTEST_FROM_FUNCTION(compiler_subgroup_scan_inclusive_max_int);
void compiler_subgroup_scan_inclusive_max_uint(void)
{
  if(!cl_check_subgroups())
    return;
  cl_uint *input = NULL;
  cl_uint *expected = NULL;
  OCL_CREATE_KERNEL_FROM_FILE("compiler_subgroup_scan_inclusive",
                              "compiler_subgroup_scan_inclusive_max_uint");
  subgroup_generic(WG_SCAN_INCLUSIVE_MAX, input, expected);
}
MAKE_UTEST_FROM_FUNCTION(compiler_subgroup_scan_inclusive_max_uint);
void compiler_subgroup_scan_inclusive_max_long(void)
{
  if(!cl_check_subgroups())
    return;
  cl_long *input = NULL;
  cl_long *expected = NULL;
  OCL_CREATE_KERNEL_FROM_FILE("compiler_subgroup_scan_inclusive",
                              "compiler_subgroup_scan_inclusive_max_long");
  subgroup_generic(WG_SCAN_INCLUSIVE_MAX, input, expected);
}
MAKE_UTEST_FROM_FUNCTION_WITH_ISSUE(compiler_subgroup_scan_inclusive_max_long);
void compiler_subgroup_scan_inclusive_max_ulong(void)
{
  if(!cl_check_subgroups())
    return;
  cl_ulong *input = NULL;
  cl_ulong *expected = NULL;
  OCL_CREATE_KERNEL_FROM_FILE("compiler_subgroup_scan_inclusive",
                              "compiler_subgroup_scan_inclusive_max_ulong");
  subgroup_generic(WG_SCAN_INCLUSIVE_MAX, input, expected);
}
MAKE_UTEST_FROM_FUNCTION_WITH_ISSUE(compiler_subgroup_scan_inclusive_max_ulong);
void compiler_subgroup_scan_inclusive_max_float(void)
{
  if(!cl_check_subgroups())
    return;
  cl_float *input = NULL;
  cl_float *expected = NULL;
  OCL_CREATE_KERNEL_FROM_FILE("compiler_subgroup_scan_inclusive",
                              "compiler_subgroup_scan_inclusive_max_float");
  subgroup_generic(WG_SCAN_INCLUSIVE_MAX, input, expected);
}
MAKE_UTEST_FROM_FUNCTION(compiler_subgroup_scan_inclusive_max_float);

/*
 * Workgroup scan_inclusive min utest functions
 */
void compiler_subgroup_scan_inclusive_min_int(void)
{
  if(!cl_check_subgroups())
    return;
  cl_int *input = NULL;
  cl_int *expected = NULL;
  OCL_CREATE_KERNEL_FROM_FILE("compiler_subgroup_scan_inclusive",
                              "compiler_subgroup_scan_inclusive_min_int");
  subgroup_generic(WG_SCAN_INCLUSIVE_MIN, input, expected);
}
MAKE_UTEST_FROM_FUNCTION(compiler_subgroup_scan_inclusive_min_int);
void compiler_subgroup_scan_inclusive_min_uint(void)
{
  if(!cl_check_subgroups())
    return;
  cl_uint *input = NULL;
  cl_uint *expected = NULL;
  OCL_CREATE_KERNEL_FROM_FILE("compiler_subgroup_scan_inclusive",
                              "compiler_subgroup_scan_inclusive_min_uint");
  subgroup_generic(WG_SCAN_INCLUSIVE_MIN, input, expected);
}
MAKE_UTEST_FROM_FUNCTION(compiler_subgroup_scan_inclusive_min_uint);
void compiler_subgroup_scan_inclusive_min_long(void)
{
  if(!cl_check_subgroups())
    return;
  cl_long *input = NULL;
  cl_long *expected = NULL;
  OCL_CREATE_KERNEL_FROM_FILE("compiler_subgroup_scan_inclusive",
                              "compiler_subgroup_scan_inclusive_min_long");
  subgroup_generic(WG_SCAN_INCLUSIVE_MIN, input, expected);
}
MAKE_UTEST_FROM_FUNCTION_WITH_ISSUE(compiler_subgroup_scan_inclusive_min_long);
void compiler_subgroup_scan_inclusive_min_ulong(void)
{
  if(!cl_check_subgroups())
    return;
  cl_ulong *input = NULL;
  cl_ulong *expected = NULL;
  OCL_CREATE_KERNEL_FROM_FILE("compiler_subgroup_scan_inclusive",
                              "compiler_subgroup_scan_inclusive_min_ulong");
  subgroup_generic(WG_SCAN_INCLUSIVE_MIN, input, expected);
}
MAKE_UTEST_FROM_FUNCTION_WITH_ISSUE(compiler_subgroup_scan_inclusive_min_ulong);
void compiler_subgroup_scan_inclusive_min_float(void)
{
  if(!cl_check_subgroups())
    return;
  cl_float *input = NULL;
  cl_float *expected = NULL;
  OCL_CREATE_KERNEL_FROM_FILE("compiler_subgroup_scan_inclusive",
                              "compiler_subgroup_scan_inclusive_min_float");
  subgroup_generic(WG_SCAN_INCLUSIVE_MIN, input, expected);
}
MAKE_UTEST_FROM_FUNCTION(compiler_subgroup_scan_inclusive_min_float);

