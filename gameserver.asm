section .data
	;; contants values
    SYS_WRITE equ 1 ;; equ means equate its like = sign
    SYS_SOCKET equ 41 ;; socket creation
	SYS_SETSOCKOPT equ 54 ;; reuse address
	SYS_BIND equ 49
	SYS_RECVFROM equ 45
	MSG_DONTWAIT equ 64

	;; variable values
	domain equ 2 ;; af_inet = 2
	type equ 2  ;; 1 SOCK_STREAM → TCP _ 2 SOCK_DGRAM → UDP
	protocol equ 0 ;; default value is 0
	optReuseAddr dd 1  ; int 1 for SO_REUSEADDR

	address: 
		dw 2 ;; AF_INET (domain)
	 	dw 0x911F  ;; port 8081
	  	dd 0 ;; IP address _ 0 is 0.0.0.0
	   	dq 0 ;; padding is 8 byte

	;; error messgs
	_socket_error_messg db "socket creation failed!"
	_reuseAddr_error_messg db "reuse Address has failed!"
	_recv_error_messg db "something went wrong with received data!"

	%macro socket 3
		mov rax, SYS_SOCKET
		mov rdi, %1
		mov rsi, %2
		mov rdx, %3
		syscall
	%endmacro

	;; reuse address after close
	%macro reuseAddr 2
		mov rax, SYS_SETSOCKOPT    	; SYS_SETSOCKOPT
		mov rdi, %1                	; socket fd
		mov rsi, 1                 	; SOL_SOCKET
		mov rdx, 2                 	; SO_REUSEADDR _ 2 means use address again
		mov r10, %2            		; pointer to int 1
		mov r8, 4                  	; length of int
		syscall
	%endmacro

	;; create bind
	%macro bind 2
		mov rax, SYS_BIND
		mov rdi, %1 ;; socket fd
		mov rsi, %2 
		mov rdx, 16
		syscall
	%endmacro

	;; receive data from socket
	%macro recvfrom 6
		mov rax, SYS_RECVFROM
		mov rdi, %1 ; socketfd
		mov rsi, %2 ; buffer pointer
		mov rdx, %3 ; buffer length
		mov r10, %4 ; flags _ 0 is default blocking
		mov r8, %5 ; src_addr
		mov r9, %6 ; addrlen
		syscall
	%endmacro

section .bss
	recvFromBuff resb 1024 ;; resb is reserved byte
	clientAddr resb 16      ; sockaddr_in
	addrLen    resd 1       ; socklen_t

section .text
    global main
main:
	;; create socket
    socket domain, type, protocol
	;; check socket for errors
	cmp rax, 0
	jl _socket_error ;; jump less if r12 < 0 to _socket_error

	mov r12, rax

	reuseAddr r12, optReuseAddr ;; reuse address after close
	;; check reuseAddr for errors
	cmp rax, 0
	jl _reuseAddr_error ;; jump less if rax < 0 to _reuseAddr_error

	bind r12, address ;; bind macro

_loop:
	recvfrom r12, recvFromBuff, 1024, 0, 0, 0 ;; last 3 params could be left 0
	
	cmp rax, 0
	jl _recv_error

	jmp _loop
	
_socket_error:
	mov rax, SYS_WRITE
	mov rdi, 1
	mov rsi, _socket_error_messg
	mov rdx, 23
	syscall
	jmp _exit

_reuseAddr_error:
	mov rax, SYS_WRITE
	mov rdi, 1
	mov rsi, _reuseAddr_error_messg
	mov rdx, 25
	syscall
	jmp _exit

_recv_error:
	mov rax, SYS_WRITE
	mov rdi, 1
	mov rsi, _recv_error_messg
	mov rdx, 40
	syscall
	jmp _exit

_exit:
	mov rax, 60
	mov rdi, 69 ;; exit code 69 is optional code
	syscall