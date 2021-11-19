# bubbleSort(Array A)
#  for (n=A.size; n>1; --n){
#    for (i=0; i<n-1; ++i){
#      if (A[i] > A[i+1]){
#        A.swap(i, i+1)
#      } // Ende if
#    } // Ende innere for-Schleife
#  } // Ende äußere for-Schleife
.section .text
.globl bubblesort
bubblesort:
    addi sp, sp, -16
    sd ra, 8(sp)    

    mv t0, a1
#  for (n=A.size; n>1; --n){
# t0 for n   
loop0:
    li t2, 1
    ble t0, t2, loop0end

    mv t1, x0
#    for (i=0; i<n-1; ++i){
# t1 for i
loop1:
    addi t2, t0, -1
    bge t1, t2, loop1end

#      if (A[i] > A[i+1]){
    slli t2, t1, 2
    add t3, a0, t2
    lw t4, 0(t3)
    lw t5, 4(t3)
    ble t4, t5, noswap
    
#        A.swap(i, i+1)
    sw t4, 4(t3)
    sw t5, 0(t3)

noswap:
#      } // Ende if
    addi t1, t1, 1
    j loop1
#    } // Ende innere for-Schleife
loop1end:
    addi t0, t0, -1
    j loop0
#  } // Ende äußere for-Schleife
loop0end:

    ld ra, 8(sp)
    addi sp,sp, 16
    ret
