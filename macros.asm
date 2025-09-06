%macro imprimeEnPantalla 2
   	mov     rax, 1              ; syscall para sys_write (escribe)
   	mov     rdi, 1              ; Descriptor de archivo (1 para la salida estándar)
   	mov     rsi, %1             ; Puntero al mensaje
   	mov     rdx, %2             ; Longitud del mensaje
   	syscall                     ; Llama a la función sys_write
%endmacro

%macro recibirEntrada 2
    mov rax, 0          ; sys_read
    mov rdi, 0          ; stdin
    mov rsi, %1         ; buffer
    mov rdx, %2         ; longitud
    syscall
    mov [entrada_len], rax ; guardar longitud de entrada
%endmacro

%macro reproducepunto 0
    imprimeEnPantalla textpunto, 2
    
%endmacro

%macro reproduceraya 0
    imprimeEnPantalla textraya, 2
%endmacro