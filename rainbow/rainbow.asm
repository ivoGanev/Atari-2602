    processor 6502

    include "vcs.h"
    include "macro.h"
    
    seg Code ; Define a new segment named "Code"
    org $F000 ; Define the origin of the ROM code at memory address $F000

START: 
    CLEAN_START ; Macro to safely clear the entire memory

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start a new frame by turning on VBLANC and VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
NEXT_FRAME:
    lda #%0010
    sta VBLANK ; enable VBLACK
    sta VSYNC  ; enable VSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Generate the three lines of VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    sta WSYNC ; TIA halt and wait for the scanline to complete rendering
    sta WSYNC ; wait for the next scanline
    sta WSYNC ; wait for the next scanline
    
    lda #0
    sta VSYNC ; disable VSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Let TIA output the recommended 37 lines of VBLANK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ldx #37
LOOP_V_BLANK:
    sta WSYNC ; hit WSYNC again and wait for the next scanline
    dex
    bne LOOP_V_BLANK

    lda #0
    sta VBLANK ; turn off VBLANK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Draw 192 visible scanlines (kernel)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ldx #192
LOOP_SCANLINES:
    stx COLUBK ; paint the background color
    sta WSYNC ; wait for the next scanline
    dex
    bne LOOP_SCANLINES

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Finally output the rest of the VBLANK scanlines (overscan) to complete the frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    lda #2
    sta VBLANK ; turn on VBLANK again
    
    ldx #30
LOOP_OVERSCAN:
    stx WSYNC ; wait for the next scanline
    dex
    bne LOOP_OVERSCAN

    jmp NEXT_FRAME

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Complete the ROM size 4Kb
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    org $FFFC ; End the ROM by adding required values to memory position $FFFC
    .word START ; Put 2 bytes with the reset address at memory position $FFFC
    .word START ; Put 2 bytes with the break address at memory position $FFFE