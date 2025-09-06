format pe64 efi
entry efi_main

%include "abc.asm"

section '.data' data readable writeable
    textbienvenida du "ingrese palabra", 13, 10, 13, 10, 0  ; Cadena UCS-2 con dos saltos de línea
    espacio du 13, 10, 0  ; Salto de línea para separar letras

section '.bss' data readable writeable
    buffer resb 64   ; Espacio para almacenar entradas
    entrada_len resb 1 ; Para almacenar la longitud de la entrada

section '.text' code executable readable

efi_main:
    ; Parámetros vienen en RCX (ImageHandle) y RDX (SystemTable)
    mov [ImageHandle], rcx
    mov [SystemTable], rdx
    
    ; Imprimir mensaje de bienvenida
    imprimeEnPantalla textbienvenida
    
    ; Recibir entrada del usuario
    recibirEntrada buffer, 64

    xor r10, r10    ; r10 va a almacenar el numero de iteracion que lleva la llamada
    mov r8, buffer  ; r8 apunta al buffer de entrada

iterar_caracter:
    mov al, [r8 + r10]
    test al, al          ; Verificar fin de cadena
    jz exit
    cmp al, 13          ; Verificar si es enter 
    je exit

    mov r9b, al          ; Guardar carácter actual en r9b
    call convertir_morse ; Llamar a función de conversión
    reproduceespera      ; Espacio entre caracteres
    
    inc r10
    jmp iterar_caracter

exit:
    mov eax, 0          ; EFI exitoso
    retn

; Variables globales
ImageHandle dq 0
SystemTable dq 0