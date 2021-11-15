.section .text
.globl ascii2uint32
ascii2uint32:
    # a0: source pointer for ascii 
    # a1: dest pointer for uint32
    # a2: number of ascii chars
    # allocate stack space, align multiple of 16
    addi sp, sp, -16
    sw ra, 0(sp)


    # process the ascii string from back
    add a0, a0, a2
    # counter
    mv t2, a2
au_loop:
    # while t2 > 0
    blez t2, au_end
    # t2--
    addi t2, t2, -1

    # a0--
    addi a0, a0, -1
    # (a0) to t0 (read)
    lb t0, 0(a0)

    # convert first nibble
    call au_nibble
    mv t1, t0

    # end if t2 is counted down
    beqz t2, 1f
    # decrement 
    addi t2, t2, -1
    # decrement pointer
    addi a0, a0, -1
    # load ascii (a0) to t0
    lb t0, 0(a0)
    # convert 
    call au_nibble

    # shift nibble 
    slli t0, t0, 4
    # combine nibble
    or t0, t1, t0

1:
    # t0 to (a1) (write)
    sb t0, 0(a1)
    # a1++
    addi a1, a1, 1
    j au_loop
au_end:
    lw ra, 0(sp)
    addi sp, sp, 16
    ret

au_nibble:
    addi t0, t0, -0x30
    li t3, 0x10
    blt t0, t3, au_nibble_09
    addi t0, t0, -0x07
au_nibble_09:
    ret

.globl uint32ascii
uint32ascii:
    # allocate stack space, align multiple of 16
    addi sp, sp, -32
    sw ra, 16(sp)

    # put chars on stack
    # we use 0(sp) to 15(sp), use t2
    addi t2, sp, 15
    # store begin of our mem. stack in t4
    mv t4, t2

    # base is 10
    li t0, 10

ua_loop:
    # end if a0 is zero
    beqz a0, ua_pop
    # get remainder
    remu t1, a0, t0
    # next a0 = a0 / t0
    divu a0, a0, t0

    # to ascii
    addi t1, t1, 0x30
    # push 
    sb t1, 0(t2)
    # decrement -1
    addi t2, t2, -1
    j ua_loop

ua_pop:
    # correct pointer 
    addi t2, t2, 1
    # check if our stack is empty
    bgt t2, t4, ua_end
    lb t1, 0(t2)
    sb t1, 0(a1)
    addi a1, a1, 1
    j ua_pop
ua_end:
    lw ra, 16(sp)
    addi sp, sp, 32
    ret