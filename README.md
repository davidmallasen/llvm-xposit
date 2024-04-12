# Xposit RISC-V custom extension for posit arithmetic

This repository contains the LLVM compilation support for posit arithmetic that can be used together with the PERCIVAL posit RISC-V core available here: https://github.com/artecs-group/PERCIVAL

## Publication

The Xposit extension was introduced in the following paper, if you use it in your academic work you can cite us:

```
@article{mallasen2022PERCIVAL,
  title = {PERCIVAL: Open-Source Posit RISC-V Core With Quire Capability},
  author = {Mallasén, David and Murillo, Raul and Del Barrio, Alberto A. and Botella, Guillermo and Piñuel, Luis and Prieto-Matias, Manuel},
  year = {2022},
  journal = {IEEE Transactions on Emerging Topics in Computing},
  volume = {10},
  number = {3},
  pages = {1241-1252},
  issn = {2168-6750},
  doi = {10.1109/TETC.2022.3187199}
}
```

## Getting started

As well as this repository, you will need the RISC-V gcc toolchain.

0. Install some pre-requisites:
~~~
sudo apt install \
  binutils build-essential libtool texinfo \
  gzip zip unzip patchutils curl git \
  make cmake ninja-build automake bison flex gperf \
  grep sed gawk python bc \
  zlib1g-dev libexpat1-dev libmpc-dev \
  libglib2.0-dev libfdt-dev libpixman-1-dev 
~~~

1. Install the RISC-V gcc toolchain following the instructions in https://github.com/riscv-collab/riscv-gnu-toolchain for newlib multilib. When you are done, you should have a `riscv64-unknown-elf-gcc` or a `riscv32-unknown-elf-gcc` compiler. Remember to add the bin directory to your path. If you are compiling for PERCIVAL, use the `riscv64` option.

2. Clone, build, and install this repository. The `XPOSIT_INSTALL_DIR` can be the same directory where the RISC-V gcc toolchain is installed. Change `riscv64-unknown-elf` to `riscv32-unknown-elf` depending on your needs and the gcc toolchain installed in the previous step.
~~~
export XPOSIT_INSTALL_DIR="/path/to/dir"
export XPOSIT_GCC_DIR="/path/to/riscv64-unknown-elf"
export XPOSIT_TARGET="riscv64-unknown-elf"
mkdir -p $XPOSIT_INSTALL_DIR

git clone https://github.com/artecs-group/llvm-xposit.git
cd llvm-xposit
ln -s ../../clang llvm/tools || true
mkdir build && cd build

cmake -G Ninja \
        -DCMAKE_BUILD_TYPE="Debug" \
        -DBUILD_SHARED_LIBS=True \
        -DLLVM_USE_SPLIT_DWARF=True \
        -DCMAKE_INSTALL_PREFIX=$XPOSIT_INSTALL_DIR \
        -DLLVM_OPTIMIZED_TABLEGEN=True \
        -DLLVM_BUILD_TESTS=True \
        -DDEFAULT_SYSROOT=$XPOSIT_GCC_DIR \
        -DLLVM_DEFAULT_TARGET_TRIPLE=$XPOSIT_TARGET \
        -DLLVM_TARGETS_TO_BUILD="RISCV" \
        -DLLVM_ENABLE_PROJECTS=clang \
        ../llvm
cmake --build . --target install -j`nproc`
~~~
3. Add the Xposit clang compiler to your path. Add this in your `.bashrc` if you want it persistent.
~~~
export XPOSIT_INSTALL_DIR="/path/to/dir"
export PATH="$PATH:$XPOSIT_INSTALL_DIR/bin"
~~~

4. Compile a test application. For example the [posit_testsuite_llvm.c](https://github.com/artecs-group/PERCIVAL/blob/posit-master/posit_testsuite_llvm.c) of PERCIVAL. Change to `riscv32` and `rv32` depending on your installation.
~~~
clang --target=riscv64 -march=rv64gcxposit posit_testsuite_llvm.c -c -o posit_testsuite_llvm.o
riscv64-unknown-elf-gcc posit_testsuite_llvm.o -o posit_testsuite_llvm.elf
~~~

## Acknowledgments
This work was supported in part by the 2020 Leonardo Grant for Researchers and Cultural Creators, from BBVA Foundation under Grant PR2003_20/01, and in part by the Spanish MINECO, the EU(FEDER), and Comunidad de Madrid under Grants RTI2018-093684-B-I00 and S2018/TCS-4423.

# The LLVM Compiler Infrastructure

This directory and its sub-directories contain source code for LLVM,
a toolkit for the construction of highly optimized compilers,
optimizers, and run-time environments.

The README briefly describes how to get started with building LLVM.
For more information on how to contribute to the LLVM project, please
take a look at the
[Contributing to LLVM](https://llvm.org/docs/Contributing.html) guide.

## Getting Started with the LLVM System

Taken from https://llvm.org/docs/GettingStarted.html.

### Overview

Welcome to the LLVM project!

The LLVM project has multiple components. The core of the project is
itself called "LLVM". This contains all of the tools, libraries, and header
files needed to process intermediate representations and convert them into
object files.  Tools include an assembler, disassembler, bitcode analyzer, and
bitcode optimizer.  It also contains basic regression tests.

C-like languages use the [Clang](http://clang.llvm.org/) front end.  This
component compiles C, C++, Objective-C, and Objective-C++ code into LLVM bitcode
-- and from there into object files, using LLVM.

Other components include:
the [libc++ C++ standard library](https://libcxx.llvm.org),
the [LLD linker](https://lld.llvm.org), and more.

### Getting the Source Code and Building LLVM

The LLVM Getting Started documentation may be out of date.  The [Clang
Getting Started](http://clang.llvm.org/get_started.html) page might have more
accurate information.

This is an example work-flow and configuration to get and build the LLVM source:

1. Checkout LLVM (including related sub-projects like Clang):

     * ``git clone https://github.com/llvm/llvm-project.git``

     * Or, on windows, ``git clone --config core.autocrlf=false
    https://github.com/llvm/llvm-project.git``

2. Configure and build LLVM and Clang:

     * ``cd llvm-project``

     * ``cmake -S llvm -B build -G <generator> [options]``

        Some common build system generators are:

        * ``Ninja`` --- for generating [Ninja](https://ninja-build.org)
          build files. Most llvm developers use Ninja.
        * ``Unix Makefiles`` --- for generating make-compatible parallel makefiles.
        * ``Visual Studio`` --- for generating Visual Studio projects and
          solutions.
        * ``Xcode`` --- for generating Xcode projects.

        Some common options:

        * ``-DLLVM_ENABLE_PROJECTS='...'`` --- semicolon-separated list of the LLVM
          sub-projects you'd like to additionally build. Can include any of: clang,
          clang-tools-extra, compiler-rt,cross-project-tests, flang, libc, libclc,
          libcxx, libcxxabi, libunwind, lld, lldb, mlir, openmp, polly, or pstl.

          For example, to build LLVM, Clang, libcxx, and libcxxabi, use
          ``-DLLVM_ENABLE_PROJECTS="clang;libcxx;libcxxabi"``.

        * ``-DCMAKE_INSTALL_PREFIX=directory`` --- Specify for *directory* the full
          path name of where you want the LLVM tools and libraries to be installed
          (default ``/usr/local``).

        * ``-DCMAKE_BUILD_TYPE=type`` --- Valid options for *type* are Debug,
          Release, RelWithDebInfo, and MinSizeRel. Default is Debug.

        * ``-DLLVM_ENABLE_ASSERTIONS=On`` --- Compile with assertion checks enabled
          (default is Yes for Debug builds, No for all other build types).

      * ``cmake --build build [-- [options] <target>]`` or your build system specified above
        directly.

        * The default target (i.e. ``ninja`` or ``make``) will build all of LLVM.

        * The ``check-all`` target (i.e. ``ninja check-all``) will run the
          regression tests to ensure everything is in working order.

        * CMake will generate targets for each tool and library, and most
          LLVM sub-projects generate their own ``check-<project>`` target.

        * Running a serial build will be **slow**.  To improve speed, try running a
          parallel build.  That's done by default in Ninja; for ``make``, use the option
          ``-j NNN``, where ``NNN`` is the number of parallel jobs, e.g. the number of
          CPUs you have.

      * For more information see [CMake](https://llvm.org/docs/CMake.html)

Consult the
[Getting Started with LLVM](https://llvm.org/docs/GettingStarted.html#getting-started-with-llvm)
page for detailed information on configuring and compiling LLVM. You can visit
[Directory Layout](https://llvm.org/docs/GettingStarted.html#directory-layout)
to learn about the layout of the source code tree.
