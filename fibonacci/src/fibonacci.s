.section .text
.globl main
main:
    addi sp, sp, -16
    sd ra, 8(sp)

    la a0, prompt
    call printf

    la a0, scanfmt
    # we use 0(sp) as it is not used
    mv a1, sp
    call scanf

    lw a0, 0(sp)
    call fib
    mv a1, a0

    la a0, result
    call printf

    li a0, 0

    ld ra, 8(sp)
    addi sp, sp, 16
    ret

fib:
    # allocate for two register
    addi sp, sp, -16
    # save return address
    sd ra, 8(sp)
    # save s1
    sd s1, 0(sp)

    li t0, 1
    # f(0) = 0, f(1) = 1
    ble a0, t0, fib_end

    # else_
    # n-1
    addi a0, a0, -1
    # save n-1 
    mv s1, a0
    # f(n-1)
    call fib

    # save temp. f(n-1) in t0
    mv t0, a0
    # restore n
    mv a0, s1
    # n-2
    addi a0, a0, -1
    # save f(n-1)
    mv s1, t0
    # f(n-2)
    call fib

    # add f(n-1) + f(n-2)
    add a0, a0, s1 

fib_end:
    # restore s1
    ld s1, 0(sp)
    # restore return address
    ld ra, 8(sp)
    # free stack
    addi sp, sp, 16
    ret

.section .rodata
prompt:
.asciz "Enter n: "
scanfmt:
.asciz "%u"
result:
.asciz "Fib is %d\n"
