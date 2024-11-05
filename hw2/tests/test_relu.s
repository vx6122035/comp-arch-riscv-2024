.data

.LC1:
    .string "Testing ReLU function:"
.LC2:
    .string "Before ReLU: "
.LC3:
    .string "%d "
.LC4:
    .string "After ReLU: "
.LC5:
    .string "\n"

# Input array
.LC0:
    .word   1
    .word   -2
    .word   3
    .word   -4
    .word   5
    .word   -6

.text       # Add this line to switch back to the text segment


relu:
        addi    sp,sp,-48
        sw      ra,44(sp)
        sw      s0,40(sp)
        addi    s0,sp,48
        sw      a0,-36(s0)
        sw      a1,-40(s0)
        sw      zero,-20(s0)
        j       .L2
.L4:
        lw      a5,-20(s0)
        slli    a5,a5,2
        lw      a4,-36(s0)
        add     a5,a4,a5
        lw      a5,0(a5)
        bge     a5,zero,.L3
        lw      a5,-20(s0)
        slli    a5,a5,2
        lw      a4,-36(s0)
        add     a5,a4,a5
        sw      zero,0(a5)
.L3:
        lw      a5,-20(s0)
        addi    a5,a5,1
        sw      a5,-20(s0)
.L2:
        lw      a4,-20(s0)
        lw      a5,-40(s0)
        blt     a4,a5,.L4
        nop
        nop
        lw      ra,44(sp)
        lw      s0,40(sp)
        addi    sp,sp,48
        jr      ra

test_relu:
        addi    sp,sp,-64
        sw      ra,60(sp)
        sw      s0,56(sp)
        addi    s0,sp,64
        # lui     a5,%hi(.LC1)
        # addi    a0,a5,%lo(.LC1)
        la      a0, .LC1 # replace lui, addi
        call    puts
        lui     a5,%hi(.LC0)
        addi    a5,a5,%lo(.LC0)
        lw      a0,0(a5)
        lw      a1,4(a5)
        lw      a2,8(a5)
        lw      a3,12(a5)
        lw      a4,16(a5)
        lw      a5,20(a5)
        sw      a0,-52(s0)
        sw      a1,-48(s0)
        sw      a2,-44(s0)
        sw      a3,-40(s0)
        sw      a4,-36(s0)
        sw      a5,-32(s0)
        li      a5,6
        sw      a5,-28(s0)
        lui     a5,%hi(.LC2)
        addi    a0,a5,%lo(.LC2)
        call    printf
        sw      zero,-20(s0)
        j       .L6
.L7:
        lw      a4,-20(s0)
        addi    a5,s0,-52
        slli    a4,a4,2
        add     a5,a4,a5
        lw      a5,0(a5)
        mv      a1,a5
        lui     a5,%hi(.LC3)
        addi    a0,a5,%lo(.LC3)
        call    printf
        lw      a5,-20(s0)
        addi    a5,a5,1
        sw      a5,-20(s0)
.L6:
        lw      a4,-20(s0)
        lw      a5,-28(s0)
        blt     a4,a5,.L7
        li      a0,10
        call    putchar
        addi    a5,s0,-52
        lw      a1,-28(s0)
        mv      a0,a5
        call    relu
        lui     a5,%hi(.LC4)
        addi    a0,a5,%lo(.LC4)
        call    printf
        sw      zero,-24(s0)
        j       .L8
.L9:
        lw      a4,-24(s0)
        addi    a5,s0,-52
        slli    a4,a4,2
        add     a5,a4,a5
        lw      a5,0(a5)
        mv      a1,a5
        lui     a5,%hi(.LC3)
        addi    a0,a5,%lo(.LC3)
        call    printf
        lw      a5,-24(s0)
        addi    a5,a5,1
        sw      a5,-24(s0)
.L8:
        lw      a4,-24(s0)
        lw      a5,-28(s0)
        blt     a4,a5,.L9
        lui     a5,%hi(.LC5)
        addi    a0,a5,%lo(.LC5)
        call    puts
        nop
        lw      ra,60(sp)
        lw      s0,56(sp)
        addi    sp,sp,64
        jr      ra
main:
        addi    sp,sp,-16
        sw      ra,12(sp)
        sw      s0,8(sp)
        addi    s0,sp,16
        call    test_relu
        li      a5,0
        mv      a0,a5
        lw      ra,12(sp)
        lw      s0,8(sp)
        addi    sp,sp,16
        jr      ra