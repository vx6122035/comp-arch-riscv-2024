#include <stdio.h>
#include <stdlib.h>

// Task 1: ReLU function
// Applies ReLU activation function element-wise
void relu(int* array, int length) {
    for (int i = 0; i < length; i++) {
        if (array[i] < 0) {
            array[i] = 0;
        }
    }
}

// Task 2: ArgMax function
// Returns the index of the largest element
int argmax(int* array, int length) {
    if (length <= 0) return -1;  // Error case
    
    int max_index = 0;
    int max_value = array[0];
    
    for (int i = 1; i < length; i++) {
        if (array[i] > max_value) {
            max_value = array[i];
            max_index = i;
        }
    }
    
    return max_index;
}

// Task 3.1: Dot Product function
// Computes dot product of two vectors with strides
int dot(int* v1, int* v2, int length, int stride_v1, int stride_v2) {
    int result = 0;
    
    for (int i = 0; i < length; i++) {
        result += v1[i * stride_v1] * v2[i * stride_v2];
    }
    
    return result;
}

// Task 3.2: Matrix Multiplication function
// Performs matrix multiplication C = A × B
// A is n×m matrix, B is m×k matrix, resulting in n×k matrix C
int* matmul(int* A, int* B, int n, int m, int k) {
    // Check for compatible dimensions
    if (n <= 0 || m <= 0 || k <= 0) {
        exit(4);
    }
    
    // Allocate memory for result matrix
    int* C = (int*)malloc(n * k * sizeof(int));
    if (C == NULL) {
        exit(4);
    }
    
    // Perform matrix multiplication
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < k; j++) {
            int sum = 0;
            for (int x = 0; x < m; x++) {
                // A is in row-major order: A[i][x] = A[i * m + x]
                // B is in row-major order: B[x][j] = B[x * k + j]
                sum += A[i * m + x] * B[x * k + j];
            }
            C[i * k + j] = sum;
        }
    }
    
    return C;
}

// Test function for ReLU
void test_relu() {
    printf("Testing ReLU function:\n");
    int test_array[] = {1, -2, 3, -4, 5, -6};
    int length = 6;
    
    printf("Before ReLU: ");
    for (int i = 0; i < length; i++) {
        printf("%d ", test_array[i]);
    }
    printf("\n");
    
    relu(test_array, length);
    
    printf("After ReLU: ");
    for (int i = 0; i < length; i++) {
        printf("%d ", test_array[i]);
    }
    printf("\n\n");
}

// Test function for ArgMax
void test_argmax() {
    printf("Testing ArgMax function:\n");
    int test_array[] = {1, 5, 3, 8, 2, 4};
    int length = 6;
    
    printf("Array: ");
    for (int i = 0; i < length; i++) {
        printf("%d ", test_array[i]);
    }
    printf("\n");
    
    int max_index = argmax(test_array, length);
    printf("Index of maximum value: %d\n\n", max_index);
}

// Test function for Dot Product
void test_dot() {
    printf("Testing Dot Product function:\n");
    int v1[] = {1, 2, 3};
    int v2[] = {1, 3, 5};
    int length = 3;
    
    printf("Vector 1: ");
    for (int i = 0; i < length; i++) {
        printf("%d ", v1[i]);
    }
    printf("\n");
    
    printf("Vector 2: ");
    for (int i = 0; i < length; i++) {
        printf("%d ", v2[i]);
    }
    printf("\n");
    
    int result = dot(v1, v2, length, 1, 1);
    printf("Dot product result: %d\n\n", result);
}

// Test function for Matrix Multiplication
void test_matmul() {
    printf("Testing Matrix Multiplication function:\n");
    int m0[] = {1, 2, 3,
                4, 5, 6,
                7, 8, 9};
    int m1[] = {1, 2, 3,
                4, 5, 6,
                7, 8, 9};
    int n = 3, m = 3, k = 3;
    
    printf("Matrix 1:\n");
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < m; j++) {
            printf("%d ", m0[i * m + j]);
        }
        printf("\n");
    }
    
    printf("\nMatrix 2:\n");
    for (int i = 0; i < m; i++) {
        for (int j = 0; j < k; j++) {
            printf("%d ", m1[i * k + j]);
        }
        printf("\n");
    }
    
    int* result = matmul(m0, m1, n, m, k);
    
    printf("\nResult Matrix:\n");
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < k; j++) {
            printf("%d ", result[i * k + j]);
        }
        printf("\n");
    }
    
    free(result);
    printf("\n");
}

int main() {
    test_relu();
    test_argmax();
    test_dot();
    test_matmul();
    return 0;
}