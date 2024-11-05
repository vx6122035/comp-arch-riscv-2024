.globl dot

.text
# =======================================================
# FUNCTION: Strided Dot Product Calculator
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
#
# Preconditions:
#   - Element count must be positive (>= 1)
#   - Both strides must be positive (>= 1)
#
# Error Handling:
#   - Exits with code 36 if element count < 1
#   - Exits with code 37 if any stride < 1
# =======================================================
dot:
    li t0, 1
    blt a2, t0, error_terminate  # Check if element count < 1
    blt a3, t0, error_terminate  # Check if stride1 < 1
    blt a4, t0, error_terminate  # Check if stride2 < 1

    li t0, 0            # Initialize sum to 0
    li t1, 0           # Initialize counter i to 0

loop_start:
    bge t1, a2, loop_end    # If counter >= element_count, exit loop
    
    # Calculate offset for first array: t2 = i * stride1 * 4
    mul t2, t1, a3     # t2 = i * stride1
    slli t2, t2, 2     # t2 = t2 * 4 (multiply by 4 for byte offset)
    add t2, a0, t2     # t2 = address of arr0[i * stride1]
    lw t3, 0(t2)       # Load value from first array
    
    # Calculate offset for second array: t4 = i * stride2 * 4
    mul t4, t1, a4     # t4 = i * stride2
    slli t4, t4, 2     # t4 = t4 * 4 (multiply by 4 for byte offset)
    add t4, a1, t4     # t4 = address of arr1[i * stride2]
    lw t5, 0(t4)       # Load value from second array
    
    # Multiply values and add to sum
    mul t6, t3, t5     # t6 = arr0[i * stride1] * arr1[i * stride2]
    add t0, t0, t6     # sum += t6
    
    # Increment counter
    addi t1, t1, 1
    j loop_start

loop_end:
    mv a0, t0          # Move sum to return register
    jr ra

error_terminate:
    blt a2, t0, set_error_36
    li a0, 37
    j exit

set_error_36:
    li a0, 36
    j exit

exit:
    # Exit the program with error code in a0
    li a7, 93         # syscall number for exit
    ecall