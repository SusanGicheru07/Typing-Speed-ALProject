; ==============================================================================
; TYPING SPEED TEST - Assembly Language Implementation
; This program measures user input speed against a predefined string.
; ==============================================================================

.386                    ; Use 80386 instruction set
.model flat, stdcall    ; Flat memory model, standard calling convention
option casemap:none     ; Case sensitive symbols

; Include necessary Windows and MASM32 definitions
include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc

; Link required libraries
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib

.data
; --- Pre-initialized strings ---
welcomeMsg  db 13,10,"==============================",13,10
            db "      TYPING SPEED TEST       ",13,10
            db "==============================",13,10,0
textMsg     db 13,10,"Type the following sentence exactly:",13,10,0
sentence    db "assembly language is fun",0      ; The target string
inputLabel  db 13,10,"Your Input: ",0
correctMsg  db 13,10,"Correct typing!",13,10,0
wrongMsg    db 13,10,"Typing does not match!",13,10,0
timeMsg     db 13,10,"Time Taken (seconds): ",0
wpmMsg      db 13,10,"Estimated WPM: ",0
newline     db 13,10,0

.data?
; --- Uninitialized buffers and variables ---
buffer      db 100 dup(?)   ; Buffer to store user input
timeBuffer  db 20 dup(?)    ; Buffer for time string conversion
wpmBuffer   db 20 dup(?)    ; Buffer for WPM string conversion
startTime   dd ?            ; Tick count at start
endTime     dd ?            ; Tick count at end
elapsed     dd ?            ; Calculated elapsed seconds
wpm         dd ?            ; Calculated words per minute

.code
main:
    ; --- User Interface: Display Prompts ---
    invoke StdOut, ADDR welcomeMsg
    invoke StdOut, ADDR textMsg
    invoke StdOut, ADDR sentence
    invoke StdOut, ADDR inputLabel

    ; --- Timing Start ---
    invoke GetTickCount     ; Get current system time (ms)
    mov startTime, eax

    ; --- Input Acquisition ---
    invoke StdIn, ADDR buffer, 100

    ; --- Timing End ---
    invoke GetTickCount
    mov endTime, eax

    ; --- Input Normalization (Cleaning) ---
    ; StdIn captures carriage return (0Dh), which must be removed for comparison.
    mov edi, OFFSET buffer  ; Point EDI to start of input
    mov ecx, 100            ; Set search limit
    mov al, 0Dh             ; Byte to find (Carriage Return)
    repne scasb             ; Scan buffer for 0Dh
    dec edi                 ; Move pointer back to position of 0Dh
    mov byte ptr [edi], 0   ; Replace with null terminator (string end)

    ; --- Calculate Elapsed Seconds ---
    mov eax, endTime
    sub eax, startTime      ; Difference in milliseconds
    xor edx, edx            ; Clear EDX for division
    mov ebx, 1000
    div ebx                 ; EAX = ms / 1000
    
    .if eax == 0            ; Prevent division by zero
        mov eax, 1
    .endif
    mov elapsed, eax

    ; --- Compare Input ---
    ; lstrcmpi performs case-insensitive comparison
    invoke lstrcmpi, ADDR buffer, ADDR sentence
    
    .if eax == 0            ; lstrcmpi returns 0 if strings are equal
        invoke StdOut, ADDR correctMsg
    .else
        invoke StdOut, ADDR wrongMsg
    .endif

    ; --- Display Time ---
    invoke StdOut, ADDR timeMsg
    invoke dwtoa, elapsed, ADDR timeBuffer  ; Convert DWORD to ASCII string
    invoke StdOut, ADDR timeBuffer
    invoke StdOut, ADDR newline

    ; --- Calculate WPM ---
    ; Logic: (Total Characters / 5) * (60 / Seconds)
    ; Optimized constant: (24 chars / 5) * 60 = 288
    mov eax, 288
    xor edx, edx
    div elapsed             ; EAX = 288 / elapsed
    mov wpm, eax

    ; --- Display WPM ---
    invoke StdOut, ADDR wpmMsg
    invoke dwtoa, wpm, ADDR wpmBuffer
    invoke StdOut, ADDR wpmBuffer
    invoke StdOut, ADDR newline

    ; --- Exit Program ---
    invoke ExitProcess, 0
end main