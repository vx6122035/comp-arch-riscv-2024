    .data
# Constants
exp_offset:     .word 0x03800000    # 0xE0 << 23
mask:           .word 0x3F000000    # 126 << 23
denorm_cutoff:  .word 0x08000000    # 1 << 27

    .text
    .globl fp16_to_fp32

fp16_to_fp32:
    # Prologue
    addi sp, sp, -20         # Allocate stack space
    sw ra, 16(sp)            # Save return address
    sw s0, 12(sp)            # Save s0
    sw s1, 8(sp)             # Save s1
    sw s2, 4(sp)             # Save s2
    sw s3, 0(sp)             # Save s3

    # Input: h in a0
    slli s0, a0, 16          # s0 = w = h << 16

    # s1 = sign = w & 0x80000000
    li t0, 0x80000000
    and s1, s0, t0

    # s2 = two_w = w + w
    add s2, s0, s0

    # temp = (two_w >> 4) + exp_offset
    srli t1, s2, 4           # t1 = two_w >> 4
    la t2, exp_offset
    lw t2, 0(t2)             # t2 = exp_offset
    add s3, t1, t2           # s3 = temp

    # normalized_value = bits_to_fp32(temp)
    mv a0, s3
    jal ra, bits_to_fp32     # Result in a0

    # Store normalized_value in s4
    mv s4, a0

    # temp = (two_w >> 17) | mask
    srli t1, s2, 17          # t1 = two_w >> 17
    la t2, mask
    lw t2, 0(t2)             # t2 = mask
    or s3, t1, t2            # s3 = temp

    # denormalized_value = bits_to_fp32(temp)
    mv a0, s3
    jal ra, bits_to_fp32     # Result in a0

    # Store denormalized_value in s5
    mv s5, a0

    # Compare two_w with denorm_cutoff
    la t0, denorm_cutoff
    lw t0, 0(t0)             # t0 = denorm_cutoff
    blt s2, t0, use_denorm

    # Use normalized_value
    mv a0, s4
    j assemble_result

use_denorm:
    # Use denormalized_value
    mv a0, s5

assemble_result:
    # Combine sign with the selected value
    or a0, a0, s1            # a0 = sign | selected_value

    # Epilogue
    lw ra, 16(sp)
    lw s0, 12(sp)
    lw s1, 8(sp)
    lw s2, 4(sp)
    lw s3, 0(sp)
    addi sp, sp, 20
    ret