%include "abc.asm"

section .data
    textbienvenida db "ingrese palabra",10,10 ; 16 caracteres incluyendo los dos saltos de línea
    espacio db 10   ; Espacio para separar letras

section .bss
    buffer resb 64   ; Espacio para almacenar entradas
    entrada_len resb 1 ; Para almacenar la longitud de la entrada



section .text
global _start

_start: 

    imprimeEnPantalla textbienvenida, 16 

    recibirEntrada buffer, 64

    xor r10, r10    ;r10 va a almacenar el numero de iteracion que lleva la llamada
    xor r9, r9      ;r9 almacenara el numero de ascci de la letra a consultar
    mov r8, buffer



iterar_caracter:
    mov al, [r8 + r10]
    test al, al          ; Verificar fin de cadena
    jz exit
    cmp al, 10          ; Verificar si es salto de línea (Enter)
    je exit


    mov r9b, al          ; Guardar carácter actual en r9b
    call convertir_morse ; Llamar a función de conversión
    reproduceespera   ; Espacio entre caracteres
    
    inc r10
    jmp iterar_caracter

exit:
    mov rax, 60         ; sys_exit
    xor rdi, rdi
    syscall
