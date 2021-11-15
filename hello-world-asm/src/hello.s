.section .text
.globl  _start
_start:
        li      a0, 1
        la      a1, msgbegin 
        lbu     a2, msgsize 
        li      a7, 64
        ecall
        li      a7, 93
        ecall

.section .rodata
msgbegin:
.ascii  "Hello World!\n"
msgsize:
.byte   .-msgbegin
