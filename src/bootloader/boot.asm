org 0x7C00
bits 16

%define ENDL 0x0D, 0x0A

;prints a string to the screen

; FAT12 HEADER

jmp short start
nop


bdb_oem:                    db 'MSWIN4.1'           ; 8 bytes
bdb_bytes_per_sector:       dw 512
bdb_sectors_per_cluster:    db 1
bdb_reserved_sectors:       dw 1
bdb_fat_count:              db 2
bdb_dir_entries_count:      dw 0E0h
bdb_total_sectors:          dw 2880                 ; 2880 * 512 = 1.44MB
bdb_media_descriptor_type:  db 0F0h                 ; F0 = 3.5" floppy disk
bdb_sectors_per_fat:        dw 9                    ; 9 sectors/fat
bdb_sectors_per_track:      dw 18
bdb_heads:                  dw 2
bdb_hidden_sectors:         dd 0
bdb_large_sector_count:     dd 0

; extended boot record
ebr_drive_number:           db 0                    ; 0x00 floppy, 0x80 hdd, useless
                            db 0                    ; reserved
ebr_signature:              db 29h
ebr_volume_id:              db 12h, 34h, 56h, 78h   ; serial number, value doesn't matter
ebr_volume_label:           db 'K_OS       '        ; 11 bytes, padded with spaces
ebr_system_id:              db 'FAT12   '           ; 8 bytes




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


;
;Disk routines
;

;
;Convert LBA to CHS
; Parameters:
;   ax - LBA
;  Returns:
;   -cx - number of sectors
;   -dh - head
;   -bx - sector
;

lba_to_chs:

    push ax
    push dx 

    xor dx, dx
    div word [bdb_sectors_per_track] ; ax / sectors_per_track, dx = ax % sectors_per_track
    inc dx

    mov cx, dx
    xor dx, dx
    div word [bdb_heads] ; dx = ax / heads, dx = ax % heads

    mov dh, dl
    mov ch, al
    shl ah, 6
    or cl, ah

    pop dx
    mov dl, al
    pop ax
    ret


disk_read:
    push cx
    call lba_to_chs
    pop ax

    mov ah, 02h
    int 13h




msg_hello db "Meu primeiro bootloader em Assembly", ENDL, 0

times 510-($-$$) db 0
dw 0AA55h