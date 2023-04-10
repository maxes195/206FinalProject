;|Final Project
;|-----------------------------
;|Created By:   Brennan Laing
;|Class:        ITSC 204
;|Date:         04/04/2023 
;|      x86-64, NASM
;|-----------------------------

struc sockaddr_in_type

    .sin_family:        resw 1
    .sin_port:          resw 1
    .sin_addr:          resd 1
    .sin_zero:          resd 2              
endstruc

global _start
section .text ; Stores instructions for the computer to follow

_start:
    call _connection.socket_created
    call _connection.connect


    call _connection.close


_connection:
    .socket_created:
        mov rax, 0x29                       ; socket syscall
        mov rdi, 0x02                       ; int domain - AF_INET = 2, AF_LOCAL = 1
        mov rsi, 0x01                       ; int type - SOCK_STREAM = 1
        mov rdx, 0x00                       ; int protocol is 0
        syscall
        
        cmp rax, -1
        je _messages.socket_failed
        mov qword [sock_fd], rax            ; takes the return of socket syscall (fd) and stores it in sock_fd 

        ret
    .connect:
        mov rax, 0x2A                       ; connect syscall
        mov rdi, qword [sock_fd]            ; file discriptor of the socket created in .socket_created
        mov rsi, sockaddr_in               ; struct for connection
        mov rdx, sockaddr_in_l             ; length of struct

        cmp rax, 0x0                        ; if RAX is not 0 then the connection has failed
        jne _messages.failed_connection
        ret

    .close:    
        mov rax, 0x3                        ; close syscall
        mov rdi, qword [sock_fd]            ; socket fd
        mov rsi, 0x2                        ; shuwdown RW
        syscall
        cmp rax, 0x0
        jne _end
        call _messages.socket_closed

_messages:
    .socket_failed:
        push socket_failed_l   
        push socket_failed_msg
        call _print
        jmp _end  

    .failed_connection:
        push failed_connection_l
        push failed_connection_msg
        call _print
        jmp _end

    .socket_closed:
        push socket_closed_l   
        push socket_closed_msg
        call _print
        jmp _end

      

_print:
    ; prologue
    push rbp
    mov rbp, rsp
    push rdi
    push rsi

    mov rax, 0x1
    mov rdi, 0x1
    mov rsi, [rbp + 0x10]
    mov rdx, [rbp + 0x18]
    syscall

    ; epilogue
    pop rsi
    pop rdi
    pop rbp
    ret 0x10                                ; clean up the stack upon return - not strictly following C Calling Convention

_end:
    mov rax, 0x3C
    mov rdi, 0x00
    syscall

section .data ; Where you declare and store data, static
    sockaddr_in: 
        istruc sockaddr_in_type 

            at sockaddr_in_type.sin_family,  dw 0x02            ;AF_INET -> 2 
            at sockaddr_in_type.sin_port,    dw 0x901F          ;(DEFAULT, passed on stack) port in hex and big endian order, 8080 -> 0x901F
            at sockaddr_in_type.sin_addr,    dd 0x0100007F      ;(DEFAULT) 00 -> any address, address 127.0.0.1 -> 0x0100007F

        iend
    sockaddr_in_l: equ $ - sockaddr_in

    ; messages
    socket_failed_msg: db "Socket creation failed.", 0xA, 0x0
    socket_failed_l: equ $ - socket_failed_msg
    failed_connection_msg: db "Failed to connect to server.", 0xA, 0x0
    failed_connection_l: equ $ - failed_connection_msg
    socket_closed_msg: db "Closed socket.", 0xA, 0x0
    socket_closed_l: equ $ - socket_closed_msg

section .bss
    sock_fd resq 1       ; file discriptor of the socket