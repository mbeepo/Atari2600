    processor 6502
    include "vcs.h"
    include "macro.h"

    SEG
    ORG $F000

Reset
      ; set player 0 color to solid white
        lda #$0F
        sta COLUP0

        lda #$FF
        sta GRP0

      ; set background to green and playfield to lavender
        lda #$B8
        sta COLUBK

        lda #$58
        sta COLUPF

      ; enable playfield mirroring
        lda #%1
        sta CTRLPF

      ; set port A to input
        lda #0
        sta SWACNT
    

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

    lda #%01000010
    sta VBLANK      ; end of picture - enter blanking

Overscan0:
      ; 30 scanlines of overscan
      ; set timer to 3 at a 1024 cycle interval
      ; do stuff then wait for it to overflow
      ; set timer to 4 at a 64 cycle interval
      ; wait for it to overflow then strobe WSYNC
        lda #3
        sta T1024T

        ldx SWCHA
        
      ; check if joystick moved left
        txa
        and #%01000000
        beq MoveLeft

      ; check if joystick moved right
        txa
        and #%10000000
        bne Overscan1
        lda #$D0
        sta HMP0
        sta WSYNC
        sta HMOVE

        lda #$0F
        sta COLUP0
    
Overscan1:
        sta WSYNC
        lda INTIM
        bne Overscan1
        lda #4
        sta TIM64T

Overscan2:
        sta WSYNC
        lda INTIM
        bne Overscan2

    jmp StartOfFrame

MoveLeft:
        lda #$20
        sta HMP0
        sta WSYNC
        sta HMOVE
        
        lda #0
        sta COLUP0

    jmp Overscan1

    ORG $FFFA

    .word Reset     ; NMI
    .word Reset     ; RESET
    .word Reset     ; IRQ

    END