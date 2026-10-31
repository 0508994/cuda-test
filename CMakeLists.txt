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
    CUDA_ARCHITECTURES 61
)
