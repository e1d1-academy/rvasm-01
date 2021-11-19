.equ MAX_VALUES, 100
.section .text
.globl main
main:
    addi sp, sp, -16
    sd ra, 8(sp)    

    la a0, file_name
    la a1, file_mode
    call fopen
    beq a0, x0, exit

    mv s1, a0 # filehandle

    mv s2, x0 # counter 
loop_in:
    mv a0, s1
    la a1, scan_fmt
    la a2, data_in
    add a2, a2, s2
    call fscanf
    add s2, s2, 4
    # div by 4
    srli t0, s2, 2
    li t1, MAX_VALUES
    beq t0, t1, close
    bgez a0, loop_in
    
close:
    mv a0, s1
    call fclose

# bubblesort
    la a0, data_in
    srli a1, s2, 2
    call bubblesort

    mv s3, x0
loop_out:
    la a0, out_fmt
    la a1, data_in
    add a1, a1, s3
    lw a1, 0(a1)
    call printf
    add s3, s3, 4
    bne s2, s3, loop_out

    li a0, 0

exit:
    ld ra, 8(sp)
    addi sp,sp, 16
    ret

.section .rodata
file_name:
.asciz "zahlen.asc"
file_mode:
.asciz "r"
scan_fmt:
.asciz "%d"
out_fmt:
.asciz "%d "

.section .bss
data_in:
.skip 4*MAX_VALUES, 0
