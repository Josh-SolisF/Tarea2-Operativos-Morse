; - Lee las teclas con UEFI ConIn y ALMACENA en búfer hasta toparse con ENTER.
; - Al presionar ENTER, imprime en morse la línea completa y reinicia la entrada.
;


%define EXITO_EFI                 0

; Desplazamientos en EFI_SYSTEM_TABLE (x64) relevantes
%define DESPLAZAMIENTO_TABLA_SISTEMA_EFI_EntradaCon        0x30
%define DESPLAZAMIENTO_TABLA_SISTEMA_EFI_SalidaCon         0x40

; EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL
%define DESPLAZAMIENTO_STO_Reinicio                       0x00
%define DESPLAZAMIENTO_STO_CadenaSalida                   0x08

; EFI_SIMPLE_TEXT_INPUT_PROTOCOL
%define DESPLAZAMIENTO_SIN_Reinicio                       0x00
%define DESPLAZAMIENTO_SIN_LeerTecla                      0x08

; Códigos de control
%define CARACTER_RETROCESO                                0x0008
%define CARACTER_RETORNO                                  0x000D   ; Enter
%define CODIGO_ESC_EFI                                   0x0017   ; ScanCode para ESC en UEFI

%define MAX_BUF                                          512      ; caracteres UTF-16 (incluye NUL)

; Macros para reproducir punto y raya
%macro REPRODUCIR_PUNTO 0
    mov     rcx, rbx
    lea     rdx, [rel caracter_punto]
    mov     r11, [rbx + DESPLAZAMIENTO_STO_CadenaSalida]
    call    r11
%endmacro

%macro REPRODUCIR_RAYA 0
    mov     rcx, rbx
    lea     rdx, [rel caracter_raya]
    mov     r11, [rbx + DESPLAZAMIENTO_STO_CadenaSalida]
    call    r11
%endmacro

default rel
extern  __chkstk

section .text
align 16
global  efi_main

; --------------------------------------------------------------------------------------
; EFI_STATUS principal_efi(EFI_HANDLE RCX, EFI_SYSTEM_TABLE* RDX)
; --------------------------------------------------------------------------------------
efi_main:
    sub     rsp, 32
    mov     rsi, rdx                                   ; TablaSistema

    ; ------------------------------------
    ; Inicializar SalidaCon/EntradaCon
    ; ------------------------------------
    mov     rbx, [rsi + DESPLAZAMIENTO_TABLA_SISTEMA_EFI_SalidaCon] ; rbx = SalidaCon
    mov     rdi, [rsi + DESPLAZAMIENTO_TABLA_SISTEMA_EFI_EntradaCon] ; rdi = EntradaCon

    ; Reinicio de SalidaCon
    mov     rcx, rbx
    xor     rdx, rdx
    mov     r11, [rbx + DESPLAZAMIENTO_STO_Reinicio]
    call    r11

    ; Reinicio de EntradaCon
    mov     rcx, rdi
    xor     rdx, rdx
    mov     r11, [rdi + DESPLAZAMIENTO_SIN_Reinicio]
    call    r11

    ; Mensajes iniciales
    mov     rcx, rbx
    lea     rdx, [rel cadena_inicio]
    mov     r11, [rbx + DESPLAZAMIENTO_STO_CadenaSalida]
    call    r11

    ; ------------------------------------
    ; Estado del búfer: r12 = puntero base, r13 = longitud actual (en CHAR16)
    ; ------------------------------------
    lea     r12, [rel búfer_línea]
    xor     r13, r13                                   ; longitud = 0

.prompt:
    ; Mostrar prompt
    mov     rcx, rbx
    lea     rdx, [rel cadena_prompt]
    mov     r11, [rbx + DESPLAZAMIENTO_STO_CadenaSalida]
    call    r11

.bucle_lectura:
    ; esperar tecla
    mov     rcx, rdi
    lea     rdx, [rel búfer_tecla]
    mov     r11, [rdi + DESPLAZAMIENTO_SIN_LeerTecla]
    call    r11
    test    rax, rax
    jnz     .bucle_lectura

    ; cargar ScanCode y UnicodeChar
    movzx   eax, word [búfer_tecla + 0]                ; ScanCode
    movzx   edx, word [búfer_tecla + 2]                ; UnicodeChar

    ; ESC -> salir
    cmp     ax, CODIGO_ESC_EFI
    je      .salir

    ; ENTER -> imprimir línea completa
    cmp     dx, CARACTER_RETORNO
    je      .procesar_linea

    ; RETROCESO -> borrar último char del búfer
    cmp     dx, CARACTER_RETROCESO
    je      .manejar_retroceso

    ; Si es carácter imprimible (UnicodeChar != 0) y hay espacio en buf
    test    dx, dx
    jz      .bucle_lectura

    cmp     r13, MAX_BUF-1
    jae     .beep_o_ignorar                            ; sin espacio, ignorar

    ; Guardar char en el búfer (UTF-16)
    mov     [r12 + r13*2], dx
    inc     r13
    jmp     .bucle_lectura

.manejar_retroceso:
    test    r13, r13
    jz      .bucle_lectura
    dec     r13
    jmp     .bucle_lectura

.procesar_linea:
    ; Cerrar con NUL
    mov     word [r12 + r13*2], 0

    ; Imprimir línea
    mov     rcx, rbx
    lea     rdx, [rel búfer_línea]
    mov     r11, [rbx + DESPLAZAMIENTO_STO_CadenaSalida]
    call    r11

    ; Salto de línea
    mov     rcx, rbx
    lea     rdx, [rel cadena_nueva_linea]
    mov     r11, [rbx + DESPLAZAMIENTO_STO_CadenaSalida]
    call    r11

    ; -------------------------------------------------
    ; Iterar sobre cada carácter en búfer_línea
    ; -------------------------------------------------
    xor     r14, r14               ; índice i = 0

.bucle_iteracion:
    cmp     r14, r13
    jae     .despues_iteracion      ; si i >= len -> salir del bucle

    movzx   edx, word [r12 + r14*2] ; dx = UnicodeChar (UTF-16)
    inc     r14

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

    jmp     .bucle_iteracion

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
    mov     rcx, rbx
    lea     rdx, [rel caracter_espacio]
    mov     r11, [rbx + DESPLAZAMIENTO_STO_CadenaSalida]
    call    r11
    jmp     .bucle_iteracion

.despues_iteracion:
    ; Limpiar para la siguiente línea
    xor     r13, r13
    jmp     .prompt

.beep_o_ignorar:
    jmp     .bucle_lectura

.salir:
    mov     rcx, rbx
    lea     rdx, [rel cadena_despedida]
    mov     r11, [rbx + DESPLAZAMIENTO_STO_CadenaSalida]
    call    r11

    xor     rax, rax
    add     rsp, 32
    ret

section .data
align 2
cadena_inicio:     dw 'I','n','g','r','e','s','e',' ','p','a','l','a','b','r','a','s',':',13,10,0
caracter_punto:    dw '.', 0
caracter_raya:     dw '-', 0
caracter_espacio:  dw ' ', 0

cadena_prompt:     dw '>', '>',' ', 0
cadena_nueva_linea: dw 13,10,0
cadena_despedida:  dw 13,10,'S','a','l','i','e','n','d','o',' ','c','o','n',' ','E','S','C','.',13,10,0

section .bss
align 2
búfer_tecla:                ; EFI_INPUT_KEY { UINT16 ScanCode; UINT16 UnicodeChar; }
    resw 2
búfer_línea:               ; Búfer de línea (UTF-16)
    resw MAX_BUF
