;|Final Project
;|-----------------------------
;|Created By:   Brennan Laing
;|Class:        ITSC 204
;|Date:         04/04/2023 
;|      x86-64, NASM
;|-----------------------------

struc sockaddr_out_type

    .sin_family:        resw 1
    .sin_port:          resw 1
    .sin_addr:          resd 1
    .sin_zero:          resd 2              
endstruc

global _start
section .text ; Stores instructions for the computer to follow

_start:


_init:
    mov rax, 0x29                       ; socket syscall
    mov rdi, 0x02                       ; int domain - AF_INET = 2, AF_LOCAL = 1
    mov rsi, 0x01                       ; int type - SOCK_STREAM = 1
    mov rdx, 0x00                       ; int protocol is 0
    syscall
    


_end:
    mov rax, 0x3C
    mov rdi, 0x00
    syscall

section .data ; Where you declare and store data, static
    sockaddr_out: 
        istruc sockaddr_out_type 

            at sockaddr_out_type.sin_family,  dw 0x02            ;AF_INET -> 2 
            at sockaddr_out_type.sin_port,    dw 0x901F          ;(DEFAULT, passed on stack) port in hex and big endian order, 8080 -> 0x901F
            at sockaddr_out_type.sin_addr,    dd 0x00            ;(DEFAULT) 00 -> any address, address 127.0.0.1 -> 0x0100007F

        iend
    sockaddr_out_l: equ $ - sockaddr_out