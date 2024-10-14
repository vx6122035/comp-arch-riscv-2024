    # Function: bits_to_fp32
    # Input: w (in a0)
    # Output: Approximated integer value of the float (in a0)
    # This function approximates the float value by manipulating the bit pattern.

    .text

bits_to_fp32:
    # Extract sign bit
    srli t0, a0, 31          # t0 = Sign bit (0 or 1)

    # Extract exponent bits
    srli t1, a0, 23          # t1 = Bits [31:23] (Sign bit + exponent)
    andi t1, t1, 0xFF        # t1 = Exponent bits (8 bits)

    # Extract mantissa bits and add implicit leading 1
    slli t2, a0, 9           # Shift left to remove sign and exponent
    srli t2, t2, 9           # Shift back to align mantissa bits
    li t3, 1
    slli t3, t3, 23          # t3 = 1 << 23 (implicit leading 1)
    or t2, t2, t3            # t2 = mantissa | implicit leading 1

    # Adjust exponent bias (E - 127)
    addi t1, t1, -127        # t1 = E - 127

    # Handle exponent being negative or positive
    blt t1, zero_exponent    # If exponent < 0, branch to zero_exponent

    # Positive exponent
    sll t2, t2, t1           # Shift mantissa left by (E - 127)
    j apply_sign

zero_exponent:
    # Negative or zero exponent
    sub t1, x0, t1           # t1 = -(E - 127)
    srl t2, t2, t1           # Shift mantissa right by -(E - 127)

apply_sign:
    # Apply sign
    bnez t0, negative        # If sign bit is 1, number is negative

    # Positive number
    mv a0, t2                # Result in a0
    ret

negative:
    # Negative number
    sub a0, x0, t2           # a0 = -t2
    ret