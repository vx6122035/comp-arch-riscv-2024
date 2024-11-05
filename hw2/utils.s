.globl print_int, print_str, print_char, print_int_array, malloc, free, print_newline

# ==============================================================================
# FUNCTION: Print integer
# Arguments:
#   a1 (int) is the number to print
# ==============================================================================
# print_int:
#     # Preserve registers
#     addi sp, sp, -8
#     sw ra, 0(sp)
#     sw a0, 4(sp)

#     # Print integer
#     mv a0, a1
#     li a7, 1           # syscall number for print_int
#     ecall

#     # Restore registers
#     lw ra, 0(sp)
#     lw a0, 4(sp)
#     addi sp, sp, 8
#     ret
print_int:
    addi sp, sp, -4
    sw ra, 0(sp)

    li a7, 1
    ecall

    lw ra, 0(sp)
    addi sp, sp, 4
    ret


# ==============================================================================
# FUNCTION: Print string
# Arguments:
#   a1 (char*) is the string address
# ==============================================================================
# print_str:
#     # Preserve registers
#     addi sp, sp, -8
#     sw ra, 0(sp)
#     sw a0, 4(sp)

#     # Print string
#     mv a0, a1
#     li a7, 4           # syscall number for print_string
#     ecall

#     # Restore registers
#     lw ra, 0(sp)
#     lw a0, 4(sp)
#     addi sp, sp, 8
#     ret
print_str:
    addi sp, sp, -4
    sw ra, 0(sp)

    li a7, 4
    ecall

    lw ra, 0(sp)
    addi sp, sp, 4
    ret


# ==============================================================================
# FUNCTION: Print character
# Arguments:
#   a1 (char) is the character to print
# ==============================================================================
# print_char:
#     # Preserve registers
#     addi sp, sp, -8
#     sw ra, 0(sp)
#     sw a0, 4(sp)

#     # Print character
#     mv a0, a1
#     li a7, 11          # syscall number for print_character
#     ecall

#     # Restore registers
#     lw ra, 0(sp)
#     lw a0, 4(sp)
#     addi sp, sp, 8
#     ret
print_char:
    addi sp, sp, -4
    sw ra, 0(sp)

    li a7, 11
    ecall

    lw ra, 0(sp)
    addi sp, sp, 4
    ret


# ==============================================================================
# FUNCTION: Print newline
# Arguments: none
# ==============================================================================
# print_newline:
#     # Preserve registers
#     addi sp, sp, -8
#     sw ra, 0(sp)
#     sw a0, 4(sp)

#     # Print newline
#     li a1, '\n'
#     jal print_char

#     # Restore registers
#     lw ra, 0(sp)
#     lw a0, 4(sp)
#     addi sp, sp, 8
#     ret
print_newline:
    addi sp, sp, -4
    sw ra, 0(sp)

    li a0, '\n'
    jal print_char

    lw ra, 0(sp)
    addi sp, sp, 4
    ret


# ==============================================================================
# FUNCTION: Print integer array
# Arguments:
#   a0 (int*) is the pointer to array
#   a1 (int)  is the length of array
# ==============================================================================
# print_int_array:
#     # Preserve registers
#     addi sp, sp, -16
#     sw ra, 0(sp)
#     sw s0, 4(sp)
#     sw s1, 8(sp)
#     sw s2, 12(sp)

#     # Save arguments
#     mv s0, a0           # array pointer
#     mv s1, a1           # length
#     li s2, 0            # counter

# array_loop:
#     beq s2, s1, array_done
    
#     # Calculate current element address
#     slli t0, s2, 2      # offset = counter * 4
#     add t0, s0, t0      # address = base + offset
    
#     # Load and print current element
#     # lw a1, 0(t0)
#     lw a0, 0(t0)
#     jal print_int
    
#     # Print space (except after last element)
#     addi t0, s1, -1     # t0 = length - 1
#     beq s2, t0, skip_space
#     li a1, ' '
#     jal print_char
# skip_space:
    
#     # Increment counter
#     addi s2, s2, 1
#     j array_loop

# array_done:
#     # Restore registers
#     lw ra, 0(sp)
#     lw s0, 4(sp)
#     lw s1, 8(sp)
#     lw s2, 12(sp)
#     addi sp, sp, 16
#     ret
print_int_array:
    # Preserve registers
    addi sp, sp, -28
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)

    # Initialize pointers and counters
    mv s0, a0       # s0 = array pointer
    mv s1, a1       # s1 = length
    li s2, 0        # s2 = counter (i)

array_loop:
    beq s2, s1, array_done    # if i == length, exit loop

    # Calculate address: s3 = s0 + i * 4
    slli s4, s2, 2            # s4 = i * 4
    add s3, s0, s4            # s3 = array + (i * 4)

    # Load and print current element
    lw a0, 0(s3)              # a0 = array[i]
    jal print_int

    # Print space (except after last element)
    addi s5, s1, -1           # s5 = length - 1
    beq s2, s5, skip_space
    li a0, ' '
    jal print_char
skip_space:
    addi s2, s2, 1            # i++
    j array_loop

array_done:
    # Restore registers
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    addi sp, sp, 28
    ret



# ==============================================================================
# FUNCTION: Allocate memory
# Arguments:
#   a0 (int) is the number of bytes to allocate
# Returns:
#   a0 (void*) is the pointer to allocated memory
# ==============================================================================
malloc:
    # syscall for memory allocation
    li a7, 9           # sbrk syscall number
    ecall
    ret

# ==============================================================================
# FUNCTION: Free memory
# Arguments:
#   a0 (void*) is the pointer to memory to free
# ==============================================================================
free:
    ret                # In RISC-V simulator, we don't actually need to free memory