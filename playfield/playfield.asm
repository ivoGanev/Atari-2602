    processor 6502

    include "vcs.h"
    include "macro.h"
    
    seg Code ; Define a new segment named "Code"
    org $F000 ; Define the origin of the ROM code at memory address $F000

RESET: 
    CLEAN_START ; Macro to safely clear the entire memory

    ldx #$80   ; blue background
    stx COLUBK ; background color

    lda #$1C   ; yellow playfield
    sta COLUPF ; playfield color
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start a new frame by turning on VBLANC and VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
NEXT_FRAME:
    lda #02   
    sta VBLANK ; turn on VBLANK
    sta VSYNC  ; turn on VSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Complete the ROM size 4Kb
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    jmp NEXT_FRAME

    org $FFFC ; End the ROM by adding required values to memory position $FFFC
    .word RESET ; Put 2 bytes with the reset address at memory position $FFFC
    .word RESET ; Put 2 bytes with the break address at memory position $FFFE