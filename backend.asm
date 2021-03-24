include Irvine32.inc

.data?
new_map byte 10000 DUP(?)

.code
; INPUT: pointer to array, height, width
update_board proc
Initialization:
	mov ebp, esp
	push ebp

	mov ecx, 0

	mov esi, [ebp + 12]

	mov edi, offset new_map
Count_Neighbors:
	; TODO Implement this proto

	; Assume the number of neighbors is in edx
	mov edx, 4
Check_Alive:
	cmp byte ptr [esi], 0
	je Dead_Start
	jmp Alive_Start
Dead_Start:
	cmp edx, 3
	jne Staying_Dead
	jmp Resurrecting
Resurrecting:
	mov byte ptr [edi], 1
	jmp Dead_End
Staying_Dead:
	mov byte ptr [edi], 0
	jmp Dead_End
Dead_End:
	jmp Update
Alive_Start:
	cmp edx, 2
	jb Dying
	cmp edx, 3
	ja Dying
	jmp Staying_Alive
Dying:
	mov byte ptr [edi], 0
	jmp Alive_End
Staying_Alive:
	mov byte ptr [edi], 1
	jmp Alive_End
Alive_End:
	jmp Update
Update:
	inc edi
	inc esi
	inc ecx
	
	mov eax, [ebp + 8]
	mul byte ptr [ebp + 4]

	cmp eax, ecx
	jbe Ending
	jmp Count_Neighbors
Ending:
	mov esp, ebp
	pop eax
	sub esp, 12
	mov edi, offset new_map
	push edi
	push eax
	ret
update_board endp


.data
direction byte 0, 1, 0, -1, 1, 0, -1, 0, 1, 1, 1, -1, -1, 1, -1, -1
.code
get_neighbor_count proc
	
get_neighbor_count endp


; Driver code (TODO remove this)
.data
map byte 1, 1, 1, 1
.code
main proc
	mov esi, offset map
	mov eax, 2
	mov ebx, 2
	push esi
	push eax
	push ebx
	call update_board
main endp
end main