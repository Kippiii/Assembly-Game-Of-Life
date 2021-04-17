include Irvine32.inc
include backend.inc

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
	push ebp
	push ecx
	push esi
	push edi
	
	push [ebp + 12]
	push [ebp + 8]
	push [ebp + 4]
	push ecx

	call get_neighbor_count
	pop edx

	pop edi
	pop esi
	pop ecx
	pop ebp
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
	mov ecx, eax
	mov esi, offset new_map
	mov edi, [ebp + 12]
Looping:
	mov bl, byte ptr [esi]
	mov byte ptr [edi], bl
	inc esi
	inc edi
	loop Looping

	mov esp, ebp
	pop eax
	add esp, 12
	push eax
	ret
update_board endp


.data
direction dword 0, 1, 0, -1, 1, 0, -1, 0, 1, 1, 1, -1, -1, 1, -1, -1
.code
; INPUT: pointer to array, height, width, pos
get_neighbor_count proc
Initialization:
	mov ebp, esp
	push ebp

	mov ebx, 0
	mov ecx, 8
	mov esi, offset direction
Bounds_Check:
	mov eax, [ebp + 4]
	mov edx, 0
	div dword ptr [ebp + 8]
	; EAX has y-pos, EDX has x-pos
	add edx, [esi]
	add eax, [esi + 4]

	cmp edx, 0
	jl Cleanup
	cmp edx, [ebp + 8]
	jge Cleanup
	cmp eax, 0
	jl Cleanup
	cmp eax, [ebp + 12]
	jge Cleanup
	jmp Alive_Check
Alive_Check:
	push edx
	mul dword ptr [ebp + 8]
	pop edx
	add eax, edx

	mov edi, [ebp + 16]
	add edi, eax
	cmp byte ptr [edi], 0
	je Is_Dead
	jmp Is_Alive
Is_Alive:
	add ebx, 1
	jmp Cleanup
Is_Dead:
	jmp Cleanup
Cleanup:
	add esi, 8
	loop Bounds_Check
Ending:
	mov esp, ebp
	pop eax
	add esp, 16
	push ebx
	push eax
	ret
get_neighbor_count endp

; INPUT: source, dest, size
copy_array proc
Initialization:
	mov ebp, esp
	push ebp

	mov ecx, [ebp + 4]
	mov esi, [ebp + 12]
	mov edi, [ebp + 8]
My_Loop:
	mov al, byte ptr [esi]
	mov byte ptr [edi], al
	inc esi
	inc edi
	loop My_Loop

Ending:
	mov esp, ebp
	pop eax
	add esp, 12
	push eax
	ret
copy_array endp

end