.include "src/constants.s"
.equ NB_CLUSTERS, 3
.section .text
.globl main
main:
    addi sp, sp, -16
    sd ra, 8(sp)    
# file open
    la a0, file_name
    la a1, file_mode
    call fopen
    beq a0, x0, exit

    mv s1, a0 # filehandle

# file read
    mv s2, x0 # counter 
loop_in:
    mv a0, s1
    la a1, scan_fmt
    la a2, data_in
    mv t0, s2
    # mul by 4 for size of float
    slli t0, t0, 2
    add a2, a2, t0
    call fscanf

    # only accept max*dim vlues
    add s2, s2, 1
    li t1, MAX_VALUES*DIM
    beq s2, t1, close

    # check against file end, not reached loop_in
    bgez a0, loop_in
    # reached here, we have one count too much
    addi s2, s2, -1

# file close
close:
    mv a0, s1
    call fclose

# s2 shall contain number of data tuples
    li t0, DIM
    div s2, s2, t0 # values per DIM

# kmeans parameters: address to data, number of data tuples and k 
    la a0, data_in
    mv a1, s2
    li a2, NB_CLUSTERS
    call kmeans

# return are a0 with clusters, a1 with assignments to data input
    mv s5, a0
    mv s4, a1

# print out all data points
    la s1, data_in
    li s3, 0 
loop_out:
    la a0, out_fmt

    flw ft0, 0(s1)
    fcvt.d.s ft0, ft0
    fmv.x.d a1, ft0

    flw ft0, 4(s1)
    fcvt.d.s ft0, ft0
    fmv.x.d a2, ft0

    lb a3, 0(s4)

    call printf

    # next tuple
    li t0, DIM
    # float = 4 bytes
    # slli by 2 is mult by 4
    slli t0, t0, 2
    add s1, s1, t0

    # add one to assignments
    addi s4, s4, 1

    addi s3, s3, 1
    blt s3, s2, loop_out

    li s4, NB_CLUSTERS

loop_cen:
    la a0, cen_fmt

    flw ft0, 0(s5)
    fcvt.d.s ft0, ft0
    fmv.x.d a1, ft0

    flw ft0, 4(s5)
    fcvt.d.s ft0, ft0
    fmv.x.d a2, ft0

    call printf

    # next tuple
    li t0, DIM
    slli t0, t0, 2
    add s5, s5, t0

    addi s4, s4, -1
    bgtz s4, loop_cen

    li a0, 0

exit:
    ld ra, 8(sp)
    addi sp,sp, 16
    ret

.section .rodata
file_name:
.asciz "kmeans.txt"
file_mode:
.asciz "r"
scan_fmt:
.asciz "%f"
out_fmt:
.asciz "%0.f %0.f %d\n"
cen_fmt:
.asciz "%.0f %.0f +\n"

.section .bss
.balign 4
# single float are 4 bytes in lp64
data_in:
.skip 4*MAX_VALUES*DIM, 0
