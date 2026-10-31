#include "matrix.h"

#include <cuda_runtime.h>
#include <cstdio>
#include <cstdlib>

#define CUDA_CHECK(call)                                      \
    do {                                                      \
        cudaError_t err = (call);                            \
        if (err != cudaSuccess) {                            \
            fprintf(stderr, "CUDA error at %s:%d: %s\n",      \
                    __FILE__, __LINE__, cudaGetErrorString(err)); \
            std::exit(EXIT_FAILURE);                         \
        }                                                     \
    } while (0)

__global__ void matrixAdd(
    const float* A,
    const float* B,
    float* C,
    int rows,
    int cols
) {
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    int col = blockIdx.x * blockDim.x + threadIdx.x;

    if (row < rows && col < cols) {
        int i = row * cols + col;
        C[i] = A[i] + B[i];
    }
}

void matrix_add(
    const float* A,
    const float* B,
    float* C,
    int rows,
    int cols
) {
    const size_t bytes =
        static_cast<size_t>(rows) *
        static_cast<size_t>(cols) *
        sizeof(float);

    float* d_A = nullptr;
    float* d_B = nullptr;
    float* d_C = nullptr;

    CUDA_CHECK(cudaMalloc(&d_A, bytes));
    CUDA_CHECK(cudaMalloc(&d_B, bytes));
    CUDA_CHECK(cudaMalloc(&d_C, bytes));

    CUDA_CHECK(cudaMemcpy(
        d_A, A, bytes, cudaMemcpyHostToDevice
    ));

    CUDA_CHECK(cudaMemcpy(
        d_B, B, bytes, cudaMemcpyHostToDevice
    ));

    dim3 threads(16, 16);

    dim3 blocks(
        (cols + threads.x - 1) / threads.x,
        (rows + threads.y - 1) / threads.y
    );

    matrixAdd<<<blocks, threads>>>(
        d_A,
        d_B,
        d_C,
        rows,
        cols
    );

    // Detect errors launching/executing the kernel.
    CUDA_CHECK(cudaGetLastError());
    CUDA_CHECK(cudaDeviceSynchronize());

    CUDA_CHECK(cudaMemcpy(
        C, d_C, bytes, cudaMemcpyDeviceToHost
    ));

    CUDA_CHECK(cudaFree(d_A));
    CUDA_CHECK(cudaFree(d_B));
    CUDA_CHECK(cudaFree(d_C));
}

__global__ void matrixMultiply(
    const float* A,
    const float* B,
    float* C,
    int rowsA,
    int colsA,
    int colsB
) {
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    int col = blockIdx.x * blockDim.x + threadIdx.x;

    if (row < rowsA && col < colsB) {
        float sum = 0.0f;

        for (int k = 0; k < colsA; ++k) {
            sum += A[row * colsA + k] *
                   B[k * colsB + col];
        }

        C[row * colsB + col] = sum;
    }
}

void matrix_multiply(
    const float* A,
    const float* B,
    float* C,
    int rowsA,
    int colsA,
    int colsB
) {
    // A = rowsA x colsA
    // B = colsA x colsB
    // C = rowsA x colsB

    const size_t bytesA =
        static_cast<size_t>(rowsA) *
        static_cast<size_t>(colsA) *
        sizeof(float);

    const size_t bytesB =
        static_cast<size_t>(colsA) *
        static_cast<size_t>(colsB) *
        sizeof(float);

    const size_t bytesC =
        static_cast<size_t>(rowsA) *
        static_cast<size_t>(colsB) *
        sizeof(float);

    float* d_A = nullptr;
    float* d_B = nullptr;
    float* d_C = nullptr;

    CUDA_CHECK(cudaMalloc(&d_A, bytesA));
    CUDA_CHECK(cudaMalloc(&d_B, bytesB));
    CUDA_CHECK(cudaMalloc(&d_C, bytesC));

    CUDA_CHECK(cudaMemcpy(
        d_A, A, bytesA, cudaMemcpyHostToDevice
    ));

    CUDA_CHECK(cudaMemcpy(
        d_B, B, bytesB, cudaMemcpyHostToDevice
    ));

    dim3 threads(16, 16);

    dim3 blocks(
        (colsB + threads.x - 1) / threads.x,
        (rowsA + threads.y - 1) / threads.y
    );

    matrixMultiply<<<blocks, threads>>>(
        d_A,
        d_B,
        d_C,
        rowsA,
        colsA,
        colsB
    );

    CUDA_CHECK(cudaGetLastError());
    CUDA_CHECK(cudaDeviceSynchronize());

    CUDA_CHECK(cudaMemcpy(
        C, d_C, bytesC, cudaMemcpyDeviceToHost
    ));

    CUDA_CHECK(cudaFree(d_A));
    CUDA_CHECK(cudaFree(d_B));
    CUDA_CHECK(cudaFree(d_C));
}

