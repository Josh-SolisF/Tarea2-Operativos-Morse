%macro imprimeEnPantalla 1
    ; Macro para imprimir cadena UCS-2 en UEFI
    mov rcx, [SystemTable]
    mov rcx, [rcx + 0x40]      ; ConOut pointer
    mov rdx, %1                ; Puntero a la cadena UCS-2
    mov rax, [rcx]             ; OutputString function pointer
    call rax
%endmacro

%macro recibirEntrada 2
    ; Macro para recibir entrada en UEFI (implementación simplificada)
    mov rcx, [SystemTable]
    mov rcx, [rcx + 0x38]      ; 
    mov rdx, buffer
    mov r8, 0
    
    %%leer_caracter:
        push rdx
        push rcx
        mov rax, [rcx]         ; ReadKeyStroke function pointer
        call rax               ; Leer tecla
        pop rcx
        pop rdx
        
        test rax, rax          ; Verificar si hay tecla disponible
        jnz %%leer_caracter
        
        ; Guardar caracter (simplificado)
        mov al, [rcx + 0x10]   ; El caracter está en el campo UnicodeChar
        mov [rdx + r8], al
        inc r8
        cmp r8, %2
        jl %%leer_caracter
    
    mov byte [rdx + r8], 0     ; Terminar cadena
%endmacro

%macro reproducepunto 0
    ; Reproducir punto 
    imprimeEnPantalla textpunto
%endmacro

%macro reproduceraya 0
    ; Reproducir raya 
    imprimeEnPantalla textraya
%endmacro

%macro reproduceespera 0
    ; Pausa entre letras 
    imprimeEnPantalla espacio
%endmacro