/*
 * Copyright © 2012 - 2014 Intel Corporation
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library. If not, see <http://www.gnu.org/licenses/>.
 *
 */
#include "ocl_math.h"
#include "ocl_float.h"
#include "ocl_relational.h"
#include "ocl_common.h"
#include "ocl_integer.h"

extern constant int __ocl_math_fastpath_flag;

CONST float __gen_ocl_fabs(float x) __asm("llvm.fabs" ".f32");
CONST float __gen_ocl_sin(float x) __asm("llvm.sin" ".f32");
CONST float __gen_ocl_cos(float x) __asm("llvm.cos" ".f32");
CONST float __gen_ocl_sqrt(float x) __asm("llvm.sqrt" ".f32");
PURE CONST float __gen_ocl_rsqrt(float x);
CONST float __gen_ocl_log(float x) __asm("llvm.log2" ".f32");
CONST float __gen_ocl_exp(float x) __asm("llvm.exp2" ".f32");
PURE CONST float __gen_ocl_pow(float x, float y) __asm("llvm.pow" ".f32");
PURE CONST float __gen_ocl_rcp(float x);
CONST float __gen_ocl_rndz(float x) __asm("llvm.trunc" ".f32");
CONST float __gen_ocl_rnde(float x) __asm("llvm.rint" ".f32");
CONST float __gen_ocl_rndu(float x) __asm("llvm.ceil" ".f32");
CONST float __gen_ocl_rndd(float x) __asm("llvm.floor" ".f32");


/* native functions */
OVERLOADABLE float native_cos(float x) { return __gen_ocl_cos(x); }
OVERLOADABLE float native_sin(float x) { return __gen_ocl_sin(x); }
OVERLOADABLE float native_sqrt(float x) { return __gen_ocl_sqrt(x); }
OVERLOADABLE float native_rsqrt(float x) { return __gen_ocl_rsqrt(x); }
OVERLOADABLE float native_log2(float x) { return __gen_ocl_log(x); }
OVERLOADABLE float native_log(float x) {
  return native_log2(x) * 0.6931472002f;
}
OVERLOADABLE float native_log10(float x) {
  return native_log2(x) * 0.3010299956f;
}
OVERLOADABLE float native_powr(float x, float y) { return __gen_ocl_pow(x,y); }
OVERLOADABLE float native_recip(float x) { return __gen_ocl_rcp(x); }
OVERLOADABLE float native_tan(float x) {
  return native_sin(x) / native_cos(x);
}
OVERLOADABLE float native_exp2(float x) { return __gen_ocl_exp(x); }
OVERLOADABLE float native_exp(float x) { return __gen_ocl_exp(M_LOG2E_F*x); }
OVERLOADABLE float native_exp10(float x) { return __gen_ocl_exp(M_LOG210_F*x); }
OVERLOADABLE float native_divide(float x, float y) { return x/y; }

/* Fast path */
OVERLOADABLE float __gen_ocl_internal_fastpath_acosh (float x) {
    return native_log(x + native_sqrt(x + 1) * native_sqrt(x - 1));
}
OVERLOADABLE float __gen_ocl_internal_fastpath_asinh (float x) {
    return native_log(x + native_sqrt(x * x + 1));
}
OVERLOADABLE float __gen_ocl_internal_fastpath_atanh (float x) {
    return 0.5f * native_log((1 + x) / (1 - x));
}
OVERLOADABLE float __gen_ocl_internal_fastpath_cbrt (float x) {
    return __gen_ocl_pow(x, 0.3333333333f);
}
OVERLOADABLE float __gen_ocl_internal_fastpath_cos (float x) {
    return native_cos(x);
}
OVERLOADABLE float __gen_ocl_internal_fastpath_cosh (float x) {
    return (1 + native_exp(-2 * x)) / (2 * native_exp(-x));
}
OVERLOADABLE float __gen_ocl_internal_fastpath_cospi (float x) {
    return __gen_ocl_cos(x * M_PI_F);
}
OVERLOADABLE float __gen_ocl_internal_fastpath_exp (float x) {
    return native_exp(x);
}
OVERLOADABLE float __gen_ocl_internal_fastpath_exp10 (float x) {
    return native_exp10(x);
}
OVERLOADABLE float __gen_ocl_internal_fastpath_expm1 (float x) {
    return __gen_ocl_pow(M_E_F, x) - 1;
}
OVERLOADABLE float __gen_ocl_internal_fastpath_fmod (float x, float y) {
    return x-y*__gen_ocl_rndz(x/y);
}
OVERLOADABLE float __gen_ocl_internal_fastpath_hypot (float x, float y) {
    return __gen_ocl_sqrt(x*x + y*y);
}
OVERLOADABLE int __gen_ocl_internal_fastpath_ilogb (float x) {
    return __gen_ocl_rndd(native_log2(x));
}
OVERLOADABLE float __gen_ocl_internal_fastpath_ldexp (float x, int n) {
    return __gen_ocl_pow(2, n) * x;
}
OVERLOADABLE float __gen_ocl_internal_fastpath_log (float x) {
    return native_log(x);
}
OVERLOADABLE float __gen_ocl_internal_fastpath_log2 (float x) {
    return native_log2(x);
}
OVERLOADABLE float __gen_ocl_internal_fastpath_log10 (float x) {
    return native_log10(x);
}
OVERLOADABLE float __gen_ocl_internal_fastpath_log1p (float x) {
    return native_log(x + 1);
}
OVERLOADABLE float __gen_ocl_internal_fastpath_logb (float x) {
    return __gen_ocl_rndd(native_log2(x));
}
OVERLOADABLE float __gen_ocl_internal_fastpath_remainder (float x, float y) {
    return x-y*__gen_ocl_rnde(x/y);
}
OVERLOADABLE float __gen_ocl_internal_fastpath_rootn(float x, int n) {
    return __gen_ocl_pow(x, 1.f / n);
}
OVERLOADABLE float __gen_ocl_internal_fastpath_sin (float x) {
    return native_sin(x);
}
OVERLOADABLE float __gen_ocl_internal_fastpath_sincos (float x, __global float *cosval) {
    *cosval = native_cos(x);
    return native_sin(x);
}
OVERLOADABLE float __gen_ocl_internal_fastpath_sincos (float x, __local float *cosval) {
    *cosval = native_cos(x);
    return native_sin(x);
}
OVERLOADABLE float __gen_ocl_internal_fastpath_sincos (float x, __private float *cosval) {
    *cosval = native_cos(x);
    return native_sin(x);
}
OVERLOADABLE float __gen_ocl_internal_fastpath_sinh (float x) {
    return (1 - native_exp(-2 * x)) / (2 * native_exp(-x));
}
OVERLOADABLE float __gen_ocl_internal_fastpath_sinpi (float x) {
    return __gen_ocl_sin(x * M_PI_F);
}
OVERLOADABLE float __gen_ocl_internal_fastpath_tan (float x) {
    return native_tan(x);
}
OVERLOADABLE float __gen_ocl_internal_fastpath_tanh (float x) {
    float y = native_exp(-2 * x);
    return (1 - y) / (1 + y);
}


/* Internal implement, high accuracy. */
OVERLOADABLE float __gen_ocl_internal_floor(float x) { return __gen_ocl_rndd(x); }
OVERLOADABLE float __gen_ocl_internal_copysign(float x, float y) {
  union { unsigned u; float f; } ux, uy;
  ux.f = x;
  uy.f = y;
  ux.u = (ux.u & 0x7fffffff) | (uy.u & 0x80000000u);
  return ux.f;
}

OVERLOADABLE float inline __gen_ocl_internal_log_valid(float x) {
/*
 *  Conversion to float by Ian Lance Taylor, Cygnus Support, ian@cygnus.com
 * ====================================================
 * Copyright (C) 1993 by Sun Microsystems, Inc. All rights reserved.
 *
 * Developed at SunPro, a Sun Microsystems, Inc. business.
 * Permission to use, copy, modify, and distribute this
 * software is freely granted, provided that this notice
 * is preserved.
 * ====================================================
 */
  union { unsigned int i; float f; } u;
  const float
  ln2_hi = 6.9313812256e-01,  /* 0x3f317180 */
  ln2_lo = 9.0580006145e-06,  /* 0x3717f7d1 */
  two25 =  3.355443200e+07, /* 0x4c000000 */
  Lg1 = 6.6666668653e-01, /* 3F2AAAAB */
  Lg2 = 4.0000000596e-01, /* 3ECCCCCD */
  Lg3 = 2.8571429849e-01, /* 3E924925 */
  Lg4 = 2.2222198546e-01; /* 3E638E29 */

  const float zero   =  0.0;
  float fsq, f, s, z, R, w, t1, t2, partial;
  int k, ix, i, j;

  u.f = x;  ix = u.i;
  k = 0;

  k += (ix>>23) - 127;
  ix &= 0x007fffff;
  i = (ix + (0x95f64<<3)) & 0x800000;
  u.i = ix | (i^0x3f800000); x = u.f;
  k += (i>>23);
  f = x - 1.0f;
  fsq = f * f;

  if((0x007fffff & (15 + ix)) < 16) { /* |f| < 2**-20 */
      R = fsq * (0.5f - 0.33333333333333333f * f);
      return k * ln2_hi + k * ln2_lo + f - R;
  }

  s = f / (2.0f + f);
  z = s * s;
  i = ix - (0x6147a << 3);
  w = z * z;
  j = (0x6b851 << 3) - ix;
  t1= w * mad(w, Lg4, Lg2);
  t2= z * mad(w, Lg3, Lg1);
  i |= j;
  R = t2 + t1;
  partial = (i > 0) ? -mad(s, 0.5f * fsq, -0.5f * fsq) : (s * f);

  return mad(s, R, f) - partial + k * ln2_hi + k * ln2_lo;;
}

OVERLOADABLE float __gen_ocl_internal_log(float x)
{
  union { unsigned int i; float f; } u;
  u.f = x;
  int ix = u.i;

  if (ix < 0 )
	return NAN;  /* log(-#) = NaN */
  if (ix >= 0x7f800000)
    return NAN;

  return __gen_ocl_internal_log_valid(x);
}

OVERLOADABLE float __gen_ocl_internal_log10(float x)
{
  union { float f; unsigned i; } u;
  const float
  ivln10     =  4.3429449201e-01, /* 0x3ede5bd9 */
  log10_2hi  =  3.0102920532e-01, /* 0x3e9a2080 */
  log10_2lo  =  7.9034151668e-07; /* 0x355427db */

  float y, z;
  int i, k, hx;

  u.f = x; hx = u.i;

  if (hx<0)
    return NAN; /* log(-#) = NaN */
  if (hx >= 0x7f800000)
    return NAN;

  k = (hx >> 23) - 127;
  i  = ((unsigned)k & 0x80000000) >> 31;
  hx = (hx&0x007fffff) | ((0x7f-i) << 23);
  y  = (float)(k + i);
  u.i = hx; x = u.f;

  return  y * log10_2lo + y * log10_2hi + ivln10 * __gen_ocl_internal_log_valid(x);
}


OVERLOADABLE float __gen_ocl_internal_log2(float x)
{
  const float zero   =  0.0,
  invln2 = 0x1.715476p+0f;
  int ix;

  union { float f; int i; } u;
  u.f = x; ix = u.i;

  if (ix < 0)
	return NAN;    /** log(-#) = NaN */
  if (ix >= 0x7f800000)
	return NAN;

  return invln2 * __gen_ocl_internal_log_valid(x);
}


float __gen_ocl_scalbnf (float x, int n){
  /* copy from fdlibm */
  float two25 = 3.355443200e+07,	/* 0x4c000000 */
  twom25 = 2.9802322388e-08,	        /* 0x33000000 */
  huge = 1.0e+30,
  tiny = 1.0e-30;
  int k,ix;
  GEN_OCL_GET_FLOAT_WORD(ix,x);
  k = (ix&0x7f800000)>>23; /* extract exponent */
  if (k==0) {	/* 0 or subnormal x */
    if ((ix&0x7fffffff)==0) return x; /* +-0 */
    x *= two25;
    GEN_OCL_GET_FLOAT_WORD(ix,x);
    k = ((ix&0x7f800000)>>23) - 25;
  }
  if (k==0xff) return x+x;	/* NaN or Inf */
  if (n< -50000)
    return tiny*__gen_ocl_internal_copysign(tiny,x);	/*underflow*/
  if (n> 50000 || k+n > 0xfe)
    return huge*__gen_ocl_internal_copysign(huge,x); /* overflow  */
  /* Now k and n are bounded we know that k = k+n does not overflow. */
  k = k+n;
  if (k > 0) { /* normal result */
    GEN_OCL_SET_FLOAT_WORD(x,(ix&0x807fffff)|(k<<23));
    return x;
  }
  if (k <= -25)
    return tiny*__gen_ocl_internal_copysign(tiny,x);	/*underflow*/
  k += 25;				/* subnormal result */
  GEN_OCL_SET_FLOAT_WORD(x,(ix&0x807fffff)|(k<<23));
  return x*twom25;
}

const __constant unsigned int two_over_pi[] = {
0, 0, 0xA2F, 0x983, 0x6E4, 0xe44, 0x152, 0x9FC,
0x275, 0x7D1, 0xF53, 0x4DD, 0xC0D, 0xB62,
0x959, 0x93C, 0x439, 0x041, 0xFE5, 0x163,
};

// The main idea is from "Radian Reduction for Trigonometric Functions"
// written by Mary H. Payne and Robert N. Hanek. Also another reference
// is "A Continued-Fraction Analysis of Trigonometric Argument Reduction"
// written by Roger Alan Smith, who gave the worst case in this paper.
// for single float, worst x = 0x1.47d0fep34, and there are 29 bit
// leading zeros in the fraction part of x*(2.0/pi). so we need at least
// 29 (leading zero)+ 24 (fraction )+12 (integer) + guard bits. that is,
// 65 + guard bits, as we calculate in 12*7 = 84bits, which means we have
// about 19 guard bits. If we need further precision, we may need more
// guard bits
// Note we place two 0 in two_over_pi, which is used to handle input less
// than 0x1.0p23

int payne_hanek(float x, float *y) {
  union { float f; unsigned u;} ieee;
  ieee.f = x;
  unsigned u = ieee.u;
  int k = ((u & 0x7f800000) >> 23)-127;
  int ma = (u & 0x7fffff) | 0x800000;
  unsigned  high, low;
  high = (ma & 0xfff000) >> 12;
  low = ma & 0xfff;

  // Two tune below macro, you need to fully understand the algorithm
#define CALC_BLOCKS 7
#define ZERO_BITS 2

  unsigned result[CALC_BLOCKS];

  // round down, note we need 2 bits integer precision
  int index = (k-23-2) < 0 ? (k-23-2-11)/12 : (k-23-2)/12;

  for (int i = 0; i < CALC_BLOCKS; i++) {
    result[i] =  low * two_over_pi[index+i+ZERO_BITS] ;
    result[i] +=  high * two_over_pi[index+i+1+ZERO_BITS];
  }

  for (int i = CALC_BLOCKS-1; i > 0; i--) {
    int temp = result[i] >> 12;
    result[i]  -= temp << 12;
    result[i-1] += temp;
  }
#undef CALC_BLOCKS
#undef ZERO_BITS

  // get number of integer digits in result[0], note we only consider 12 valid bits
  // and also it means the fraction digits in result[0] is (12-intDigit)

  int intDigit = index*(-12) + (k-23);

  // As the integer bits may be all included in result[0], and also maybe
  // some bits in result[0], and some in result[1]. So we merge succesive bits,
  // which makes easy coding.

  unsigned b0 = (result[0] << 12) | result[1];
  unsigned b1 = (result[2] << 12) | result[3];
  unsigned b2 = (result[4] << 12) | result[5];
  unsigned b3 = (result[6] << 12);

  unsigned intPart = b0 >> (24-intDigit);

  unsigned fract1 = ((b0 << intDigit) | (b1 >> (24-intDigit))) & 0xffffff;
  unsigned fract2 = ((b1 << intDigit) | (b2 >> (24-intDigit))) & 0xffffff;
  unsigned fract3 = ((b2 << intDigit) | (b3 >> (24-intDigit))) & 0xffffff;

  // larger than 0.5? which mean larger than pi/4, we need
  // transform from [0,pi/2] to [-pi/4, pi/4] through -(1.0-fract)
  int largerPiBy4 = ((fract1 & 0x800000) != 0);
  int sign = largerPiBy4 ? 1 : 0;
  intPart = largerPiBy4 ? (intPart+1) : intPart;

  fract1 = largerPiBy4 ? (fract1 ^ 0x00ffffff) : fract1;
  fract2 = largerPiBy4 ? (fract2 ^ 0x00ffffff) : fract2;
  fract3 = largerPiBy4 ? (fract3 ^ 0x00ffffff) : fract3;

  int leadingZero = (fract1 == 0);

  // +1 is for the hidden bit 1 in floating-point format
  int exponent = leadingZero ? -(24+1) : -(0+1);

  fract1 = leadingZero ? fract2 : fract1;
  fract2 = leadingZero ? fract3 : fract2;

  // fract1 may have leading zeros, add it
  int shift = clz(fract1)-8;
  exponent += -shift;

  float pio2 = 0x1.921fb6p+0;
  unsigned fdigit = ((fract1 << shift) | (fract2 >> (24-shift))) & 0xffffff;

  // we know that denormal number will not appear here
  ieee.u = (sign << 31) | ((exponent+127) << 23) | (fdigit & 0x7fffff);
  *y = ieee.f * pio2;
  return intPart;
}

int argumentReduceSmall(float x, float * remainder) {
  union {
    float f;
    unsigned u;
  } ieee;

  float twoByPi = 2.0f/3.14159265f;
  float piBy2_1h = (float) 0xc90/0x1.0p11,
        piBy2_1l = (float) 0xfda/0x1.0p23,
        piBy2_2h = (float) 0xa22/0x1.0p35,
        piBy2_2l = (float) 0x168/0x1.0p47,
        piBy2_3h = (float) 0xc23/0x1.0p59,
        piBy2_3l = (float) 0x4c4/0x1.0p71;

  float y = (float)(int)(twoByPi * x + 0.5f);
  ieee.f = y;
  ieee.u = ieee.u & 0xfffff000;

  float yh = ieee.f;
  float yl = y - yh;
  float rem = x - yh*piBy2_1h - yh*piBy2_1l - yl*piBy2_1h - yl*piBy2_1l;
  rem = rem - yh*piBy2_2h - yh*piBy2_2l + yl*piBy2_2h + yl*piBy2_2l;
  rem = rem - yh*piBy2_3h - yh*piBy2_3l - yl*piBy2_3h - yl*piBy2_3l;

  *remainder = rem;
  return (int)y;
}


int __ieee754_rem_pio2f(float x, float *y) {
  if (x < 4000.0f) {
    return argumentReduceSmall(x, y);
  } else {
    return payne_hanek(x, y);
  }
}

OVERLOADABLE float __kernel_sinf(float x)
{
  /* copied from fdlibm */
  const float
  S1  = -1.6666667163e-01, /* 0xbe2aaaab */
  S2  =  8.3333337680e-03, /* 0x3c088889 */
  S3  = -1.9841270114e-04, /* 0xb9500d01 */
  S4  =  2.7557314297e-06; /* 0x3638ef1b */
  float z,r,v;
  z =  x*x;
  v =  z*x;
  r = mad(z, mad(z, mad(z, S4, S3), S2), S1);

  return mad(v, r, x);
}

float __kernel_cosf(float x, float y)
{
  /* copied from fdlibm */
  const float
  one =  1.0000000000e+00, /* 0x3f800000 */
  C1  =  4.1666667908e-02, /* 0x3d2aaaab */
  C2  = -1.3888889225e-03, /* 0xbab60b61 */
  C3  =  2.4801587642e-05; /* 0x37d00d01 */
  float a,hz,z,r,qx;
  int ix;
  GEN_OCL_GET_FLOAT_WORD(ix,x);
  ix &= 0x7fffffff;     /* ix = |x|'s high word*/
  z  = x*x;
  r = z * mad(z, mad(z, C3, C2), C1);

  if(ix < 0x3e99999a)       /* if |x| < 0.3 */
      return one - ((float)0.5*z - (z*r - x*y));
  else {
      GEN_OCL_SET_FLOAT_WORD(qx,ix-0x01000000); /* x/4 */
      hz = (float)0.5*z-qx;
      a  = one-qx;
      return a - (hz - (z*r-x*y));
  }
}

OVERLOADABLE float sin(float x)
{
  if (__ocl_math_fastpath_flag)
    return __gen_ocl_internal_fastpath_sin(x);

  const float pio4  =  7.8539812565e-01; /* 0x3f490fda */
  float y,z=0.0;
  int n, ix;

  float negative = x < 0.0f? -1.0f : 1.0f;
  x = fabs(x);

  GEN_OCL_GET_FLOAT_WORD(ix,x);
  ix &= 0x7fffffff;

    /* sin(Inf or NaN) is NaN */
  if (ix >= 0x7f800000) return x-x;

  if(x <= pio4)
	  return negative * __kernel_sinf(x);
  /* argument reduction needed */
  else {
      n = __ieee754_rem_pio2f(x,&y);
      float s = __kernel_sinf(y);
      float c = __kernel_cosf(y,0.0f);
      float ret = (n&1) ? negative*c : negative*s;
      return (n&3)> 1? -1.0f*ret : ret;
  }
}

OVERLOADABLE float cos(float x)
{
  if (__ocl_math_fastpath_flag)
    return __gen_ocl_internal_fastpath_cos(x);

  const float pio4  =  7.8539812565e-01; /* 0x3f490fda */
  float y,z=0.0;
  int n, ix;
  x = __gen_ocl_fabs(x);
  GEN_OCL_GET_FLOAT_WORD(ix,x);

  ix &= 0x7fffffff;

    /* cos(Inf or NaN) is NaN */
  if (ix >= 0x7f800000) return x-x;

  if(x <= pio4)
	  return __kernel_cosf(x, 0.f);
  /* argument reduction needed */
  else {
      n = __ieee754_rem_pio2f(x,&y);
      n &= 3;
      float c = __kernel_cosf(y, 0.0f);
      float s = __kernel_sinf(y);
      float v = (n&1) ? s : c;
      /* n&3   return
          0    cos(y)
          1   -sin(y)
          2   -cos(y)
          3    sin(y)
      */
      int mask = (n>>1) ^ n;
      float sign = (mask&1) ? -1.0f : 1.0f;
      return sign * v;
  }
}

float __kernel_tanf(float x, float y, int iy)
{
  /* copied from fdlibm */
        float z,r,v,w,s;
        int ix,hx;
        const float
        one   =  1.0000000000e+00, /* 0x3f800000 */
        pio4  =  7.8539812565e-01, /* 0x3f490fda */
        pio4lo=  3.7748947079e-08; /* 0x33222168 */
        float T[13];// =  {
         T[0] = 3.3333334327e-01; /* 0x3eaaaaab */
         T[1] = 1.3333334029e-01; /* 0x3e088889 */
         T[2] = 5.3968254477e-02; /* 0x3d5d0dd1 */
         T[3] = 2.1869488060e-02; /* 0x3cb327a4 */
         T[4] = 8.8632395491e-03; /* 0x3c11371f */
         T[5] = 3.5920790397e-03; /* 0x3b6b6916 */
         T[6] = 1.4562094584e-03; /* 0x3abede48 */
         T[7] = 5.8804126456e-04; /* 0x3a1a26c8 */

        GEN_OCL_GET_FLOAT_WORD(hx,x);
        ix = hx&0x7fffffff;     /* high word of |x| */
        if(ix<0x31800000)                       /* x < 2**-28 */
            {if((int)x==0) {                    /* generate inexact */
                if((ix|(iy+1))==0) return one/__gen_ocl_fabs(x);
                else return (iy==1)? x: -one/x;
            }
            }
        if(ix>=0x3f2ca140) {                    /* |x|>=0.6744 */
            if(hx<0) {x = -x; y = -y;}
            z = pio4-x;
            w = pio4lo-y;
            x = z+w; y = 0.0;
        }
        z       =  x*x;
        w       =  z*z;
		/* Break x^5*(T[1]+x^2*T[2]+...) into
		 *    x^5(T[1]+x^4*T[3]+...+x^20*T[11]) +
		 *    x^5(x^2*(T[2]+x^4*T[4]+...+x^22*[T12]))
		 */

        r = mad(w, mad(w, mad(w, T[7], T[5]), T[3]), T[1]);
        v = z* mad(w, mad(w, T[6], T[4]), T[2]);

        s = z*x;
        r = mad(z, mad(s, r + v, y), y);
        r += T[0]*s;
        w = x+r;
        if(ix>=0x3f2ca140) {
            v = (float)iy;
            return (float)(1-((hx>>30)&2))*(v-(float)2.0*(x-(w*w/(w+v)-r)));
        }
        if(iy==1) return w;
        else
        	return -1.0/(x+r);
}

OVERLOADABLE float tan(float x)
{
    if (__ocl_math_fastpath_flag)
      return __gen_ocl_internal_fastpath_tan(x);

    float y,z=0.0;
    int n, ix;
    float negative = x < 0.0f? -1.0f : 1.0f;
    x = negative * x;

    GEN_OCL_GET_FLOAT_WORD(ix,x);

    ix &= 0x7fffffff;

    /* tan(Inf or NaN) is NaN */
    if (ix>=0x7f800000) return x-x;            /* NaN */

    /* argument reduction needed */
    else {
      n = __ieee754_rem_pio2f(x,&y);
      return negative * __kernel_tanf(y,0.0f,1-((n&1)<<1)); /*   1 -- n even
                                                              -1 -- n odd */
    }
}

OVERLOADABLE float __gen_ocl_internal_cospi(float x) {
  int ix;
  if(isinf(x) || isnan(x)) { return NAN; }
  if(x < 0.0f) { x = -x; }
  GEN_OCL_GET_FLOAT_WORD(ix, x);
  if(x> 0x1.0p24) return 1.0f;
  float m = __gen_ocl_internal_floor(x);
  ix = (int)m;
  m = x-m;
  if((ix&0x1) != 0) m+=1.0f;
    ix = __gen_ocl_internal_floor(m*4.0f);

  switch(ix) {
   case 0:
    return __kernel_cosf(m*M_PI_F, 0.0f);
   case 1:
   case 2:
    return __kernel_sinf((0.5f-m)*M_PI_F);
   case 3:
   case 4:
    return -__kernel_cosf((m-1.0f)*M_PI_F, 0.0f);
   case 5:
   case 6:
    return __kernel_sinf((m-1.5f)*M_PI_F);
   default:
    return __kernel_cosf((2.0f-m)*M_PI_F, 0.0f);
   }
}

OVERLOADABLE float __gen_ocl_internal_sinpi(float x) {
  float sign = 1.0f;
  int ix;
  if(isinf(x)) return NAN;
  if(x < 0.0f) { x = -x; sign = -1.0f; }
  GEN_OCL_GET_FLOAT_WORD(ix, x);
  if(x> 0x1.0p24) return 0.0f;
  float m = __gen_ocl_internal_floor(x);
  ix = (int)m;
  m = x-m;
  if((ix&0x1) != 0) m+=1.0f;
    ix = __gen_ocl_internal_floor(m*4.0f);

  switch(ix) {
   case 0:
    return sign*__kernel_sinf(m*M_PI_F);
   case 1:
   case 2:
    return sign*__kernel_cosf((m-0.5f)*M_PI_F, 0.0f);
   case 3:
   case 4:
    return -sign*__kernel_sinf((m-1.0f)*M_PI_F);
   case 5:
   case 6:
    return -sign*__kernel_cosf((m-1.5f)*M_PI_F, 0.0f);
   default:
    return -sign*__kernel_sinf((2.0f-m)*M_PI_F);
   }

}

OVERLOADABLE float lgamma(float x) {
/*
 * ====================================================
 * Copyright (C) 1993 by Sun Microsystems, Inc. All rights reserved.
 *
 * Developed at SunPro, a Sun Microsystems, Inc. business.
 * Permission to use, copy, modify, and distribute this
 * software is freely granted, provided that this notice
 * is preserved.
 * ====================================================
 */
    const float
        zero=  0.,
        one =  1.0000000000e+00,
        pi  =  3.1415927410e+00,
        a0  =  7.7215664089e-02,
        a1  =  3.2246702909e-01,
        a2  =  6.7352302372e-02,
        a3  =  2.0580807701e-02,
        a4  =  7.3855509982e-03,
        a5  =  2.8905137442e-03,
        a6  =  1.1927076848e-03,
        a7  =  5.1006977446e-04,
        a8  =  2.2086278477e-04,
        a9  =  1.0801156895e-04,
        a10 =  2.5214456400e-05,
        a11 =  4.4864096708e-05,
        tc  =  1.4616321325e+00,
        tf  = -1.2148628384e-01,
        tt  =  6.6971006518e-09,
        t0  =  4.8383611441e-01,
        t1  = -1.4758771658e-01,
        t2  =  6.4624942839e-02,
        t3  = -3.2788541168e-02,
        t4  =  1.7970675603e-02,
        t5  = -1.0314224288e-02,
        t6  =  6.1005386524e-03,
        t7  = -3.6845202558e-03,
        t8  =  2.2596477065e-03,
        t9  = -1.4034647029e-03,
        t10 =  8.8108185446e-04,
        t11 = -5.3859531181e-04,
        t12 =  3.1563205994e-04,
        t13 = -3.1275415677e-04,
        t14 =  3.3552918467e-04,
        u0  = -7.7215664089e-02,
        u1  =  6.3282704353e-01,
        u2  =  1.4549225569e+00,
        u3  =  9.7771751881e-01,
        u4  =  2.2896373272e-01,
        u5  =  1.3381091878e-02,
        v1  =  2.4559779167e+00,
        v2  =  2.1284897327e+00,
        v3  =  7.6928514242e-01,
        v4  =  1.0422264785e-01,
        v5  =  3.2170924824e-03,
        s0  = -7.7215664089e-02,
        s1  =  2.1498242021e-01,
        s2  =  3.2577878237e-01,
        s3  =  1.4635047317e-01,
        s4  =  2.6642270386e-02,
        s5  =  1.8402845599e-03,
        s6  =  3.1947532989e-05,
        r1  =  1.3920053244e+00,
        r2  =  7.2193557024e-01,
        r3  =  1.7193385959e-01,
        r4  =  1.8645919859e-02,
        r5  =  7.7794247773e-04,
        r6  =  7.3266842264e-06,
        w0  =  4.1893854737e-01,
        w1  =  8.3333335817e-02,
        w2  = -2.7777778450e-03,
        w3  =  7.9365057172e-04,
        w4  = -5.9518753551e-04,
        w5  =  8.3633989561e-04,
        w6  = -1.6309292987e-03;
	float t, y, z, nadj, p, p1, p2, p3, q, r, w;
	int i, hx, ix;
	nadj = 0;
	hx = *(int *)&x;
	ix = hx & 0x7fffffff;
	if (ix >= 0x7f800000)
		return x * x;
	if (ix == 0)
		return ((x + one) / zero);
	if (ix < 0x1c800000) {
		if (hx < 0) {
			return -native_log(-x);
		} else
			return -native_log(x);
	}
	if (hx < 0) {
		if (ix >= 0x4b000000)
			return ((-x) / zero);
		t = __gen_ocl_internal_sinpi(x);
		if (t == zero)
			return ((-x) / zero);
		nadj = native_log(pi / __gen_ocl_fabs(t * x));
		x = -x;
	}
	if (ix == 0x3f800000 || ix == 0x40000000)
		r = 0;
	else if (ix < 0x40000000) {
		if (ix <= 0x3f666666) {
			r = -native_log(x);
			if (ix >= 0x3f3b4a20) {
				y = one - x;
				i = 0;
			} else if (ix >= 0x3e6d3308) {
				y = x - (tc - one);
				i = 1;
			} else {
				y = x;
				i = 2;
			}
		} else {
			r = zero;
			if (ix >= 0x3fdda618) {
				y = (float) 2.0 - x;
				i = 0;
			}
			else if (ix >= 0x3F9da620) {
				y = x - tc;
				i = 1;
			}
			else {
				y = x - one;
				i = 2;
			}
		}
		switch (i) {
		case 0:
			z = y * y;
			p1 = mad(z, mad(z, mad(z, mad(z, mad(z, a10, a8), a6), a4), a2), a0);
			p2 = z * mad(z, mad(z, mad(z, mad(z, mad(z, a11, a9), a7), a5), a3), a1);
			p = mad(y, p1, p2);
			r += (p - (float) 0.5 * y);
			break;
		case 1:
			z = y * y;
			w = z * y;
			p1 = mad(w, mad(w, mad(w, mad(w, t12, t9), t6), t3), t0);
			p2 = mad(w, mad(w, mad(w, mad(w, t13, t10), t7), t4), t1);
			p3 = mad(w, mad(w, mad(w, mad(w, t14, t11), t8), t5), t2);
			p = mad(p1, z, mad(w, mad(y, p3, p2), -tt));
			r += (tf + p);
			break;
		case 2:
			p1 = y * mad(y, mad(y, mad(y, mad(y, mad(y, u5, u4), u3), u2), u1), u0);
			p2 = mad(y, mad(y, mad(y, mad(y, mad(y, v5, v4), v3), v2), v1), one);
			r += (-(float) 0.5 * y + p1 / p2);
		}
	} else if (ix < 0x41000000) {
		i = (int) x;
		t = zero;
		y = x - (float) i;

		p =y * mad(y, mad(y, mad(y, mad(y, mad(y, mad(y, s6, s5), s4), s3), s2), s1), s0);
		q = mad(y, mad(y, mad(y, mad(y, mad(y, mad(y, r6, r5), r4), r3), r2), r1), one);
		r = .5f * y + p / q;
		z = one;

		switch (i) {
		case 7:
			z *= (y + 6.0f);
		case 6:
			z *= (y + 5.0f);
		case 5:
			z *= (y + 4.0f);
		case 4:
			z *= (y + 3.0f);
		case 3:
			z *= (y + 2.0f);
			r += native_log(z);
			break;
		}

	} else if (ix < 0x5c800000) {
		t = native_log(x);
		z = one / x;
		y = z * z;
		w = mad(z, mad(y, mad(y, mad(y, mad(y, mad(y, w6, w5), w4), w3), w2), w1), w0);
		r = (x - .5f) * (t - one) + w;
	} else
		r = x * (native_log(x) - one);
	if (hx < 0)
		r = nadj - r;
	return r;
}

/*
 * ====================================================
 * Copyright (C) 1993 by Sun Microsystems, Inc. All rights reserved.
 *
 * Developed at SunPro, a Sun Microsystems, Inc. business.
 * Permission to use, copy, modify, and distribute this
 * software is freely granted, provided that this notice
 * is preserved.
 * ====================================================
 */
#define BODY \
    const float  \
        zero=  0.,  \
        one =  1.0000000000e+00,  \
        pi  =  3.1415927410e+00,  \
        a0  =  7.7215664089e-02,  \
        a1  =  3.2246702909e-01,  \
        a2  =  6.7352302372e-02,  \
        a3  =  2.0580807701e-02,  \
        a4  =  7.3855509982e-03,  \
        a5  =  2.8905137442e-03,  \
        a6  =  1.1927076848e-03,  \
        a7  =  5.1006977446e-04,  \
        a8  =  2.2086278477e-04,  \
        a9  =  1.0801156895e-04,  \
        a10 =  2.5214456400e-05,  \
        a11 =  4.4864096708e-05,  \
        tc  =  1.4616321325e+00,  \
        tf  = -1.2148628384e-01,  \
        tt  =  6.6971006518e-09,  \
        t0  =  4.8383611441e-01,  \
        t1  = -1.4758771658e-01,  \
        t2  =  6.4624942839e-02,  \
        t3  = -3.2788541168e-02,  \
        t4  =  1.7970675603e-02,  \
        t5  = -1.0314224288e-02,  \
        t6  =  6.1005386524e-03,  \
        t7  = -3.6845202558e-03,  \
        t8  =  2.2596477065e-03,  \
        t9  = -1.4034647029e-03,  \
        t10 =  8.8108185446e-04,  \
        t11 = -5.3859531181e-04,  \
        t12 =  3.1563205994e-04,  \
        t13 = -3.1275415677e-04,  \
        t14 =  3.3552918467e-04,  \
        u0  = -7.7215664089e-02,  \
        u1  =  6.3282704353e-01,  \
        u2  =  1.4549225569e+00,  \
        u3  =  9.7771751881e-01,  \
        u4  =  2.2896373272e-01,  \
        u5  =  1.3381091878e-02,  \
        v1  =  2.4559779167e+00,  \
        v2  =  2.1284897327e+00,  \
        v3  =  7.6928514242e-01,  \
        v4  =  1.0422264785e-01,  \
        v5  =  3.2170924824e-03,  \
        s0  = -7.7215664089e-02,  \
        s1  =  2.1498242021e-01,  \
        s2  =  3.2577878237e-01,  \
        s3  =  1.4635047317e-01,  \
        s4  =  2.6642270386e-02,  \
        s5  =  1.8402845599e-03,  \
        s6  =  3.1947532989e-05,  \
        r1  =  1.3920053244e+00,  \
        r2  =  7.2193557024e-01,  \
        r3  =  1.7193385959e-01,  \
        r4  =  1.8645919859e-02,  \
        r5  =  7.7794247773e-04,  \
        r6  =  7.3266842264e-06,  \
        w0  =  4.1893854737e-01,  \
        w1  =  8.3333335817e-02,  \
        w2  = -2.7777778450e-03,  \
        w3  =  7.9365057172e-04,  \
        w4  = -5.9518753551e-04,  \
        w5  =  8.3633989561e-04,  \
        w6  = -1.6309292987e-03;  \
	float t, y, z, nadj, p, p1, p2, p3, q, r, w;  \
	int i, hx, ix;  \
	nadj = 0;  \
	hx = *(int *)&x;  \
	*signgamp = 1;  \
	ix = hx & 0x7fffffff;  \
	if (ix >= 0x7f800000)  \
		return x * x;  \
	if (ix == 0)  \
		return ((x + one) / zero);  \
	if (ix < 0x1c800000) {  \
		if (hx < 0) {  \
			*signgamp = -1;  \
			return -native_log(-x);  \
		} else  \
			return -native_log(x);  \
	}  \
	if (hx < 0) {  \
		if (ix >= 0x4b000000)  \
			return ((-x) / zero);  \
		t = __gen_ocl_internal_sinpi(x);  \
		if (t == zero)  \
			return ((-x) / zero);  \
		nadj = native_log(pi / __gen_ocl_fabs(t * x));  \
		if (t < zero)  \
			*signgamp = -1;  \
		x = -x;  \
	}  \
	if (ix == 0x3f800000 || ix == 0x40000000)  \
		r = 0;  \
	else if (ix < 0x40000000) {  \
		if (ix <= 0x3f666666) {  \
			r = -native_log(x);  \
			if (ix >= 0x3f3b4a20) {  \
				y = one - x;  \
				i = 0;  \
			} else if (ix >= 0x3e6d3308) {  \
				y = x - (tc - one);  \
				i = 1;  \
			} else {  \
				y = x;  \
				i = 2;  \
			}  \
		} else {  \
			r = zero;  \
			if (ix >= 0x3fdda618) {  \
				y = (float) 2.0 - x;  \
				i = 0;  \
			}  \
			else if (ix >= 0x3F9da620) {  \
				y = x - tc;  \
				i = 1;  \
			}  \
			else {  \
				y = x - one;  \
				i = 2;  \
			}  \
		}  \
		switch (i) {  \
		case 0:  \
			z = y * y;  \
			p1 = mad(z, mad(z, mad(z, mad(z, mad(z, a10, a8), a6), a4), a2), a0);	\
			p2 = z * mad(z, mad(z, mad(z, mad(z, mad(z, a11, a9), a7), a5), a3), a1);	\
			p = mad(y, p1, p2);	\
			r = r - mad(y, 0.5f, -p);	\
			break;  \
		case 1:  \
			z = y * y;  \
			w = z * y;  \
			p1 = mad(w, mad(w, mad(w, mad(w, t12, t9), t6), t3), t0);	\
			p2 = mad(w, mad(w, mad(w, mad(w, t13, t10), t7), t4), t1);	\
			p3 = mad(w, mad(w, mad(w, mad(w, t14, t11), t8), t5), t2);	\
			p = z * p1 + mad(w, mad(y, p3, p2), -tt);	\
			r += (tf + p);  \
			break;  \
		case 2:  \
			p1 = y * mad(y, mad(y, mad(y, mad(y, mad(y, u5, u4), u3), u2), u1), u0);	\
			p2 = mad(y, mad(y, mad(y, mad(y, mad(y, v5, v4), v3), v2), v1), one);	\
			r = r + mad(y, -0.5f, p1 / p2);	\
		}  \
	} else if (ix < 0x41000000) {  \
		i = (int) x;  \
		t = zero;  \
		y = x - (float) i;  \
		p = y * mad(y, mad(y, mad(y, mad(y, mad(y, mad(y, s6, s5), s4), s3), s2), s1), s0);		\
		q = mad(y, mad(y, mad(y, mad(y, mad(y, mad(y, r6, r5), r4), r3), r2), r1), one);	\
		r = mad(y, 0.5f, p / q);	\
		z = one;  \
		switch (i) {  \
		case 7:  \
			z *= (y + (float) 6.0);  \
		case 6:  \
			z *= (y + (float) 5.0);  \
		case 5:  \
			z *= (y + (float) 4.0);  \
		case 4:  \
			z *= (y + (float) 3.0);  \
		case 3:  \
			z *= (y + (float) 2.0);  \
			r += native_log(z);  \
			break;  \
		}  \
		  \
	} else if (ix < 0x5c800000) {  \
		t = native_log(x);  \
		z = one / x;  \
		y = z * z;  \
		w = mad(z, mad(y, mad(y, mad(y, mad(y, mad(y, w6, w5), w4), w3), w2), w1), w0);  \
		r = (x - .5f) * (t - one) + w;  \
	} else  \
		r = x * (native_log(x) - one);	\
	if (hx < 0)  \
		r = nadj - r;  \
	return r;
OVERLOADABLE float lgamma_r(float x, global int *signgamp) { BODY; }
OVERLOADABLE float lgamma_r(float x, local int *signgamp) { BODY; }
OVERLOADABLE float lgamma_r(float x, private int *signgamp) { BODY; }
#undef BODY

OVERLOADABLE float log1p(float x) {
  if (__ocl_math_fastpath_flag)
    return __gen_ocl_internal_fastpath_log1p(x);
/*
 *  Conversion to float by Ian Lance Taylor, Cygnus Support, ian@cygnus.com
 * ====================================================
 * Copyright (C) 1993 by Sun Microsystems, Inc. All rights reserved.
 *
 * Developed at SunPro, a Sun Microsystems, Inc. business.
 * Permission to use, copy, modify, and distribute this
 * software is freely granted, provided that this notice
 * is preserved.
 * ====================================================
 */
  const float
  ln2_hi =   6.9313812256e-01,  /* 0x3f317180 */
  ln2_lo =   9.0580006145e-06,  /* 0x3717f7d1 */
  two25 =    3.355443200e+07, /* 0x4c000000 */
  Lp1 = 6.6666668653e-01, /* 3F2AAAAB */
  Lp2 = 4.0000000596e-01, /* 3ECCCCCD */
  Lp3 = 2.8571429849e-01, /* 3E924925 */
  Lp4 = 2.2222198546e-01; /* 3E638E29 */
  const float zero = 0.0;
  float hfsq,f,c,s,z,R,u;
  int k,hx,hu,ax;
  union {float f; unsigned i;} un;
  un.f = x;  hx = un.i;
  ax = hx&0x7fffffff;

  k = 1;
  if (hx < 0x3ed413d7) {      /* x < 0.41422  */
      if(ax>=0x3f800000) {    /* x <= -1.0 */
    if(x==(float)-1.0) return -two25/zero; /* log1p(-1)=+inf */
    else return (x-x)/(x-x);  /* log1p(x<-1)=NaN */
      }
      if(ax<0x31000000) {     /* |x| < 2**-29 */
    if(two25+x>zero     /* raise inexact */
              &&ax<0x24800000)    /* |x| < 2**-54 */
        return x;
    else
        return x - x*x*(float)0.5;
      }
      if(hx>0||hx<=((int)0xbe95f61f)) {
    k=0;f=x;hu=1;}  /* -0.2929<x<0.41422 */
  }
  if (hx >= 0x7f800000) return x+x;
  if(k!=0) {
      if(hx<0x5a000000) {
    u  = (float)1.0+x;

    un.f = u; hu = un.i;
          k  = (hu>>23)-127;
    /* correction term */
          c  = (k>0)? (float)1.0-(u-x):x-(u-(float)1.0);
    c /= u;
      } else {
    u  = x;
    un.f = u; hu = un.i;
          k  = (hu>>23)-127;
    c  = 0;
      }
      hu &= 0x007fffff;
      if(hu<0x3504f7) {
          un.i = hu|0x3f800000; u = un.f;/* normalize u */
      } else {
          k += 1;
          un.i = hu|0x3f000000; u = un.f;  /* normalize u/2 */
          hu = (0x00800000-hu)>>2;
      }
      f = u-(float)1.0;
  }
  hfsq=(float)0.5*f*f;
  if(hu==0)
  { /* |f| < 2**-20 */
      if(f==zero)
      {
    	  if(k==0) return zero;
    	  else {c = mad(k , ln2_lo, c); return mad(k, ln2_hi, c);}
      }
      R = mad(hfsq, 1.0f, -0.66666666666666666f * f);
      if(k==0) return f-R; else
    	  return k * ln2_hi - (R - mad(k, ln2_lo, c) - f);
  }
  s = f/((float)2.0+f);
  z = s*s;
  R = z * mad(z, mad(z, mad(z, Lp4, Lp3), Lp2), Lp1);
  if(k==0)
	  return f + mad(hfsq + R, s, -hfsq);
  else
	  return k*ln2_hi-( (hfsq - mad(s, hfsq + R, mad(k, ln2_lo, c))) - f);
}

OVERLOADABLE float logb(float x) {
  if (__ocl_math_fastpath_flag)
    return __gen_ocl_internal_fastpath_logb(x);

  union {float f; unsigned i;} u;
  u.f = x;
  int e =  ((u.i & 0x7f800000) >> 23);
  float r1 = e-127;
  float r2 = -INFINITY;
  float r3 = x*x;
    /* sub normal or +/-0 */
  float r = e == 0 ? r2 : r1;
    /* inf & nan */
  return e == 0xff ? r3 : r;
}

OVERLOADABLE int ilogb(float x) {
  if (__ocl_math_fastpath_flag)
    return __gen_ocl_internal_fastpath_ilogb(x);

  union { int i; float f; } u;
  if (isnan(x))
    return FP_ILOGBNAN;
  if (isinf(x))
    return 0x7FFFFFFF;
  u.f = x;
  u.i &= 0x7fffffff;
  if (u.i == 0)
    return FP_ILOGB0;
  if (u.i >= 0x800000)
    return (u.i >> 23) - 127;
  int r = -126;
  int a = u.i & 0x7FFFFF;
  while(a < 0x800000) {
    a <<= 1;
    r --;
  }
  return r;
}
OVERLOADABLE float nan(uint code) {
  return NAN;
}
OVERLOADABLE float __gen_ocl_internal_tanpi(float x) {
  float sign = 1.0f;
  int ix;
  if(isinf(x)) return NAN;
  if(x < 0.0f) { x = -x; sign = -1.0f; }
  GEN_OCL_GET_FLOAT_WORD(ix, x);
  if(x> 0x1.0p24) return 0.0f;
  float m = __gen_ocl_internal_floor(x);
  ix = (int)m;
  m = x-m;
  int n = __gen_ocl_internal_floor(m*4.0f);
  if(m == 0.5f) {
    return (ix&0x1) == 0 ? sign*INFINITY : sign*-INFINITY;
  }
  if(m == 0.0f) {
    return (ix&0x1) == 0 ? 0.0f : -0.0f;
  }

  switch(n) {
    case 0:
      return sign * __kernel_tanf(m*M_PI_F, 0.0f, 1);
    case 1:
      return sign * 1.0f/__kernel_tanf((0.5f-m)*M_PI_F, 0.0f, 1);
    case 2:
      return sign * 1.0f/__kernel_tanf((0.5f-m)*M_PI_F, 0.0f, 1);
    default:
      return sign * -1.0f*__kernel_tanf((1.0f-m)*M_PI_F, 0.0f, 1);
  }
}
OVERLOADABLE float __gen_ocl_internal_cbrt(float x) {
  /* copied from fdlibm */
  const unsigned
  B1 = 709958130, /* B1 = (84+2/3-0.03306235651)*2**23 */
  B2 = 642849266; /* B2 = (76+2/3-0.03306235651)*2**23 */

  const float
  C =  5.4285717010e-01, /* 19/35     = 0x3f0af8b0 */
  D = -7.0530611277e-01, /* -864/1225 = 0xbf348ef1 */
  E =  1.4142856598e+00, /* 99/70     = 0x3fb50750 */
  F =  1.6071428061e+00, /* 45/28     = 0x3fcdb6db */
  G =  3.5714286566e-01; /* 5/14      = 0x3eb6db6e */

  float r,s,t, w;
  int hx;
  uint sign;
  uint high;

  GEN_OCL_GET_FLOAT_WORD(hx,x);
  sign=hx&0x80000000;     /* sign= sign(x) */
  hx  ^=sign;
  if(hx>=0x7f800000) return(x+x); /* cbrt(NaN,INF) is itself */
  if(hx==0)
      return(x);    /* cbrt(0) is itself */

  GEN_OCL_SET_FLOAT_WORD(x,hx); /* x <- |x| */
    /* rough cbrt to 5 bits */
  if(hx<0x00800000)     /* subnormal number */
    {
    //SET_FLOAT_WORD(t,0x4b800000); /* set t= 2**24 */
     //t*=x; GET_FLOAT_WORD(high,t); SET_FLOAT_WORD(t,high/3+B2);
      t = (sign = 0) ? 0.0f : -0.0f;
      return t;
    }
  else
    GEN_OCL_SET_FLOAT_WORD(t,hx/3+B1);


    /* new cbrt to 23 bits */
  r=t*t/x;
  s=mad(r, t, C);
  t*=G+F/(s+E+D/s);
    /* one step newton iteration to 53 bits with error less than 0.667 ulps */
  s=t*t;    /* t*t is exact */
  r=x/s;
  w=t+t;
  r=(r-t)/(w+r);  /* r-s is exact */
  t=mad(t, r, t);

    /* retore the sign bit */
  GEN_OCL_GET_FLOAT_WORD(high,t);
  GEN_OCL_SET_FLOAT_WORD(t,high|sign);
  return(t);
}

#define BODY \
  *cosval = cos(x); \
  return sin(x);

OVERLOADABLE float sincos(float x, global float *cosval) {
  if (__ocl_math_fastpath_flag)
    return __gen_ocl_internal_fastpath_sincos(x, cosval);
  BODY;
}
OVERLOADABLE float sincos(float x, local float *cosval) {
  if (__ocl_math_fastpath_flag)
    return __gen_ocl_internal_fastpath_sincos(x, cosval);
  BODY;
}
OVERLOADABLE float sincos(float x, private float *cosval) {
  if (__ocl_math_fastpath_flag)
    return __gen_ocl_internal_fastpath_sincos(x, cosval);
  BODY;
}
#undef BODY

INLINE float __gen_ocl_asin_util(float x) {
/*
 * ====================================================
 * Copyright (C) 1993 by Sun Microsystems, Inc. All rights reserved.
 *
 * Developed at SunSoft, a Sun Microsystems, Inc. business.
 * Permission to use, copy, modify, and distribute this
 * software is freely granted, provided that this notice
 * is preserved.
 * ====================================================
 */
  float
  pS0 =  1.66666666666666657415e-01,
  pS1 = -3.25565818622400915405e-01,
  pS2 =  2.01212532134862925881e-01,
  pS3 = -4.00555345006794114027e-02,
  pS4 =  7.91534994289814532176e-04,
  qS1 = -2.40339491173441421878e+00,
  qS2 =  2.02094576023350569471e+00,
  qS3 = -6.88283971605453293030e-01,
  qS4 =  7.70381505559019352791e-02;

  float t = x*x;
  float p = t * mad(t, mad(t, mad(t, mad(t, pS4, pS3), pS2), pS1), pS0);
  float q = mad(t, mad(t, mad(t, mad(t, qS4, qS3), qS2), qS1), 1.0f);
  float w = p / q;
  return mad(x, w, x);
}

OVERLOADABLE float __gen_ocl_internal_asin(float x) {
  uint ix;
  union { uint i; float f; } u;
  u.f = x;
  ix = u.i & 0x7fffffff;
  if(ix == 0x3f800000) {
    return x * M_PI_2_F;  /* asin(|1|)=+-pi/2 with inexact */
  }
  if(ix > 0x3f800000) {            /* |x|>= 1 */
    return  NAN;          /* asin(|x|>1) is NaN */
  }

  if(ix < 0x32000000) {            /* if |x| < 2**-27 */
    if(HUGE_VALF + x > FLT_ONE) return x;   /* return x with inexact if x!=0*/
  }

  if(x < -0.5) {
    return 2 * __gen_ocl_asin_util(native_sqrt((1+x) / 2)) - M_PI_2_F;
  } else if(x > 0.5) {
    return M_PI_2_F - 2 * __gen_ocl_asin_util(native_sqrt((1-x) / 2));
  } else {
    return __gen_ocl_asin_util(x);
  }
}
OVERLOADABLE float __gen_ocl_internal_asinpi(float x) {
  return __gen_ocl_internal_asin(x) / M_PI_F;
}
OVERLOADABLE float __gen_ocl_internal_acos(float x) {
  if(x > 0.5)
    return 2 * __gen_ocl_asin_util(native_sqrt((1-x)/2));
  else
    return M_PI_2_F - __gen_ocl_internal_asin(x);
}
OVERLOADABLE float __gen_ocl_internal_acospi(float x) {
  return __gen_ocl_internal_acos(x) / M_PI_F;
}
__constant float atanhi[4] = {
  4.6364760399e-01, /* atan(0.5)hi 0x3eed6338 */
  7.8539812565e-01, /* atan(1.0)hi 0x3f490fda */
  9.8279368877e-01, /* atan(1.5)hi 0x3f7b985e */
  1.5707962513e+00, /* atan(inf)hi 0x3fc90fda */
};
__constant float atanlo[4] = {
  5.0121582440e-09, /* atan(0.5)lo 0x31ac3769 */
  3.7748947079e-08, /* atan(1.0)lo 0x33222168 */
  3.4473217170e-08, /* atan(1.5)lo 0x33140fb4 */
  7.5497894159e-08, /* atan(inf)lo 0x33a22168 */
};

OVERLOADABLE float __gen_ocl_internal_atan(float x) {
  /* copied from fdlibm */
  float aT[11];
  aT[0] = 3.3333334327e-01; /* 0x3eaaaaaa */
  aT[1] =  -2.0000000298e-01; /* 0xbe4ccccd */
  aT[2] =   1.4285714924e-01; /* 0x3e124925 */
  aT[3] =  -1.1111110449e-01; /* 0xbde38e38 */
  aT[4] =   9.0908870101e-02; /* 0x3dba2e6e */
  aT[5] =  -7.6918758452e-02; /* 0xbd9d8795 */
  aT[6] =   6.6610731184e-02; /* 0x3d886b35 */
  const float one = 1.0, huge = 1.0e30;

  float w,s1,s2,z;
  int ix,hx,id;

  GEN_OCL_GET_FLOAT_WORD(hx,x);
  ix = hx&0x7fffffff;
  if(ix>=0x50800000) {  /* if |x| >= 2^34 */
      if(ix>0x7f800000)
    return x+x;   /* NaN */
      if(hx>0) return  atanhi[3]+atanlo[3];
      else     return -atanhi[3]-atanlo[3];
  } if (ix < 0x3ee00000) {  /* |x| < 0.4375 */
      if (ix < 0x31000000) {  /* |x| < 2^-29 */
    if(huge+x>one) return x;  /* raise inexact */
      }
      id = -1;
  } else {
  x = __gen_ocl_fabs(x);
  if (ix < 0x3f980000) {    /* |x| < 1.1875 */
      if (ix < 0x3f300000) {  /* 7/16 <=|x|<11/16 */
    id = 0; x = ((float)2.0*x-one)/((float)2.0+x);
      } else {      /* 11/16<=|x|< 19/16 */
    id = 1; x  = (x-one)/(x+one);
      }
  } else {
      if (ix < 0x401c0000) {  /* |x| < 2.4375 */
    id = 2; x  = (x-(float)1.5)/(one+(float)1.5*x);
      } else {      /* 2.4375 <= |x| < 2^66 */
    id = 3; x  = -(float)1.0/x;
      }
  }}
    /* end of argument reduction */
  z = x*x;
  w = z*z;
    /* break sum from i=0 to 10 aT[i]z**(i+1) into odd and even poly */
  s1 = z * mad(w, mad(w, mad(w, aT[6], aT[4]), aT[2]), aT[0]);
  s2 = w * mad(w, mad(w, aT[5], aT[3]), aT[1]);
  if (id<0) return x - x*(s1+s2);
  else {
      z = atanhi[id] - ((x*(s1+s2) - atanlo[id]) - x);
      return (hx<0)? -z:z;
  }

}
OVERLOADABLE float __gen_ocl_internal_atanpi(float x) {
  return __gen_ocl_internal_atan(x) / M_PI_F;
}

// XXX work-around PTX profile
OVERLOADABLE float sqrt(float x) { return native_sqrt(x); }
OVERLOADABLE float rsqrt(float x) { return native_rsqrt(x); }
OVERLOADABLE float __gen_ocl_internal_atan2(float y, float x) {
  /* copied from fdlibm */
  float z;
  int k,m,hx,hy,ix,iy;
  const float
  tiny  = 1.0e-30,
  zero  = 0.0,
  pi_o_4  = 7.8539818525e-01, /* 0x3f490fdb */
  pi_o_2  = 1.5707963705e+00, /* 0x3fc90fdb */
  pi      = 3.1415927410e+00, /* 0x40490fdb */
  pi_lo   = -8.7422776573e-08; /* 0xb3bbbd2e */

  GEN_OCL_GET_FLOAT_WORD(hx,x);
  ix = hx&0x7fffffff;
  GEN_OCL_GET_FLOAT_WORD(hy,y);
  iy = hy&0x7fffffff;

  if((ix>0x7f800000)||
     (iy>0x7f800000)) /* x or y is NaN */
     return x+y;
  if(hx==0x3f800000) return z=__gen_ocl_internal_atan(y);   /* x=1.0 */
  m = ((hy>>31)&1)|((hx>>30)&2);  /* 2*sign(x)+sign(y) */

    /* when y = 0 */
  if(iy==0) {
      switch(m) {
    case 0:
    case 1: return y;   /* atan(+-0,+anything)=+-0 */
    case 2: return  pi+tiny;/* atan(+0,-anything) = pi */
    case 3: return -pi-tiny;/* atan(-0,-anything) =-pi */
      }
  }
    /* when x = 0 */
  if(ix==0) return (hy<0)?  -pi_o_2-tiny: pi_o_2+tiny;

  /* both are denorms. Gen does not support denorm, so we convert to normal float number*/
  if(ix <= 0x7fffff && iy <= 0x7fffff) {
    x = (float)(ix) * (1.0f - ((hx>>30) & 0x2));
    y = (float)(iy) * (1.0f - ((hy>>30) & 0x2));
  }

    /* when x is INF */
  if(ix==0x7f800000) {
      if(iy==0x7f800000) {
    switch(m) {
        case 0: return  pi_o_4+tiny;/* atan(+INF,+INF) */
        case 1: return -pi_o_4-tiny;/* atan(-INF,+INF) */
        case 2: return  (float)3.0*pi_o_4+tiny;/*atan(+INF,-INF)*/
        case 3: return (float)-3.0*pi_o_4-tiny;/*atan(-INF,-INF)*/
    }
      } else {
    switch(m) {
        case 0: return  zero  ; /* atan(+...,+INF) */
        case 1: return -zero  ; /* atan(-...,+INF) */
        case 2: return  pi+tiny  ;  /* atan(+...,-INF) */
        case 3: return -pi-tiny  ;  /* atan(-...,-INF) */
    }
      }
  }
    /* when y is INF */
  if(iy==0x7f800000) return (hy<0)? -pi_o_2-tiny: pi_o_2+tiny;

    /* compute y/x */
  k = (iy-ix)>>23;
  if(k > 60) z=pi_o_2+(float)0.5*pi_lo;   /* |y/x| >  2**60 */
  else if(hx<0&&k<-60) z=0.0;   /* |y|/x < -2**60 */
  else z=__gen_ocl_internal_atan(__gen_ocl_fabs(y/x)); /* safe to do y/x */
  switch (m) {
      case 0: return       z  ; /* atan(+,+) */
      case 1: {
              uint zh;
          GEN_OCL_GET_FLOAT_WORD(zh,z);
          GEN_OCL_SET_FLOAT_WORD(z,zh ^ 0x80000000);
        }
        return       z  ; /* atan(-,+) */
      case 2: return  pi-(z-pi_lo);/* atan(+,-) */
      default: /* case 3 */
            return  (z-pi_lo)-pi;/* atan(-,-) */
  }
}

OVERLOADABLE float __gen_ocl_internal_atan2pi(float y, float x) {
  return __gen_ocl_internal_atan2(y, x) / M_PI_F;
}
OVERLOADABLE float __gen_ocl_internal_fabs(float x)  { return __gen_ocl_fabs(x); }
OVERLOADABLE float __gen_ocl_internal_trunc(float x) { return __gen_ocl_rndz(x); }
OVERLOADABLE float __gen_ocl_internal_round(float x) {
  float y = __gen_ocl_rndz(x);
  if (__gen_ocl_fabs(x - y) >= 0.5f)
    y += __gen_ocl_internal_copysign(1.f, x);
  return y;
}
OVERLOADABLE float __gen_ocl_internal_ceil(float x)  { return __gen_ocl_rndu(x); }
OVERLOADABLE float __gen_ocl_internal_rint(float x) {
  return __gen_ocl_rnde(x);
}

OVERLOADABLE float __gen_ocl_internal_exp(float x) {
  float o_threshold = 8.8721679688e+01,  /* 0x42b17180 */
  u_threshold = -1.0397208405e+02,  /* 0xc2cff1b5 */
  twom100 = 7.8886090522e-31, 	 /* 2**-100=0x0d800000 */
  ivln2	 =	1.4426950216e+00, /* 0x3fb8aa3b =1/ln2 */
  one = 1.0,
  huge = 1.0e+30,
  P1 = 1.6666667163e-01, /* 0x3e2aaaab */
  P2 = -2.7777778450e-03; /* 0xbb360b61 */
  float y,hi=0.0,lo=0.0,c,t;
  int k=0,xsb;
  unsigned hx;
  float ln2HI_0 = 6.9313812256e-01;	/* 0x3f317180 */
  float ln2HI_1 = -6.9313812256e-01;	/* 0xbf317180 */
  float ln2LO_0 = 9.0580006145e-06;  	/* 0x3717f7d1 */
  float ln2LO_1 = -9.0580006145e-06; /* 0xb717f7d1 */
  float half_0 = 0.5;
  float half_1 =	-0.5;

  GEN_OCL_GET_FLOAT_WORD(hx,x);
  xsb = (hx>>31)&1;		/* sign bit of x */
  hx &= 0x7fffffff;		/* high word of |x| */

  /* filter out non-finite argument */
  if(hx >= 0x42b17218) {			/* if |x|>=88.721... */
    if(hx>0x7f800000)
      return x+x;			/* NaN */
    if(hx==0x7f800000)
      return (xsb==0)? x:0.0; 	/* exp(+-inf)={inf,0} */
    if(x > o_threshold) return huge*huge; /* overflow */
    if(x < u_threshold) return twom100*twom100; /* underflow */
  }
  /* argument reduction */
  if(hx > 0x3eb17218) {		/* if  |x| > 0.5 ln2 */
    if(hx < 0x3F851592) {	/* and |x| < 1.5 ln2 */
      hi = x-(xsb ==1 ? ln2HI_1 : ln2HI_0); lo= xsb == 1? ln2LO_1 : ln2LO_0; k = 1-xsb-xsb;
    } else {
      float tmp = xsb == 1 ? half_1 : half_0;
      k  = ivln2*x+tmp;
      t  = k;
      hi = x - t*ln2HI_0;	/* t*ln2HI is exact here */
      lo = t*ln2LO_0;
    }
    x  = hi - lo;
  }
  else if(hx < 0x31800000)  { /* when |x|<2**-28 */
    if(huge+x>one) return one+x;/* trigger inexact */
  }
  else k = 0;

  /* x is now in primary range */
  t  = x*x;
  c  = x - t*(P1+t*P2);
  if(k==0)
    return one-((x*c)/(c-(float)2.0)-x);
  else
    y = one-((lo-(x*c)/((float)2.0-c))-hi);
  if(k >= -125) {
    unsigned hy;
    GEN_OCL_GET_FLOAT_WORD(hy,y);
    GEN_OCL_SET_FLOAT_WORD(y,hy+(k<<23));	/* add k to y's exponent */
    return y;
  } else {
    unsigned hy;
    GEN_OCL_GET_FLOAT_WORD(hy,y);
    GEN_OCL_SET_FLOAT_WORD(y,hy+((k+100)<<23)); /* add k to y's exponent */
    return y*twom100;
  }
}

/* erf,erfc from glibc s_erff.c -- float version of s_erf.c.
 * Conversion to float by Ian Lance Taylor, Cygnus Support, ian@cygnus.com.
 */

/*
 * ====================================================
 * Copyright (C) 1993 by Sun Microsystems, Inc. All rights reserved.
 *
 * Developed at SunPro, a Sun Microsystems, Inc. business.
 * Permission to use, copy, modify, and distribute this
 * software is freely granted, provided that this notice
 * is preserved.
 * ====================================================
 */

INLINE_OVERLOADABLE float __gen_ocl_internal_erf(float x) {
/*...*/
const float
tiny = 1.0e-30,
half_val=  5.0000000000e-01, /* 0x3F000000 */
one =  1.0000000000e+00, /* 0x3F800000 */
two =  2.0000000000e+00, /* 0x40000000 */
	/* c = (subfloat)0.84506291151 */
erx =  8.4506291151e-01, /* 0x3f58560b */
/*
 * Coefficients for approximation to  erf on [0,0.84375]
 */
efx =  1.2837916613e-01, /* 0x3e0375d4 */
efx8=  1.0270333290e+00, /* 0x3f8375d4 */
pp0  =  1.2837916613e-01, /* 0x3e0375d4 */
pp1  = -3.2504209876e-01, /* 0xbea66beb */
pp2  = -2.8481749818e-02, /* 0xbce9528f */
pp3  = -5.7702702470e-03, /* 0xbbbd1489 */
pp4  = -2.3763017452e-05, /* 0xb7c756b1 */
qq1  =  3.9791721106e-01, /* 0x3ecbbbce */
qq2  =  6.5022252500e-02, /* 0x3d852a63 */
qq3  =  5.0813062117e-03, /* 0x3ba68116 */
qq4  =  1.3249473704e-04, /* 0x390aee49 */
qq5  = -3.9602282413e-06, /* 0xb684e21a */
/*
 * Coefficients for approximation to  erf  in [0.84375,1.25]
 */
pa0  = -2.3621185683e-03, /* 0xbb1acdc6 */
pa1  =  4.1485610604e-01, /* 0x3ed46805 */
pa2  = -3.7220788002e-01, /* 0xbebe9208 */
pa3  =  3.1834661961e-01, /* 0x3ea2fe54 */
pa4  = -1.1089469492e-01, /* 0xbde31cc2 */
pa5  =  3.5478305072e-02, /* 0x3d1151b3 */
pa6  = -2.1663755178e-03, /* 0xbb0df9c0 */
qa1  =  1.0642088205e-01, /* 0x3dd9f331 */
qa2  =  5.4039794207e-01, /* 0x3f0a5785 */
qa3  =  7.1828655899e-02, /* 0x3d931ae7 */
qa4  =  1.2617121637e-01, /* 0x3e013307 */
qa5  =  1.3637083583e-02, /* 0x3c5f6e13 */
qa6  =  1.1984500103e-02, /* 0x3c445aa3 */
 /*
 * Coefficients for approximation to  erfc in [1.25,1/0.35]
 */ra0  = -9.8649440333e-03, /* 0xbc21a093 */
ra1  = -6.9385856390e-01, /* 0xbf31a0b7 */
ra2  = -1.0558626175e+01, /* 0xc128f022 */
ra3  = -6.2375331879e+01, /* 0xc2798057 */
ra4  = -1.6239666748e+02, /* 0xc322658c */
ra5  = -1.8460508728e+02, /* 0xc3389ae7 */
ra6  = -8.1287437439e+01, /* 0xc2a2932b */
ra7  = -9.8143291473e+00, /* 0xc11d077e */
sa1  =  1.9651271820e+01, /* 0x419d35ce */
sa2  =  1.3765776062e+02, /* 0x4309a863 */
sa3  =  4.3456588745e+02, /* 0x43d9486f */
sa4  =  6.4538726807e+02, /* 0x442158c9 */
sa5  =  4.2900814819e+02, /* 0x43d6810b */
sa6  =  1.0863500214e+02, /* 0x42d9451f */
sa7  =  6.5702495575e+00, /* 0x40d23f7c */
sa8  = -6.0424413532e-02, /* 0xbd777f97 */
/*
 * Coefficients for approximation to  erfc in [1/.35,28]
 */
rb0  = -9.8649431020e-03, /* 0xbc21a092 */
rb1  = -7.9928326607e-01, /* 0xbf4c9dd4 */
rb2  = -1.7757955551e+01, /* 0xc18e104b */
rb3  = -1.6063638306e+02, /* 0xc320a2ea */
rb4  = -6.3756646729e+02, /* 0xc41f6441 */
rb5  = -1.0250950928e+03, /* 0xc480230b */
rb6  = -4.8351919556e+02, /* 0xc3f1c275 */
sb1  =  3.0338060379e+01, /* 0x41f2b459 */
sb2  =  3.2579251099e+02, /* 0x43a2e571 */
sb3  =  1.5367296143e+03, /* 0x44c01759 */
sb4  =  3.1998581543e+03, /* 0x4547fdbb */
sb5  =  2.5530502930e+03, /* 0x451f90ce */
sb6  =  4.7452853394e+02, /* 0x43ed43a7 */
sb7  = -2.2440952301e+01; /* 0xc1b38712 */

	int hx,ix,i;
	float R,S,P,Q,s,y,z,r;
	GEN_OCL_GET_FLOAT_WORD(hx,x);
	ix = hx&0x7fffffff;
	if(ix>=0x7f800000) {		/* erf(nan)=nan */
	    i = ((unsigned int)hx>>31)<<1;
	    return (float)(1-i)+one/x;	/* erf(+-inf)=+-1 */
	}

	if(ix < 0x3f580000) {		/* |x|<0.84375 */
	    if(ix < 0x31800000) { 	/* |x|<2**-28 */
	        if (ix < 0x04000000)
		    /*avoid underflow */
		    return (float)0.125*((float)8.0*x+efx8*x);
		return x + efx*x;
	    }
	    z = x*x;
	    r = mad(z, mad(z, mad(z, mad(z, pp4, pp3), pp2), pp1), pp0);
	    s = mad(z, mad(z, mad(z, mad(z, mad(z, qq5,qq4), qq3), qq2), qq1), one);
	    y = r / s;
	    return mad(x, y, x);
	}
	if(ix < 0x3fa00000) {		/* 0.84375 <= |x| < 1.25 */
	    s = __gen_ocl_internal_fabs(x)-one;
	    P = mad(s, mad(s, mad(s, mad(s, mad(s, mad(s, pa6, pa5), pa4), pa3), pa2), pa1), pa0);
	    Q = mad(s, mad(s, mad(s, mad(s, mad(s, mad(s, qa6, qa5), qa4), qa3), qa2), qa1), one);
	    if(hx>=0) return erx + P/Q; else return -erx - P/Q;
	}
	if (ix >= 0x40c00000) {		/* inf>|x|>=6 */
	    if(hx>=0) return one-tiny; else return tiny-one;
	}
	x = __gen_ocl_internal_fabs(x);
    s = one/(x*x);
	if(ix< 0x4036DB6E) {	/* |x| < 1/0.35 */
	    R = mad(s, mad(s, mad(s, mad(s, mad(s, mad(s, mad(s,
	    		ra7, ra6), ra5), ra4), ra3), ra2), ra1), ra0);
	    S = mad(s, mad(s, mad(s, mad(s, mad(s, mad(s, mad(s, mad(s,
	    		sa8, sa7), sa6), sa5), sa4), sa3), sa2), sa1), one);
	} else {	/* |x| >= 1/0.35 */
	    R = mad(s, mad(s, mad(s, mad(s, mad(s, mad(s,
	    		rb6, rb5), rb4), rb3), rb2), rb1), rb0);
	    S = mad(s, mad(s, mad(s, mad(s, mad(s, mad(s, mad(s,
	    		sb7, sb6), sb5), sb4), sb3), sb2), sb1), one);
	}
	GEN_OCL_GET_FLOAT_WORD(ix,x);
	GEN_OCL_SET_FLOAT_WORD(z,ix&0xfffff000);
	r  =  __gen_ocl_internal_exp(-z*z-(float)0.5625)*__gen_ocl_internal_exp((z-x)*(z+x)+R/S);
	if(hx>=0) return one-r/x; else return  r/x-one;
}
INLINE_OVERLOADABLE float __gen_ocl_internal_erfc(float x) {
/*...*/
const float
tiny = 1.0e-30,
half_val=  5.0000000000e-01, /* 0x3F000000 */
one =  1.0000000000e+00, /* 0x3F800000 */
two =  2.0000000000e+00, /* 0x40000000 */
	/* c = (subfloat)0.84506291151 */
erx =  8.4506291151e-01, /* 0x3f58560b */
/*
 * Coefficients for approximation to  erf on [0,0.84375]
 */
efx =  1.2837916613e-01, /* 0x3e0375d4 */
efx8=  1.0270333290e+00, /* 0x3f8375d4 */
pp0  =  1.2837916613e-01, /* 0x3e0375d4 */
pp1  = -3.2504209876e-01, /* 0xbea66beb */
pp2  = -2.8481749818e-02, /* 0xbce9528f */
pp3  = -5.7702702470e-03, /* 0xbbbd1489 */
pp4  = -2.3763017452e-05, /* 0xb7c756b1 */
qq1  =  3.9791721106e-01, /* 0x3ecbbbce */
qq2  =  6.5022252500e-02, /* 0x3d852a63 */
qq3  =  5.0813062117e-03, /* 0x3ba68116 */
qq4  =  1.3249473704e-04, /* 0x390aee49 */
qq5  = -3.9602282413e-06, /* 0xb684e21a */
/*
 * Coefficients for approximation to  erf  in [0.84375,1.25]
 */
pa0  = -2.3621185683e-03, /* 0xbb1acdc6 */
pa1  =  4.1485610604e-01, /* 0x3ed46805 */
pa2  = -3.7220788002e-01, /* 0xbebe9208 */
pa3  =  3.1834661961e-01, /* 0x3ea2fe54 */
pa4  = -1.1089469492e-01, /* 0xbde31cc2 */
pa5  =  3.5478305072e-02, /* 0x3d1151b3 */
pa6  = -2.1663755178e-03, /* 0xbb0df9c0 */
qa1  =  1.0642088205e-01, /* 0x3dd9f331 */
qa2  =  5.4039794207e-01, /* 0x3f0a5785 */
qa3  =  7.1828655899e-02, /* 0x3d931ae7 */
qa4  =  1.2617121637e-01, /* 0x3e013307 */
qa5  =  1.3637083583e-02, /* 0x3c5f6e13 */
qa6  =  1.1984500103e-02, /* 0x3c445aa3 */
 /*
 * Coefficients for approximation to  erfc in [1.25,1/0.35]
 */ra0  = -9.8649440333e-03, /* 0xbc21a093 */
ra1  = -6.9385856390e-01, /* 0xbf31a0b7 */
ra2  = -1.0558626175e+01, /* 0xc128f022 */
ra3  = -6.2375331879e+01, /* 0xc2798057 */
ra4  = -1.6239666748e+02, /* 0xc322658c */
ra5  = -1.8460508728e+02, /* 0xc3389ae7 */
ra6  = -8.1287437439e+01, /* 0xc2a2932b */
ra7  = -9.8143291473e+00, /* 0xc11d077e */
sa1  =  1.9651271820e+01, /* 0x419d35ce */
sa2  =  1.3765776062e+02, /* 0x4309a863 */
sa3  =  4.3456588745e+02, /* 0x43d9486f */
sa4  =  6.4538726807e+02, /* 0x442158c9 */
sa5  =  4.2900814819e+02, /* 0x43d6810b */
sa6  =  1.0863500214e+02, /* 0x42d9451f */
sa7  =  6.5702495575e+00, /* 0x40d23f7c */
sa8  = -6.0424413532e-02, /* 0xbd777f97 */
/*
 * Coefficients for approximation to  erfc in [1/.35,28]
 */
rb0  = -9.8649431020e-03, /* 0xbc21a092 */
rb1  = -7.9928326607e-01, /* 0xbf4c9dd4 */
rb2  = -1.7757955551e+01, /* 0xc18e104b */
rb3  = -1.6063638306e+02, /* 0xc320a2ea */
rb4  = -6.3756646729e+02, /* 0xc41f6441 */
rb5  = -1.0250950928e+03, /* 0xc480230b */
rb6  = -4.8351919556e+02, /* 0xc3f1c275 */
sb1  =  3.0338060379e+01, /* 0x41f2b459 */
sb2  =  3.2579251099e+02, /* 0x43a2e571 */
sb3  =  1.5367296143e+03, /* 0x44c01759 */
sb4  =  3.1998581543e+03, /* 0x4547fdbb */
sb5  =  2.5530502930e+03, /* 0x451f90ce */
sb6  =  4.7452853394e+02, /* 0x43ed43a7 */
sb7  = -2.2440952301e+01; /* 0xc1b38712 */
	int hx,ix;
	float R,S,P,Q,s,y,z,r;
	GEN_OCL_GET_FLOAT_WORD(hx,x);
	ix = hx&0x7fffffff;
	if(ix>=0x7f800000) {			/* erfc(nan)=nan */
						/* erfc(+-inf)=0,2 */
	    return (float)(((unsigned int)hx>>31)<<1)+one/x;
	}

	if(ix < 0x3f580000) {		/* |x|<0.84375 */
	    if(ix < 0x23800000)  	/* |x|<2**-56 */
		return one-x;
	    z = x*x;
	    r = mad(z, mad(z, mad(z, mad(z, pp4, pp3), pp2), pp1), pp0);
	    s = mad(z, mad(z, mad(z, mad(z, mad(z, qq5, qq4), qq3), qq2), qq1), one);
	    y = r/s;
	    if(hx < 0x3e800000) {  	/* x<1/4 */
		return one-(x+x*y);
	    } else {
		r = x*y;
		r += (x-half_val);
	        return half_val - r ;
	    }
	}
	if(ix < 0x3fa00000) {		/* 0.84375 <= |x| < 1.25 */
	    s = __gen_ocl_internal_fabs(x)-one;
	    P = mad(s, mad(s, mad(s, mad(s, mad(s, mad(s, pa6, pa5), pa4), pa3), pa2), pa1), pa0);
	    Q = mad(s, mad(s, mad(s, mad(s, mad(s, mad(s, qa6, qa5), qa4), qa3), qa2), qa1), one);
	    if(hx>=0) {
	        z  = one-erx; return z - P/Q;
	    } else {
		z = erx+P/Q; return one+z;
	    }
	}
	if (ix < 0x41e00000) {		/* |x|<28 */
	    x = __gen_ocl_internal_fabs(x);
        s = one/(x*x);
	    if(ix< 0x4036DB6D) {	/* |x| < 1/.35 ~ 2.857143*/
		    R = mad(s, mad(s, mad(s, mad(s, mad(s, mad(s, mad(s,
		    		ra7, ra6), ra5), ra4), ra3), ra2), ra1), ra0);
		    S = mad(s, mad(s, mad(s, mad(s, mad(s, mad(s, mad(s, mad(s,
		    		sa8, sa7), sa6), sa5), sa4), sa3), sa2), sa1), one);
	    } else {			/* |x| >= 1/.35 ~ 2.857143 */
		if(hx<0&&ix>=0x40c00000) return two-tiny;/* x < -6 */
		    R = mad(s, mad(s, mad(s, mad(s, mad(s, mad(s,
		    		rb6, rb5), rb4), rb3), rb2), rb1), rb0);
		    S = mad(s, mad(s, mad(s, mad(s, mad(s, mad(s, mad(s,
		    		sb7, sb6), sb5), sb4), sb3), sb2), sb1), one);
	    }
	    GEN_OCL_GET_FLOAT_WORD(ix,x);
	    GEN_OCL_SET_FLOAT_WORD(z,ix&0xffffe000);
	    r  =  __gen_ocl_internal_exp(-z*z-(float)0.5625)*
			__gen_ocl_internal_exp((z-x)*(z+x)+R/S);
	    if(hx>0) {
		float ret = r/x;
		return ret;
	    } else
		return two-r/x;
	} else {
	    if(hx>0) {
		return tiny*tiny;
	    } else
		return two-tiny;
	}
}

OVERLOADABLE float __gen_ocl_internal_fmod (float x, float y) {
  //return x-y*__gen_ocl_rndz(x/y);
  float one = 1.0;
  float Zero[2];
  int n,hx,hy,hz,ix,iy,sx,i;
  Zero[0] = 0.0;
  Zero[1] = -0.0;
  GEN_OCL_GET_FLOAT_WORD(hx,x);
  GEN_OCL_GET_FLOAT_WORD(hy,y);
  sx = hx&0x80000000;		/* sign of x */
  hx ^=sx;		/* |x| */
  hy &= 0x7fffffff;	/* |y| */
  /* purge off exception values */
  if(hy==0||(hx>=0x7f800000)||		/* y=0,or x not finite */
  (hy>0x7f800000))			/* or y is NaN */
    return (x*y)/(x*y);
  if(hx<hy) return x;			/* |x|<|y| return x */
  if(hx==hy)
    return Zero[(unsigned)sx>>31];	/* |x|=|y| return x*0*/

  /* determine ix = ilogb(x) */
  if(hx<0x00800000) {	/* subnormal x */
    for (ix = -126,i=(hx<<8); i>0; i<<=1) ix -=1;
  } else ix = (hx>>23)-127;

  /* determine iy = ilogb(y) */
  if(hy<0x00800000) {	/* subnormal y */
    for (iy = -126,i=(hy<<8); i>=0; i<<=1) iy -=1;
  } else iy = (hy>>23)-127;

  /* set up {hx,lx}, {hy,ly} and align y to x */
  if(ix >= -126)
    hx = 0x00800000|(0x007fffff&hx);
  else {		/* subnormal x, shift x to normal */
    n = -126-ix;
    hx = hx<<n;
  }
  if(iy >= -126)
    hy = 0x00800000|(0x007fffff&hy);
  else {		/* subnormal y, shift y to normal */
    n = -126-iy;
    hy = hy<<n;
  }
  /* fix point fmod */
  n = ix - iy;
  while(n--) {
    hz=hx-hy;
    if(hz<0){hx = hx+hx;}
    else {
      if(hz==0)		/* return sign(x)*0 */
        return Zero[(unsigned)sx>>31];
      hx = hz+hz;
    }
  }
  hz=hx-hy;
  if(hz>=0) {hx=hz;}

    /* convert back to floating value and restore the sign */
  if(hx==0)			/* return sign(x)*0 */
    return Zero[(unsigned)sx>>31];
  while(hx<0x00800000) {		/* normalize x */
    hx = hx+hx;
    iy -= 1;
  }
  if(iy>= -126) {		/* normalize output */
    hx = ((hx-0x00800000)|((iy+127)<<23));
	GEN_OCL_SET_FLOAT_WORD(x,hx|sx);
   } else {		/* subnormal output */
     n = -126 - iy;
     hx >>= n;
     GEN_OCL_SET_FLOAT_WORD(x,hx|sx);
     x *= one;		/* create necessary signal */
  }
  return x;		/* exact output */
}

OVERLOADABLE float __gen_ocl_internal_expm1(float x) {
  //return __gen_ocl_pow(M_E_F, x) - 1;
  float	Q1 = -3.3333335072e-02, /* 0xbd088889 */
  ln2_hi = 6.9313812256e-01,	/* 0x3f317180 */
  ln2_lo = 9.0580006145e-06,	/* 0x3717f7d1 */
  Q2 = 1.5873016091e-03, /* 0x3ad00d01 */
  huge = 1.0e30,
  tiny = 1.0e-30,
  ivln2 = 1.4426950216e+00, /* 0x3fb8aa3b =1/ln2 */
  one	=  1.0,
  o_threshold=  8.8721679688e+01;  /* 0x42b17180 */
  float y,hi,lo,c,t,e,hxs,hfx,r1;
  int k,xsb;
  int hx;
  GEN_OCL_GET_FLOAT_WORD(hx,x);
  xsb = hx&0x80000000;
  /* sign bit of x */
  //if(xsb==0)
  //y=x;
  //else
  //y= -x; /* y = |x| */
  y = __gen_ocl_internal_fabs(x);
  hx &= 0x7fffffff;		/* high word of |x| */
  /* filter out huge and non-finite argument */
  if(hx >= 0x4195b844) {			/* if |x|>=27*ln2 */
    if(hx >= 0x42b17218) {		/* if |x|>=88.721... */
      if(hx>0x7f800000)
        return x+x; 	 /* NaN */
      if(hx==0x7f800000)
        return (xsb==0)? x:-1.0;/* exp(+-inf)={inf,-1} */
      if(x > o_threshold)
        return huge*huge; /* overflow */
    }
    if(xsb!=0) { /* x < -27*ln2, return -1.0 with inexact */
      if(x+tiny<(float)0.0)	/* raise inexact */
        return tiny-one;	/* return -1 */
    }
  }
  /* argument reduction */
  if(hx > 0x3eb17218) {/* if  |x| > 0.5 ln2 */
    if(hx < 0x3F851592) {/* and |x| < 1.5 ln2 */
      if(xsb==0){
        hi = x - ln2_hi; lo = ln2_lo;  k =  1;
      }	else {
        hi = x + ln2_hi; lo = -ln2_lo;  k = -1;
      }
    } else {
      k  = ivln2*x+((xsb==0)?(float)0.5:(float)-0.5);
      t  = k;
      hi = x - t*ln2_hi;/* t*ln2_hi is exact here */
      lo = t*ln2_lo;
    }
    x  = hi - lo;
    c  = (hi-x)-lo;
  } else if(hx < 0x33000000) {	/* when |x|<2**-25, return x */
    //t = huge+x; /* return x with inexact flags when x!=0 */
    //return x - (t-(huge+x));
    return x;
  } else k = 0;
  /* x is now in primary range */
  hfx = (float)0.5*x;
  hxs = x*hfx;
  r1 = one+hxs*(Q1+hxs*Q2);
  t = (float)3.0-r1*hfx;
  e = hxs*((r1-t)/((float)6.0 - x*t));
  if(k==0)
    return x - (x*e-hxs);		/* c is 0 */
  else{
    e = (x*(e-c)-c);
    e -= hxs;
    if(k== -1)return (float)0.5*(x-e)-(float)0.5;
    if(k==1){
      if(x < (float)-0.25)
        return -(float)2.0*(e-(x+(float)0.5));
      else
        return  (one+(float)2.0*(x-e));
    }
    if (k <= -2 || k>56) {	 /* suffice to return exp(x)-1 */
      int i;
      y = one-(e-x);
      GEN_OCL_GET_FLOAT_WORD(i,y);
      GEN_OCL_SET_FLOAT_WORD(y,i+(k<<23));	/* add k to y's exponent */
      return y-one;
    }
    t = one;
    if(k<23) {
      int i;
      GEN_OCL_SET_FLOAT_WORD(t,0x3f800000 - (0x1000000>>k)); /* t=1-2^-k */
      y = t-(e-x);
      GEN_OCL_GET_FLOAT_WORD(i,y);
      GEN_OCL_SET_FLOAT_WORD(y,i+(k<<23));	/* add k to y's exponent */
    } else {
      int i;
      GEN_OCL_SET_FLOAT_WORD(t,((0x7f-k)<<23));	/* 2^-k */
      y = x-(e+t);
      y += one;
      GEN_OCL_GET_FLOAT_WORD(i,y);
      GEN_OCL_SET_FLOAT_WORD(y,i+(k<<23));	/* add k to y's exponent */
    }
  }
  return y;
}

OVERLOADABLE float __gen_ocl_internal_acosh(float x) {
  //return native_log(x + native_sqrt(x + 1) * native_sqrt(x - 1));
  float one	= 1.0,
  ln2	= 6.9314718246e-01;/* 0x3f317218 */
  float t;
  int hx;
  GEN_OCL_GET_FLOAT_WORD(hx,x);
  if(hx<0x3f800000) {	/* x < 1 */
    return (x-x)/(x-x);
  } else if(hx >=0x4d800000) {	/* x > 2**28 */
    if(hx >=0x7f800000) {/* x is inf of NaN */
      return x+x;
    } else
      return __gen_ocl_internal_log(x)+ln2;/* acosh(huge)=log(2x) */
  } else if (hx==0x3f800000) {
    return 0.0;			/* acosh(1) = 0 */
  } else if (hx > 0x40000000) {	/* 2**28 > x > 2 */
    t=x*x;
    return __gen_ocl_internal_log((float)2.0*x-one/(x+__gen_ocl_sqrt(t-one)));
  } else {			/* 1<x<2 */
    t = x-one;
    return log1p(t+__gen_ocl_sqrt((float)2.0*t+t*t));
  }
}

OVERLOADABLE float __gen_ocl_internal_asinh(float x){
  //return native_log(x + native_sqrt(x * x + 1));
  float one =  1.0000000000e+00, /* 0x3F800000 */
  ln2 =  6.9314718246e-01, /* 0x3f317218 */
  huge=  1.0000000000e+30;
  float w;
  int hx,ix;
  GEN_OCL_GET_FLOAT_WORD(hx,x);
  ix = hx&0x7fffffff;
  if(ix< 0x38000000) {	/* |x|<2**-14 */
    if(huge+x>one) return x;	/* return x inexact except 0 */
  }
  if(ix>0x47000000) {/* |x| > 2**14 */
    if(ix>=0x7f800000) return x+x;/* x is inf or NaN */
    w = __gen_ocl_internal_log(__gen_ocl_internal_fabs(x))+ln2;
  } else {
    float xa = __gen_ocl_internal_fabs(x);
    if (ix>0x40000000) {/* 2**14 > |x| > 2.0 */
      w = __gen_ocl_internal_log(mad(xa, 2.0f, one / (__gen_ocl_sqrt(mad(xa, xa, one)) + xa)));
    } else {		/* 2.0 > |x| > 2**-14 */
      float t = xa*xa;
      w =log1p(xa+t/(one+__gen_ocl_sqrt(one+t)));
    }
  }
  return __gen_ocl_internal_copysign(w, x);
}

OVERLOADABLE float __gen_ocl_internal_sinh(float x){
  //return (1 - native_exp(-2 * x)) / (2 * native_exp(-x));
  float one = 1.0,
  shuge = 1.0e37;
  float t,w,h;
  int ix,jx;
  GEN_OCL_GET_FLOAT_WORD(jx,x);
  ix = jx&0x7fffffff;
  /* x is INF or NaN */
  if(ix>=0x7f800000) return x+x;
  h = 0.5;
  if (jx<0) h = -h;
  /* |x| in [0,22], return sign(x)*0.5*(E+E/(E+1))) */
  if (ix < 0x41b00000) {		/* |x|<22 */
    if (ix<0x31800000)	/* |x|<2**-28 */
      if(shuge+x>one) return x;/* sinh(tiny) = tiny with inexact */
    t = __gen_ocl_internal_expm1(__gen_ocl_internal_fabs(x));
    if(ix<0x3f800000) return h*((float)2.0*t-t*t/(t+one));
      return h*(t+t/(t+one));
  }
  /* |x| in [22, log(maxdouble)] return 0.5*exp(|x|) */
  if (ix < 0x42b17180)  return h*__gen_ocl_internal_exp(__gen_ocl_internal_fabs(x));
  /* |x| in [log(maxdouble), overflowthresold] */
  if (ix<=0x42b2d4fc) {
    w = __gen_ocl_internal_exp((float)0.5*__gen_ocl_internal_fabs(x));
    t = h*w;
    return t*w;
  }
  /* |x| > overflowthresold, sinh(x) overflow */
  return x*shuge;
}

OVERLOADABLE float __gen_ocl_internal_tanh(float x) {
  //float y = native_exp(-2 * x);
  //return (1 - y) / (1 + y);
  float one=1.0, two=2.0, tiny = 1.0e-30;
  float t,z;
  int jx,ix;
  GEN_OCL_GET_FLOAT_WORD(jx,x);
  ix = jx&0x7fffffff;
  /* x is INF or NaN */
  if(ix>=0x7f800000) {
    if (jx>=0)
      return one/x+one; /* tanh(+-inf)=+-1 */
    else
      return one/x-one; /* tanh(NaN) = NaN */
  }

  if (ix < 0x41b00000) { /* |x|<22 */
    if (ix == 0)
      return x;		/* x == +-0 */
    if (ix<0x24000000) 	/* |x|<2**-55 */
      return x*(one+x);    	/* tanh(small) = small */
    if (ix>=0x3f800000) {	/* |x|>=1  */
      t = __gen_ocl_internal_expm1(two*__gen_ocl_internal_fabs(x));
      z = one - two/(t+two);
    } else {
      t = __gen_ocl_internal_expm1(-two*__gen_ocl_internal_fabs(x));
      z= -t/(t+two);
    }
  } else { /* |x| > 22, return +-1 */
    z = one - tiny;		/* raised inexact flag */
  }
  return (jx>=0)? z: -z;
}

OVERLOADABLE float __gen_ocl_internal_cosh(float x) {
  //return (1 + native_exp(-2 * x)) / (2 * native_exp(-x));
  float halF = 0.5,
  huge = 1.0e+30,
  tiny = 1.0e-30,
  one = 1.0;
  float t,w;
  int ix;
  GEN_OCL_GET_FLOAT_WORD(ix,x);
  ix &= 0x7fffffff;
  /* |x| in [0,22] */
  if (ix < 0x41b00000) {
    /* |x| in [0,0.5*ln2], return 1+expm1(|x|)^2/(2*exp(|x|)) */
    if(ix<0x3eb17218) {
      t = __gen_ocl_internal_expm1(__gen_ocl_fabs(x));
      w = one+t;
      if (ix<0x24000000) return w;	/* cosh(tiny) = 1 */
      return one+(t*t)/(w+w);
    }
    /* |x| in [0.5*ln2,22], return (exp(|x|)+1/exp(|x|)/2; */
    t = __gen_ocl_internal_exp(__gen_ocl_fabs(x));
    return halF*t+halF/t;
  }
  /* |x| in [22, log(maxdouble)] return half*exp(|x|) */
  if (ix < 0x42b17180)  return halF*__gen_ocl_internal_exp(__gen_ocl_fabs(x));
  /* |x| in [log(maxdouble), overflowthresold] */
  if (ix<=0x42b2d4fc) {
    w = __gen_ocl_internal_exp(halF*__gen_ocl_fabs(x));
    t = halF*w;
    return t*w;
  }
  /* x is INF or NaN */
  if(ix>=0x7f800000) return x*x;
  /* |x| > overflowthresold, cosh(x) overflow */
  return huge*huge;
}

OVERLOADABLE float __gen_ocl_internal_remainder(float x, float p){
  //return x-y*__gen_ocl_rnde(x/y);
  float zero = 0.0;
  int hx,hp;
  unsigned sx;
  float p_half;
  GEN_OCL_GET_FLOAT_WORD(hx,x);
  GEN_OCL_GET_FLOAT_WORD(hp,p);
  sx = hx&0x80000000;
  hp &= 0x7fffffff;
  hx &= 0x7fffffff;
  /* purge off exception values */
  if(hp==0) return (x*p)/(x*p);	        /* p = 0 */
  if((hx>=0x7f800000)||               /* x not finite */
    ((hp>0x7f800000)))	               /* p is NaN */
    return (x*p)/(x*p);
  if (hp<=0x7effffff) x = __gen_ocl_internal_fmod(x,p+p); /* now x < 2p */
  if ((hx-hp)==0) return zero*x;
  x = __gen_ocl_fabs(x);
  p = __gen_ocl_fabs(p);
  if (hp<0x01000000) {
    if(x+x>p) {
      x-=p;
      if(x+x>=p) x -= p;
    }
  } else {
    p_half = (float)0.5*p;
    if(x>p_half) {
      x-=p;
      if(x>=p_half) x -= p;
    }
  }
  GEN_OCL_GET_FLOAT_WORD(hx,x);
  GEN_OCL_SET_FLOAT_WORD(x,hx^sx);
  return x;
}

OVERLOADABLE float __gen_ocl_internal_ldexp(float x, int n) {
  x = __gen_ocl_scalbnf(x,n);
  return x;
}

OVERLOADABLE float __gen_ocl_internal_atanh(float x) {
  //return 0.5f * native_sqrt((1 + x) / (1 - x));
  float xa = __gen_ocl_fabs (x);
  float t;
  if (isless (xa, 0.5f)){
    if (xa < 0x1.0p-28f) return x;
    t = xa + xa;
    t = 0.5f * log1p (t + t * xa / (1.0f - xa));
  } else if (isless (xa, 1.0f)){
    t = 0.5f * log1p ((xa + xa) / (1.0f - xa));
  } else{
    if (isgreater (xa, 1.0f)) return (x - x) / (x - x);
    return x / 0.0f;
  }
  return __gen_ocl_internal_copysign(t, x);
}

OVERLOADABLE float __gen_ocl_internal_exp10(float x){
  float px, qx,ans;
  short n;
  int i;
  float*p;
  float MAXL10 = 38.230809449325611792;
  float LOG210 = 3.32192809488736234787e0;
  float LG102A = 3.00781250000000000000E-1;
  float LG102B = 2.48745663981195213739E-4;
  float P[6];
  P[0] = 2.063216740311022E-001;
  P[1] = 5.420251702225484E-001;
  P[2] = 1.171292686296281E+000;
  P[3] = 2.034649854009453E+000;
  P[4] = 2.650948748208892E+000;
  P[5] = 2.302585167056758E+000;

  if( x < -MAXL10 ) return 0.0;

  if( isinf(x))  return INFINITY;
  /* The following is necessary because range reduction blows up: */
  if( x == 0 )return 1.0;

  /* Express 10**x = 10**g 2**n
    *	 = 10**g 10**( n log10(2) )
    *	 = 10**( g + n log10(2) )
    */
  px = x * LOG210;
  qx = __gen_ocl_internal_floor( px + 0.5 );
  n = qx;
  x -= qx * LG102A;
  x -= qx * LG102B;

  /* rational approximation for exponential
    * of the fractional part:
    * 10**x - 1  =  2x P(x**2)/( Q(x**2) - P(x**2) )
    */
  p = P;
  ans = *p++;
  i = 5;
  do{
    ans = ans * x  +  *p++;
  }
  while( --i );
  px = 1.0 + x * ans;

  /* multiply by power of 2 */
  x = __gen_ocl_internal_ldexp( px, n );
  return x;
}

OVERLOADABLE float cospi(float x) {
  if (__ocl_math_fastpath_flag)
    return __gen_ocl_internal_fastpath_cospi(x);

  return __gen_ocl_internal_cospi(x);
}

OVERLOADABLE float cosh(float x) {
  if (__ocl_math_fastpath_flag)
    return __gen_ocl_internal_fastpath_cosh(x);

  return  __gen_ocl_internal_cosh(x);
}

OVERLOADABLE float acos(float x) {
  return __gen_ocl_internal_acos(x);
}

OVERLOADABLE float acospi(float x) {
  return __gen_ocl_internal_acospi(x);
}

OVERLOADABLE float acosh(float x) {
  if (__ocl_math_fastpath_flag)
    return __gen_ocl_internal_fastpath_acosh(x);

  return __gen_ocl_internal_acosh(x);
}

OVERLOADABLE float sinpi(float x) {
  if (__ocl_math_fastpath_flag)
    return __gen_ocl_internal_fastpath_sinpi(x);

  return __gen_ocl_internal_sinpi(x);
}

OVERLOADABLE float sinh(float x) {
  if (__ocl_math_fastpath_flag)
    return __gen_ocl_internal_fastpath_sinh(x);

  return __gen_ocl_internal_sinh(x);
}

OVERLOADABLE float asin(float x) {
  return __gen_ocl_internal_asin(x);
}

OVERLOADABLE float asinpi(float x) {
  return __gen_ocl_internal_asinpi(x);
}

OVERLOADABLE float asinh(float x) {
  if (__ocl_math_fastpath_flag)
    return __gen_ocl_internal_fastpath_asinh(x);

  return __gen_ocl_internal_asinh(x);
}

OVERLOADABLE float tanpi(float x) {
  return __gen_ocl_internal_tanpi(x);
}

OVERLOADABLE float tanh(float x) {
  if (__ocl_math_fastpath_flag)
    return __gen_ocl_internal_fastpath_tanh(x);

  return __gen_ocl_internal_tanh(x);
}

OVERLOADABLE float atan(float x) {
  return __gen_ocl_internal_atan(x);
}

OVERLOADABLE float atan2(float y, float x) {
  return __gen_ocl_internal_atan2(y, x);
}

OVERLOADABLE float atan2pi(float y, float x) {
  return __gen_ocl_internal_atan2pi(y, x);
}

OVERLOADABLE float atanpi(float x) {
  return __gen_ocl_internal_atanpi(x);
}

OVERLOADABLE float atanh(float x) {
  if (__ocl_math_fastpath_flag)
    return __gen_ocl_internal_fastpath_atanh(x);

  return __gen_ocl_internal_atanh(x);
}

OVERLOADABLE float cbrt(float x) {
  if (__ocl_math_fastpath_flag)
    return __gen_ocl_internal_fastpath_cbrt(x);

  return __gen_ocl_internal_cbrt(x);
}

OVERLOADABLE float rint(float x) {
  return __gen_ocl_internal_rint(x);
}

OVERLOADABLE float copysign(float x, float y) {
  return __gen_ocl_internal_copysign(x, y);
}

OVERLOADABLE float erf(float x) {
  return __gen_ocl_internal_erf(x);
}

OVERLOADABLE float erfc(float x) {
  return __gen_ocl_internal_erfc(x);
}

OVERLOADABLE float fmod (float x, float y) {
  if (__ocl_math_fastpath_flag)
    return __gen_ocl_internal_fastpath_fmod(x, y);

  return __gen_ocl_internal_fmod(x, y);
}

OVERLOADABLE float remainder(float x, float p) {
  if (__ocl_math_fastpath_flag)
    return __gen_ocl_internal_fastpath_remainder(x, p);

  return __gen_ocl_internal_remainder(x, p);
}

OVERLOADABLE float ldexp(float x, int n) {
  if (__ocl_math_fastpath_flag)
    return __gen_ocl_internal_fastpath_ldexp(x, n);

  if (x == (float)0.0f) x = 0.0f;
  return __gen_ocl_internal_ldexp(x, n);
}

CONST OVERLOADABLE float __gen_ocl_mad(float a, float b, float c) __asm("llvm.fma" ".f32");
CONST OVERLOADABLE half __gen_ocl_mad(half a, half b, half c) __asm("llvm.fma" ".f16");
PURE CONST float __gen_ocl_fmax(float a, float b);
PURE CONST float __gen_ocl_fmin(float a, float b);

OVERLOADABLE float mad(float a, float b, float c) {
  return __gen_ocl_mad(a, b, c);
}


#define BODY \
  if (isnan(x) || isinf(x)) { \
    *exp = 0; \
    return x; \
  } \
  uint u = as_uint(x); \
  uint a = u & 0x7FFFFFFFu; \
  if (a == 0) { \
    *exp = 0; \
    return x; \
  } \
  if (a >= 0x800000) { \
    *exp = (a >> 23) - 126; \
    return as_float((u & (0x807FFFFFu)) | 0x3F000000); \
  } \
  int e = -126; \
  while (a < 0x400000) { \
    e --; \
    a <<= 1; \
  } \
  a <<= 1; \
  *exp = e; \
  return as_float((a & (0x807FFFFFu)) | (u & 0x80000000u) | 0x3F000000);
OVERLOADABLE float frexp(float x, global int *exp) { BODY; }
OVERLOADABLE float frexp(float x, local int *exp) { BODY; }
OVERLOADABLE float frexp(float x, private int *exp) { BODY; }
#undef BODY

OVERLOADABLE float nextafter(float x, float y) {
  int hx, hy, ix, iy;
  hx = as_int(x);
  hy = as_int(y);
  ix = hx & 0x7fffffff;
  iy = hy & 0x7fffffff;
  if(ix == 0)
    ix = hx & 0x7fffff;
  if(iy == 0)
    iy = hy & 0x7fffff;
  if(ix>0x7f800000 || iy>0x7f800000)
    return x+y;
  if(hx == hy)
    return y;
  if(ix == 0) {
    if(iy == 0)
      return y;
    else
      return as_float((hy&0x80000000) | 1);
  }
  if(hx >= 0) {
    if(hx > hy) {
      hx -= 1;
    } else {
      hx += 1;
    }
  } else {
    if(hy >= 0 || hx > hy){
      hx -= 1;
    } else {
      hx += 1;
    }
  }
  return as_float(hx);
}

#define BODY \
  uint hx = as_uint(x), ix = hx & 0x7FFFFFFF; \
  if (ix > 0x7F800000) { \
    *i = nan(0u); \
    return nan(0u); \
  } \
  if (ix == 0x7F800000) { \
    *i = x; \
    return as_float(hx & 0x80000000u); \
  } \
  *i = __gen_ocl_rndz(x); \
  return x - *i;
OVERLOADABLE float modf(float x, global float *i) { BODY; }
OVERLOADABLE float modf(float x, local float *i) { BODY; }
OVERLOADABLE float modf(float x, private float *i) { BODY; }
#undef BODY

OVERLOADABLE float __gen_ocl_internal_fmax(float a, float b) { return max(a,b); }
OVERLOADABLE float __gen_ocl_internal_fmin(float a, float b) { return min(a,b); }
OVERLOADABLE float __gen_ocl_internal_fmax(half a, half b) { return max(a,b); }
OVERLOADABLE float __gen_ocl_internal_fmin(half a, half b) { return min(a,b); }
OVERLOADABLE float __gen_ocl_internal_maxmag(float x, float y) {
  float a = __gen_ocl_fabs(x), b = __gen_ocl_fabs(y);
  return a > b ? x : b > a ? y : max(x, y);
}
OVERLOADABLE float __gen_ocl_internal_minmag(float x, float y) {
  float a = __gen_ocl_fabs(x), b = __gen_ocl_fabs(y);
  return a < b ? x : b < a ? y : min(x, y);
}
OVERLOADABLE float __gen_ocl_internal_fdim(float x, float y) {
  if(isnan(x))
    return x;
  if(isnan(y))
    return y;
  return x > y ? (x - y) : +0.f;
}
/*
 * the pow/pown high precision implementation are copied from msun library.
 * Conversion to float by Ian Lance Taylor, Cygnus Support, ian@cygnus.com.
 */

/*
 * ====================================================
 * Copyright (C) 1993 by Sun Microsystems, Inc. All rights reserved.
 *
 * Developed at SunPro, a Sun Microsystems, Inc. business.
 * Permission to use, copy, modify, and distribute this
 * software is freely granted, provided that this notice
 * is preserved.
 * ====================================================
 */

OVERLOADABLE float __gen_ocl_internal_pow(float x, float y) {
  float z,ax,z_h,z_l,p_h,p_l;
  float y1,t1,t2,r,s,sn,t,u,v,w;
  int i,j,k,yisint,n;
  int hx,hy,ix,iy,is;
  float bp[2],dp_h[2],dp_l[2],
  zero    =  0.0,
  one	=  1.0,
  two	=  2.0,
  two24	=  16777216.0,	/* 0x4b800000 */
  huge	=  1.0e30,
  tiny    =  1.0e-30,
  /* poly coefs for (3/2)*(log(x)-2s-2/3*s**3 */
  L1  =  6.0000002384e-01, /* 0x3f19999a */
  L2  =  4.2857143283e-01, /* 0x3edb6db7 */
  P1   =  1.6666667163e-01, /* 0x3e2aaaab */
  P2   = -2.7777778450e-03, /* 0xbb360b61 */
  lg2  =  6.9314718246e-01, /* 0x3f317218 */
  lg2_h  =  6.93145752e-01, /* 0x3f317200 */
  lg2_l  =  1.42860654e-06, /* 0x35bfbe8c */
  ovt =  4.2995665694e-08, /* -(128-log2(ovfl+.5ulp)) */
  cp    =  9.6179670095e-01, /* 0x3f76384f =2/(3ln2) */
  cp_h  =  9.6179199219e-01, /* 0x3f763800 =head of cp */
  cp_l  =  4.7017383622e-06, /* 0x369dc3a0 =tail of cp_h */
  ivln2    =  1.4426950216e+00, /* 0x3fb8aa3b =1/ln2 */
  ivln2_h  =  1.4426879883e+00, /* 0x3fb8aa00 =16b 1/ln2*/
  ivln2_l  =  7.0526075433e-06; /* 0x36eca570 =1/ln2 tail*/
  bp[0] = 1.0,bp[1] = 1.5,
  dp_h[0] = 0.0,dp_h[1] = 5.84960938e-01,
  dp_l[0] = 0.0,dp_l[1] = 1.56322085e-06;
  GEN_OCL_GET_FLOAT_WORD(hx,x);
  GEN_OCL_GET_FLOAT_WORD(hy,y);
  ix = hx&0x7fffffff;  iy = hy&0x7fffffff;
  if (ix < 0x00800000) {	   /* x < 2**-126  */
    ix = 0;/* Gen does not support subnormal number now */
  }
  if (iy < 0x00800000) {	  /* y < 2**-126  */
    iy = 0;/* Gen does not support subnormal number now */
  }
   /* y==zero: x**0 = 1 */
  if(iy==0) return one;
  /* pow(+1, y) returns 1 for any y, even a NAN */
  if(hx==0x3f800000) return one;
  /* +-NaN return x+y */
  if(ix > 0x7f800000 || iy > 0x7f800000)
    return (x+0.0f)+y+(0.0f);
  /* determine if y is an odd int when x < 0
     * yisint = 0	... y is not an integer
     * yisint = 1	... y is an odd int
     * yisint = 2	... y is an even int
     */
  yisint  = 0;
  if(hx<0) {
    if(iy>=0x4b800000) yisint = 2; /* even integer y */
    else if(iy>=0x3f800000) {
      k = (iy>>23)-0x7f;	   /* exponent */
      j = iy>>(23-k);
      if((j<<(23-k))==iy) yisint = 2-(j&1);
    }
  }
  /* special value of y */
  if (iy==0x7f800000) {	/* y is +-inf */
    if (ix==0x3f800000)
      //return  y - y;	/* inf**+-1 is NaN */
      return one;
    else if (ix > 0x3f800000)/* (|x|>1)**+-inf = inf,0 */
      return (hy>=0)? y: zero;
    else			/* (|x|<1)**-,+inf = inf,0 */
      return (hy<0)?-y: zero;
  }
  if(iy==0x3f800000) {	/* y is  +-1 */
    if(hy<0) return one/x; else return x;
  }
  if(hy==0x40000000) return x*x; /* y is  2 */
  if(hy==0x3f000000) {	/* y is  0.5 */
    if(hx>=0)return __gen_ocl_sqrt(x);
  }

  ax   = __gen_ocl_fabs(x);
    /* special value of x */
  if(ix==0x7f800000||ix==0||ix==0x3f800000){
    z = ax;			/*x is +-0,+-inf,+-1*/
    if(hy<0) z = one/z;	/* z = (1/|x|) */
    if(hx<0) {
      if(((ix-0x3f800000)|yisint)==0) {
        z = (z-z)/(z-z); /* (-1)**non-int is NaN */
      } else if(yisint==1)
        z = -z;		/* (x<0)**odd = -(|x|**odd) */
    }
    return z;
  }
  n = ((uint)hx>>31)-1;

  /* (x<0)**(non-int) is NaN */
  if((n|yisint)==0) return (x-x)/(x-x);

  sn = one; /* s (sign of result -ve**odd) = -1 else = 1 */
  if((n|(yisint-1))==0) sn = -one;/* (-ve)**(odd int) */

  /* |y| is huge */
  if(iy>0x4d000000) { /* if |y| > 2**27 */
    /* over/underflow if x is not close to one */
    if(ix<0x3f7ffff8) return (hy<0)? sn*huge*huge:sn*tiny*tiny;
    if(ix>0x3f800007) return (hy>0)? sn*huge*huge:sn*tiny*tiny;
    /* now |1-x| is tiny <= 2**-20, suffice to compute
          log(x) by x-x^2/2+x^3/3-x^4/4 */
    t = ax-1;		/* t has 20 trailing zeros */
    w = (t*t)*((float)0.5-t*(0.333333333333f-t*0.25f));
    u = ivln2_h*t;	/* ivln2_h has 16 sig. bits */
    v = t*ivln2_l-w*ivln2;
    t1 = u+v;
    GEN_OCL_GET_FLOAT_WORD(is,t1);
    GEN_OCL_SET_FLOAT_WORD(t1,is&0xfffff000);
    t2 = v-(t1-u);
  } else {
    float s2,s_h,s_l,t_h,t_l;
    n = 0;
	/* take care subnormal number */
    //if(ix<0x00800000)
      //{ax *= two24; n -= 24; GEN_OCL_GET_FLOAT_WORD(ix,ax); }
    n  += ((ix)>>23)-0x7f;
    j  = ix&0x007fffff;
	/* determine interval */
    ix = j|0x3f800000;		/* normalize ix */
    if(j<=0x1cc471) k=0;	/* |x|<sqrt(3/2) */
    else if(j<0x5db3d7) k=1;	/* |x|<sqrt(3)   */
    else {k=0;n+=1;ix -= 0x00800000;}
    GEN_OCL_SET_FLOAT_WORD(ax,ix);

	/* compute s = s_h+s_l = (x-1)/(x+1) or (x-1.5)/(x+1.5) */
    u = ax-bp[k];		/* bp[0]=1.0, bp[1]=1.5 */
    v = one/(ax+bp[k]);
    s = u*v;
    s_h = s;
    GEN_OCL_GET_FLOAT_WORD(is,s_h);
    GEN_OCL_SET_FLOAT_WORD(s_h,is&0xfffff000);
    /* t_h=ax+bp[k] High */
    is = ((ix>>1)&0xfffff000)|0x20000000;
    GEN_OCL_SET_FLOAT_WORD(t_h,is+0x00400000+(k<<21));
    t_l = ax - (t_h-bp[k]);
    s_l = v*((u-s_h*t_h)-s_h*t_l);

    /* compute log(ax) */
    s2 = s*s;
    r = s2*s2*(L1+s2*L2);
    r += s_l*(s_h+s);
    s2  = s_h*s_h;
    t_h = 3.0f+s2+r;
    GEN_OCL_GET_FLOAT_WORD(is,t_h);
    GEN_OCL_SET_FLOAT_WORD(t_h,is&0xffffe000);
    t_l = r-((t_h-3.0f)-s2);
    /* u+v = s*(1+...) */
    u = s_h*t_h;
    v = s_l*t_h+t_l*s;
    /* 2/(3log2)*(s+...) */
    p_h = u+v;
    GEN_OCL_GET_FLOAT_WORD(is,p_h);
    GEN_OCL_SET_FLOAT_WORD(p_h,is&0xffffe000);
    p_l = v-(p_h-u);
    z_h = cp_h*p_h;		/* cp_h+cp_l = 2/(3*log2) */
    z_l = cp_l*p_h+p_l*cp+dp_l[k];
    /* log2(ax) = (s+..)*2/(3*log2) = n + dp_h + z_h + z_l */
    t = (float)n;
    t1 = (((z_h+z_l)+dp_h[k])+t);
    GEN_OCL_GET_FLOAT_WORD(is,t1);
    GEN_OCL_SET_FLOAT_WORD(t1,is&0xffffe000);
    t2 = z_l-(((t1-t)-dp_h[k])-z_h);
  }

  /* split up y into y1+y2 and compute (y1+y2)*(t1+t2) */
  GEN_OCL_GET_FLOAT_WORD(is,y);
  GEN_OCL_SET_FLOAT_WORD(y1,is&0xffffe000);
  p_l = (y-y1)*t1+y*t2;
  p_h = y1*t1;
  z = p_l+p_h;
  GEN_OCL_GET_FLOAT_WORD(j,z);
  if (j>0x43000000)				/* if z > 128 */
    return sn*huge*huge;			/* overflow */
  else if (j==0x43000000) {			/* if z == 128 */
    if(p_l+ovt>z-p_h) return sn*huge*huge;	/* overflow */
  }
  else if ((j&0x7fffffff)>0x43160000)		/* z <= -150 */
    return sn*tiny*tiny;			/* underflow */
  else if (j==0xc3160000){			/* z == -150 */
    if(p_l<=z-p_h) return sn*tiny*tiny;		/* underflow */
  }

  /*
    * compute 2**(p_h+p_l)
    */
  i = j&0x7fffffff;
  k = (i>>23)-0x7f;
  n = 0;
  if(i>0x3f000000) {		/* if |z| > 0.5, set n = [z+0.5] */
    n = j+(0x00800000>>(k+1));
    k = ((n&0x7fffffff)>>23)-0x7f;	/* new k for n */
    GEN_OCL_SET_FLOAT_WORD(t,n&~(0x007fffff>>k));
    n = ((n&0x007fffff)|0x00800000)>>(23-k);
    if(j<0) n = -n;
    p_h -= t;
  }
  t = p_l+p_h;
  GEN_OCL_GET_FLOAT_WORD(is,t);
  GEN_OCL_SET_FLOAT_WORD(t,is&0xffff8000);
  u = t*lg2_h;
  v = (p_l-(t-p_h))*lg2+t*lg2_l;
  z = u+v;
  w = v-(z-u);
  t  = z*z;
  t1  = z - t*(P1+t*P2);
  r  = (z*t1)/(t1-two)-(w+z*w);
  z  = one-(r-z);
  GEN_OCL_GET_FLOAT_WORD(j,z);
  j += (n<<23);
  if((j>>23)<=0) z = __gen_ocl_scalbnf(z,n);	/* subnormal output */
  else GEN_OCL_SET_FLOAT_WORD(z,j);
  return sn*z;
}

OVERLOADABLE float tgamma (float x)
{
  /* based on glibc __ieee754_gammaf_r by Ulrich Drepper <drepper@cygnus.com> */

  unsigned int hx;
  GEN_OCL_GET_FLOAT_WORD(hx,x);
  if (hx == 0xff800000)
    {
      /* x == -Inf.  According to ISO this is NaN.  */
      return NAN;
    }
  if ((hx & 0x7f800000) == 0x7f800000)
    {
      /* Positive infinity (return positive infinity) or NaN (return
	 NaN).  */
      return x;
    }
  if (x < 0.0f && __gen_ocl_internal_floor (x) == x)
    {
      /* integer x < 0 */
      return NAN;
    }

  if (x >= 36.0f)
    {
      /* Overflow.  */
      return INFINITY;
    }
  else if (x <= 0.0f && x >= -FLT_EPSILON / 4.0f)
    {
      return 1.0f / x;
    }
  else
    {
      float sinpix = __gen_ocl_internal_sinpi(x);
      if (x <= -42.0f)
	/* Underflow.  */
	{return 0.0f * sinpix /*for sign*/;}
      int exp2_adj = 0;
      float x_abs = __gen_ocl_fabs(x);
      float gam0;

      if (x_abs < 4.0f) {
        /* gamma = exp(lgamma) is only accurate for small lgamma */
        float prod,x_adj;
        if (x_abs < 0.5f) {
          prod = 1.0f / x_abs;
          x_adj = x_abs + 1.0f;
        } else if (x_abs <= 1.5f) {
          prod = 1.0f;
          x_adj = x_abs;
        } else if (x_abs < 2.5f) {
          x_adj = x_abs - 1.0f;
          prod = x_adj;
        } else {
          x_adj = x_abs - 2.0f;
          prod = x_adj * (x_abs - 1.0f);
        }
        gam0 = __gen_ocl_internal_exp (lgamma (x_adj)) * prod;
      }
      else {
        /* Compute gamma (X) using Stirling's approximation,
  	 starting by computing pow (X, X) with a power of 2
  	 factored out to avoid intermediate overflow.  */
        float x_int = __gen_ocl_internal_round (x_abs);
        float x_frac = x_abs - x_int;
        int x_log2;
        float x_mant = frexp (x_abs, &x_log2);
        if (x_mant < M_SQRT1_2_F)
          {
          x_log2--;
          x_mant *= 2.0f;
          }
        exp2_adj = x_log2 * (int) x_int;
        float ret = (__gen_ocl_internal_pow(x_mant, x_abs)
  		   * exp2 (x_log2 * x_frac)
  		   * __gen_ocl_internal_exp (-x_abs)
  		   * sqrt (2.0f * M_PI_F / x_abs) );

        float x2 = x_abs * x_abs;
        float bsum = (0x3.403404p-12f / x2 -0xb.60b61p-12f) / x2 + 0x1.555556p-4f;
        gam0 = ret + ret * __gen_ocl_internal_expm1 (bsum / x_abs);
      }
      if (x > 0.0f) {return __gen_ocl_internal_ldexp (gam0, exp2_adj);}
      float gam1 = M_PI_F / (-x * sinpix * gam0);
      return __gen_ocl_internal_ldexp (gam1, -exp2_adj);
    }
}

float __gen_ocl_internal_pown(float x, int y) {
  const float
  bp[] = {1.0, 1.5,},
  dp_h[] = { 0.0, 5.84960938e-01,}, /* 0x3f15c000 */
  dp_l[] = { 0.0, 1.56322085e-06,}, /* 0x35d1cfdc */
  zero    =  0.0,
  one =  1.0,
  two =  2.0,
  two24 =  16777216.0,  /* 0x4b800000 */
  huge  =  1.0e30,
  tiny    =  1.0e-30,
    /* poly coefs for (3/2)*(log(x)-2s-2/3*s**3 */
  L1  =  6.0000002384e-01, /* 0x3f19999a */
  L2  =  4.2857143283e-01, /* 0x3edb6db7 */
  P1   =  1.6666667163e-01, /* 0x3e2aaaab */
  P2   = -2.7777778450e-03, /* 0xbb360b61 */
  lg2  =  6.9314718246e-01, /* 0x3f317218 */
  lg2_h  =  0x1.62ep-1,
  lg2_l  =  0x1.0bfbe8p-15,
  ovt =  4.2995665694e-08, /* -(128-log2(ovfl+.5ulp)) */
  cp    =  9.6179670095e-01, /* 0x3f76384f =2/(3ln2) */
  cp_h  =  9.6179199219e-01, /* 0x3f763800 =head of cp */
  cp_l  =  4.7017383622e-06, /* 0x369dc3a0 =tail of cp_h */
  ivln2    =  1.4426950216e+00, /* 0x3fb8aa3b =1/ln2 */
  ivln2_h  =  1.4426879883e+00, /* 0x3fb8aa00 =16b 1/ln2*/
  ivln2_l  =  7.0526075433e-06; /* 0x36eca570 =1/ln2 tail*/

  float z,ax,z_h,z_l,p_h,p_l;
  float y1,t1,t2,r,s,t,u,v,w;
  int i,j,k,yisint,n;
  int hx,ix,iy,is;

  GEN_OCL_GET_FLOAT_WORD(hx,x);
  ix = hx&0x7fffffff;
  iy = y > 0 ? y&0x7fffffff : (-y)&0x7fffffff;
    /* y==zero: x**0 = 1 */
  if(y==0) return one;

    /* +-NaN return NAN */
  if(ix > 0x7f800000)
    return NAN;

    /* determine if y is an odd int
     * yisint = 1 ... y is an odd int
     * yisint = 2 ... y is an even int
     */
    yisint = y&1 ? 1 : 2;

  if (y == 1) return x;
  if (y == -1) return one/x;
  if (y == 2) return x*x;

  ax   = __gen_ocl_fabs(x);

   /* special value of x */
  if(ix==0x7f800000||ix==0||ix==0x3f800000){
      z = ax;     /*x is +-0,+-inf,+-1*/
      if(y<0) z = one/z; /* z = (1/|x|) */
      if(hx<0) {
      if(yisint==1)
        z = -z;   /* (x<0)**odd = -(|x|**odd) */
      }
      return z;
  }

  float sn = one; /* s (sign of result -ve**odd) = -1 else = 1 */
  if(((((unsigned)hx>>31)-1)|(yisint-1))==0)
      sn = -one; /* (-ve)**(odd int) */

    /* |y| is huge */
  if(iy>0x08000000) { /* if |y| > 2**27 */
    /* over/underflow if x is not close to one */
      if(ix<0x3f7ffff8) return (y<0)? sn*huge*huge:tiny*tiny;
      if(ix>0x3f800007) return (y>0)? sn*huge*huge:tiny*tiny;
    /* now |1-x| is tiny <= 2**-20, suffice to compute
     log(x) by x-x^2/2+x^3/3-x^4/4 */
      t = ax-1;   /* t has 20 trailing zeros */
      w = (t*t)*((float)0.5-t*((float)0.333333333333-t*(float)0.25));
      u = ivln2_h*t;  /* ivln2_h has 16 sig. bits */
      v = t*ivln2_l-w*ivln2;
      t1 = u+v;
      GEN_OCL_GET_FLOAT_WORD(is,t1);
      GEN_OCL_SET_FLOAT_WORD(t1,is&0xfffff000);
      t2 = v-(t1-u);
  } else {
    float s2,s_h,s_l,t_h,t_l;
    n = 0;
    /* take care subnormal number */
//      if(ix<0x00800000)
//    {ax *= two24; n -= 24; GEN_OCL_GET_FLOAT_WORD(ix,ax); }
    n  += ((ix)>>23)-0x7f;
    j  = ix&0x007fffff;
    /* determine interval */
    ix = j|0x3f800000;    /* normalize ix */
    if(j<=0x1cc471) k=0;  /* |x|<sqrt(3/2) */
    else if(j<0x5db3d7) k=1;  /* |x|<sqrt(3)   */
    else {k=0;n+=1;ix -= 0x00800000;}
    GEN_OCL_SET_FLOAT_WORD(ax,ix);

    /* compute s = s_h+s_l = (x-1)/(x+1) or (x-1.5)/(x+1.5) */
    u = ax-bp[k];   /* bp[0]=1.0, bp[1]=1.5 */
    v = one/(ax+bp[k]);
    s = u*v;
    s_h = s;
    GEN_OCL_GET_FLOAT_WORD(is,s_h);
    GEN_OCL_SET_FLOAT_WORD(s_h,is&0xfffff000);

    /* t_h=ax+bp[k] High */
    GEN_OCL_SET_FLOAT_WORD(t_h, (((ix>>1)|0x20000000)+0x00400000+(k<<21)) &0xfffff000);
    t_l = ax - (t_h-bp[k]);
    s_l = v*((u-s_h*t_h)-s_h*t_l);


    /* compute log(ax) */
    s2 = s*s;
    r = s2*s2*(L1+s2*L2);
    r += s_l*(s_h+s);
    s2  = s_h*s_h;
    t_h = (float)3.0+s2+r;
    GEN_OCL_GET_FLOAT_WORD(is,t_h);
    GEN_OCL_SET_FLOAT_WORD(t_h,is&0xffffe000);
    t_l = r-((t_h-(float)3.0)-s2);
    /* u+v = s*(1+...) */
    u = s_h*t_h;
    v = s_l*t_h+t_l*s;
    /* 2/(3log2)*(s+...) */
    p_h = u+v;
    GEN_OCL_GET_FLOAT_WORD(is,p_h);
    GEN_OCL_SET_FLOAT_WORD(p_h,is&0xffffe000);
    p_l = v-(p_h-u);
    z_h = cp_h*p_h;   /* cp_h+cp_l = 2/(3*log2) */
    z_l = cp_l*p_h+p_l*cp+dp_l[k];
    /* log2(ax) = (s+..)*2/(3*log2) = n + dp_h + z_h + z_l */
    t = (float)n;
    t1 = (((z_h+z_l)+dp_h[k])+t);
    GEN_OCL_GET_FLOAT_WORD(is,t1);
    GEN_OCL_SET_FLOAT_WORD(t1,is&0xffffe000);
    t2 = z_l-(((t1-t)-dp_h[k])-z_h);
  }

  /* split up y into y1+y2+y3 and compute (y1+y2+y3)*(t1+t2) */

  float fy = (float)y;
  float y3 = (float)(y-(int)fy);
  GEN_OCL_GET_FLOAT_WORD(is,fy);
  GEN_OCL_SET_FLOAT_WORD(y1,is&0xfffff000);

  p_l = (fy-y1)*t1 + y3*t1 + fy*t2 + y3*t2;
  p_h = y1*t1;
  z = p_l+p_h;

  GEN_OCL_GET_FLOAT_WORD(j,z);
  if (j>0x43000000)       /* if z > 128 */
      return sn*huge*huge;       /* overflow */
  else if (j==0x43000000) {     /* if z == 128 */
      if(p_l+ovt>z-p_h) return sn*huge*huge; /* overflow */
  }
  else if ((j&0x7fffffff)>0x43160000)   /* z <= -150 */
      return sn*tiny*tiny;       /* underflow */
  else if (j==0xc3160000){      /* z == -150 */
      if(p_l<=z-p_h) return sn*tiny*tiny;    /* underflow */
  }
    /*
     * compute 2**(p_h+p_l)
     */
  i = j&0x7fffffff;
  k = (i>>23)-0x7f;
  n = 0;
  if(i>0x3f000000) {    /* if |z| > 0.5, set n = [z+0.5] */
      n = j+(0x00800000>>(k+1));
      k = ((n&0x7fffffff)>>23)-0x7f;  /* new k for n */
      GEN_OCL_SET_FLOAT_WORD(t,n&~(0x007fffff>>k));
      n = ((n&0x007fffff)|0x00800000)>>(23-k);
      if(j<0) n = -n;
      p_h -= t;

      z -= n;
  }

  t = z;
  GEN_OCL_GET_FLOAT_WORD(is,t);
  GEN_OCL_SET_FLOAT_WORD(t,is&0xfffff000);
  u = t*lg2_h;
  v = (p_l-(t-p_h))*lg2+t*lg2_l;
  z = u+v;
  w = v-(z-u);
  t  = z*z;
  t1  = z - t*(P1+t*P2);
  r  = (z*t1)/(t1-two)-(w+z*w);
  z  = one-(r-z);
  GEN_OCL_GET_FLOAT_WORD(j,z);
  j += (n<<23);
  if((j>>23)<=0) z = __gen_ocl_scalbnf(z,n);  /* subnormal output */
  else GEN_OCL_SET_FLOAT_WORD(z,j);
  return sn*z;
}

OVERLOADABLE float hypot(float x, float y) {
  if (__ocl_math_fastpath_flag)
    return __gen_ocl_internal_fastpath_hypot(x, y);

  //return __gen_ocl_sqrt(x*x + y*y);
  float a,b,an,bn,cn;
  int e;
  if (isfinite (x) && isfinite (y)){      /* Determine absolute values.  */
  x = __gen_ocl_fabs (x);
  y = __gen_ocl_fabs (y);
  /* Find the bigger and the smaller one.  */
  a = max(x,y);
  b = min(x,y);
  /* Now 0 <= b <= a.  */
  /* Write a = an * 2^e, b = bn * 2^e with 0 <= bn <= an < 1.  */
  an = frexp (a, &e);
  bn = ldexp (b, - e);
  /* Through the normalization, no unneeded overflow or underflow will occur here.  */
  cn = __gen_ocl_sqrt (an * an + bn * bn);
  return ldexp (cn, e);
  }else{
    if (isinf (x) || isinf (y))  /* x or y is infinite.  Return +Infinity.  */
      return INFINITY;
    else        /* x or y is NaN.  Return NaN.  */
      return x + y;
  }
}

#define BODY \
  if (isnan(x)) { \
    *p = x; \
    return x; \
  } \
  *p = __gen_ocl_internal_floor(x); \
  if (isinf(x)) { \
    return x > 0 ? +0. : -0.; \
  } \
  return __gen_ocl_internal_fmin(x - *p, 0x1.FFFFFep-1F);
OVERLOADABLE float fract(float x, global float *p) { BODY; }
OVERLOADABLE float fract(float x, local float *p) { BODY; }
OVERLOADABLE float fract(float x, private float *p) { BODY; }
#undef BODY

#define BODY \
  float Zero[2]; \
  int n,hx,hy,hz,ix,iy,sx,i,sy; \
  uint q,sxy; \
  Zero[0] = 0.0;Zero[1] = -0.0; \
  if (x == 0.0f) { x = 0.0f; }; \
  if (y == 0.0f) { y = 0.0f; }\
  GEN_OCL_GET_FLOAT_WORD(hx,x);GEN_OCL_GET_FLOAT_WORD(hy,y); \
  sxy = (hx ^ hy) & 0x80000000;sx = hx&0x80000000;sy = hy&0x80000000; \
  hx ^=sx; hy &= 0x7fffffff; \
  if (hx < 0x00800000)hx = 0;if (hy < 0x00800000)hy = 0; \
  if(hy==0||hx>=0x7f800000||hy>0x7f800000){ \
    *quo = 0;return NAN; \
  } \
  if( hy == 0x7F800000 || hx == 0 ) { \
    *quo = 0;return x; \
  } \
  if( hx == hy ) { \
    *quo = (x == y) ? 1 : -1; \
    return sx ? -0.0 : 0.0; \
  } \
  if(hx<hy) { \
    q = 0; \
    goto fixup; \
  } else if(hx==hy) { \
    *quo = (sxy ? -1 : 1); \
    return Zero[(uint)sx>>31]; \
  } \
  ix = (hx>>23)-127; \
  iy = (hy>>23)-127; \
  hx = 0x00800000|(0x007fffff&hx); \
  hy = 0x00800000|(0x007fffff&hy); \
  n = ix - iy; \
  q = 0; \
  while(n--) { \
    hz=hx-hy; \
    if(hz<0) hx = hx << 1; \
    else {hx = hz << 1; q++;} \
    q <<= 1; \
  } \
  hz=hx-hy; \
  if(hz>=0) {hx=hz;q++;} \
  if(hx==0) { \
    q &= 0x0000007f; \
    *quo = (sxy ? -q : q); \
    return Zero[(uint)sx>>31]; \
  } \
  while(hx<0x00800000) { \
    hx <<= 1;iy -= 1; \
  } \
  if(iy>= -126) { \
    hx = ((hx-0x00800000)|((iy+127)<<23)); \
  } else {\
    n = -126 - iy; \
    hx >>= n; \
  } \
fixup: \
  GEN_OCL_SET_FLOAT_WORD(x,hx); \
  if(hx<0x00800000){ \
    GEN_OCL_GET_FLOAT_WORD(hy,y); \
    hy &= 0x7fffffff; \
    if(hx+hx > hy ||(hx+hx==hy && (q & 1)))q++; \
    x = 0; \
  }else{ \
    y = __gen_ocl_fabs(y); \
    if (y < 0x1p-125f) { \
      if (x+x>y || (x+x==y && (q & 1))) { \
        q++;x-=y; \
      } \
    }else if (x>0.5f*y || (x==0.5f*y && (q & 1))) { \
      q++;x-=y; \
    } \
    GEN_OCL_GET_FLOAT_WORD(hx,x);GEN_OCL_SET_FLOAT_WORD(x,hx^sx); \
  } \
  int sign = sx==sy?0:1; \
  q &= 0x0000007f; \
  *quo = (sign ? -q : q); \
  return x;

OVERLOADABLE float remquo(float x, float y, global int *quo) {
	BODY;
}
OVERLOADABLE float remquo(float x, float y, local int *quo) { BODY; }
OVERLOADABLE float remquo(float x, float y, private int *quo) { BODY; }
#undef BODY

OVERLOADABLE float powr(float x, float y) {
  unsigned int hx, sx, hy, sy;

  if (__ocl_math_fastpath_flag)
    return __gen_ocl_pow(x,y);
  else {
    if (isnan(x) || isnan(y)) return NAN;
    GEN_OCL_GET_FLOAT_WORD(hx,x);
    GEN_OCL_GET_FLOAT_WORD(hy,y);
    sx = (hx & 0x80000000) >> 31;
    sy = (hy & 0x80000000) >> 31;

    if ((hx&0x7fffffff) < 0x00800000) {	   /* x < 2**-126  */
      x = 0.0f;/* Gen does not support subnormal number now */
      hx = hx &0x80000000;
    }
    if ((hy&0x7fffffff) < 0x00800000) {	  /* y < 2**-126  */
      y = 0.0;/* Gen does not support subnormal number now */
      hy = hy &0x80000000;
    }

    // (x < 0) ** y = NAN (y!=0)
    if ((sx && (hx & 0x7fffffff))) return NAN;

    // +/-0 ** +/-0 = NAN
    if ( !(hx&0x7fffffff) && !(hy&0x7fffffff)) return NAN;

    // +inf ** +/-0 = NAN
    if ( ((hx & 0x7f800000) ==0x7f800000) && !(hy&0x7fffffff)) return NAN;

    // others except nan/inf/0 ** 0 = 1.0
    if (!(hy&0x7fffffff)) return 1.0f;

    // +1 ** inf = NAN; +1 ** finite = 1;
    if (hx == 0x3f800000) {
      return isinf(y) ? NAN : 1.0f;
    }

    if ( !(hx & 0x7fffffff)) {
        // +/-0 ** y<0 = +inf
        // +/-0 ** y>0 = +0
      return sy ? INFINITY : 0.0f;
    }

    return __gen_ocl_internal_pow(x,y);
  }
}

OVERLOADABLE float pown(float x, int n) {
  if (__ocl_math_fastpath_flag) {
    if (x == 0.f && n == 0)
      return 1.f;
    if (x < 0.f && (n&1) )
      return -powr(-x, n);
    return powr(x, n);
  } else {
    int ix;
    GEN_OCL_GET_FLOAT_WORD(ix, x);
    float sign = ix < 0 ? -1.0f : 1.0f;
    if (x == 0.0f) x = sign * 0.0f;

    return __gen_ocl_internal_pown(x, n);
  }
}

OVERLOADABLE float pow(float x, float y) {
  if (!__ocl_math_fastpath_flag)
    return __gen_ocl_internal_pow(x,y);
  else {
    int n;
    if (x == 0.f && y == 0.f)
      return 1.f;
    if (x >= 0.f)
      return powr(x, y);
    n = y;
    if ((float)n == y)//is exact integer
      return pown(x, n);
    return NAN;
  }
}

OVERLOADABLE float rootn(float x, int n) {
  float ax,re;
  int sign = 0;
  int hx;
  if( n == 0 )return NAN;

  GEN_OCL_GET_FLOAT_WORD(hx, x);
  // Gen does not support denorm, flush to zero
  if ((hx & 0x7fffffff) < 0x00800000) {
    x = hx < 0 ? -0.0f : 0.0f;
  }

  //rootn ( x, n )  returns a NaN for x < 0 and n is even.
  if( x < 0 && 0 == (n&1) )
    return NAN;
  if( x == 0.0 ){
    switch( n & 0x80000001 ){
      //rootn ( +-0,  n ) is +0 for even n > 0.
      case 0:
        return 0.0f;
      //rootn ( +-0,  n ) is +-0 for odd n > 0.
      case 1:
        return x;
      //rootn ( +-0,  n ) is +inf for even n < 0.
      case 0x80000000:
        return INFINITY;

      //rootn ( +-0,  n ) is +-inf for odd n < 0.
      case 0x80000001:
        return __gen_ocl_internal_copysign(INFINITY, x);
    }
  }
  ax = __gen_ocl_fabs(x);
  if(x <0.0f && (n&1))
    sign = 1;
  if (__ocl_math_fastpath_flag)
    re = __gen_ocl_pow(ax, 1.f/n);
  else
    re = __gen_ocl_internal_pow(ax,1.f/n);
  if(sign)
    re = -re;
  return re;
}

OVERLOADABLE float fabs(float x) {
  return __gen_ocl_internal_fabs(x);
}

OVERLOADABLE float trunc(float x) {
  return  __gen_ocl_internal_trunc(x);
}

OVERLOADABLE float round(float x) {
  return __gen_ocl_internal_round(x);
}

OVERLOADABLE float floor(float x) {
  return __gen_ocl_internal_floor(x);
}

OVERLOADABLE float ceil(float x) {
  return __gen_ocl_internal_ceil(x);
}

OVERLOADABLE float log(float x) {
  if (__ocl_math_fastpath_flag)
    return __gen_ocl_internal_fastpath_log(x);

  /* Use native instruction when it has enough precision */
  if((x > 0x1.1p0) || (x <= 0))
    return __gen_ocl_internal_fastpath_log(x);

  return  __gen_ocl_internal_log(x);
}

OVERLOADABLE float log2(float x) {
  if (__ocl_math_fastpath_flag)
    return __gen_ocl_internal_fastpath_log2(x);

  /* Use native instruction when it has enough precision */
  if((x > 0x1.1p0) || (x <= 0))
    return __gen_ocl_internal_fastpath_log2(x);

  return  __gen_ocl_internal_log2(x);
}

OVERLOADABLE float log10(float x) {
  if (__ocl_math_fastpath_flag)
    return __gen_ocl_internal_fastpath_log10(x);

  /* Use native instruction when it has enough precision */
  if((x > 0x1.1p0) || (x <= 0))
    return __gen_ocl_internal_fastpath_log10(x);

  return  __gen_ocl_internal_log10(x);
}

OVERLOADABLE float exp(float x) {
  if (__ocl_math_fastpath_flag)
    return __gen_ocl_internal_fastpath_exp(x);

  /* Use native instruction when it has enough precision */
  if (x > -0x1.6p1 && x < 0x1.6p1)
    return __gen_ocl_internal_fastpath_exp(x);

  return  __gen_ocl_internal_exp(x);
}

OVERLOADABLE float exp2(float x) {
  /* Use native instruction when it has enough precision, exp2 always */
  return native_exp2(x);
}

OVERLOADABLE float exp10(float x) {
  if (__ocl_math_fastpath_flag)
    return __gen_ocl_internal_fastpath_exp10(x);

  return  __gen_ocl_internal_exp10(x);
}

OVERLOADABLE float expm1(float x) {
  if (__ocl_math_fastpath_flag)
    return __gen_ocl_internal_fastpath_expm1(x);

  return  __gen_ocl_internal_expm1(x);
}

OVERLOADABLE float fmin(float a, float b) {
  return __gen_ocl_internal_fmin(a, b);
}

OVERLOADABLE float fmax(float a, float b) {
  return __gen_ocl_internal_fmax(a, b);
}

OVERLOADABLE float fma(float a, float b, float c) {
  return mad(a, b, c);
}

OVERLOADABLE float fdim(float x, float y) {
  return __gen_ocl_internal_fdim(x, y);
}

OVERLOADABLE float maxmag(float x, float y) {
  return __gen_ocl_internal_maxmag(x, y);
}

OVERLOADABLE float minmag(float x, float y) {
  return __gen_ocl_internal_minmag(x, y);
}


/* So far, the HW do not support half float math function.
   We just do the conversion and call the float version here. */
OVERLOADABLE half cospi(half x) {
  float _x = (float)x;
  return (half)cospi(_x);
}
OVERLOADABLE half cosh(half x) {
  float _x = (float)x;
  return (half)cosh(_x);
}
OVERLOADABLE half acos(half x) {
  float _x = (float)x;
  return (half)acos(_x);
}
OVERLOADABLE float half_cos(float x) {
  return (float)cos(x);
}
OVERLOADABLE float half_divide(float x, float y) {
  return (float)native_divide(x, y);
}
OVERLOADABLE float half_exp(float x) {
  return (float)native_exp(x);
}
OVERLOADABLE float half_exp2(float x){
  return (float)native_exp2(x);
}
OVERLOADABLE float half_exp10(float x){
  return (float)native_exp10(x);
}
OVERLOADABLE float half_log(float x){
  return (float)native_log(x);
}
OVERLOADABLE float half_log2(float x){
  return (float)native_log2(x);
}
OVERLOADABLE float half_log10(float x){
  return (float)native_log10(x);
}
OVERLOADABLE float half_powr(float x, float y){
  return (float)powr(x, y);
}
OVERLOADABLE float half_recip(float x){
  return (float)native_recip(x);
}
OVERLOADABLE float half_rsqrt(float x){
  return (float)native_rsqrt(x);
}
OVERLOADABLE float half_sin(float x){
  return (float)sin(x);
}
OVERLOADABLE float half_sqrt(float x){
  return (float)native_sqrt(x);
}
OVERLOADABLE float half_tan(float x){
  return (float)tan(x);
}
OVERLOADABLE half acospi(half x) {
  float _x = (float)x;
  return (half)acospi(_x);
}
OVERLOADABLE half acosh(half x) {
  float _x = (float)x;
  return (half)acosh(_x);
}
OVERLOADABLE half sinpi(half x) {
  float _x = (float)x;
  return (half)sinpi(_x);
}
OVERLOADABLE half sinh(half x) {
  float _x = (float)x;
  return (half)sinh(_x);
}
OVERLOADABLE half asin(half x) {
  float _x = (float)x;
  return (half)asin(_x);
}
OVERLOADABLE half asinpi(half x) {
  float _x = (float)x;
  return (half)asinpi(_x);
}
OVERLOADABLE half asinh(half x) {
  float _x = (float)x;
  return (half)asinh(_x);
}
OVERLOADABLE half tanpi(half x) {
  float _x = (float)x;
  return (half)tanpi(_x);
}
OVERLOADABLE half tanh(half x) {
  float _x = (float)x;
  return (half)tanh(_x);
}
OVERLOADABLE half atan(half x) {
  float _x = (float)x;
  return (half)atan(_x);
}
OVERLOADABLE half atan2(half y, half x) {
  float _x = (float)x;
  float _y = (float)y;
  return (half)atan2(_x, _y);
}
OVERLOADABLE half atan2pi(half y, half x) {
  float _x = (float)x;
  float _y = (float)y;
  return (half)atan2pi(_x, _y);
}
OVERLOADABLE half atanpi(half x) {
  float _x = (float)x;
  return (half)atanpi(_x);
}
OVERLOADABLE half atanh(half x) {
  float _x = (float)x;
  return (half)atanh(_x);
}
OVERLOADABLE half cbrt(half x) {
  float _x = (float)x;
  return (half)cbrt(_x);
}
OVERLOADABLE half rint(half x) {
  float _x = (float)x;
  return (half)rint(_x);
}
OVERLOADABLE half copysign(half x, half y) {
  float _x = (float)x;
  float _y = (float)y;
  return (half)copysign(_x, _y);
}
OVERLOADABLE half erf(half x) {
  float _x = (float)x;
  return (half)erf(_x);
}
OVERLOADABLE half erfc(half x) {
  float _x = (float)x;
  return (half)erfc(_x);
}
OVERLOADABLE half fmod(half x, half y) {
  float _x = (float)x;
  float _y = (float)y;
  return (half)fmod(_x, _y);
}
OVERLOADABLE half remainder(half x, half p) {
  float _x = (float)x;
  float _p = (float)p;
  return (half)remainder(_x, _p);
}
OVERLOADABLE half ldexp(half x, int n) {
  float _x = (float)x;
  return (half)ldexp(_x, n);
}
OVERLOADABLE half powr(half x, half y) {
  float _x = (float)x;
  float _y = (float)y;
  return (half)powr(_x, _y);
}
OVERLOADABLE half pow(half x, half y) {
  float _x = (float)x;
  float _y = (float)y;
  return (half)pow(_x, _y);
}
//no pow, we use powr instead
OVERLOADABLE half fabs(half x) {
  float _x = (float)x;
  return (half)fabs(_x);
}
OVERLOADABLE half trunc(half x) {
  float _x = (float)x;
  return (half)trunc(_x);
}
OVERLOADABLE half round(half x) {
  float _x = (float)x;
  return (half)round(_x);
}
OVERLOADABLE half floor(half x) {
  float _x = (float)x;
  return (half)floor(_x);
}
OVERLOADABLE half ceil(half x) {
  float _x = (float)x;
  return (half)ceil(_x);
}
OVERLOADABLE half log(half x) {
  float _x = (float)x;
  return (half)log(_x);
}
OVERLOADABLE half log2(half x) {
  float _x = (float)x;
  return (half)log2(_x);
}
OVERLOADABLE half log10(half x) {
  float _x = (float)x;
  return (half)log10(_x);
}
OVERLOADABLE half exp(half x) {
  float _x = (float)x;
  return (half)exp(_x);
}
OVERLOADABLE half exp10(half x) {
  float _x = (float)x;
  return (half)exp10(_x);
}
OVERLOADABLE half expm1(half x) {
  float _x = (float)x;
  return (half)expm1(_x);
}
OVERLOADABLE half fmin(half a, half b) {
  return __gen_ocl_internal_fmin(a, b);
}
OVERLOADABLE half fmax(half a, half b) {
  return __gen_ocl_internal_fmax(a, b);
}
OVERLOADABLE half fma(half a, half b, half c) {
  float _a = (float)a;
  float _b = (float)b;
  float _c = (float)c;
  return (half)fma(_a, _b, _c);
}
OVERLOADABLE half fdim(half x, half y) {
  float _x = (float)x;
  float _y = (float)y;
  return (half)fdim(_x, _y);
}
OVERLOADABLE half maxmag(half x, half y) {
  float _x = (float)x;
  float _y = (float)y;
  return (half)maxmag(_x, _y);
}
OVERLOADABLE half minmag(half x, half y) {
  float _x = (float)x;
  float _y = (float)y;
  return (half)minmag(_x, _y);
}
OVERLOADABLE half exp2(half x) {
  float _x = (float)x;
  return (half)exp2(_x);
}
OVERLOADABLE half mad(half a, half b, half c) {
  return __gen_ocl_mad(a,b,c);
}
OVERLOADABLE half sin(half x) {
  float _x = (float)x;
  return (half)sin(_x);
}
OVERLOADABLE half cos(half x) {
  float _x = (float)x;
  return (half)cos(_x);
}
OVERLOADABLE half tan(half x) {
  float _x = (float)x;
  return (half)tan(_x);
}
OVERLOADABLE half tgamma(half x) {
  float _x = (float)x;
  return (half)tgamma(_x);
}
OVERLOADABLE half lgamma(half x) {
  float _x = (float)x;
  return (half)lgamma(_x);
}
OVERLOADABLE half lgamma_r(half x, global int *signgamp) {
  float _x = (float)x;
  return (half)lgamma_r(_x, signgamp);
}
OVERLOADABLE half lgamma_r(half x, local int *signgamp) {
  float _x = (float)x;
  return (half)lgamma_r(_x, signgamp);
}
OVERLOADABLE half lgamma_r(half x, private int *signgamp) {
  float _x = (float)x;
  return (half)lgamma_r(_x, signgamp);
}
OVERLOADABLE half log1p(half x) {
  float _x = (float)x;
  return (half)log1p(_x);
}
OVERLOADABLE half logb(half x) {
  float _x = (float)x;
  return (half)logb(_x);
}
OVERLOADABLE int ilogb(half x) {
  float _x = (float)x;
  return ilogb(_x);
}
OVERLOADABLE half nan(ushort code) {
  return (half)NAN;
}

OVERLOADABLE half sincos(half x, global half *cosval) {
  float _x = (float)x;
  float _cosval;
  half ret = (half)sincos(_x, &_cosval);
  *cosval = (half)_cosval;
  return ret;
}
OVERLOADABLE half sincos(half x, local half *cosval) {
  float _x = (float)x;
  float _cosval;
  half ret = (half)sincos(_x, &_cosval);
  *cosval = (half)_cosval;
  return ret;
}
OVERLOADABLE half sincos(half x, private half *cosval) {
  float _x = (float)x;
  float _cosval;
  half ret = (half)sincos(_x, &_cosval);
  *cosval = (half)_cosval;
  return ret;
}

OVERLOADABLE half sqrt(half x) {
  float _x = (float)x;
  return (half)sqrt(_x);
}
OVERLOADABLE half rsqrt(half x) {
  float _x = (float)x;
  return (half)rsqrt(_x);
}
OVERLOADABLE half frexp(half x, global int *exp) {
  float _x = (float)x;
  return (half)frexp(_x, exp);
}
OVERLOADABLE half frexp(half x, local int *exp) {
  float _x = (float)x;
  return (half)frexp(_x, exp);
}
OVERLOADABLE half frexp(half x, private int *exp) {
  float _x = (float)x;
  return (half)frexp(_x, exp);
}
OVERLOADABLE half nextafter(half x, half y) {
  float _x = (float)x;
  float _y = (float)y;
  return (half)nextafter(_x, _y);
}

OVERLOADABLE half modf(half x, global half *i) {
  float _x = (float)x;
  float _i;
  half ret = (half)modf(_x, &_i);
  *i = (half)_i;
  return ret;
}
OVERLOADABLE half modf(half x, local half *i) {
  float _x = (float)x;
  float _i;
  half ret = (half)modf(_x, &_i);
  *i = (half)_i;
  return ret;
}
OVERLOADABLE half modf(half x, private half *i) {
  float _x = (float)x;
  float _i;
  half ret = (half)modf(_x, &_i);
  *i = (half)_i;
  return ret;
}

OVERLOADABLE half hypot(half x, half y) {
  float _x = (float)x;
  float _y = (float)y;
  return (half)hypot(_x, _y);
}

OVERLOADABLE half fract(half x, global half *p) {
  float _x = (float)x;
  float _p;
  half ret = (half)fract(_x, &_p);
  *p = (half)_p;
  return ret;
}
OVERLOADABLE half fract(half x, local half *p) {
  float _x = (float)x;
  float _p;
  half ret = (half)fract(_x, &_p);
  *p = (half)_p;
  return ret;
}
OVERLOADABLE half fract(half x, private half *p) {
  float _x = (float)x;
  float _p;
  half ret = (half)fract(_x, &_p);
  *p = (half)_p;
  return ret;
}

OVERLOADABLE half remquo(half x, half y, global int *quo) {
  float _x = (float)x;
  float _y = (float)y;
  return (half)remquo(_x, _y, quo);
}
OVERLOADABLE half remquo(half x, half y, local int *quo) {
  float _x = (float)x;
  float _y = (float)y;
  return (half)remquo(_x, _y, quo);
}
OVERLOADABLE half remquo(half x, half y, private int *quo) {
  float _x = (float)x;
  float _y = (float)y;
  return (half)remquo(_x, _y, quo);
}

OVERLOADABLE half pown(half x, int n) {
  float _x = (float)x;
  return (half)pown(_x, n);
}
OVERLOADABLE half rootn(half x, int n) {
  float _x = (float)x;
  return (half)rootn(_x, n);
}
