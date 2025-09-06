%include "macros.asm"
%include "palabras.asm"

section .data


section .bss
    palabramorse resb 28   ; Espacio para almacenar palabra a adivinar
    buffer resb 16   ; Espacio para almacenar entradas
    entrada resb 1    ; Reserva 1 byte para almacenar el carácter de entrada
section .text

global _start
_start:
    xor r10, r10    ;r10 va a almacenar el numero de iteracion que lleva la llamada
    xor r9, r9      ;r9 almacenara el numero de ascci de la letra a consultar

    recibirEntrada

    movzx r9, byte [buffer] ; Carga el primer carácter de la cadena
    sub   r9, '0'           ; Convierte el carácter ASCII en dígito decimal
    compararabecedario

