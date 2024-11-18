.globl abs

.text
# =================================================================
# FUNCTION: Absolute Value Converter
#
# Transforms any integer into its absolute (non-negative) value by
# modifying the original value through pointer dereferencing.
# For example: -5 becomes 5, while 3 remains 3.
#
# Args:
#   a0 (int *): Memory address of the integer to be converted
#
# Returns:
#   None - The operation modifies the value at the pointer address
# =================================================================
abs:
    # Prologue
    ebreak

    # Load number from memory
    lw t0, 0(a0)       # Load the value from the pointer address
    bge t0, zero, done # If value >= 0, skip negation

    # If number is negative, negate it
    sub t0, zero, t0   # t0 = 0 - t0 (negation)
    sw t0, 0(a0)       # Store negated value back to memory at address in a0

done:
    # Epilogue
    jr ra                # Return to caller
