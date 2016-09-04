/*
 * Subgroup any all functions
 */
kernel void compiler_subgroup_any(global int *src, global int *dst) {
  int val = src[get_global_id(0)];
  int predicate = sub_group_any(val);
  dst[get_global_id(0)] = predicate;
}
kernel void compiler_subgroup_all(global int *src, global int *dst) {
  int val = src[get_global_id(0)];
  int predicate = sub_group_all(val);
  dst[get_global_id(0)] = predicate;
}

/*
 * Subgroup reduce add functions
 */
kernel void compiler_subgroup_reduce_add_char(global char *src, global char *dst) {
  char val = src[get_global_id(0)];
  char sum = sub_group_reduce_add(val);
  dst[get_global_id(0)] = sum;
}

kernel void compiler_subgroup_reduce_add_uchar(global uchar *src, global uchar *dst) {
  uchar val = src[get_global_id(0)];
  uchar sum = sub_group_reduce_add(val);
  dst[get_global_id(0)] = sum;
}

kernel void compiler_subgroup_reduce_add_short(global short *src, global short *dst) {
  short val = src[get_global_id(0)];
  short sum = sub_group_reduce_add(val);
  dst[get_global_id(0)] = sum;
}

kernel void compiler_subgroup_reduce_add_ushort(global ushort *src, global ushort *dst) {
  ushort val = src[get_global_id(0)];
  ushort sum = sub_group_reduce_add(val);
  dst[get_global_id(0)] = sum;
}

kernel void compiler_subgroup_reduce_add_int(global int *src, global int *dst) {
  int val = src[get_global_id(0)];
  int sum = sub_group_reduce_add(val);
  dst[get_global_id(0)] = sum;
}

kernel void compiler_subgroup_reduce_add_uint(global uint *src, global uint *dst) {
  uint val = src[get_global_id(0)];
  uint sum = sub_group_reduce_add(val);
  dst[get_global_id(0)] = sum;
}

kernel void compiler_subgroup_reduce_add_long(global long *src, global long *dst) {
  long val = src[get_global_id(0)];
  long sum = sub_group_reduce_add(val);
  dst[get_global_id(0)] = sum;
}

kernel void compiler_subgroup_reduce_add_ulong(global ulong *src, global ulong *dst) {
  ulong val = src[get_global_id(0)];
  ulong sum = sub_group_reduce_add(val);
  dst[get_global_id(0)] = sum;
}

kernel void compiler_subgroup_reduce_add_float(global float *src, global float *dst) {
  float val = src[get_global_id(0)];
  float sum = sub_group_reduce_add(val);
  dst[get_global_id(0)] = sum;
}

/*
 * Subgroup reduce max functions
 */
kernel void compiler_subgroup_reduce_max_int(global int *src, global int *dst) {
  int val = src[get_global_id(0)];
  int sum = sub_group_reduce_max(val);
  dst[get_global_id(0)] = sum;
}

kernel void compiler_subgroup_reduce_max_uint(global uint *src, global uint *dst) {
  uint val = src[get_global_id(0)];
  uint sum = sub_group_reduce_max(val);
  dst[get_global_id(0)] = sum;
}

kernel void compiler_subgroup_reduce_max_long(global long *src, global long *dst) {
  long val = src[get_global_id(0)];
  long sum = sub_group_reduce_max(val);
  dst[get_global_id(0)] = sum;
}

kernel void compiler_subgroup_reduce_max_ulong(global ulong *src, global ulong *dst) {
  ulong val = src[get_global_id(0)];
  ulong sum = sub_group_reduce_max(val);
  dst[get_global_id(0)] = sum;
}

kernel void compiler_subgroup_reduce_max_float(global float *src, global float *dst) {
  float val = src[get_global_id(0)];
  float sum = sub_group_reduce_max(val);
  dst[get_global_id(0)] = sum;
}

/*
 * Subgroup reduce min functions
 */
kernel void compiler_subgroup_reduce_min_int(global int *src, global int *dst) {
  int val = src[get_global_id(0)];
  int sum = sub_group_reduce_min(val);
  dst[get_global_id(0)] = sum;
}

kernel void compiler_subgroup_reduce_min_uint(global uint *src, global uint *dst) {
  uint val = src[get_global_id(0)];
  uint sum = sub_group_reduce_min(val);
  dst[get_global_id(0)] = sum;
}

kernel void compiler_subgroup_reduce_min_long(global long *src, global long *dst) {
  long val = src[get_global_id(0)];
  long sum = sub_group_reduce_min(val);
  dst[get_global_id(0)] = sum;
}

kernel void compiler_subgroup_reduce_min_ulong(global ulong *src, global ulong *dst) {
  ulong val = src[get_global_id(0)];
  ulong sum = sub_group_reduce_min(val);
  dst[get_global_id(0)] = sum;
}

kernel void compiler_subgroup_reduce_min_float(global float *src, global float *dst) {
  float val = src[get_global_id(0)];
  float sum = sub_group_reduce_min(val);
  dst[get_global_id(0)] = sum;
}
