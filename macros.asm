%macro imprimeEnPantalla 1
    mov rcx, [SystemTable]
    mov rcx, [rcx + 0x40]
    mov rdx, %1
    mov rax, [rcx]
    call rax
%endmacro

%macro recibirEntrada 2
    mov rcx, [SystemTable]
    mov rcx, [rcx + 0x38]
    mov rdx, buffer
    mov r8, 0
%%leer_caracter:
    push rdx
    push rcx
    mov rax, [rcx]
    call rax
    pop rcx
    pop rdx
    test rax, rax
    jnz %%leer_caracter
    mov al, [rcx + 0x10]
    mov [rdx + r8], al
    inc r8
    cmp r8, %2
    jl %%leer_caracter
    mov byte [rdx + r8], 0
%endmacro

%macro reproducepunto 0
    imprimeEnPantalla textpunto
%endmacro

%macro reproduceraya 0
    imprimeEnPantalla textraya
%endmacro

%macro reproduceespera 0
    imprimeEnPantalla espacio
%endmacro