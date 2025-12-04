
section .data
    SYS_READ equ 0
    SYS_WRITE equ 1 

    gamerChar db "@"
    mountainChar db "^^^"
    castleChar db "(----)"
    borderUpDownStructChar db "___"
    borderLeftRightStructChar db "|"
    upArrow db 0x1B, 0x5B, 0x41   ; ESC [ A
    downArrow db 0x1B, 0x5B, 0x42 ; ESC [ B
    leftArrow db 0x1B, 0x5B, 0x44 ; ESC [ D
    rightArrow db 0x1B, 0x5B, 0x43; ESC [ C

    %macro showMap 1
        mov rax, SYS_WRITE
        mov rdi, 1
        mov rsi, %1
        mov rdx, 250000
        syscall
    %endmacro

    %macro pressKey 1
        mov rax, SYS_READ     
        mov rdi, 0      
        lea rsi, [%1]
        mov rdx, 3      
        syscall
    %endmacro

section .bss
   map resb 10000 ;; 100x100 bytes space 
   keyboard resb 3

section .text
    global main
    ;global _gamer ;; must be global to access in extern usage
    ;global _mountain
    ;global _castle
main: 
    jmp _mapinit
_mapinit:
    ;; map initialization
    mov rcx, 10000
    mov al, " "
    lea rdi, [map]
    rep stosb ;; fill every byte of map with space n times, reduct rcx from 10k to 0 

    ;; initial position of gamer
    mov al, [gamerChar] ;; use al (1 byte for 1 byte chars)
    mov [map+9998], al

    showMap map

    pressKey keyboard

    lea rsi, [keyboard]
    lea rdi, [upArrow]
    mov rcx, 3
    repe cmpsb
    je _showmap

    jmp _exit

_showmap:
    
    jmp _exit
_exit:
	mov rax, 60
	mov rdi, 69 ;; exit code 69 is optional code
	syscall    


