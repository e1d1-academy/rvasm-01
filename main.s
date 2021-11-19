.section .text
.globl main
main:
    addi sp, sp, -16
    sd ra, 8(sp)

    la a0, msg
    call printf

    la a0, filename
    la a1, file_mode
    call fopen
    beq a0, x0, exit

    mv s1, a0 #filehandle

    # loop counter
    mv s2, x0
loop_in:
    mv a0, s1
    la a1, scan_fmt
    la a2, data_in
    add a2, a2, s2
    call fscanf
    addi s2, s2, 1
    li t0, 100
    beq t0, s2, close
    bgez a0, loop_in
    addi s2, s2, -1

close:
    mv a0, s1
    call fclose

    mv s3, x0
loop_out:
    la a0, out_fmt
    la a1, data_in
    add a1, a1, s3
    lbu a1, 0(a1)
    call printf
    addi s3, s3, 1
    bne s3, s2, loop_out

    li a0, 0
exit:
    ld ra, 8(sp)
    addi sp, sp, 16
    ret 


.section .rodata
msg:
.asciz "Reading "
filename:
.asciz "zahlen.asc"
file_mode:
.asciz "rt"
scan_fmt:
.asciz "%d"
out_fmt:
.asciz "%d "

.section .bss
data_in:
.skip 100, 0
