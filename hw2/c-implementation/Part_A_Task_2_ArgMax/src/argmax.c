#include "argmax.h"

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