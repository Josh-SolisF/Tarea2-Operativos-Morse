textpunto: 
    dw __utf16__('.'), 13, 10, 0
textraya: 
    dw __utf16__('-'), 13, 10, 0

section .text
convertir_morse:
    cmp r9b, 'a'
    je letra_a
    cmp r9b, 'b'
    je letra_b
    cmp r9b, 'c'
    je letra_c
    cmp r9b, 'd'
    je letra_d
    cmp r9b, 'e'
    je letra_e
    cmp r9b, 'f'
    je letra_f
    cmp r9b, 'g'
    je letra_g
    cmp r9b, 'h'
    je letra_h
    cmp r9b, 'i'
    je letra_i
    cmp r9b, 'j'
    je letra_j
    cmp r9b, 'k'
    je letra_k
    cmp r9b, 'l'
    je letra_l
    cmp r9b, 'm'
    je letra_m
    cmp r9b, 'n'
    je letra_n
    cmp r9b, 'o'
    je letra_o
    cmp r9b, 'p'
    je letra_p
    cmp r9b, 'q'
    je letra_q
    cmp r9b, 'r'
    je letra_r
    cmp r9b, 's'
    je letra_s
    cmp r9b, 't'
    je letra_t
    cmp r9b, 'u'
    je letra_u
    cmp r9b, 'v'
    je letra_v
    cmp r9b, 'w'
    je letra_w
    cmp r9b, 'x'
    je letra_x
    cmp r9b, 'y'
    je letra_y
    cmp r9b, 'z'
    je letra_z
    cmp r9b, '0'
    je numero_0
    cmp r9b, '1'
    je numero_1
    cmp r9b, '2'
    je numero_2
    cmp r9b, '3'
    je numero_3
    cmp r9b, '4'
    je numero_4
    cmp r9b, '5'
    je numero_5
    cmp r9b, '6'
    je numero_6
    cmp r9b, '7'
    je numero_7
    cmp r9b, '8'
    je numero_8
    cmp r9b, '9'
    je numero_9
    ret

; Letras
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

letra_c:
    reproduceraya
    reproducepunto
    reproduceraya
    reproducepunto
    ret

letra_d:
    reproduceraya
    reproducepunto
    reproducepunto
    ret

letra_e:
    reproducepunto
    ret

letra_f:
    reproducepunto
    reproducepunto
    reproduceraya
    reproducepunto
    ret

letra_g:
    reproduceraya
    reproduceraya
    reproducepunto
    ret

letra_h:
    reproducepunto
    reproducepunto
    reproducepunto
    reproducepunto
    ret

letra_i:
    reproducepunto
    reproducepunto
    ret

letra_j:
    reproducepunto
    reproduceraya
    reproduceraya
    reproduceraya
    ret

letra_k:
    reproduceraya
    reproducepunto
    reproduceraya
    ret

letra_l:
    reproducepunto
    reproduceraya
    reproducepunto
    reproducepunto
    ret

letra_m:
    reproduceraya
    reproduceraya
    ret

letra_n:
    reproduceraya
    reproducepunto
    ret

letra_o:
    reproduceraya
    reproduceraya
    reproduceraya
    ret

letra_p:
    reproducepunto
    reproduceraya
    reproduceraya
    reproducepunto
    ret

letra_q:
    reproduceraya
    reproduceraya
    reproducepunto
    reproduceraya
    ret

letra_r:
    reproducepunto
    reproduceraya
    reproducepunto
    ret

letra_s:
    reproducepunto
    reproducepunto
    reproducepunto
    ret

letra_t:
    reproduceraya
    ret

letra_u:
    reproducepunto
    reproducepunto
    reproduceraya
    ret

letra_v:
    reproducepunto
    reproducepunto
    reproducepunto
    reproduceraya
    ret

letra_w:
    reproducepunto
    reproduceraya
    reproduceraya
    ret

letra_x:
    reproduceraya
    reproducepunto
    reproducepunto
    reproduceraya
    ret

letra_y:
    reproduceraya
    reproducepunto
    reproduceraya
    reproduceraya
    ret

letra_z:
    reproduceraya
    reproduceraya
    reproducepunto
    reproducepunto
    ret

; Números
numero_0:
    reproduceraya
    reproduceraya
    reproduceraya
    reproduceraya
    reproduceraya
    ret

numero_1:
    reproducepunto
    reproduceraya
    reproduceraya
    reproduceraya
    reproduceraya
    ret

numero_2:
    reproducepunto
    reproducepunto
    reproduceraya
    reproduceraya
    reproduceraya
    ret

numero_3:
    reproducepunto
    reproducepunto
    reproducepunto
    reproduceraya
    reproduceraya
    ret

numero_4:
    reproducepunto
    reproducepunto
    reproducepunto
    reproducepunto
    reproduceraya
    ret

numero_5:
    reproducepunto
    reproducepunto
    reproducepunto
    reproducepunto
    reproducepunto
    ret

numero_6:
    reproduceraya
    reproducepunto
    reproducepunto
    reproducepunto
    reproducepunto
    ret

numero_7:
    reproduceraya
    reproduceraya
    reproducepunto
    reproducepunto
    reproducepunto
    ret

numero_8:
    reproduceraya
    reproduceraya
    reproduceraya
    reproducepunto
    reproducepunto
    ret

numero_9:
    reproduceraya
    reproduceraya
    reproduceraya
    reproduceraya
    reproducepunto
    ret