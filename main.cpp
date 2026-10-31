#include "matrix.h"

#include <cassert>
#include <iostream>
#include <vector>
#include <sstream>
#include <iomanip>

void print_matrix(
    const std::vector<float>& matrix,
    int rows,
    int cols
)
{
    std::vector<std::string> formatted(matrix.size());
    std::vector<size_t> widths(cols, 0);

    for (int row = 0; row < rows; ++row) {
        for (int col = 0; col < cols; ++col) {
            std::ostringstream stream;
            stream << matrix[row * cols + col];

            auto& value = formatted[row * cols + col];
            value = stream.str();

            widths[col] = std::max(widths[col], value.size());
        }
    }

    for (int row = 0; row < rows; ++row) {
        for (int col = 0; col < cols; ++col) {
            std::cout
                << std::setw(widths[col])
                << formatted[row * cols + col]
                << ' ';
        }
        std::cout << '\n';
    }
}

bool matrix_equal(
    const std::vector<float>& a,
    const std::vector<float>& b
)
{
    if (a.size() != b.size()) {
        return false;
    }

    for (size_t i = 0; i < a.size(); ++i) {
        if (a[i] != b[i]) {
            return false;
        }
    }

    return true;
}

int main()
{
    {
        const int rows = 2;
        const int cols = 3;

        const std::vector<float> A = {
            1, 2, 3,
            4, 5, 6
        };

        const std::vector<float> B = {
            10, 20, 30,
            40, 50, 60
        };

        std::vector<float> C(rows * cols);

        matrix_add(
            A.data(),
            B.data(),
            C.data(),
            rows,
            cols
        );

        std::cout << "A:\n";
        print_matrix(A, rows, cols);

        std::cout << "\nB:\n";
        print_matrix(B, rows, cols);

        std::cout << "\nC = A + B:\n";
        print_matrix(C, rows, cols);

        const std::vector<float> expected = {
            11, 22, 33,
            44, 55, 66
        };

        assert(matrix_equal(C, expected));

        std::cout << "\nTest passed!\n";
    }

    {
        const int A_rows = 2;
        const int A_cols = 3;

        const int B_rows = 3;
        const int B_cols = 2;

        const std::vector<float> A = {
            1, 2, 3,
            4, 5, 6
        };

        const std::vector<float> B = {
            7,  8,
            9, 10,
            11, 12
        };

        std::vector<float> C(A_rows * B_cols);

        matrix_multiply(
            A.data(),
            B.data(),
            C.data(),
            A_rows,
            A_cols,
            B_cols
        );

        std::cout << "A:\n";
        print_matrix(A, A_rows, A_cols);

        std::cout << "\nB:\n";
        print_matrix(B, B_rows, B_cols);

        std::cout << "\nC = A * B:\n";
        print_matrix(C, A_rows, B_cols);

        const std::vector<float> expected = {
            58,  64,
            139, 154
        };

        assert(matrix_equal(C, expected));

        std::cout << "\nMatrix multiplication test passed!\n";
    }

}
