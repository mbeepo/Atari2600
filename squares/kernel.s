    processor 6502
    include "vcs.h"
    include "macro.h"



    SEG
    ORG $F000

Reset:


StartOfFrame
      ; start of vertical blank processing  
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

    lda #%01000010
    sta VBLANK ; enable vblank for rest of blanking period

    ldx #37

VBlankLoop:
      ; 37 scanlines of vertical blank
        dex
        sta WSYNC

        bne VBlankLoop

    lda #%01000000
    sta VBLANK

    lda #%01000010
    sta VBLANK      ; end of screen - enter blanking

Overscan:
      ; 30 scanlines of overscan
        dex
        sta WSYNC

        bne Overscan

    jmp StartOfFrame


    ORG $FFFA

    .word Reset     ; NMI
    .word Reset     ; RESET
    .word Reset     ; IRQ


    END