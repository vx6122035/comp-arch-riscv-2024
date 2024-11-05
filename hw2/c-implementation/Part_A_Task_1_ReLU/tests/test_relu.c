#include <stdio.h>
#include "relu.h"

int main() {
    // Test array
    int test_array[] = {1, -2, 3, -4, 5, -6};
    int length = 6;
    
    // Print original array
    printf("Original array: ");
    for (int i = 0; i < length; i++) {
        printf("%d ", test_array[i]);
    }
    printf("\n");
    
    // Apply ReLU
    relu(test_array, length);
    
    // Print result
    printf("After ReLU: ");
    for (int i = 0; i < length; i++) {
        printf("%d ", test_array[i]);
    }
    printf("\n");
    
    return 0;
}