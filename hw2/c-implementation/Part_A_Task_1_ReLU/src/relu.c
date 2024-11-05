#include "relu.h"

void relu(int* array, int length) {
    for (int i = 0; i < length; i++) {
        if (array[i] < 0) {
            array[i] = 0;
        }
    }
}