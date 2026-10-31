#pragma once

void matrix_add(
    const float* A,
    const float* B,
    float* C,
    int rows,
    int cols
);

void matrix_multiply(
    const float* A,
    const float* B,
    float* C,
    int rowsA,
    int colsA,
    int colsB
);
