# CUDA 12.9 on Fedora 43 with GTX 1060

## Environment

- Fedora 43
- glibc 2.42
- NVIDIA GTX 1060 (Pascal)
- CUDA 12.9
- GCC/G++ 14
- CMake 3.31+

## Install GCC 14

Keep Fedora's default GCC unchanged:

    sudo dnf install gcc14 gcc14-c++

Verify:

    gcc-14 --version
    g++-14 --version

## Install CUDA 12.9

CUDA 12.9:

https://developer.nvidia.com/cuda-12-9-0-download-archive?target_os=Linux&target_arch=x86_64&Distribution=Fedora&target_version=41&target_type=rpm_network

Verify:

    nvcc --version

Expected:

    Cuda compilation tools, release 12.9, V12.9.86

The NVIDIA download page targets Fedora 41, but CUDA 12.9 is being used here on Fedora 43.

## CMake

Use GCC 14 as the CUDA host compiler:

    cmake -S . -B build \
        -DCMAKE_C_COMPILER=/usr/bin/gcc-14 \
        -DCMAKE_CXX_COMPILER=/usr/bin/g++-14 \
        -DCMAKE_CUDA_HOST_COMPILER=/usr/bin/g++-14

Build:

    make -j 12

Example CMakeLists.txt:

    cmake_minimum_required(VERSION 3.18)

    project(cuda_matrices LANGUAGES CXX CUDA)

    set(CMAKE_CXX_STANDARD 17)
    set(CMAKE_CUDA_STANDARD 17)

    set(CMAKE_EXPORT_COMPILE_COMMANDS TRUE)

    add_executable(
        ${PROJECT_NAME}
        main.cpp
        matrix.cu
    )

    set_target_properties(
        ${PROJECT_NAME}
        PROPERTIES
        CUDA_SEPARABLE_COMPILATION ON
    )

## Fedora 43 / glibc workaround

With Fedora 43 and glibc 2.42, CUDA 12.9 failed during CMake's CUDA compiler detection with errors involving:

- cospi
- sinpi
- cospif
- sinpif
- rsqrt
- rsqrtf

The conflict is between Fedora's newer glibc declarations and CUDA's declarations in:

    /usr/local/cuda/targets/x86_64-linux/include/crt/math_functions.h

Back up the file:

    sudo cp \
      /usr/local/cuda/targets/x86_64-linux/include/crt/math_functions.h \
      /usr/local/cuda/targets/x86_64-linux/include/crt/math_functions.h.orig

Add `noexcept(true)` to the CUDA declarations for:

    cospi
    cospif
    sinpi
    sinpif
    rsqrt
    rsqrtf

This makes their exception specifications match the declarations from the newer glibc headers.

After modifying the header:

    rm -rf build

    cmake -S . -B build \
        -DCMAKE_C_COMPILER=/usr/bin/gcc-14 \
        -DCMAKE_CXX_COMPILER=/usr/bin/g++-14 \
        -DCMAKE_CUDA_HOST_COMPILER=/usr/bin/g++-14

## Notes

GCC 14 was not the cause of the CMake error. NVCC was correctly using g++-14. The failure was caused by CUDA 12.9's headers conflicting with Fedora 43's glibc 2.42.

The GTX 1060 is Pascal (compute capability 6.1). CUDA 13+ is increasingly dropping support for older architectures, so CUDA 12.9 is a better choice for this GPU.
