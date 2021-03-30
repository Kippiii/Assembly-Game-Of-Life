include Irvine32.inc
include backend.inc

; Driver code (TODO remove this)
.data
map byte 0, 1, 1, 1
.code
main proc
	mov esi, offset map
	mov eax, 2
	mov ebx, 2
	push esi
	push eax
	push ebx
	call update_board
	mov edi, offset map
main endp
end main