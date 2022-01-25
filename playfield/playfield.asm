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

    REPEAT 3
        sta WSYNC
    REPEND

    lda #0
    sta VSYNC ; turn off VSYNC

    REPEAT 37
        sta WSYNC ;
    REPEND
    lda #0
    sta VBLANK ; turn off VBLANK

    ldx #%00000001 ; CTRLPF register to allow reflection
    stx CTRLPF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Let's start drawing on the screen finally :)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ldx #0 ; draw the first 7 lines as backgroung by skipping to set the PF
    stx PF0 
    stx PF1
    stx PF2
    REPEAT 7
        sta WSYNC ; next scanline please
    REPEND

    ldx #%11100000
    stx PF0

    ldx #%11111111
    stx PF1
    stx PF2

    REPEAT 7
        sta WSYNC
    REPEND

    ldx #%11100000
    stx PF0

    ldx #0
    stx PF1
    stx PF2

    REPEAT 164
        sta WSYNC
    REPEND

    ldx #%11100000
    stx PF0

    ldx #%11111111
    stx PF1
    stx PF2

    REPEAT 7
        sta WSYNC
    REPEND

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 30 lines for the overscan..
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #2
    sta VBLANK

    REPEAT 30
       sta WSYNC
    REPEND
    lda #0
    sta VBLANK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Complete the ROM size 4Kb
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    jmp NEXT_FRAME

    org $FFFC ; End the ROM by adding required values to memory position $FFFC
    .word RESET ; Put 2 bytes with the reset address at memory position $FFFC
    .word RESET ; Put 2 bytes with the break address at memory position $FFFE