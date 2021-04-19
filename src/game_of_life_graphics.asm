; main PROC for Game of Life
; prompts user for input
; displays current board

; IDEAS
; Nicer cursor?
; Random boards

include Irvine32.inc
include backend.inc

.data
MAXIMUM_HEIGHT BYTE 255
MAXIMUM_WIDTH  BYTE 255

carriage_X_pos BYTE 0
carriage_Y_pos BYTE 0

prev_map DWORD ?
world_map DWORD ?

board_size DWORD ?
current_key_stroke BYTE ?, 0

array_position WORD 0

hHeap DWORD ?

WELCOME_PROMPT BYTE "<->                                          John Conway's Game of Life                                           <->", 0AH, 0DH, 0
MAIN_MENU      BYTE "<->.......Controls......<->", 0AH, 0DH, 0
PROMPT_1       BYTE "w Shift carriage up.....<->", 0AH, 0DH, 0
PROMPT_2       BYTE "a Shift carriage left...<->", 0AH, 0DH, 0
PROMPT_3       BYTE "s Shift carriage down...<->", 0AH, 0DH, 0
PROMPT_4       BYTE "d Shift carriage right..<->", 0AH, 0DH, 0
PROMPT_5       BYTE "q Quit Game.............<->", 0AH, 0DH, 0
PROMPT_6       BYTE "p Toggle pause/continue.<->", 0AH, 0DH, 0
PROMPT_7       BYTE "f Step one frame........<->", 0AH, 0DH, 0
PROMPT_8       BYTE "x Flip Cell.............<->", 0AH, 0DH, 0
PROMPT_9       BYTE "c Clear all cells.......<->", 0AH, 0DH, 0
PROMPT_10      BYTE "r Randomize the grid....<->", 0AH, 0DH, 0
BOTTOM_FRAME   BYTE "<->.....................<->", 0AH, 0DH, 0

P_CHAR BYTE "p", 0
F_CHAR BYTE "f", 0
Q_CHAR BYTE "q", 0
X_CHAR BYTE "x", 0
W_CHAR BYTE "w", 0
A_CHAR BYTE "a", 0
S_CHAR BYTE "s", 0
D_CHAR BYTE "d", 0
C_CHAR BYTE "c", 0
R_CHAR BYTE "r", 0
SPACE_CHAR BYTE " ", 0

LEAVING_SET_CELL BYTE "LEAVING set_cell", 0

.code
display_WELCOME PROC
; INPUT: NONE
    mov EDX, OFFSET WELCOME_PROMPT
    call WriteString ; Print WELCOME_PROMPT
    call WaitMsg ; Stop program, Print "Press any key to continue..."
    call Clrscr
    ret
; OUTPUT: NONE
display_WELCOME ENDP

.code
display_MAIN_MENU PROC
; INPUT: NONE
    mov EDX, OFFSET MAIN_MENU
    call WriteString ; Print MAIN_MENU

    mov EDX, OFFSET PROMPT_1
    call WriteString ; Print PROMPT_1

    mov EDX, OFFSET PROMPT_2
    call WriteString ; Print PROMPT_2

    mov EDX, OFFSET PROMPT_3
    call WriteString ; Print PROMPT_3

    mov EDX, OFFSET PROMPT_4
    call WriteString ; Print PROMPT_4

    mov EDX, OFFSET PROMPT_5
    call WriteString ; Print PROMPT_5

    mov EDX, OFFSET PROMPT_6
    call WriteString ; Print PROMPT_6

    mov EDX, OFFSET PROMPT_7
    call WriteString ; Print PROMPT_7

    mov EDX, OFFSET PROMPT_8
    call WriteString ; Print PROMPT_8

    mov EDX, OFFSET PROMPT_9
    call WriteString ; Print PROMPT_9

    mov EDX, OFFSET PROMPT_10
    call WriteString ; Print PROMPT_10

    mov EDX, OFFSET BOTTOM_FRAME
    call WriteString ; Print BOTTOM_FRAME

    call WaitMsg
    call Clrscr

    ret
; OUTPUT: NONE
display_MAIN_MENU ENDP

.code
set_cell PROC
; INPUT: NONE
    mov EAX, 0
    mov AL, carriage_Y_pos
    mul MAXIMUM_WIDTH
    mov BX, 0
    mov BL, carriage_X_pos
    add AX, BX
    mov ESI, world_map
    add ESI, EAX
    xor BYTE PTR [ESI], 1

    ret
; OUTPUT: NONE
set_cell ENDP

.code
initialize_world_map PROC
; INPUT: NONE
    call Randomize
    mov ESI, 0
    mov ECX, board_size

L1:
    mov EDI, world_map
    add EDI, ESI
    mov AL, BYTE PTR [EDI]
    mov EAX, 2d ; generate random integers
    call RandomRange ; 0 or 1 in EAX
    mov BYTE PTR [EDI], BYTE PTR AL ; store in the array
    add ESI, 1 ; next array position
    loop L1

    ret
; OUTPUT: NONE
initialize_world_map ENDP

.code
display_board PROC
; INPUT: NONE
    and edx, 0 ; Set the values for Gotoxy at the origin, DL, DH
    call Gotoxy

    mov esi, 0          ; Start counter
    mov ecx, board_size ; Maximum loops
    cld
L1:
    ; Only updating when the value has been updating
    mov edi, world_map
    add edi, esi
    mov al, byte ptr [edi]
    mov edi, prev_map
    add edi, esi
    cmp al, byte ptr [edi]
    jz CONTINUE_L1

    mov eax, esi
    mov bl, MAXIMUM_WIDTH
    div bl
    mov dl, ah
    mov dh, al
    call Gotoxy

FIRST_RUN:
    mov edi, world_map
    add edi, esi
    mov al, BYTE PTR [edi]
    cmp al, 1
    jz PRINT_X_CHAR_LABEL
    jnz PRINT_SPACE_CHAR_LABEL

CONTINUE_L1:
    add ESI, 1
    cmp ECX, 1
    jz RET_LABEL
    loop L1

PRINT_X_CHAR_LABEL:
    mov EAX, yellow + (white * 16)
    call SetTextColor
    mov EDX, OFFSET SPACE_CHAR
    call WriteString
    jmp CONTINUE_L1

PRINT_SPACE_CHAR_LABEL:
    mov EAX, yellow + (blue * 16)
    call SetTextColor
    mov EDX, OFFSET SPACE_CHAR
    call WriteString
    jmp CONTINUE_L1

RET_LABEL:
    mov DL, carriage_X_pos
    mov DH, carriage_Y_pos
    call Gotoxy

    push world_map
    push prev_map
    push board_size
    call copy_array
    ret
; OUTPUT: NONE
display_board ENDP

; MAIN PROGRAM
game_of_life_main PROC
    ; Initializing the heap TODO (Handle errors?)
    invoke GetProcessHeap
    mov hHeap, eax

    ; get board measurements
    call GetMaxXY
    mov MAXIMUM_HEIGHT, AL
    mov MAXIMUM_WIDTH, DL

    mov eax, 0
    mov al, MAXIMUM_HEIGHT
    mul MAXIMUM_WIDTH
    mov board_size, eax
    invoke HeapAlloc, hHeap, HEAP_ZERO_MEMORY, board_size
    mov world_map, eax
    invoke HeapAlloc, hHeap, HEAP_ZERO_MEMORY, board_size
    mov prev_map, eax

    mov esi, prev_map
    mov ecx, board_size
PREV_ARR_MAP:
    mov byte ptr [esi], 2
    inc esi
    loop PREV_ARR_MAP

    ; display WELCOME_PROMPT
    call display_WELCOME
    ; display MAIN_MENU
    call display_MAIN_MENU
    mov DL, carriage_X_pos
    mov DH, carriage_Y_pos
    call Gotoxy
    ; while user doesnt press "q"
MAIN_LABEL:
    mov EAX, white + (black * 16)
    call SetTextColor
    call Clrscr
    
    call display_board
    jmp PAUSE_LABEL

INPUT_LABEL:
    mov ESI, world_map
    mov EAX, 0
    mov AL, MAXIMUM_HEIGHT
    mov EBX, 0
    mov BL, MAXIMUM_WIDTH

    push ESI
    push EAX
    push EBX
    call update_board

    call display_board

    mov EAX, 500
    call Delay
    call ReadKey ; Get keyboard input
    jz INPUT_LABEL ; If no input was given, repeat INPUT_LABEL
    mov current_key_stroke, AL ; current_key_stroke = ReadKey()
    ; check if p
    mov AL, P_CHAR
    cmp AL, current_key_stroke
    jz PAUSE_LABEL ; if current_key_stroke == 'p'
    ; check if q
    mov AL, Q_CHAR
    cmp AL, current_key_stroke
    jz EXIT_LABEL ; if current_key_stroke == 'q'
    ; check if w, a, s, OR d

    jnz INPUT_LABEL ; if no match to p, f, q, w, a, s, d, jump to INPUT_LABEL

PAUSE_LABEL:
    mov EAX, 10
    call Delay
    call ReadKey ; Get keyboard input
    jz PAUSE_LABEL ; If no input was given, repeat PAUSE_LABEL
    mov current_key_stroke, AL ; current_key_stroke = ReadKey()
    mov AL, Q_CHAR
    cmp AL, current_key_stroke ; if current_key_stroke == 'q'
    jz EXIT_LABEL
    mov AL, P_CHAR
    cmp AL, current_key_stroke ; if current_key_stroke == 'p'
    jz INPUT_LABEL
    mov AL, F_CHAR
    cmp AL, current_key_stroke ; if current_key_stroke == 'f'
    jz FRAME_LABEL
    mov AL, X_CHAR
    cmp AL, current_key_stroke ; if current_key_stroke == 'x'
    jz CALL_SET_CELL_LABEL
    mov AL, W_CHAR
    cmp AL, current_key_stroke ; if current_key_stroke == 'w'
    jz MOVE_CELL_UP_LABEL
    mov AL, A_CHAR
    cmp AL, current_key_stroke ; if current_key_stroke == 'a'
    jz MOVE_CELL_LEFT_LABEL
    mov AL, S_CHAR
    cmp AL, current_key_stroke ; if current_key_stroke == 's'
    jz MOVE_CELL_DOWN_LABEL
    mov AL, D_CHAR
    cmp AL, current_key_stroke ; if current_key_stroke == 'd'
    jz MOVE_CELL_RIGHT_LABEL
    mov AL, C_CHAR
    cmp AL, current_key_stroke ; if current_key_stroke == 'c'
    jz CLEAR_MAP
    mov AL, R_CHAR
    cmp AL, current_key_stroke ; if current_key_stroke == 'r'
    jz RANDOM_MAP
    jmp PAUSE_LABEL

MOVE_CELL_UP_LABEL:
    cmp carriage_Y_pos, 0
    je PAUSE_LABEL
    sub carriage_Y_pos, 1
    mov DL, carriage_X_pos
    mov DH, carriage_Y_pos
    call Gotoxy
    jmp PAUSE_LABEL

MOVE_CELL_LEFT_LABEL:
    cmp carriage_X_pos, 0
    je PAUSE_LABEL
    sub carriage_X_pos, 1
    mov DL, carriage_X_pos
    mov DH, carriage_Y_pos
    call Gotoxy
    jmp PAUSE_LABEL

MOVE_CELL_DOWN_LABEL:
    mov AL, MAXIMUM_HEIGHT
    sub AL, 1
    cmp carriage_Y_pos, AL
    je PAUSE_LABEL
    add carriage_Y_pos, 1
    mov DL, carriage_X_pos
    mov DH, carriage_Y_pos
    call Gotoxy
    jmp PAUSE_LABEL

MOVE_CELL_RIGHT_LABEL:
    mov AL, MAXIMUM_WIDTH
    sub AL, 1
    cmp carriage_X_pos, AL
    je PAUSE_LABEL
    add carriage_X_pos, 1
    mov DL, carriage_X_pos
    mov DH, carriage_Y_pos
    call Gotoxy
    jmp PAUSE_LABEL

CALL_SET_CELL_LABEL:
    call set_cell
    call display_board
    jmp PAUSE_LABEL

FRAME_LABEL:
    mov ESI, world_map
    mov EAX, 0
    mov AL, MAXIMUM_HEIGHT
    mov EBX, 0
    mov BL, MAXIMUM_WIDTH

    push ESI
    push EAX
    push EBX
    call update_board

    call display_board

    mov DL, carriage_X_pos
    mov DH, carriage_Y_pos
    call Gotoxy
    jmp PAUSE_LABEL

CLEAR_MAP:
    mov ecx, board_size
    mov esi, world_map
CLEAR_MAP_LOOP:
    mov byte ptr [esi], 0
    inc esi
    loop CLEAR_MAP_LOOP

    call display_board
    jmp PAUSE_LABEL

RANDOM_MAP:
    call initialize_world_map ; initialize a random board
    call display_board
    jmp PAUSE_LABEL

EXIT_LABEL:
    INVOKE HeapFree, hHeap, 0, world_map
    exit

game_of_life_main ENDP
END game_of_life_main
