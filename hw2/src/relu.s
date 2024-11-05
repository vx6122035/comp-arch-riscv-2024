.globl relu

# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
#   a0 (int*) is the pointer to the array
#   a1 (int)  is the length of the array
# Returns:
#   None
# ==============================================================================
relu:
    # Prologue
    addi sp, sp, -12
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)

    # Save arguments
    mv s0, a0       # array pointer
    mv s1, a1       # length

    # Initialize counter
    li t0, 0        # i = 0

loop_start:
    beq t0, s1, loop_end    # if i == length, exit loop
    
    # Calculate address of current element
    slli t1, t0, 2          # t1 = i * 4 (size of int)
    add t1, s0, t1          # t1 = array + (i * 4)
    
    # Load current element
    lw t2, 0(t1)           # t2 = array[i]
    
    # Compare with zero
    bge t2, zero, continue  # if array[i] >= 0, skip
    
    # If negative, set to zero
    sw zero, 0(t1)         # array[i] = 0

continue:
    addi t0, t0, 1         # i++
    j loop_start

loop_end:
    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    addi sp, sp, 12
    ret