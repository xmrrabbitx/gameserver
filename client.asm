section .data
	;; contants values
    SYS_WRITE equ 1 ;; equ means equate its like = sign
    SYS_SOCKET equ 41 ;; socket creation
	SYS_SENDTO equ 44
	MSG_DONTWAIT equ 64

	;; variable values
	domain equ 2 ;; af_inet = 2
	type equ 2  ;; 1 SOCK_STREAM → TCP _ 2 SOCK_DGRAM → UDP
	protocol equ 0 ;; default value is 0

	address: 
		dw 2 ;; AF_INET (domain)
	 	dw 0x911F  ;; port 8081
	  	dd 0 ;; IP address _ 0 is 0.0.0.0
	   	dq 0 ;; padding is 8 byte

	;; error messgs
	_socket_error_messg db "socket creation failed!"
	_sendto_error_messg db "something went wrong with sending data!"
    _testData db "test data from client"
    _testData_length equ $ - _testData

	%macro socket 3
		mov rax, SYS_SOCKET
		mov rdi, %1
		mov rsi, %2
		mov rdx, %3
		syscall
	%endmacro

	;; send data to socket
	%macro sendto 6
		mov rax, SYS_SENDTO
		mov rdi, %1 ; socketfd
		mov rsi, %2 ; buffer pointer
		mov rdx, %3 ; buffer length
		mov r10, %4 ; flags _ 0 is default blocking
		mov r8, %5 ; src_addr
		mov r9, %6 ; addrlen
		syscall
	%endmacro

section .bss
	sendtoBuff resb 1024 ;; resb is reserved byte
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

    ;; assign data to sendtoBuff
    mov rcx, _testData_length
    lea rsi, [_testData]
    lea rdi, [sendtoBuff]
    rep movsb

	sendto r12, sendtoBuff, 1024, 0, address, 16 ;; last 3 params could be left 0
	
	cmp rax, 0
	jl _sendto_error
    
    jmp _exit
	
_socket_error:
	mov rax, SYS_WRITE
	mov rdi, 1
	mov rsi, _socket_error_messg
	mov rdx, 23
	syscall
    jmp _exit

_sendto_error:
	mov rax, SYS_WRITE
	mov rdi, 1
	mov rsi, _sendto_error_messg
	mov rdx, 39
	syscall
    jmp _exit

_exit:
	mov rax, 60
	mov rdi, 69 ;; exit code 69 is optional code
	syscall