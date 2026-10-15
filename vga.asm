;vga functionalities
[bits 16]

puts:
    push bp
    mov bp, sp
    pusha
    xor bh, bh
    mov si, [bp + 4]
    mov ah, 0x0E

puts_loop:
    lodsb 
    cmp al, 0
    je puts_end
    int 0x10
    jmp puts_loop

puts_end:
    popa
    pop bp
    ret

putc:
    push bp
    mov bp, sp
    pusha
    xor bh, bh
    mov ax, [bp + 4]
    mov ah, 0x0E
    int 0x10
    popa
    pop bp
    ret

;places character from screen in al
getc:
    push bx
    push cx
    push dx
    push si
    push di

    mov ah, 0x08
    xor bx, bx
    int 0x10

    xor ah, ah

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    ret

;pushes cursor back
cursor_back:
    pusha
    xor bh, bh
    mov ah, 0x03
    int 0x10

    cmp dl, 0
    je cursor_end

    dec dl
    mov ah, 0x02
    int 0x10
    jmp cursor_end

cursor_forward:
    pusha
    xor bh, bh
    mov ah, 0x03
    int 0x10

    cmp dl,79 ;80 characters
    je cursor_end

    inc dl
    mov ah, 0x02
    int 0x10

cursor_end:
    popa
    ret
