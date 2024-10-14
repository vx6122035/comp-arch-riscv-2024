    .data
bias_threshold: .word 0x71000000
bias_offset:    .word 0x07800000
max_exponent:   .word 0xFF000000
nan_value:      .word 0x7E00

    .text
    .globl fp32_to_fp16

fp32_to_fp16:
    # Prologue
    addi sp, sp, -28         # Allocate stack space
    sw ra, 24(sp)            # Save return address
    sw s0, 20(sp)            # Save s0
    sw s1, 16(sp)            # Save s1
    sw s2, 12(sp)            # Save s2
    sw s3, 8(sp)             # Save s3
    sw s4, 4(sp)             # Save s4
    sw s5, 0(sp)             # Save s5

    # Input: f in a0
    jal ra, fp32_to_bits     # a0 = w
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
    jal ra, bits_to_fp32     # a0 = base
    mv s5, a0                # s5 = base

    # Convert base back to bits
    jal ra, fp32_to_bits     # a0 = bits
    mv s6, a0                # s6 = bits

    # Extract exponent and mantissa
    srli t5, s6, 13          # t5 = bits >> 13
    andi t5, t5, 0x7C00      # t5 = exp_bits

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