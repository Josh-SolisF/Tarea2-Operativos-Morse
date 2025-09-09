; - Usa UEFI ConIn para leer las letras y las mete en búfer hasta toparse con ENTER.
; - Al presionar ENTER, imprime en morse la línea completa y reinicia la entrada.
;


%define EXITO_EFI                 0

; Desplazamientos en EFI_SYSTEM_TABLE (x64) relevantes
%define DESPLAZAMIENTO_TABLA_SISTEMA_EFI_EntradaCon        0x30 ;codigo del protocolo de entrada 
%define DESPLAZAMIENTO_TABLA_SISTEMA_EFI_SalidaCon         0x40 ;codigo del protocolo de salida 

; EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL
%define DESPLAZAMIENTO_STO_Reinicio                       0x00  ;Para reiniciar la consola 
%define DESPLAZAMIENTO_STO_CadenaSalida                   0x08  ;Para imprimir el String 

; EFI_SIMPLE_TEXT_INPUT_PROTOCOL
%define DESPLAZAMIENTO_SIN_Reinicio                       0x00  ;Para resetear la entrada
%define DESPLAZAMIENTO_SIN_LeerTecla                      0x08  ;Para leer la tecla

; Códigos de control
%define CARACTER_RETORNO                                  0x000D   ; Enter

%define MAX_BUF                                          512      ; Es la cantidad de bytes máximo del búfer

; Macros que imprimen el punto y la rata
%macro REPRODUCIR_PUNTO 0
    mov     rcx, rbx                                    ;RCX = Para el protocolo de salida del output 
    lea     rdx, [rel caracter_punto]                   ;RDX para la dirección del String y le metemos el punto
    mov     r11, [rbx + DESPLAZAMIENTO_STO_CadenaSalida];Para poder agarrar la funcion para imprimir
    call    r11                                         ;función de la salida 
%endmacro

%macro REPRODUCIR_RAYA 0
    mov     rcx, rbx                                    ;RCX = Para el protocolo de salida del output 
    lea     rdx, [rel caracter_raya]                    ;RDX para la dirección del String y le metemos la raya
    mov     r11, [rbx + DESPLAZAMIENTO_STO_CadenaSalida];Para poder agarrar la funcion para imprimir
    call    r11                                         ;función de la salida
%endmacro

default rel
extern  __chkstk

section .text
align 16
global  efi_main


; EFI principal_efi
efi_main:
    sub     rsp, 32                                    ;Reservar el campo para alinear las llamads 
    mov     rsi, rdx                                   ; Guardar TablaSistema en RSI que antes estaba en RDX


    ; Inicializar SalidaCon/EntradaCon
    mov     rbx, [rsi + DESPLAZAMIENTO_TABLA_SISTEMA_EFI_SalidaCon] ; rbx = va tener el protocolo de salida 
    mov     rdi, [rsi + DESPLAZAMIENTO_TABLA_SISTEMA_EFI_EntradaCon] ; RDI = va tener el protocolo de entrada 

    ; Reiniciar la consola de salida 
    mov     rcx, rbx                                ; Primer parámetro: protocolo de salida
    xor     rdx, rdx                                ; Segundo parámetro: NULL
    mov     r11, [rbx + DESPLAZAMIENTO_STO_Reinicio]; Obtener función de reset
    call    r11                                     ; Llamar a la función

    ; Reiniciar consola de entrada (limpiar búfer que va a tener la entrada del teclado)
    mov     rcx, rdi                   ; Primer parámetro: protocolo de entrada
    xor     rdx, rdx                   ; Segundo parámetro: NULL
    mov     r11, [rdi + DESPLAZAMIENTO_SIN_Reinicio] ; Obtener función de reset
    call    r11                        ; Llamar a la función

    ; Mostrar mensaje de bienvenida
    mov     rcx, rbx                   ; Protocolo de salida
    lea     rdx, [rel cadena_inicio]   ; Cadena de bienvenida
    mov     r11, [rbx + DESPLAZAMIENTO_STO_CadenaSalida] ; Función de impresión
    call    r11                        ; Imprimir mensaje

    ;Vamos a ponerle registros a las variables
    ;r12 va a tener la dirección del bufer 
    ;r13 va a tener la dirección de la longitud actual

    lea     r12, [rel búfer_línea]     ; Cargar dirección del búfer
    xor     r13, r13                   ; Inicializar contador de caracteres a 0

.prompt:
    ; Mostrar prompt de entrada (">> ")
    mov     rcx, rbx                   ; Protocolo de salida
    lea     rdx, [rel cadena_prompt]   ; Cadena del prompt
    mov     r11, [rbx + DESPLAZAMIENTO_STO_CadenaSalida] ; Función de impresión
    call    r11                        ; Imprimir prompt

.bucle_lectura:
    ; Leer una tecla del servicio de entrada
    mov     rcx, rdi                   ; Protocolo de entrada
    lea     rdx, [rel búfer_tecla]     ; Búfer donde se almacenará la tecla
    mov     r11, [rdi + DESPLAZAMIENTO_SIN_LeerTecla] ; Función de lectura
    call    r11                        ; Leer tecla
    test    rax, rax                   ; Verificar si hubo error (RAX != 0)
    jnz     .bucle_lectura             ; Reintentar si hay error

    ; Analizar la tecla presionada
    movzx   eax, word [búfer_tecla + 0] ; Cargar ScanCode
    movzx   edx, word [búfer_tecla + 2] ; Cargar UnicodeChar


; Verificar si se presionó ENTER (procesar línea)
    cmp     dx, CARACTER_RETORNO
    je      .procesar_linea


    ; Ignorar teclas sin carácter Unicode (teclas especiales)
    test    dx, dx
    jz      .bucle_lectura

    ; Verificar si el búfer está lleno
    cmp     r13, MAX_BUF-1
    jae     .beep_o_ignorar                            ; ignorar si esta lleno

    ; Guardar char en el búfer (UTF-16)
    mov     [r12 + r13*2], dx          ; Guardar carácter en posición actual
    inc     r13                        ; Incrementar contador de caracteres
    jmp     .bucle_lectura             ; Continuar lectura



.procesar_linea:
    ; Terminar la cadena con NULL (UTF-16)
    mov     word [r12 + r13*2], 0      ; Agregar terminador nulo

    ; Imprimir la línea ingresada (para retroalimentación)
    mov     rcx, rbx                   ; Protocolo de salida
    lea     rdx, [rel búfer_línea]     ; Cadena a imprimir
    mov     r11, [rbx + DESPLAZAMIENTO_STO_CadenaSalida] ; Función de impresión
    call    r11                        ; Imprimir línea

    ; Imprimir salto de línea
    mov     rcx, rbx                   ; Protocolo de salida
    lea     rdx, [rel cadena_nueva_linea] ; Caracteres de nueva línea
    mov     r11, [rbx + DESPLAZAMIENTO_STO_CadenaSalida] ; Función de impresión
    call    r11                        ; Imprimir nueva línea

    ;Hacer cada caracter de bufer a morse
    ; En este caso r14 va a indicar el índice del carácter actual

    xor     r14, r14               ; Inicializar índice i a 0

.bucle_iteracion:
    cmp     r14, r13                   ; Verificar si se procesaron todos los caracteres
    jae     .despues_iteracion         ; Salir del bucle si es así

    ; Cargar carácter actual del búfer
    movzx   edx, word [r12 + r14*2]    ; Cargar carácter UTF-16
    inc     r14                        ; Incrementar índice para siguiente carácter

    ; Comparar con cada letra/número y saltar a su conversión Morse
    ; (Se omiten las comparaciones por brevedad, pero cada bloque REPRODUCIR_* 
    ; corresponde a la representación Morse del carácter)
    cmp     dx, 'a'
    je      .imprimir_para_a
    cmp     dx, 'A'
    je      .imprimir_para_a

    cmp     dx, 'b'
    je      .imprimir_para_b
    cmp     dx, 'B'
    je      .imprimir_para_b

    cmp     dx, 'c'
    je      .imprimir_para_c
    cmp     dx, 'C'
    je      .imprimir_para_c

    cmp     dx, 'd'
    je      .imprimir_para_d
    cmp     dx, 'D'
    je      .imprimir_para_d

    cmp     dx, 'e'
    je      .imprimir_para_e
    cmp     dx, 'E'
    je      .imprimir_para_e

    cmp     dx, 'f'
    je      .imprimir_para_f
    cmp     dx, 'F'
    je      .imprimir_para_f

    cmp     dx, 'g'
    je      .imprimir_para_g
    cmp     dx, 'G'
    je      .imprimir_para_g

    cmp     dx, 'h'
    je      .imprimir_para_h
    cmp     dx, 'H'
    je      .imprimir_para_h

    cmp     dx, 'i'
    je      .imprimir_para_i
    cmp     dx, 'I'
    je      .imprimir_para_i

    cmp     dx, 'j'
    je      .imprimir_para_j
    cmp     dx, 'J'
    je      .imprimir_para_j

    cmp     dx, 'k'
    je      .imprimir_para_k
    cmp     dx, 'K'
    je      .imprimir_para_k

    cmp     dx, 'l'
    je      .imprimir_para_l
    cmp     dx, 'L'
    je      .imprimir_para_l

    cmp     dx, 'm'
    je      .imprimir_para_m
    cmp     dx, 'M'
    je      .imprimir_para_m

    cmp     dx, 'n'
    je      .imprimir_para_n
    cmp     dx, 'N'
    je      .imprimir_para_n

    cmp     dx, 'o'
    je      .imprimir_para_o
    cmp     dx, 'O'
    je      .imprimir_para_o

    cmp     dx, 'p'
    je      .imprimir_para_p
    cmp     dx, 'P'
    je      .imprimir_para_p

    cmp     dx, 'q'
    je      .imprimir_para_q
    cmp     dx, 'Q'
    je      .imprimir_para_q

    cmp     dx, 'r'
    je      .imprimir_para_r
    cmp     dx, 'R'
    je      .imprimir_para_r

    cmp     dx, 's'
    je      .imprimir_para_s
    cmp     dx, 'S'
    je      .imprimir_para_s

    cmp     dx, 't'
    je      .imprimir_para_t
    cmp     dx, 'T'
    je      .imprimir_para_t

    cmp     dx, 'u'
    je      .imprimir_para_u
    cmp     dx, 'U'
    je      .imprimir_para_u

    cmp     dx, 'v'
    je      .imprimir_para_v
    cmp     dx, 'V'
    je      .imprimir_para_v

    cmp     dx, 'w'
    je      .imprimir_para_w
    cmp     dx, 'W'
    je      .imprimir_para_w

    cmp     dx, 'x'
    je      .imprimir_para_x
    cmp     dx, 'X'
    je      .imprimir_para_x

    cmp     dx, 'y'
    je      .imprimir_para_y
    cmp     dx, 'Y'
    je      .imprimir_para_y

    cmp     dx, 'z'
    je      .imprimir_para_z
    cmp     dx, 'Z'
    je      .imprimir_para_z

    cmp     dx, '0'
    je      .imprimir_para_0

    cmp     dx, '1'
    je      .imprimir_para_1

    cmp     dx, '2'
    je      .imprimir_para_2

    cmp     dx, '3'
    je      .imprimir_para_3

    cmp     dx, '4'
    je      .imprimir_para_4

    cmp     dx, '5'
    je      .imprimir_para_5

    cmp     dx, '6'
    je      .imprimir_para_6

    cmp     dx, '7'
    je      .imprimir_para_7

    cmp     dx, '8'
    je      .imprimir_para_8

    cmp     dx, '9'
    je      .imprimir_para_9
    ; Si no es un carácter válido, continuar con el siguiente
    jmp     .bucle_iteracion


; Bloques de conversión Morse para cada carácter
; Cada bloque llama a los macros REPRODUCIR_PUNTO/RAYA según el código Morse
; y luego salta a .imprimir_espacio para separar caracteres

.imprimir_para_a:
    REPRODUCIR_PUNTO
    REPRODUCIR_RAYA
    jmp     .imprimir_espacio

.imprimir_para_b:
    REPRODUCIR_RAYA
    REPRODUCIR_PUNTO
    REPRODUCIR_PUNTO
    REPRODUCIR_PUNTO
    jmp     .imprimir_espacio

.imprimir_para_c:
    REPRODUCIR_RAYA
    REPRODUCIR_PUNTO
    REPRODUCIR_RAYA
    REPRODUCIR_PUNTO
    jmp     .imprimir_espacio

.imprimir_para_d:
    REPRODUCIR_RAYA
    REPRODUCIR_PUNTO
    REPRODUCIR_PUNTO
    jmp     .imprimir_espacio

.imprimir_para_e:
    REPRODUCIR_PUNTO
    jmp     .imprimir_espacio

.imprimir_para_f:
    REPRODUCIR_PUNTO
    REPRODUCIR_PUNTO
    REPRODUCIR_RAYA
    REPRODUCIR_PUNTO
    jmp     .imprimir_espacio

.imprimir_para_g:
    REPRODUCIR_RAYA
    REPRODUCIR_RAYA
    REPRODUCIR_PUNTO
    jmp     .imprimir_espacio

.imprimir_para_h:
    REPRODUCIR_PUNTO
    REPRODUCIR_PUNTO
    REPRODUCIR_PUNTO
    REPRODUCIR_PUNTO
    jmp     .imprimir_espacio

.imprimir_para_i:
    REPRODUCIR_PUNTO
    REPRODUCIR_PUNTO
    jmp     .imprimir_espacio

.imprimir_para_j:
    REPRODUCIR_PUNTO
    REPRODUCIR_RAYA
    REPRODUCIR_RAYA
    REPRODUCIR_RAYA
    jmp     .imprimir_espacio

.imprimir_para_k:
    REPRODUCIR_RAYA
    REPRODUCIR_PUNTO
    REPRODUCIR_RAYA
    jmp     .imprimir_espacio

.imprimir_para_l:
    REPRODUCIR_PUNTO
    REPRODUCIR_RAYA
    REPRODUCIR_PUNTO
    REPRODUCIR_PUNTO
    jmp     .imprimir_espacio

.imprimir_para_m:
    REPRODUCIR_RAYA
    REPRODUCIR_RAYA
    jmp     .imprimir_espacio

.imprimir_para_n:
    REPRODUCIR_RAYA
    REPRODUCIR_PUNTO
    jmp     .imprimir_espacio

.imprimir_para_o:
    REPRODUCIR_RAYA
    REPRODUCIR_RAYA
    REPRODUCIR_RAYA
    jmp     .imprimir_espacio

.imprimir_para_p:
    REPRODUCIR_PUNTO
    REPRODUCIR_RAYA
    REPRODUCIR_RAYA
    REPRODUCIR_PUNTO
    jmp     .imprimir_espacio

.imprimir_para_q:
    REPRODUCIR_RAYA
    REPRODUCIR_RAYA
    REPRODUCIR_PUNTO
    REPRODUCIR_RAYA
    jmp     .imprimir_espacio

.imprimir_para_r:
    REPRODUCIR_PUNTO
    REPRODUCIR_RAYA
    REPRODUCIR_PUNTO
    jmp     .imprimir_espacio

.imprimir_para_s:
    REPRODUCIR_PUNTO
    REPRODUCIR_PUNTO
    REPRODUCIR_PUNTO
    jmp     .imprimir_espacio

.imprimir_para_t:
    REPRODUCIR_RAYA
    jmp     .imprimir_espacio

.imprimir_para_u:
    REPRODUCIR_PUNTO
    REPRODUCIR_PUNTO
    REPRODUCIR_RAYA
    jmp     .imprimir_espacio

.imprimir_para_v:
    REPRODUCIR_PUNTO
    REPRODUCIR_PUNTO
    REPRODUCIR_PUNTO
    REPRODUCIR_RAYA
    jmp     .imprimir_espacio

.imprimir_para_w:
    REPRODUCIR_PUNTO
    REPRODUCIR_RAYA
    REPRODUCIR_RAYA
    jmp     .imprimir_espacio

.imprimir_para_x:
    REPRODUCIR_RAYA
    REPRODUCIR_PUNTO
    REPRODUCIR_PUNTO
    REPRODUCIR_RAYA
    jmp     .imprimir_espacio

.imprimir_para_y:
    REPRODUCIR_RAYA
    REPRODUCIR_PUNTO
    REPRODUCIR_RAYA
    REPRODUCIR_RAYA
    jmp     .imprimir_espacio

.imprimir_para_z:
    REPRODUCIR_RAYA
    REPRODUCIR_RAYA
    REPRODUCIR_PUNTO
    REPRODUCIR_PUNTO
    jmp     .imprimir_espacio

.imprimir_para_0:
    REPRODUCIR_RAYA
    REPRODUCIR_RAYA
    REPRODUCIR_RAYA
    REPRODUCIR_RAYA
    REPRODUCIR_RAYA
    jmp     .imprimir_espacio

.imprimir_para_1:
    REPRODUCIR_PUNTO
    REPRODUCIR_RAYA
    REPRODUCIR_RAYA
    REPRODUCIR_RAYA
    REPRODUCIR_RAYA
    jmp     .imprimir_espacio

.imprimir_para_2:
    REPRODUCIR_PUNTO
    REPRODUCIR_PUNTO
    REPRODUCIR_RAYA
    REPRODUCIR_RAYA
    REPRODUCIR_RAYA
    jmp     .imprimir_espacio

.imprimir_para_3:
    REPRODUCIR_PUNTO
    REPRODUCIR_PUNTO
    REPRODUCIR_PUNTO
    REPRODUCIR_RAYA
    REPRODUCIR_RAYA
    jmp     .imprimir_espacio

.imprimir_para_4:
    REPRODUCIR_PUNTO
    REPRODUCIR_PUNTO
    REPRODUCIR_PUNTO
    REPRODUCIR_PUNTO
    REPRODUCIR_RAYA
    jmp     .imprimir_espacio

.imprimir_para_5:
    REPRODUCIR_PUNTO
    REPRODUCIR_PUNTO
    REPRODUCIR_PUNTO
    REPRODUCIR_PUNTO
    REPRODUCIR_PUNTO
    jmp     .imprimir_espacio

.imprimir_para_6:
    REPRODUCIR_RAYA
    REPRODUCIR_PUNTO
    REPRODUCIR_PUNTO
    REPRODUCIR_PUNTO
    REPRODUCIR_PUNTO
    jmp     .imprimir_espacio

.imprimir_para_7:
    REPRODUCIR_RAYA
    REPRODUCIR_RAYA
    REPRODUCIR_PUNTO
    REPRODUCIR_PUNTO
    REPRODUCIR_PUNTO
    jmp     .imprimir_espacio

.imprimir_para_8:
    REPRODUCIR_RAYA
    REPRODUCIR_RAYA
    REPRODUCIR_RAYA
    REPRODUCIR_PUNTO
    REPRODUCIR_PUNTO
    jmp     .imprimir_espacio

.imprimir_para_9:
    REPRODUCIR_RAYA
    REPRODUCIR_RAYA
    REPRODUCIR_RAYA
    REPRODUCIR_RAYA
    REPRODUCIR_PUNTO
    jmp     .imprimir_espacio


.imprimir_espacio:
    ; Imprimir espacio entre caracteres Morse
    mov     rcx, rbx                   ; Protocolo de salida
    lea     rdx, [rel caracter_espacio] ; Espacio
    mov     r11, [rbx + DESPLAZAMIENTO_STO_CadenaSalida] ; Función de impresión
    call    r11                        ; Imprimir espacio
    jmp     .bucle_iteracion           ; Continuar con próximo carácter

.despues_iteracion:
    ; Reiniciar el búfer para nueva entrada
    xor     r13, r13                   ; Resetear contador de caracteres
    jmp     .prompt                    ; Volver a mostrar prompt

.beep_o_ignorar:
    ; Podría añadirse un beep aquí para indicar error
    jmp     .bucle_lectura             ; Continuar lectura



section .data
align 2
cadena_inicio:     dw 'P','a','l','a','b','r','a',' ','m','o','r','s','e','!','!',' ',':',13,10,0
caracter_punto:    dw '.', 0
caracter_raya:     dw '-', 0
caracter_espacio:  dw ' ', 0

cadena_prompt:     dw '/', '/',' ', 0
cadena_nueva_linea: dw 13,10,0

section .bss
align 2
búfer_tecla:                ; Estructura para almacenar tecla (ScanCode + UnicodeChar)
    resw 2
búfer_línea:               ; Búfer de línea (UTF-16)
    resw MAX_BUF
