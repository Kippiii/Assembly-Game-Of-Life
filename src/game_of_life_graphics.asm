; main PROC for Game of Life
; prompts user for input
; displays current board

include Irvine32.inc
include backend.inc

.data
MAXIMUM_HEIGHT BYTE ?
MAXIMUM_WIDTH  BYTE ?

world_map BYTE 0, 1, 0, 1, 0, 1, 0, 1, 0
old_key_stroke BYTE ?
current_key_stroke BYTE ?

WELCOME_PROMPT BYTE "<->                                          John Conway's Game of Life                                           <->", 0AH, 0DH, 0
MAIN_MENU    BYTE "<->......Controls.......<->", 0AH, 0DH, 0
PROMPT_1     BYTE "W Shift carriage up.....<->", 0AH, 0DH, 0
PROMPT_2     BYTE "A Shift carriage left...<->", 0AH, 0DH, 0
PROMPT_3     BYTE "S Shift carriage down...<->", 0AH, 0DH, 0
PROMPT_4     BYTE "D Shift carriage right..<->", 0AH, 0DH, 0
PROMPT_5     BYTE "ESC Exit Game...........<->", 0AH, 0DH, 0
PROMPT_6     BYTE "p Toggle pause/continue.<->", 0AH, 0DH, 0
PROMPT_7     BYTE "f Step one frame........<->", 0AH, 0DH, 0
PROMPT_8     BYTE "SPACE BAR Flip Cell.....<->", 0AH, 0DH, 0
BOTTOM_FRAME BYTE "<->.....................<->", 0AH, 0DH, 0

P_CHAR BYTE "p", 0
F_CHAR BYTE "f", 0
ESC_CHAR BYTE "ESC", 0
SPACE_CHAR BYTE " ", 0
W_CHAR BYTE "w", 0
A_CHAR BYTE "a", 0
S_CHAR BYTE "s", 0
D_CHAR BYTE "d", 0

.code
display_world_map PROC
; INPUT: EAX - Height of Array
; INPUT: EBX - Width of Array
; INPUT: ECX - Pointer to Array
    ret
; OUTPUT: NONE
display_world_map ENDP

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

    ret
; OUTPUT: NONE
display_MAIN_MENU ENDP

.code
set_cell PROC
; INPUT: EAX - Pointer to array
; INPUT: AL  - X Position
; INPUT: BL  - Y Position
    ret
; OUTPUT: EAX - Pointer to array
set_cell ENDP

.code
get_input PROC
; INPUT: NONE
    ret
; OUTPUT: EAX
get_input ENDP

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

        ;main_loop: ; while user doesnt press ESC, ESC will end the game during any state
        main_loop:
            ; current_key_stroke = call ReadKey
            input1_loop:
                mov EAX, 1000
                call Delay
                call ReadKey
                ;call update_board
                ;call display_board ; Render board while waiting for input
                jz   input1_loop
                mov current_key_stroke, AL
                ; if current_key_stroke == 'p'
                mov EDX, OFFSET P_CHAR
                call WriteString
                mov EDX, OFFSET current_key_stroke
                call WriteString
                INVOKE Str_Compare, ADDR P_CHAR, ADDR current_key_stroke
                jz input1_loop
                call DumpRegs
                    ; move_cursor_loop:
                        ; current_key_stroke = call ReadKey
                        ; if current_key_stroke == 'ESC'
                            ; exit game
                        ; else if current_key_stroke == 'p'
                            ; break out of loop
                        ; else if current_key_stroke == 'spacebar'
                            ; call set_cell
                        ; else if current_key_stroke == 'f'
                            ; call update_board
                        ; else
                            ; call move_cursor
                    ; loop move_cursor_loop
                ; else if current_key_stroke == 'f'
                    ; call update_board
                    ; call display_board
                ; else if current_key_stroke == 'ESC'
                    ; exit game
            ; call update_board
            ; call display_board
        ;loop main_loop

    exit

game_of_life_main ENDP
END game_of_life_main
