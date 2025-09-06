	%macro imprimeEnPantalla 2
    	mov     rax, 1              ; syscall para sys_write (escribe)
    	mov     rdi, 1              ; Descriptor de archivo (1 para la salida estándar)
    	mov     rsi, %1             ; Puntero al mensaje
    	mov     rdx, %2             ; Longitud del mensaje
    	syscall                     ; Llama a la función sys_write
	%endmacro

%macro recibirEntrada
    xor rax, rax
    xor rsi, rsi 
    xor r11, r11    ;Longitud maxima del bufer
    xor rdi, rdi

 	mov rdi, 0          ; Descriptor de archivo estándar de entrada (stdin)
    mov rsi, buffer     ; Puntero al búfer que almacena la entrada
    mov r11, 6          ; Longitud  del búfer
    mov rax, 0          ; Código de la syscall para leer 
    syscall
    %endmacro

%macro reproducepunto

    syscall
    %endmacro

%macro reproduceraya

    syscall
    %endmacro