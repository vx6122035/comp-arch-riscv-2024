.import read_matrix.s
.import write_matrix.s
.import matmul.s
.import dot.s
.import relu.s
.import argmax.s
.import utils.s
.import classify.s

.globl main
# =================================================================
# MAIN: Classification Function Test
#
# Sequential steps:
# 1. a2 = 0     (verbose mode)
# 2. classify()  (single classification)
# 3. exit(0)    (normal termination)
#
# Design note: classify() supports repeated calls if needed
# =================================================================
main:
    # initialize register a2 to zero
    mv a2, zero

    # call classify function
    jal classify

    # exit program normally
    li a0 0
    jal exit
