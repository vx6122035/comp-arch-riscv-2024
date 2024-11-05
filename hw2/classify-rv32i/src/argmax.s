.globl argmax

.text
# =================================================================
# FUNCTION: Maximum Element First Index Finder
#
# Scans an integer array to find its maximum value and returns the
# position of its first occurrence. In cases where multiple elements
# share the maximum value, returns the smallest index.
#
# Arguments:
#   a0 (int *): Pointer to the first element of the array
#   a1 (int):  Number of elements in the array
#
# Returns:
#   a0 (int):  Position of the first maximum element (0-based index)
#
# Preconditions:
#   - Array must contain at least one element
#
# Error Cases:
#   - Terminates program with exit code 36 if array length < 1
# =================================================================
argmax:
    # Check if array length is valid (>= 1)
    li t6, 1
    blt a1, t6, handle_error

    # Initialize first element as current maximum
    lw t0, 0(a0)       # t0 = current maximum value
    
    # Initialize indices
    li t1, 0           # t1 = index of current maximum
    li t2, 1           # t2 = current loop index

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

handle_error:
    li a0, 36
    j exit