    processor 6502
    include "vcs.h"
    include "macro.h"

    SEG
    ORG $F000

; chars are 32x32
; 
;   x x
; 
;   x x
;   xxx
;

Reset
    ; set background to green and playfield to lavender

    lda #$B8
    sta COLUBK

    lda #$58
    sta COLUPF

    lda #%1
    sta CTRLPF

StartOfFrame
  ; Start of vertical blank processing
    
    lda #0
    sta VBLANK

    lda #2
    sta VSYNC
        ; 3 scanlines of VSYNCH signal

        sta WSYNC
        sta WSYNC
        sta WSYNC
    
    lda #0
    sta VSYNC

    ldx #37

VBlankLoop:
      ; 37 scanlines of vertical blank
        dex
        sta WSYNC

        bne VBlankLoop

    ldx #32

PreEyes:
      ; 32 scanlines of background
        dex
        sta WSYNC
    
        bne PreEyes

    lda #0  
    ldy #$F 

            ; 00000000111111110000
    sta PF0
    sty PF1 ; #%00001111 (MSB first)
    sty PF2 ; #%00001111 (LSB first)

    ldx #32

Eyes:
      ; 32 scanlines of eyes on playfield
        dex
        sta WSYNC

        bne Eyes

    sta PF1
    sta PF2

    ldx #32

AfterEyes:
      ; 32 scanlines of background
        dex
        sta WSYNC

        bne AfterEyes

    sty PF1
    sty PF2

    ldx #32

MouthCorners:
      ; 32 scanlines of mouth corners
        dex
        sta WSYNC

        bne MouthCorners

    ldx #$FF

    sty PF1
    stx PF2

    ldx #32

MouthProper:
      ; 32 scanlines of mouth
        dex
        sta WSYNC

        bne MouthProper

    sta PF1
    sta PF2

    ldx #32

AfterMouth:
      ; final 32 scanlines of picture
        dex
        sta WSYNC

        bne AfterMouth

    ldx #30

OverscanLoop:
      ; 30 scanlines of overscan
        dex
        sta WSYNC

        bne OverscanLoop


    lda #%01000010
    sta VBLANK      ; end of screen - enter blanking

    jmp StartOfFrame


    ORG $FFFA

    .word Reset     ; NMI
    .word Reset     ; RESET
    .word Reset     ; IRQ


    END