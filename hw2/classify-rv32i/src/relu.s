.globl relu

.text
# ==============================================================================
# FUNCTION: Array ReLU Activation
#
# Applies ReLU (Rectified Linear Unit) operation in-place:
# For each element x in array: x = max(0, x)
#
# Arguments:
#   a0: Pointer to integer array to be modified
#   a1: Number of elements in array
#
# Returns:
#   None - Original array is modified directly
#
# Validation:
#   Requires non-empty array (length ≥ 1)
#   Terminates (code 36) if validation fails
#
# Example:
#   Input:  [-2, 0, 3, -1, 5]
#   Result: [ 0, 0, 3,  0, 5]
# ==============================================================================
relu:
    # Prologue
    li t0, 1              # t0 = 1 for validation check
    blt a1, t0, error     # if length < 1, go to error
    li t1, 0              # t1 = loop counter

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

error:
    li a0, 36            # exit code 36
    j exit               # terminate program