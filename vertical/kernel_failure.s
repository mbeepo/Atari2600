; this was an attempt to make a better guy but it ended up branching too much

PLAYERY = $80       ; the scanline the player is currently on. must exist so PLAYERIN can be reset in vblank
PLAYERACTIVE = $81  ; this will be set to 8 and decremented each scanline when the player should be drawn, and 128 until then
PLAYERIN = $82      ; the number of scanlines left before the player will be rendered

PLAYERHEIGHT = 8

SPEEDX = 2
SPEEDY = 2

COLORLEFT = $00
COLORRIGHT = $0F
COLORUP = $08
COLORDOWN = $80
    
SPEEDLEFT = SPEEDX << 4
SPEEDRIGHT = $100 - SPEEDLEFT
PLAYERHEIGHTR = PLAYERHEIGHT >> 1

    processor 6502
    include "vcs.h"
    include "macro.h"
    
    SEG
    ORG $F000
    .byte SPEEDRIGHT

Reset
      ; set player color to solid white
        lda #$0F
        sta COLUP0

      ; hide the player to start
        lda #0
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

      ; set player y to 8
        lda #8
        sta PLAYERY

      ; set player to not yet drawn
        lda #$80
        sta PLAYERACTIVE

      ; placeholder value until we get to vblank
        lda #$FF
        sta PLAYERIN

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

    ldx #36

VBlankLoop:
      ; 36 scanlines of vertical blank
        dex
        sta WSYNC

        bne VBlankLoop
    
    lda PLAYERY
    sta PLAYERIN

    lda #$80
    sta PLAYERACTIVE

    sta WSYNC

    lda #%01000000
    sta VBLANK

    ldx #32
    lda #0

PreEyes0:
      ; 32 scanlines of background
        dex
        sta WSYNC
        beq PreEyes1
        jsr TryDrawPlayer
        beq PreEyes1
        jmp PreEyes0

PreEyes1:
    lda #0  
    ldy #$F 

            ; 00000000111111110000
    sta PF0
    sty PF1 ; #%00001111 (MSB first)
    sty PF2 ; #%00001111 (LSB first)

    ldx #32
    txa

Eyes0:
      ; 32 scanlines of eyes on playfield
        dex
        sta WSYNC
        beq Eyes1
        jsr TryDrawPlayer
        beq Eyes1
        jmp Eyes0

Eyes1:
    lda #0
    sta PF1
    sta PF2

    ldx #32
    lda #64

AfterEyes0:
      ; 32 scanlines of background
        dex
        sta WSYNC
        beq AfterEyes1
        jsr TryDrawPlayer
        beq AfterEyes1
        jmp AfterEyes0
    
AfterEyes1:
    ldy #$F

    sty PF1
    sty PF2

    ldx #32
    lda #96

MouthCorners0:
      ; 32 scanlines of mouth corners
        dex
        sta WSYNC
        beq MouthCorners1
        jsr TryDrawPlayer
        jmp MouthCorners0

MouthCorners1:
    ldy #$F
    ldx #$FF

    sty PF1
    stx PF2

    ldx #32
    lda #128

MouthProper0:
      ; 32 scanlines of mouth
        dex
        sta WSYNC
        beq MouthProper1
        jsr TryDrawPlayer
        jmp MouthProper0

MouthProper1:
    lda #0

    sta PF1
    sta PF2

    ldx #32
    lda #160

AfterMouth0:
      ; final 32 scanlines of picture
        dex
        sta WSYNC
        beq AfterMouth1
        jsr TryDrawPlayer
        jmp AfterMouth0
    
AfterMouth1:
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
        
      ; joystick is left
        txa
        and #%01000000
        php
        
        lda #SPEEDLEFT
        ldy #COLORLEFT
        plp

        beq MoveSide

      ; joystick is right
        txa
        and #%10000000
        php

        lda #SPEEDRIGHT
        ldy #COLORRIGHT
        plp

        beq MoveSide

OverscanVert:
      ; joystick is up
        txa
        and #%10000
        php

        lda PLAYERY
        sec
        sbc #SPEEDY
        ldy #COLORUP
        plp

        beq MoveVert

      ; joystick is down
        txa
        and #%100000
        php

        lda PLAYERY
        clc
        adc #SPEEDY
        ldy #COLORDOWN
        plp

        beq MoveVert
    
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

MoveSide:
        sta HMP0
        sta WSYNC
        sta HMOVE
        
        sty COLUP0

        jmp OverscanVert

MoveVert:
        sta PLAYERY
        sty COLUP0

        jmp Overscan1

Return:
    lda #1 ; clear the Z flag so the caller doesn't exit early
    rts

TryDrawPlayer:
      ; if PLAYERACTIVE is 0, the player has already been drawn
        lda PLAYERACTIVE
        beq EndDrawPlayer

DrawPlayer0:
      ; if PLAYERACTIVE.7 is set, the player has not been drawn yet
      ; therefore if it is not set, the player is currently being drawn
        bit PLAYERACTIVE
        bmi PollPlayer
        lda PLAYERACTIVE
        and #PLAYERHEIGHTR
        bne DrawPlayer1
        dec PLAYERACTIVE
        beq EndDrawPlayer

DrawPlayer1:
        ldy #$FF
        dex
        sta WSYNC
        sty GRP0
        rts

EndDrawPlayer:
        ldy #0
        dex
        sta WSYNC
        sty GRP0
        rts

PollPlayer:
      ; check if the player is on the next scanline
        dec PLAYERIN
        bne Return

StartDrawPlayer:
        lda #PLAYERHEIGHTR
        sta PLAYERACTIVE
        lda #1
        rts


    ORG $FFFA

    .word Reset     ; NMI
    .word Reset     ; RESET
    .word Reset     ; IRQ

    END