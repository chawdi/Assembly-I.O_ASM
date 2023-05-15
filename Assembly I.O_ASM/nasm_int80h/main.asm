; compile: nasm -f elf32 main.asm
; link: gcc
; variant 18: (c*149 + b*b)/(a + b - 117)
extern calculate_asm

global a,b,c,num,denom,result

section .bss
	a: resd 1
	b: resd 1
	c: resd 1
	num: resq 1
	denom: resd 1
	result: resd 1
	input: resb 256

section .data ; Data section, initialized variables
	greeting_msg: db "Enter a, b, and c separated with new line: ", 10, 0
	greeting_msg_len: equ $ - greeting_msg

	result_str: db "numerator, denominator, and result: ", 10, 0
	result_str_len: equ $ - result_str

	error_msg: db "Invalid input. ", 10, 0
	error_msg_len: equ $ - error_msg

section .text ; Code section.
        global main ; the standard gcc entry point
        global input_str ; get a number
        global string_to_int ; convert a string to an integer
        global int_to_string ; convert an integer to a string
        global print_string ; prints string

main: ; the program label for the entry point
        push    ebp ; set up stack frame
        mov     ebp,esp

; print a greeting message
	mov ecx, greeting_msg_len
	mov eax, greeting_msg
	call print_string

; enter the required numbers

; enter a
	call input_str
	mov esi, input
	call string_to_int
	mov [a], eax

;enter b
	call input_str
	mov esi, input
	call string_to_int
	mov [b], eax

;enter c
	call input_str
	mov esi, input
	call string_to_int
	mov [c], eax

; calculate the result
	call calculate_asm ; call the other function

; print the result message
	mov ecx, result_str_len
	mov eax, result_str
	call print_string

; print the result
	mov eax, [num]
	mov esi, input
	call int_to_string
	call print_string

	mov eax, [denom]
	mov esi, input
	call int_to_string
	call print_string

	mov eax, [result]
	mov esi, input
	call int_to_string
	call print_string

; exit
return:
	mov esp, ebp ; takedown stack frame
	pop ebp      ; same as "leave" op
	mov eax, 0   ; return value is 0
	ret          ; return

; a function to enter a string using int80 syscall
; the string is always in "input"
input_str:
	mov edx, 256 ; length of the string
	mov ecx, input ; pointer to the variable
	mov ebx, 0 ; stdin
	mov eax, 3 ; sys in call number
	int 0x80 ; call kernel

	cmp eax, 0 ; check the return value
	je error
	ret
; in case of error
error:
	mov ecx, error_msg_len
	mov eax, error_msg
	call print_string
	mov	ebx, 1		; exit code, 0=normal
	mov	eax, 1		; exit command to kernel
	int	0x80		; interrupt 80 hex, call kernel

; string to integer
; Input:
; ESI = pointer to the string to convert
; Output:
; EAX = integer value
string_to_int:
	xor eax, eax    ; clear a "result so far"
.next_digit:
	movzx ecx, byte [esi]
	inc esi ; ready for next one
	cmp ecx, 10
	je .done
	cmp ecx, '0' ; valid?
	jb error
	cmp ecx, '9'
	ja error
	sub ecx, '0' ; "convert" character to number
	imul eax, 10 ; multiply "result so far" by ten
	add eax, ecx ; add in current digit, now eax = eax*10 + ecx
	jmp .next_digit ; until done
.done:
	ret

; integer to string
; Input:
; EAX = integer value to convert
; ESI = pointer to buffer to store the string in
; (must have room for at least 256 bytes)
; Output:
; EAX = pointer to the first character of the generated string
int_to_string:
	add esi, 255
	mov byte [esi], 0
	dec esi
	mov byte [esi], 10
	mov ebx, 10 ; divide by 10 every iteration
	mov ecx, 2
.next_digit:
	xor edx,edx         ; Clear edx prior to dividing edx:eax by ebx
	div ebx             ; eax /= 10
	add dl,'0'          ; Convert the remainder to ASCII
	dec esi             ; store characters in reverse order
	mov [esi], dl
	inc ecx
	cmp eax, 0
	jne .next_digit ; Repeat until eax==0
	mov eax,esi
	ret

; print string
; Input:
; ECX = message length
; EAX = pointer to the message to write
; Output:
; nothing
print_string:
	mov edx, ecx ; third argument: message length
	mov ecx, eax ; second argument: pointer to the message to write
	mov ebx, 1 ; first argument: file handle (stdout)
	mov eax, 4 ; system call number (sys_write)
	int 0x80 ; call kernel
	ret
