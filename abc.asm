%include 

%macro compararabecedario
    cmp r9 97
    jne comparab
    reproducepunto
    reproduceraya


comparab:
    cmp r9 98
    jne comparac
    reproduceraya 
    reproducepunto
    reproducepunto
    reproducepunto
    

%endmacro