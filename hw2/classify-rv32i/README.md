# Assignment 2: Classify

For the essential functions like ReLU, ArgMax, Dot Product, …, I tried to use the C code to interpret this function's idea (logic). 

## Part A: Mathematical Functions
### Task 1: ReLU

$$
ReLU(a)=max(a,0)
$$

Based on the description in the `relu.s` file, this function has two arguments.
The first one is the pointer to an integer array to be modified. The second one is the number of elements in this array.

Thus, I used two variables (array, length) to represent the a0 and a1 registers in the RISC-V assembly code.

```c
// Task 1: ReLU function
// Applies ReLU activation function element-wise
void relu(int* array, int length) {
    for (int i = 0; i < length; i++) {
        if (array[i] < 0) {
            array[i] = 0;
        }
    }
}
```

A for loop is applied in this function to check if every element is larger than zero or not.
If the component is less than zero, the element will be set to zero based on the index i.

(To prevent misunderstandings, I will show the code I have modified in the `relu.s`.)
#### relu.s
```c
loop_start:
    beq t1, a1, done      # if counter == length, exit loop
    
    # Calculate current address
    slli t2, t1, 2        # t2 = counter * 4 (shift left by 2)
    add t2, a0, t2        # t2 = base + offset
    
    # Load current element
    lw t3, 0(t2)          # t3 = current element
    
    # Check if element is negative
    bge t3, zero, continue # if element >= 0, skip to continue
    
    # If negative, set to 0
    sw zero, 0(t2)        # store 0 at current address

continue:
    addi t1, t1, 1        # increment counter
    j loop_start          # continue loop

done:
    ret                   # return to caller
```

1. In the main loop, register t1 is used as the counter to check whether the current loop is finished.
2. Calculate the current element address using the shift left by two and save the address into the register t2.
3. Load the current element into register t3
4. If the element is smaller than zero, replace it with zero.
5. Increase the counter register t1 by one and return to the label loop_start to start the next iteration.


### Task 2: ArgMax

To determine the index of the most significant element in a given 1D vector, initialize variables (max_index and max_value) to store the result.

```c
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
```

A for loop is applied in this function to check whether the current element value is greater than the max_value.
If the current element value exceeds the max_value, update the max_value and max_index to the current element’s value and index in the 1D vector.
Finally, return the max_index.

#### argmax.s
```c
loop_start:
    # Check loop termination condition
    beq t2, a1, loop_end
    
    # Load current element
    slli t3, t2, 2     # t3 = t2 * 4 (offset in bytes)
    add t4, a0, t3     # t4 = address of current element
    lw t5, 0(t4)       # t5 = value at current element
    
    # Compare with current maximum
    ble t5, t0, loop_continue
    
    # Update maximum if current element is larger
    mv t0, t5          # Update maximum value
    mv t1, t2          # Update index of maximum

loop_continue:
    addi t2, t2, 1     # Increment loop counter
    j loop_start

loop_end:
    mv a0, t1          # Return index of maximum
    ret
```

1. Check if the current loop index is equal to the length of the input array. If they are the same, jump to label loop_end and return the maximum index by transferring the value from register t1 to register a0.
2. By using shift left by two, calculate the offset in bytes and save this offset to register t3. Then, add the base address from register a0 with offset in register t3 and save the result to register t4. Load the current element value into register t5.
3. Compare the current element value in register t5 with the initial maximum value in register t0.
4. If the current element value in register t5 is greater than the initial maximum value in register t0, update the maximum value and index. Then, increase the counter register t2 and start the next iteration by jumping to label loop_start.
   If the situation is the opposite, this function will skip the update of the maximum value and index, jump to label loop_continue to increase the counter register t2, and then start the next iteration by jumping to label loop_start.

### Task 3.1: Dot Product

$$ 
dot(a,b) = \sum_{i=0}^{n-1}(a_i \cdot b_i)
$$

To implement a dot product with strides function, the arguments are two vectors, two strides, and the length of these two vectors (since only the 1D vectors have the same dimension can have a dot product, here this function only requires one length value is enough.)

```c
// Computes dot product of two vectors with strides
int dot(int* v1, int* v2, int length, int stride_v1, int stride_v2) {
    int result = 0;
    
    for (int i = 0; i < length; i++) {
        result += v1[i * stride_v1] * v2[i * stride_v2];
    }
    
    return result;
}
```

Initialize a variable “result” to store the result of the dot product, use a for loop to exhaust every element in the vectors, and sum up their products.


#### dot.s

Note:
Based on one of the requirements, only RV32I instructions are available in this assignment, so it is required to use RV32I instructions to replace M-extension `mul` instruction.

##### Version 1 (Naive implementation)

1. Uses a separate `multiply` subroutine for all multiplication operations.
2. Calls `multiply` subroutine three times per loop iteration:
   1. Calculating offsets:
      - i * stride0 for the first array
      - i * stride1 for the second array
   2. Calculating the product of loaded elements:
      - Multiplying the two array values
3. Implements multiplication via repeated addition
4. Handles negative numbers by adjusting the sign and performing addition in a loop until the multiplier reaches zero.

```c
.globl dot

.text
# =======================================================
# FUNCTION: Strided Dot Product Calculator (RV32I only)
#
# Calculates sum(arr0[i * stride0] * arr1[i * stride1])
# where i ranges from 0 to (element_count - 1)
#
# Args:
#   a0 (int *): Pointer to first input array
#   a1 (int *): Pointer to second input array
#   a2 (int):   Number of elements to process
#   a3 (int):   Skip distance in first array
#   a4 (int):   Skip distance in second array
#
# Returns:
#   a0 (int):   Resulting dot product value
# =======================================================
dot:
    # Prologue: save ra and other registers we'll use
    addi sp, sp, -24
    sw ra, 0(sp)
    sw s0, 4(sp)  # Save base address of first array
    sw s1, 8(sp)  # Save base address of second array
    sw s2, 12(sp) # Save running sum
    sw s3, 16(sp) # Save counter
    sw s4, 20(sp) # Save element count

    # Save arguments to saved registers
    mv s0, a0     # Save base address of first array
    mv s1, a1     # Save base address of second array
    mv s4, a2     # Save element count

    li t0, 1
    blt a2, t0, error_terminate  # Check if element count < 1
    blt a3, t0, error_terminate  # Check if stride1 < 1
    blt a4, t0, error_terminate  # Check if stride2 < 1

    li s2, 0      # Initialize sum to 0
    li s3, 0      # Initialize counter i to 0

loop_start:
    bge s3, s4, loop_end    # If counter >= element_count, exit loop
    
    # Calculate offset for first array: t2 = i * stride1 * 4
    mv a6, s3          # Save i
    mv a7, a3          # Save stride1
    jal ra, multiply   # Result in a0: i * stride1
    slli t2, a0, 2     # t2 = (i * stride1) * 4
    add t2, s0, t2     # t2 = base_addr + (i * stride1 * 4)
    lw t3, 0(t2)       # Load value from first array
    
    # Calculate offset for second array: t4 = i * stride2 * 4
    mv a6, s3          # Save i
    mv a7, a4          # Save stride2
    jal ra, multiply   # Result in a0: i * stride2
    slli t4, a0, 2     # t4 = (i * stride2) * 4
    add t4, s1, t4     # t4 = base_addr + (i * stride2 * 4)
    lw t5, 0(t4)       # Load value from second array
    
    # Multiply values and add to sum
    mv a6, t3          # First number
    mv a7, t5          # Second number
    jal ra, multiply   # Result in a0
    add s2, s2, a0     # sum += result
    
    # Increment counter
    addi s3, s3, 1
    j loop_start

loop_end:
    mv a0, s2          # Move sum to return register
    
    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 24
    jr ra

# Multiply subroutine
# Args:
#   a6: First number
#   a7: Second number
# Returns:
#   a0: Product
multiply:
    li a0, 0           # Initialize result to 0
    beq a6, zero, mult_done  # If first number is 0, return 0
    beq a7, zero, mult_done  # If second number is 0, return 0
    
    # Handle negative numbers
    li t6, 0           # Flag for result sign
    
    bgez a6, check_second  # If first number >= 0, check second
    not a6, a6         # Negate first number
    addi a6, a6, 1
    not t6, t6         # Toggle sign flag
    
check_second:
    bgez a7, mult_loop  # If second number >= 0, start multiplication
    not a7, a7         # Negate second number
    addi a7, a7, 1
    not t6, t6         # Toggle sign flag
    
mult_loop:
    beq a7, zero, check_sign  # If second number is 0, we're done
    add a0, a0, a6     # Add first number to result
    addi a7, a7, -1    # Decrement second number
    j mult_loop
    
check_sign:
    beq t6, zero, mult_done  # If sign flag is 0, result is positive
    not a0, a0         # Negate result
    addi a0, a0, 1
    
mult_done:
    jr ra

error_terminate:
    blt a2, t0, set_error_36
    li a0, 37
    j exit

set_error_36:
    li a0, 36
    j exit

exit:
    li a7, 93         # syscall number for exit
    ecall
```

Execution time for the first version.
```
Ran 46 tests in 180.975s
```

#### Version 2 (Optimization)

1. Eliminates the multiply subroutine entirely.
2. Performs multiplication operations inlined within the main loop.
3. Implements a shift-and-add multiplication algorithm.
4. Handles sign management upfront by checking if the operands are negative and setting a sign flag.


```c
.globl dot

.text
# =======================================================
# FUNCTION: Strided Dot Product Calculator (RV32I only)
#
# Calculates sum(arr0[i * stride0] * arr1[i * stride1])
# where i ranges from 0 to (element_count - 1)
#
# Args:
#   a0 (int *): Pointer to first input array
#   a1 (int *): Pointer to second input array
#   a2 (int):   Number of elements to process
#   a3 (int):   Skip distance in first array
#   a4 (int):   Skip distance in second array
#
# Returns:
#   a0 (int):   Resulting dot product value
# =======================================================
dot:
    # Prologue
    addi sp, sp, -24
    sw ra, 0(sp)
    sw s0, 4(sp)  # Base address of first array
    sw s1, 8(sp)  # Base address of second array
    sw s2, 12(sp) # Running sum
    sw s3, 16(sp) # Current offset for first array
    sw s4, 20(sp) # Current offset for second array

    # Input validation
    li t0, 1
    blt a2, t0, error_terminate  # Check if element count < 1
    blt a3, t0, error_terminate  # Check if stride1 < 1
    blt a4, t0, error_terminate  # Check if stride2 < 1

    # Initialize
    mv s0, a0          # Save base address of first array
    mv s1, a1          # Save base address of second array
    li s2, 0           # Initialize sum = 0
    li s3, 0           # Initialize first array offset = 0
    li s4, 0           # Initialize second array offset = 0

    # t0 will be our counter
    li t0, 0

loop_start:
    bge t0, a2, loop_end    # If counter >= element_count, exit

    # Load elements from both arrays
    add t1, s0, s3     # Calculate address for first array
    lw t3, 0(t1)       # Load value from first array
    
    add t2, s1, s4     # Calculate address for second array
    lw t4, 0(t2)       # Load value from second array

    # Improved multiplication for any integers
    li t5, 0           # Initialize product
    li t6, 0           # Sign flag
    
    # Handle signs
    bgez t3, check_t4
    not t3, t3
    addi t3, t3, 1
    not t6, t6
check_t4:
    bgez t4, mult_pos
    not t4, t4
    addi t4, t4, 1
    not t6, t6
    
mult_pos:
    beqz t4, mult_sign  # If multiplier is zero, skip to sign
    andi t1, t4, 1     # Check LSB
    beqz t1, shift     # If LSB is 0, just shift
    add t5, t5, t3     # Add multiplicand if LSB is 1
shift:
    slli t3, t3, 1     # Shift multiplicand left
    srli t4, t4, 1     # Shift multiplier right
    bnez t4, mult_pos  # Continue if multiplier not zero

mult_sign:
    beqz t6, mult_done # If sign flag is 0, result is positive
    not t5, t5         # Negate result
    addi t5, t5, 1
    
mult_done:
    add s2, s2, t5     # Add product to sum

    # Update offsets for next iteration
    slli t1, a3, 2     # Multiply stride1 by 4
    add s3, s3, t1     # Update first array offset
    
    slli t2, a4, 2     # Multiply stride2 by 4
    add s4, s4, t2     # Update second array offset

    # Increment counter
    addi t0, t0, 1
    j loop_start

loop_end:
    mv a0, s2          # Return sum

    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 24
    jr ra

error_terminate:
    blt a2, t0, set_error_36
    li a0, 37
    j exit

set_error_36:
    li a0, 36

exit:
    li a7, 93         # syscall number for exit
    ecall
```

Execution time for the second version.
```
Ran 46 tests in 64.764s
```

Summarization:

1. Optimizing the multiplication algorithm:
   1. Replacing repeated addition with an efficient shift-and-add method.
   2. Inlining the multiplication to eliminate function call overhead.

2. Streamlining array offset calculations:
   1. Maintaining and incrementing offsets rather than recalculating them each time.
   2. Eliminating unnecessary multiplications within the loop.

3. Reducing overhead:
   1. Minimizing function calls and register saving/restoring.
   2. Simplifying loop control and register usage.

### Task 3.2: Maxtrix Multiplication

$$ 
C[i][j] = dot(A[i],B[:,j])
$$

From the definition of matrix multiplication, the dimensions of two matrices must be compatible.
That is, if matrix A is a $n \times m$ matrix, B is $m \times k$ matrix, resulting in $n \times k$ matrix C. 

```c
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
```

#### matmul.s

Since the original code basis has already been done
1. Basic error checking for matrix dimensions
2. Sets up the main loop structure for matrix multiplication:
   1. Outer loop (controlled by s0) iterates through rows of Matrix A
   2. Inner loop (controlled by s1) iterates through columns of Matrix B
3. Uses helper function `dot` to compute dot products for each element

Here are only the parts that are different from the original basic code.
1. Completed `inner_loop_end` to move the pointer for Matrix A to the next row after completing a row of calculations.
2. Add the complete epilogue section to properly restore all saved registers and returns from the function.

```c
inner_loop_end:
    # Move to next row of matrix A
    mv t1, a2
    # multiply by number of columns in A
    slli t1, t1, 2  # t1 = a2 * 4 (shift left by 2 positions)
    add s3, s3, t1  # move pointer to next row
    
    addi s0, s0, 1  # increment outer loop counter
    j outer_loop_start

outer_loop_end:
    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    addi sp, sp, 28
    
    ret
```

## Part B: File Operations and Main
### Task 1: Read Matrix

The original basic code gives the following functionalities.
1. Opens the file (By using `fopen`)
2. Reads the header to get rows and columns and saves them to register t1 and t2 based on the addresses provided in register a1 and a2.
3. Calculates the total elements to allocate memory
4. Allocates memory for the matrix
5. Reads the matrix data into the allocated memory
6. Closes the file and returns the matrix pointer

My Added Multiplication Code:

Purpose: Calculate total number of elements ($rows \times columns$) without using `mul` instruction

#### read_matrix.s
```c
    # Multiplication implementation
    li s1, 0         # Initialize result
    mv t3, t1        # Copy number of rows to t3
multiplication_loop:
    beq t3, zero, multiplication_done
    add s1, s1, t2   # Add number of columns
    addi t3, t3, -1  # Decrement counter
    j multiplication_loop
multiplication_done:
    # Now s1 contains t1 * t2 (number of elements)
```

### Task 2: Write Matrix

The original basic code gives the following functionalities.
1. Opens the file (By using `fopen`) for writing
2. Writes the matrix rows and columns as header information
3. Calculates the total elements to allocate memory
4. Writes matrix data to the file
5. Closes the file and returns the matrix pointer

My Added Multiplication Code:

Purpose: Calculate total number of elements ($rows \times columns$) without using `mul` instruction

Try to use the binary representation of numbers to perform the multiplication.
1. If the row number is odd (the last bit is 1), add the current column value to our result
2. Shift row right (divide by 2) and column left (multiply by 2)
3. continue until row becomes 0
Here is the example
Row (7) | Column (4) | Is Row Odd? | Add Column to Result?
-------------------------------------------------------
0111    | 0100      | Yes         | Result += 4  (4)
0011    | 1000      | Yes         | Result += 8  (12)
0001    | 10000     | Yes         | Result += 16 (28)
0000    | 100000    | No          | Done! Result = 28


#### write_matrix.s
```c
    # Calculate total number of elements (rows × columns)
    mv t0, s2        # t0 = rows
    mv t1, s3        # t1 = columns
    li s4, 0         # Initialize result to 0
    
multiply:
    beqz t0, multiply_done    # If rows == 0, done
    andi t2, t0, 1            # Check if current row count is odd
    beqz t2, skip_add         # If even, skip addition
    add s4, s4, t1            # Add columns to result
skip_add:
    slli t1, t1, 1            # Double columns
    srli t0, t0, 1            # Halve rows
    j multiply
multiply_done:
```

### Task 3: Classification

The original code sets up the structure for performing matrix operations required in a neural network classifier.

1. Reads three matrices from files (M0, M1, and input) 
2. Performs matrix multiplication: $h=M0 \times input$ 
3. Applies ReLU activation function to h 
4. Performs second matrix multiplication: $o=M1 \times h$ 
5. Writes the result to the output file 
6. Returns the argmax of the output (index of maximum value)

Main steps in this classification process:
Input -> Matrix M0 -> ReLU -> Matrix M1 -> Output

1. `mul_loop1` is introduced to perform multiplication by adding t1 to a0, t0 times. 
   Calculate the total size needed for `h`.
2. `mul_loop2` calculates the array `h` length.
   This is the argument for the `relu` function.
3. `mul_loop3` performs multiplication by repeated addition to compute the size needed for the output matrix `o`.
4. `mul_loop4` calculates the length of the array `o` needed for the `argmax` function.

#### classify.s
```c
# Section 1
    # Implement multiplication without mul instruction
    mv a0, x0     # Initialize result to 0
    mv t2, x0     # Initialize counter
mul_loop1:
    beq t2, t0, mul_loop1_end
    add a0, a0, t1
    addi t2, t2, 1
    j mul_loop1
mul_loop1_end:

# Section 2
    # Implement multiplication without mul instruction
    mv a1, x0     # Initialize result to 0
    mv t2, x0     # Initialize counter
mul_loop2:
    beq t2, t0, mul_loop2_end
    add a1, a1, t1
    addi t2, t2, 1
    j mul_loop2
mul_loop2_end:

# Section 3
    # Implement multiplication without mul instruction
    mv a0, x0     # Initialize result to 0
    mv t2, x0     # Initialize counter
mul_loop3:
    beq t2, t0, mul_loop3_end
    add a0, a0, t1
    addi t2, t2, 1
    j mul_loop3
mul_loop3_end:

# Section 4
    # Implement multiplication without mul instruction
    mv a1, x0     # Initialize result to 0
    mv t2, x0     # Initialize counter
mul_loop4:
    beq t2, t0, mul_loop4_end
    add a1, a1, t1
    addi t2, t2, 1
    j mul_loop4
mul_loop4_end:
```
