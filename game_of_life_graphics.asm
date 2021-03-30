; main PROC for Game of Life
; prompts user for input
; displays current board

include Irvine32.inc
include backend.inc

.data
MAXIMUM_HEIGHT BYTE ?
MAXIMUM_WIDTH  BYTE ?

world_map BYTE 0, 1, 0, 1, 0, 1, 0, 1, 0
player_input DWORD 0

WELCOME_PROMPT BYTE "<->                                          John Conway's Game of Life                                           <->", 0AH, 0DH, 0
MAIN_MENU BYTE "<->      Controls      <->", 0AH, 0DH, 0
PROMPT_1 BYTE  "W Shift carriage up    <->", 0AH, 0DH, 0
PROMPT_2 BYTE  "A Shift carriage left  <->", 0AH, 0DH, 0
PROMPT_3 BYTE  "S Shift carriage down  <->", 0AH, 0DH, 0
PROMPT_4 BYTE  "D Shift carriage right <->", 0AH, 0DH, 0
PROMPT_5 BYTE  "ESC Exit Game          <->", 0AH, 0DH, 0

.code
display_world_map PROC
; INPUT: EAX - Height of Array
; INPUT: EBX - Width of Array
; INPUT: ECX - Pointer to Array
    ret
; OUTPUT: NONE
display_world_map ENDP

.code
display_MAIN_MENU PROC
; INPUT: NONE
    mov EDX, OFFSET WELCOME_PROMPT
    call WriteString ; Print WELCOME_PROMPT
    call WaitMsg ; Stop program, Print "Press any key to continue..."
    call Clrscr

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
    
    ; display WELCOME_PROMPT
    ; display MAIN_MENU
    call display_MAIN_MENU
    call Clrscr
    ; while user doesnt press ESC

    ; initialize board

    ; update_board

    ; display_board
    mov EAX, OFFSET world_map
    mov EBX, OFFSET MAXIMUM_HEIGHT
    mov ECX, OFFSET MAXIMUM_WIDTH
    push EAX
    push EBX
    push ECX
    call display_world_map

    ; while user wants to play
        ; update_board

        ; display_board

    call DumpRegs

    exit

game_of_life_main ENDP
END game_of_life_main
