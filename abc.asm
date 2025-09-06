%include "macros.asm"

section .data 
    textpunto db ".", 10 ;placerholder en vez del sonido
    textraya db "-", 10   ;placeholder en vez de la raya

section .text


convertir_morse:
    cmp r9b, 'a'
    je letra_a
    cmp r9b, 'b'
    je letra_b
    ret

letra_a:
    reproducepunto
    reproduceraya
    ret

letra_b:
    reproduceraya
    reproducepunto
    reproducepunto
    reproducepunto
    ret