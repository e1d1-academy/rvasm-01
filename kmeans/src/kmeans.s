.include "src/constants.s"
.section .text
.globl kmeans
# a0 data of float (4 bytes = one float)
# a1 number of data points
# a2 number k of clusters
# DIM is used from constants, testet only with DIM == 2
kmeans:
    addi sp, sp, -16
    sd ra, 8(sp)    

    mv s1, a0
    mv s2, a1
    sw a2, nb_clusters, t0
    call initial_centers

    li s3, NB_ITERATIONS
kmeans_loop:
    mv a0, s1
    mv a1, s2
    call assign_points

    mv a0, s1
    mv a1, s2
    call update_centers

    addi s3, s3, -1
    bgtz s3, kmeans_loop

kmeans_end:
    la a0, centers
    la a1, assignments

    ld ra, 8(sp)
    addi sp,sp, 16
    ret

distance:
# pointer (to float) to a in a0 and b in a1
# computes Euclidean distance squared 
# return in fa0
    addi sp, sp, -16
    sd ra, 8(sp)

    li t0, DIM
    # sum init with 0
    fcvt.s.w fa0, x0
distance_loop:
    # a
    flw ft0, 0(a0)
    # b
    flw ft1, 0(a1)
    # a(i) - b(i) for dim i
    fsub.s ft2, ft0, ft1
    # (a(i) - b(i))^2
    fmul.s ft2, ft2, ft2
    # add to sum
    fadd.s fa0, fa0, ft2

    # next
    addi a0, a0, 4
    addi a1, a1, 4
    addi t0, t0, -1
    bgtz t0, distance_loop

    ld ra, 8(sp)
    addi sp, sp, 16
    ret

initial_centers:
    addi sp, sp, -16
    sd ra, 8(sp)

    lw t1, nb_clusters
    la t4, centers

    # computer step width
    div t2, a1, t1
    li t0, DIM*4
    mul t2, t2, t0

initial_centers_loop:
    li t0, DIM
    mv a3, a0

initial_centers_dim_loop:
    lw t5, 0(a0)
    sw t5, 0(t4)

    # next dim value
    addi a0, a0, 4
    addi t4, t4, 4

    addi t0, t0, -1
    bgtz t0, initial_centers_dim_loop

    # use step width for next center of source data
    add a0, a3, t2

    addi t1, t1, -1
    bgtz t1, initial_centers_loop

    ld ra, 8(sp)
    addi sp, sp, 16
    ret

# a0: address of data points
# a1: number of data points
assign_points:
    addi sp, sp, -64
    sd ra, 56(sp)
    sd s1, 48(sp)
    sd s2, 40(sp)
    sd s3, 32(sp)
    sd s4, 24(sp)
    sd s5, 16(sp)
    sd s6,  8(sp)

    # s2: points
    # s3: assigments
    # s4: cluster
    # s5: counter for points
    # s6: counter for clusters
    mv s2, a0
    la s3, assignments

    mv s5, a1 

assign_points_loop:
    sw x0, 0(s3)   # initial assignment ist 0
    la s4, centers # 
    mv a0, s2
    mv a1, s4 
    call distance  # compute distance 
    fsw fa0, 0(sp) # min distance in 0(sp)

    addi s4, s4, DIM*4
    li s6, 1

assign_points_cluster_loop:
    mv a0, s2
    mv a1, s4
    call distance

    # if distance lower or equal then change
    flw fa1, 0(sp)
    fle.s t6, fa0, fa1
    beqz t6, assign_points_dont_change
    fsw fa0, 0(sp)
    sw s6, 0(s3)

assign_points_dont_change:
    addi s4, s4, DIM*4
    addi s6, s6, 1
    lw t0, nb_clusters
    blt s6, t0, assign_points_cluster_loop

    # next point
    addi s2, s2, DIM*4
    addi s3, s3, 1

    addi s5, s5, -1
    bgtz s5, assign_points_loop

    ld s6,  8(sp)
    ld s5, 16(sp)
    ld s4, 24(sp)
    ld s3, 32(sp)
    ld s2, 40(sp)
    ld s1, 48(sp)
    ld ra, 56(sp)
    addi sp, sp, 64
    ret

# a0: address of data points
# a1: number of data points
update_centers:
    addi sp, sp, -64
    sd ra, 56(sp)
    sd s1, 48(sp)
    sd s2, 40(sp)
    sd s3, 32(sp)
    sd s4, 24(sp)
    sd s5, 16(sp)
    sd s6,  8(sp)

    # s1 counter of matches
    # s2 address of assignments
    # s3 address of points of current dim.
    # s4 address of centers
    # t0 cluster counter
    # t1 dimension counter
    # t2 points counter

    li t0, 0
    la s4, centers

# for all clusters
update_centers_loop:

    li t1, 0 # dim counter
# for all dimensions
update_centers_dim_loop:

    slli t6, t1, 2  # mul by 4
    add s3, a0, t6 

    li t2, 0
    la s2, assignments

    li s1, 0 # counter for matches 
    fcvt.s.w ft0, x0 # sum init with zero

# for all points loop
update_centers_points_loop:

# check assignment 
    add t4, s2, t2 
    lb t5, 0(t4)
    bne t0, t5, update_center_no_match
    # count divisor
    addi s1, s1, 1
    # add to sum
    flw ft1, 0(s3)
    fadd.s ft0, ft0, ft1

update_center_no_match:

# increment of points loop
    addi s3, s3, DIM*4
    addi t2, t2, 1
    blt t2, a1, update_centers_points_loop
# end of points loop

    slli t6, t1, 2 # mul by 4
    add t6, t6, s4

    # mean for current dim and update 
    fcvt.s.w ft1, s1
    fdiv.s ft1, ft0, ft1
    fsw ft1, 0(t6)

# increment for dim loop
    addi t1, t1, 1
    li t6, DIM
    blt t1, t6, update_centers_dim_loop
# end dim loop

# increments of end for all clusters
    addi s4, s4, DIM*4
    addi t0, t0, 1
    lw t6, nb_clusters
    blt t0, t6, update_centers_loop
# // end for all cluster

    ld s6,  8(sp)
    ld s5, 16(sp)
    ld s4, 24(sp)
    ld s3, 32(sp)
    ld s2, 40(sp)
    ld s1, 48(sp)
    ld ra, 56(sp)
    addi sp, sp, 64
    ret

.section .bss
.balign 4
nb_clusters:
.word 0
centers:
.skip 4*DIM*MAX_NB_CLUSTERS, 0
assignments:
.skip MAX_VALUES, 0