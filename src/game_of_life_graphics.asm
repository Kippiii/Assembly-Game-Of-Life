; main PROC for Game of Life
; prompts user for input
; displays current board

include Irvine32.inc
include backend.inc

.data
MAXIMUM_HEIGHT BYTE ?
MAXIMUM_WIDTH  BYTE ?

carriage_X_pos BYTE 0
carriage_Y_pos BYTE 10

world_map BYTE 100 DUP(1)
current_key_stroke BYTE ?, 0

array_position WORD 0
flag BYTE 0

WELCOME_PROMPT BYTE "<->                                          John Conway's Game of Life                                           <->", 0AH, 0DH, 0
MAIN_MENU    BYTE   "<->.......Controls......<->", 0AH, 0DH, 0
PROMPT_1     BYTE   "w Shift carriage up.....<->", 0AH, 0DH, 0
PROMPT_2     BYTE   "a Shift carriage left...<->", 0AH, 0DH, 0
PROMPT_3     BYTE   "s Shift carriage down...<->", 0AH, 0DH, 0
PROMPT_4     BYTE   "d Shift carriage right..<->", 0AH, 0DH, 0
PROMPT_5     BYTE   "q Quit Game.............<->", 0AH, 0DH, 0
PROMPT_6     BYTE   "p Toggle pause/continue.<->", 0AH, 0DH, 0
PROMPT_7     BYTE   "f Step one frame........<->", 0AH, 0DH, 0
PROMPT_8     BYTE   "x Flip Cell.............<->", 0AH, 0DH, 0
BOTTOM_FRAME BYTE   "<->.....................<->", 0AH, 0DH, 0

P_CHAR BYTE "p", 0
F_CHAR BYTE "f", 0
Q_CHAR BYTE "q", 0
X_CHAR BYTE "x", 0
W_CHAR BYTE "w", 0
A_CHAR BYTE "a", 0
S_CHAR BYTE "s", 0
D_CHAR BYTE "d", 0

NEW_LINE BYTE 0AH, 0DH, 0

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

    mov EDX, OFFSET BOTTOM_FRAME
    call WriteString ; Print BOTTOM_FRAME

    call WaitMsg
    call Clrscr

    ret
; OUTPUT: NONE
display_MAIN_MENU ENDP

.code
set_cell PROC
; INPUT: EAX - Pointer to array
    mov [world_map + ECX], 1

    ret
; OUTPUT: EAX - Pointer to array
set_cell ENDP

.code
display_board PROC
; INPUT: EAX - Pointer to array
    call Clrscr

    and EDX, 0
    call Gotoxy

    mov ESI, OFFSET world_map
    mov ECX, 100h
    cld
    L1: lodsd
        mov EDX, OFFSET X_CHAR
        call WriteString
        add array_position, 1
        mov AX, array_position
        mov BL, OFFSET 100
        div BL
        jc PRINT_NEW_LINE_LABEL
        loop L1

    PRINT_NEW_LINE_LABEL:
        mov EDX, OFFSET NEW_LINE
        call WriteString
        jmp L1

    call Crlf

    ret
; OUTPUT: NONE
display_board ENDP

; MAIN PROGRAM
game_of_life_main PROC
    ; get board measurements
    call GetMaxXY
    mov MAXIMUM_WIDTH, DL
    mov MAXIMUM_HEIGHT, AL
    ; display WELCOME_PROMPT
    call display_WELCOME
    ; display MAIN_MENU
    call display_MAIN_MENU
    mov DL, carriage_X_pos
    mov DH, carriage_Y_pos
    call Gotoxy
        ;MAIN_LABEL: ; while user doesnt press ESC, ESC will end the game during any state
    MAIN_LABEL:
    mov EAX, red + (blue * 16)
    call SetTextColor
        INPUT1_LABEL:
            ; call update_board
            mov EAX, OFFSET world_map
            push EAX
            call display_board ; INPUTS: EAX

            mov EAX, 100
            call Delay
            call ReadKey ; Get keyboard input
            jz INPUT1_LABEL ; If no input was given, repeat INPUT1_LABEL
            mov EDX, OFFSET PROMPT_1
            call WriteString
            mov current_key_stroke, AL ; current_key_stroke = ReadKey()
            ; check if p
            mov AL, P_CHAR
                cmp AL, current_key_stroke
                jz PAUSE_LABEL ; if current_key_stroke == 'p'
            mov AL, X_CHAR
                cmp AL, current_key_stroke
                jz PAUSE_LABEL ; if current_key_stroke == 'x'
            ; check if f
            mov AL, F_CHAR
                cmp AL, current_key_stroke
                jz FRAME_LABEL ; if current_key_stroke == 'f'
            ; check if q
            mov AL, Q_CHAR
                cmp AL, current_key_stroke
                jz EXIT_LABEL ; if current_key_stroke == 'q'
            ; check if w, a, s, OR d
            mov AL, W_CHAR
                cmp AL, current_key_stroke
                jz MOVE_CELL_UP_LABEL ; if current_key_stroke == 'w'
            mov AL, A_CHAR
                cmp AL, current_key_stroke
                jz MOVE_CELL_LEFT_LABEL ; if current_key_stroke == 'a'
            mov AL, S_CHAR
                cmp AL, current_key_stroke
                jz MOVE_CELL_DOWN_LABEL ; if current_key_stroke == 's'
            mov AL, D_CHAR
                cmp AL, current_key_stroke
                jz MOVE_CELL_RIGHT_LABEL ; if current_key_stroke == 'd'

            jnz INPUT1_LABEL ; if no match to p, f, q, w, a, s, d, jump to INPUT1_LABEL

        PAUSE_LABEL:
            mov EAX, 10
            call Delay
            call ReadKey ; Get keyboard input
            jz PAUSE_LABEL ; If no input was given, repeat PAUSE_LABEL
            mov EDX, OFFSET PROMPT_6
            call WriteString
            mov current_key_stroke, AL ; current_key_stroke = ReadKey()
            mov AL, Q_CHAR
                cmp AL, current_key_stroke ; if current_key_stroke == 'q'
                jz EXIT_LABEL
            mov AL, P_CHAR
                cmp AL, current_key_stroke ; if current_key_stroke == 'p'
                jz INPUT1_LABEL
            mov AL, F_CHAR
                cmp AL, current_key_stroke ; if current_key_stroke == 'f'
                jz FRAME_LABEL
            mov AL, X_CHAR
                cmp AL, current_key_stroke ; if current_key_stroke == 'x'
                jz CALL_SET_CELL_LABEL
            ; check if w, a, s, OR d
            mov AL, W_CHAR
                cmp AL, current_key_stroke
                jz MOVE_CELL_UP_LABEL ; if current_key_stroke == 'w'
            mov AL, A_CHAR
                cmp AL, current_key_stroke
                jz MOVE_CELL_LEFT_LABEL ; if current_key_stroke == 'a'
            mov AL, S_CHAR
                cmp AL, current_key_stroke
                jz MOVE_CELL_DOWN_LABEL ; if current_key_stroke == 's'
            mov AL, D_CHAR
                cmp AL, current_key_stroke
                jz MOVE_CELL_RIGHT_LABEL ; if current_key_stroke == 'd'
            jnz PAUSE_LABEL

        MOVE_CELL_UP_LABEL:
            sub carriage_Y_pos, 1
            mov DL, carriage_X_pos
            mov DH, carriage_Y_pos
            call Gotoxy
            jmp INPUT1_LABEL

        MOVE_CELL_LEFT_LABEL:
            sub carriage_X_pos, 1
            mov DL, carriage_X_pos
            mov DH, carriage_Y_pos
            call Gotoxy
            jmp INPUT1_LABEL

        MOVE_CELL_DOWN_LABEL:
            add carriage_Y_pos, 1
            mov DL, carriage_X_pos
            mov DH, carriage_Y_pos
            call Gotoxy
            jmp INPUT1_LABEL

        MOVE_CELL_RIGHT_LABEL:
            add carriage_X_pos, 1
            mov DL, carriage_X_pos
            mov DH, carriage_Y_pos
            call Gotoxy
            jmp INPUT1_LABEL

        CALL_SET_CELL_LABEL:
            call set_cell
            call display_board
            mov EDX, OFFSET PROMPT_8
            call WriteString
            jmp PAUSE_LABEL

        FRAME_LABEL:
            ; call update_board
            call display_board
            mov EDX, OFFSET PROMPT_7
            call WriteString
            jmp PAUSE_LABEL

        EXIT_LABEL:
            mov EDX, OFFSET PROMPT_5
            call WriteString
            call DumpRegs
            exit

game_of_life_main ENDP
END game_of_life_main
