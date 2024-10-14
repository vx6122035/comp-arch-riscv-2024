    .data
# Constants for `fp16_to_fp32`
exp_offset:     .word 0x03800000    # 0xE0 << 23
mask:           .word 0x3F000000    # 126 << 23
denorm_cutoff:  .word 0x08000000    # 1 << 27

# Constants for `fp32_to_fp16`
bias_threshold: .word 0x71000000
bias_offset:    .word 0x07800000
max_exponent:   .word 0xFF000000
nan_value:      .word 0x7E00

# Constants for your main program
MAX_SPEED:      .word 10000000       # Maximum speed

# Testing data
# dist_array: .word 1, 3, 2    # Example distances

    .text
    .globl main

# Entry Point
main:
    # For testing, set up the `dist` array, `distSize`, and `hour` here.
    # Example:
    la a0, dist_array        # Load address of `dist` array into a0
    li a1, 3                 # distSize = 3
    li a2, 0x4200            # hour = 2.5 in FP16 (example value)
    jal minSpeedOnTime       # Call the main function
    # Result will be in a0
    ret

# `dist` array
    .data
dist_array: .word 1, 3, 2    # Example distances

    .text
    .globl fp32_to_fp16

fp32_to_fp16:
    # Prologue
    addi sp, sp, -28         # Allocate stack space
    sw ra, 24(sp)            # Save return address
    sw s0, 20(sp)
    sw s1, 16(sp)
    sw s2, 12(sp)
    sw s3, 8(sp)
    sw s4, 4(sp)
    sw s5, 0(sp)

    # Input: f in a0
    jal fp32_to_bits         # a0 = w
    mv s0, a0                # s0 = w

    # s1 = shl1_w = w + w
    add s1, s0, s0

    # s2 = sign = w & 0x80000000
    li t0, 0x80000000
    and s2, s0, t0

    # s3 = bias = shl1_w & 0xFF000000
    li t1, 0xFF000000
    and s3, s1, t1

    # Adjust bias if necessary
    la t2, bias_threshold
    lw t2, 0(t2)             # t2 = 0x71000000
    blt s3, t2, adjust_bias
    j compute_base

adjust_bias:
    mv s3, t2                # s3 = bias = 0x71000000

compute_base:
    # s4 = (bias >> 1) + bias_offset
    srli t3, s3, 1           # t3 = bias >> 1
    la t4, bias_offset
    lw t4, 0(t4)             # t4 = 0x07800000
    add s4, t3, t4           # s4 = temp

    # base = bits_to_fp32(s4)
    mv a0, s4
    jal bits_to_fp32         # a0 = base
    mv s5, a0                # s5 = base

    # Convert base back to bits
    jal fp32_to_bits         # a0 = bits
    mv s6, a0                # s6 = bits

    # Extract exponent and mantissa
    srli t5, s6, 13          # t5 = bits >> 13

    # Correcting immediate overflow by loading 0x7C00 into a register
    li t7, 0x7C00
    and t5, t5, t7           # t5 = t5 & 0x7C00

    andi t6, s6, 0x0FFF      # t6 = mantissa_bits

    # nonsign = exp_bits + mantissa_bits
    add t0, t5, t6           # t0 = nonsign

    # Check for NaN or Infinity
    la t1, max_exponent
    lw t1, 0(t1)             # t1 = 0xFF000000
    bgt s1, t1, return_nan

    # Assemble fp16 value
    srli s2, s2, 16          # s2 = sign >> 16
    or a0, s2, t0            # a0 = sign | nonsign
    j fp32_to_fp16_end

return_nan:
    # Return NaN value
    srli s2, s2, 16          # s2 = sign >> 16
    la t2, nan_value
    lw t2, 0(t2)             # t2 = 0x7E00
    or a0, s2, t2            # a0 = sign | 0x7E00

fp32_to_fp16_end:
    # Epilogue
    lw ra, 24(sp)
    lw s0, 20(sp)
    lw s1, 16(sp)
    lw s2, 12(sp)
    lw s3, 8(sp)
    lw s4, 4(sp)
    lw s5, 0(sp)
    addi sp, sp, 28
    ret


    .text
    .globl fp16_to_fp32

fp16_to_fp32:
    # Prologue
    addi sp, sp, -20
    sw ra, 16(sp)
    sw s0, 12(sp)
    sw s1, 8(sp)
    sw s2, 4(sp)
    sw s3, 0(sp)

    # Input: h in a0
    slli s0, a0, 16          # s0 = w = h << 16

    # s1 = sign = w & 0x80000000
    li t0, 0x80000000
    and s1, s0, t0

    # s2 = two_w = w + w
    add s2, s0, s0

    # temp = (two_w >> 4) + exp_offset
    srli t1, s2, 4
    la t2, exp_offset
    lw t2, 0(t2)
    add s3, t1, t2

    # normalized_value = bits_to_fp32(temp)
    mv a0, s3
    jal bits_to_fp32
    mv s4, a0

    # temp = (two_w >> 17) | mask
    srli t1, s2, 17
    la t2, mask
    lw t2, 0(t2)
    or s3, t1, t2

    # denormalized_value = bits_to_fp32(temp)
    mv a0, s3
    jal bits_to_fp32
    mv s5, a0

    # Compare two_w with denorm_cutoff
    la t0, denorm_cutoff
    lw t0, 0(t0)
    blt s2, t0, use_denorm

    # Use normalized_value
    mv a0, s4
    j assemble_result

use_denorm:
    # Use denormalized_value
    mv a0, s5

assemble_result:
    # Combine sign with the selected value
    or a0, a0, s1

    # Epilogue
    lw ra, 16(sp)
    lw s0, 12(sp)
    lw s1, 8(sp)
    lw s2, 4(sp)
    lw s3, 0(sp)
    addi sp, sp, 20
    ret

    .text
    .globl fp32_to_bits

fp32_to_bits:
    # Input: Approximate integer value in a0
    # Output: Reconstructed bit pattern in a0
    # For the purposes of this program, we'll treat the integer as the bit pattern directly
    ret


    .text
    .globl bits_to_fp32

bits_to_fp32:
    # Input: w (in a0)
    # Output: Approximate integer value of the float (in a0)
    # This function approximates the float value by manipulating the bit pattern.

    # Extract sign bit
    srli t0, a0, 31          # t0 = Sign bit (0 or 1)

    # Extract exponent bits
    srli t1, a0, 23          # t1 = Bits [31:23]
    andi t1, t1, 0xFF        # t1 = Exponent bits (8 bits)

    # Extract mantissa bits and add implicit leading 1
    slli t2, a0, 9           # Shift left to remove sign and exponent
    srli t2, t2, 9           # t2 = Mantissa bits
    li t3, 1
    slli t3, t3, 23          # t3 = 1 << 23
    or t2, t2, t3            # t2 = Mantissa with implicit leading 1

    # Adjust exponent bias (E - 127)
    addi t1, t1, -127        # t1 = E - 127

    # Handle exponent being negative or positive
    blt t1, zero_exponent

    # Positive exponent
    sll t2, t2, t1           # Shift left by (E - 127)
    j apply_sign

zero_exponent:
    # Negative or zero exponent
    sub t1, x0, t1           # t1 = -(E - 127)
    srl t2, t2, t1           # Shift right by -(E - 127)

apply_sign:
    # Apply sign
    bnez t0, negative

    # Positive number
    mv a0, t2
    ret

negative:
    sub a0, x0, t2
    ret

    .text
    .globl divu

divu:
    beq a1, zero, divu_zero_divisor
    li t0, 0            # t0 = quotient
    mv t1, a0           # t1 = dividend
    mv t2, a1           # t2 = divisor

    # Find the highest bit set in divisor
    li t3, 0            # t3 = shift amount
divu_shift_divisor:
    slli t4, t2, t3
    blt t1, t4, divu_divide
    addi t3, t3, 1
    j divu_shift_divisor

divu_divide:
    addi t3, t3, -1
divu_divide_loop:
    slli t4, t2, t3
    blt t1, t4, divu_no_subtract
    sub t1, t1, t4
    slli t0, t0, 1
    addi t0, t0, 1
    j divu_next
divu_no_subtract:
    slli t0, t0, 1
divu_next:
    addi t3, t3, -1
    bgez t3, divu_divide_loop

    mv a0, t0
    ret

divu_zero_divisor:
    li a0, -1
    ret


