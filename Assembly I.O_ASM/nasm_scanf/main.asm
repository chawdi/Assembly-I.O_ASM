; compile: nasm -f elf32 main.asm
; link: gcc
; variant 18: (c*149 + b*b)/(a + b - 117)
extern calculate_asm

extern printf ; C function
extern scanf
global a,b,c,num,denom,result

section .data		; Data section, initialized variables

prt: db "Enter a b c: ", 0
scn: db "%hd%hd%hd",0
res: db "num = %d",10,"denom = %hd",10,"result = %hd",10,0

section .bss
a resw 1
b resw 1
c resw 1
num resd 1
denom resw 1
result resw 1

section .text ; Code section.

        global main ; the standard gcc entry point
main: ; the program label for the entry point
        push    ebp		; set up stack frame
        mov     ebp,esp

        push    dword prt ; address of ctrl string
        call    printf    ; call C function
        add     esp, 4

	push dword c ; scanf requires an address
	push dword b
	push dword a
	push dword scn
	call scanf
	add esp, 16

	cmp eax, 3
	jne ret

	call calculate_asm ; call the other function

	push dword [result] ; printf requires a value, not an address
	push dword [denom]
	push dword [num]
	push dword res
	call printf
	add esp, 16

ret:
	mov esp, ebp ; takedown stack frame
	pop ebp      ; same as "leave" op

	mov eax, 0   ; normal, no error, return value
	ret          ; return
