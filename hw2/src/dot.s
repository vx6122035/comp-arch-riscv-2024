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


