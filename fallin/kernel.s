SHIFTINTERVAL = 1
SHIFTLEFT = $80
COLOR = $81


    processor 6502
    include "vcs.h"
    include "macro.h"

    SEG
    ORG $F000

Reset
    ; set background to green and playfield to lavender

    lda #0
    sta COLUBK

    lda #$58
    sta COLUPF

    lda #%1
    sta CTRLPF

    ldx #SHIFTINTERVAL
    stx SHIFTLEFT

    ldx #0
    stx COLOR

    ldy #0

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

    dec SHIFTLEFT
    ldy #0
    bne BeforeVBlank
        ; reset shift counter and increment y

        ldx #SHIFTINTERVAL
        stx SHIFTLEFT
        inc COLOR
        ldy COLOR

BeforeVBlank:
    ldx #37

VBlankLoop:
      ; 37 scanlines of vertical blank
        dex
        sta WSYNC

        bne VBlankLoop

    ldx #192

DrawLoop:
      ; 192 pictures scanlines, increment color on each one
        iny
        dex
        sty COLUBK
        sta WSYNC

        bne DrawLoop

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