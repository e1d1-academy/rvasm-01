.equ STDIN, 0
.equ STDOUT, 1
.equ READ, 63
.equ WRITE, 64

.section .text
.globl write
write:
    # a1 expects address of string
    # a2 expect size of strings
    # a0, a1, a2 and a7 are caller saved
    # no need to save them here
    li a0, STDOUT
    li a7, WRITE
    ecall
    ret
.globl read
read:
    # a1 expects address of buffer
    # a2 expects size of string to read
    li a0, STDIN
    li a7, READ
    ecall
    ret


    
