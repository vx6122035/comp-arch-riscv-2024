.globl __start

.text
__start:
    # Print integer
    li a0, 10        # number to print
    li a7, 1         # syscall 1 is for printing integers
    ecall

    # Print newline
    li a0, '\n'      # newline character
    li a7, 11        # syscall 11 is for printing characters
    ecall

    # Exit program
    li a0, 0         # exit code 0
    li a7, 93        # syscall 93 is for exit
    ecall