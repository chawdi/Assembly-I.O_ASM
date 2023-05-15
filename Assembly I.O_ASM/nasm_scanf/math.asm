; nasm -f elf64 name.asm
; ld -o name name.o
; variant 18: (c*149 + b*b)/(a + b - 117)
; signed word

section .data
extern a, b, c, num, denom, result

section .text
global calculate_asm

calculate_asm:
	mov ax, 149
	imul word [c] ; dx,ax = c*149

	mov bx, ax
	mov cx, dx

	mov ax, [b]
	imul ax ; dx, ax = b*b
	add ax,bx ; sum c*149 and b*b
	adc dx,cx ; sum 
	
	mov word [num], ax
	mov word [num+2], dx
	
	mov bx, [a]
	add bx, [b]
	sub bx, 117 ; bx = a + b - 117
	mov [denom], bx
	
	idiv bx ; divide dx,ax by bx ; now ax = result

	mov [result], ax
	
	ret ; ret returns to main()
