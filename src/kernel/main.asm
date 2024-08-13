org 0x7C00
bits 16

%define ENDL 0x0D, 0x0A

start:
    jmp main

;prints a string to the screen
;parameters:
;    ds:si - pointer to string

puts:
    ;save registers we will modify
    push ax
    push si


.loop:
    lodsb   ;Carrega um byte de ds:si para al
    or al, al  ;Se o byte for 0, termina o loop
    jz .done 
    

    mov ah, 0x0E ;chama a BIOS para mostrar um caractere
    mov bh, 0 
    int 0x10 

    jmp .loop


.done:
    pop si ;restaura o valor de si
    pop ax ;restaura o valor de ax
    ret ;retorna

main:

    ;setup data segments
    mov ax, 0
    mov ds, ax
    mov es, ax

    mov ss, ax
    mov sp, 0x7C00

    mov si, msg_hello
    call puts

    hlt

.halt:
    jmp .halt

msg_hello db "Meu primeiro bootloader em Assembly", ENDL, 0

times 510-($-$$) db 0
dw 0AA55h