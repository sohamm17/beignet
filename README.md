# Beignet - For Intel 32-bits  OpenCL Runtime

This package is forked from the official source code of the [beignet debian repository](https://salsa.debian.org/opencl-team/beignet) beignet debian repository. I have already applied the patches from the debian repo. I have fixed a few bugs so that beignet can run in latest Coffe Lake processors in Linux 32-bits. However, please remember the project is almost dead.

## How beignet works
Beignet is the OpenCL runtime for Intel graphics cards. Beignet provides `libcl.so, libgbeinterp.so, libgbe.so, gbe_bin_generater, beignet.bc, beignet.local.pch, beignet.pch`.  `gbe_bin_generater` is the OpenCL kernel code compiler, which depends on `libgbe.so`.  `gbe_bin_generater` depends on LLVM and Clang development files.

Once `gbe_bin_generater` is compiled, this compiler compiles different library kernels of the `beignet` itself and generates `libcl.so, libgbeinterp.so`, etc.

## Instructions to run beignet in Yocto Linux 32 bits
If you have a 32-bits build host for Yocto then, you can build beignet in the build host and deploy. However, I did not have a 32 bits build host, then it is hard to cross-compile beignet for 32 bits Yocto Linux. I decided to build beignet partially in a 32bits Ubuntu and partially in the Yocto target on board.

As `gbe_bin_generater` depends on LLVM, if you want to build the whole beignet in Yocto target, then you need LLVM and Clang development files on board. I did not deploy all the LLVM and Clang files on board but I do have Clang and GCC in on board Yocto. I use them.

My approach is to build `gbe_bin_generator` and related files in a 32 bit Ubuntu Linux, and then take the repo and build `libcl.so, libgbeinterp.so` in Yocto Linux target board.

### Steps

#### In a Ubuntu Linux 32 bits:

1. Clone this repo in a Ubuntu or Debian-based system.
2. Go to the repository.
3. `mkdir build && cd build`
4. For coffee lake the PCI_ID for my machine was 0x3e92. Check your iGPU PCI ID and put in the `-DGEN_PCI_ID`.

```
cmake ../ -DCOMPILER=GCC -DBUILD_STANDALONE_GBE_COMPILER=true -DGEN_PCI_ID=0x3e92 \
-DBEIGNET_INSTALL_DIR=/usr/lib/beignet -DCMAKE_BUILD_TYPE=RELEASE
```
5. `make`

#### In Yocto Linux 32 bits target:
1. Create a directory `/usr/lib/beignet/`.
2. Copy compiled beignet files to the above directory: 

```
beignet/build/backend/src/libgbe.so
beignet/build/backend/src/gbe_bin_generater
beignet/build/backend/src/libocl/usr/lib/beignet/beignet.bc
beignet/build/backend/src/libocl/usr/lib/beignet/beignet.pch
beignet/build/backend/src/libocl/usr/lib/beignet/beignet.local.pch
```
4. Go to the beignet directory. Save the following script in `utests/setenv.sh.bak`
```
#!/bin/sh
#
export OCL_BITCODE_LIB_PATH=/usr/lib/beignet/beignet.bc
export OCL_HEADER_FILE_DIR=/usr/lib/beignet/include/
export OCL_BITCODE_LIB_20_PATH=
export OCL_PCH_PATH=/usr/lib/beignet/beignet.local.pch
export OCL_PCH_20_PATH=
export OCL_KERNEL_PATH=beignet-debian/beignet/utests/../kernels
export OCL_GBE_PATH=/usr/lib/beignet/libgbe.so
export OCL_INTERP_PATH=/usr/lib/beignet/libgbeinterp.so
#disable self-test so we can get something more precise than "doesn't work"
export OCL_IGNORE_SELF_TEST=1
```
5. `chmod +x ./utests/setenv.sh.bak && . ./utests/setenv.sh.bak`
6. `mkdir build2 && cd build2`
7. 
```
cmake ../ -DUSE_STANDALONE_GBE_COMPILER=true -DSTANDALONE_GBE_COMPILER_DIR=/usr/lib/beignet/ -DCMAKE_BUILD_TYPE=RELEASE -DKERNEL_DIR_SOHAM=beignet/kernels/ -DNOT_BUILD_STAND_ALONE_UTEST=TRUE -DGEN_PCI_ID=0x3e92 -DBEIGNET_INSTALL_DIR=/usr/lib/beignet/ -DCMAKE_C_FLAGS=-std=c99 -D_POSIX_SOURCE -DCMAKE_CXX_FLAGS=-std=c++0x -DCOMPILER=GCC
```
8. `make && make install`

#### Run the tests
1. `cd build2/utests`
2. `./utest_run -a`

#### For Ubuntu or debian-based systems

Download from the official sources.