[BITS 64]
; morse.asm - Punto de entrada para UEFI
org 0x0

%include "macros.asm"
%include "abc.asm"

section .text
efi_main:
    mov [ImageHandle], rcx
    mov [SystemTable], rdx
    imprimeEnPantalla textbienvenida
    recibirEntrada buffer, 64
    xor r10, r10
    mov r8, buffer
.iterar:
    mov al, [r8 + r10]
    test al, al
    jz .exit
    cmp al, 13
    je .exit
    mov r9b, al
    call convertir_morse
    reproduceespera
    inc r10
    jmp .iterar
.exit:
    mov eax, 0
    retn

section .data
textbienvenida: 
    dw __utf16__('ingrese palabra'), 13, 10, 13, 10, 0
espacio:
    dw 13, 10, 0

section .bss
ImageHandle: resq 1
SystemTable: resq 1
buffer: resb 64
entrada_len: resb 1