#include <stdio.h>
#include "argmax.h"

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

int main() {
    test_argmax();
    return 0;
}
