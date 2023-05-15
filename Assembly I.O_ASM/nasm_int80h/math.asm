; nasm -f elf64 name.asm
; ld -o name name.o
; lab 1; variant 18: (c*149 + b*b)/(a + b - 117)
; unsigned dword version

section .data
extern a, b, c, num, denom, result

section .text
global calculate_asm

calculate_asm:
;; calculate numerator
	mov eax, 149
	mul dword [c] ; edx, eax = c * 149

; save the previous result for future use
	mov ebx, eax ; junior part
	mov ecx, edx ; senior part

	mov eax, [b] ; eax = b
	mul eax ; edx, eax = b*b

; add c*149 to b*b
	add eax, ebx ; sum c*149 and b*b, junior part
	adc edx, ecx ; senior part

; save numerator
	mov dword [num], eax ; junior part
	mov dword [num+4], edx ; senior part

;; calculate denominator
	mov ebx, [a] ; ebx = a
	add ebx, [b] ; ebx = a + b
	sub ebx, 117 ; ebx = a + b - 117
	mov dword [denom], ebx

;; calculate result
	div ebx ; divide edx, eax by ebx ; now eax = result
	mov dword [result], eax

	ret ; ret returns to main()
