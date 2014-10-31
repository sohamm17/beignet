kernel void builtin_lgamma(global float *src, global float *dst) {
  int i = get_global_id(0);
  dst[i] = lgamma(src[i]);
};
