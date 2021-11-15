.equ EXIT, 93
.equ dec_number_size, 11
.equ uint32_string_size, 8

.section .text
.globl _start
_start:

# print prompt 
    la a1, prompt_msg
    lbu a2, prompt_size
    call write

# input number in hex
    la a1, dec_conv
    li a2, uint32_string_size
    call read

# discard carriage return in case of fewer characters
# if a0 == uint32_string_size then a0--
    la t0, uint32_string_size
    beq a0, t0, 1f
    addi a0, a0, -1
1:

# convert hex to dec
    mv a2, a0
    la a0, dec_conv
    la a1, hex_value
    call ascii2uint32
    lwu a0, hex_value
    la a1, dec_conv
    call uint32ascii

# print result
    la a1, dec_msg
    lbu a2, dec_size
    call write

# exit
    li  a0, 0
    li  a7, EXIT
    ecall 

.section .rodata
prompt_msg:
.ascii "Hex?: "
prompt_size:
.byte .-prompt_msg

.section .data
dec_msg:
.ascii "Dec: "
dec_conv:
.skip dec_number_size, 0
dec_size:
.byte .-dec_msg

.section .bss
hex_value:
.skip 4,0
