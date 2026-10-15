[org 0x7C00]
[bits 16]

%macro clear_register 1
xor %1,%1
%endmacro

mov [drive_num], dl

main:
   clear_register ax
   clear_register bx
   clear_register cx
   clear_register dx
   clear_register di
   clear_register si
   
load_kernel_loader:
   cli
   mov dl, [drive_num]
   sti
   int 0x13
   
   cli
   mov bx, 0x0000
   mov ax, 0x1000
   mov es, ax
   clear_register ax

   mov ah, 0x02
   mov al, 4
   mov ch, 0
   mov cl, 2
   mov dh, 0
   mov dl, [drive_num]
   sti

   int 0x13

   jc load_failed

jump_kernel_loader:
   mov ax, 0x1000
   mov ds, ax
   mov ss, ax
   mov sp, 0xFFFF
   
   jmp 0x1000:0000

load_failed: ;skull emoji
   mov si, failed
   call print
hang:
   cli
   hlt
drive_num:
   db 0
failed:
   db "Drive failed to load :skull emoji: x3",0

print:
  mov ah, 0x0E
print_loop:
  lodsb
  cmp al, 0
  je print_end
  int 0x10
  jmp print_loop
print_end:
  ret

times 510-($-$$) db 0
dw 0xAA55
