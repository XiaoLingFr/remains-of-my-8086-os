[org 0x0000]
[bits 16]

kernel_setup:
    mov [kernel_drive_num], dl
    call ivt_setup

kernel:
   call shell 
    cli
    jmp $

;simple ivt setup
ivt_setup:
    push bp
    mov bp, sp

    xor bx, bx
    mov es, bx
    mov cx, 0x1000

    ;divison by zero
    mov word [es:bx], kernel
    add bx, 2
    mov word [es:bx], cx

    mov bx, 0x0200
    mov word [es:bx], userspace
    add bx, 2
    mov word [es:bx], cx

    ;raw disk read/write, requires the lba number in ax, es and bx defined
    mov bx, 0x0080
    mov word [es:bx], raw_disk_read
    add bx, 2
    mov word [es:bx], cx
    add bx, 2

    mov word [es:bx], raw_disk_write
    add bx, 2
    mov word[es:bx], cx
    add bx, 2

    ;continuous disk read/write, requires lba number in ax and number of sectors in cx
    mov word [es:bx], continuous_read
    add bx, 2
    mov word[es:bx], cx
    add bx, 2

    mov word [es:bx], continuous_write
    add bx, 2
    mov word [es:bx], cx
    
    pop bp
    ret

raw_disk_read:
    cli
    
    push bp
    mov bp, sp

    push ax
    call lba_to_chs
    mov ah, 0x02
    mov al, 1
    mov dl, [kernel_drive_num]

    sti

    int 0x13

    pop ax
    pop bp
    iret

continuous_read:
    push bp
    mov bp, sp

continuous_read_loop:
    cmp cx, 0
    je continuous_read_end

    push cx ;prevent getting written over
    push ax
    
    int 0x20

    pop ax
    pop cx

    inc ax
    dec cx
    add bx, 512
    jc continuous_read_end ;I believe x86 sets the carry with unsigned numbers instead of overflow
    jmp continuous_read_loop

continuous_read_end:
    pop bp
    iret

raw_disk_write:
    cli
    
    push bp
    mov bp, sp

    push ax
    call lba_to_chs
    mov ah, 0x03
    mov al, 1
    mov dl, [kernel_drive_num]

    sti

    int 0x13

    pop ax
    pop bp
    iret

continuous_write:
    push bp
    mov bp, sp

continuous_write_loop:
    cmp cx, 0
    je continuous_write_end

    push cx
    push ax
    
    int 0x21

    pop ax
    pop cx

    inc ax
    dec cx
    add bx, 512
    jc continuous_write_end
    jmp continuous_write_loop

continuous_write_end:
    pop bp
    iret

;this was from my previous OS code, its a bit messy
lba_to_chs:
    push bp
    mov bp, sp

    push ax
    push bx
    push dx
    push si

    mov si, sp

    xor ax, ax
    xor bx, bx
    xor dx, dx
    
    ;1. temp value
    mov ax, [bp + 4]
    mov bl, [sectors_per_track]
    div bx

    ;4. increment remainder and move to cl
    inc dx
    mov cl, dl

    ;back to step 1
    push ax

    ;2. cylinder
    xor ax, ax
    xor bx, bx
    xor dx, dx
    
    mov ax, [si - 2]
    mov bl, [heads_per_cylinder]
    div bx
    mov ch, al

    ;3. head
    mov bx, dx
    mov sp, si
    pop si
    pop dx
    mov dh, bl
    
    pop bx
    pop ax

    pop bp
    ret

heads_per_cylinder:
    db 2
sectors_per_track:
    db 18

kernel_drive_num:
    db 0

%include "vga.asm"
%include "init.asm"
