; ==============================================================================
; ASSEMBLY BEEP MUSIC COMPOSER
; ==============================================================================

.386
.model flat, stdcall
option casemap:none

; Load Windows definitions first
include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc

; Load Libraries
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib

; Define a structure for our notes
NOTE STRUCT
    frequency dd ?
    duration  dd ?
NOTE ENDS

.data
; Define a melody: {Frequency in Hz, Duration in ms}
; Ending with 0 frequency acts as a terminator
melody NOTE <523, 250>, <587, 250>, <659, 250>, <698, 250>, <784, 500>, <0, 0>

msgStart db "Playing music...", 13, 10, 0

.code
main:
    ; Print start message
    invoke StdOut, ADDR msgStart ; Note: Requires masm32 lib if used

    ; Point ESI to the start of the melody array
    mov esi, OFFSET melody

play_loop:
    ; Load frequency and duration into registers
    mov eax, [esi].NOTE.frequency
    mov ebx, [esi].NOTE.duration

    ; Check for terminator (0 frequency)
    test eax, eax
    jz finished

    ; Play the beep
    ; invoke Beep, frequency, duration
    push ebx
    push eax
    call Beep

    ; Advance to next note (size of structure is 8 bytes)
    add esi, 8
    jmp play_loop

finished:
    invoke ExitProcess, 0
end main