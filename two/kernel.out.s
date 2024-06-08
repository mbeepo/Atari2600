  ; stella emulator seems unhappy with the rom dasm makes from this
  ; sometimes it draws the player as it should, other times it draws little clones of it on other scanlines
PLAYER0HEIGHT = 16
PLAYER1HEIGHT = 16
COLORLEFT = $00
COLORRIGHT = $0F
COLORUP = $08
COLORDOWN = $81
SPEEDX = 2
SPEEDY = 2

PLAYER0Y = $80
PLAYER0SPRITE = $81 ; the sprite to draw this scanline for player 0
PLAYER0STAT = $82   ; 0 if not yet drawn, 128 if currently drawing, 64 if fully drawn
PLAYER0LEFT = $83   ; if PLAYER0STAT is 64, this is how many scanlines are left to draw it on
PLAYER0UNTIL = $84  ; number of scanlines until player 0 will start being drawn
PLAYER1Y = $88
PLAYER1SPRITE = $89 ; the sprite to draw this scanline for player 1
PLAYER1STAT = $8A   ; 0 if not yet drawn, 128 if currently drawing, 64 if fully drawn
PLAYER1LEFT = $8B   ; if PLAYER1STAT is 64, this is how many scanlines are left to draw it on
PLAYER1UNTIL = $8C  ; number of scanlines until player 1 will start being drawn

SECTIONEND = $90   ; pointer to little endian return address for each section
SECTIONENDM = $91
    
SPEEDLEFT = SPEEDX << 4
SPEEDRIGHT = $100 - SPEEDLEFT

SECTIONAMT = 6
SECTION0 = %00000000000000000000
SECTION1 = %00000000111111110000
SECTION2 = %00000000000000000000
SECTION3 = %00000000111111110000
SECTION4 = %00000000111111111111
SECTION5 = %00000000000000000000

SECTIONHEIGHT = 192 / SECTIONAMT
SECTIONMOD = 192 % SECTIONAMT


    processor 6502
    include "vcs.h"
    include "macro.h"
    
    SEG
    ORG $F000

Reset
      ; set player 0 color to COLORRIGHT
        lda #COLORRIGHT
        sta COLUP0
        
      ; set player 1 color to COLORLEFT
        lda #COLORLEFT
        sta COLUP1

      ; hide the player to start
        lda #0
        sta GRP0
        sta GRP1

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

      ; set player 0 y to 8
        lda #8
        sta PLAYER0Y

      ; set player 1 y to 32
        lda #32
        sta PLAYER1Y

      ; set player 1 to not draw yet
        lda #0
        sta PLAYER1SPRITE

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

  ; initialize player status to not yet drawn
    lda #0
    sta PLAYER0STAT
    sta PLAYER1STAT

    ldx #37

VBlankLoop:
      ; 37 scanlines of vertical blank
        dex
        sta WSYNC

        bne VBlankLoop

    lda #%01000000
    sta VBLANK

    lda #0
    sta PLAYER0STAT
    sta PLAYER1STAT

    lda PLAYER0Y
    sta PLAYER0UNTIL

    lda PLAYER1Y
    sta PLAYER1UNTIL

  ; {1} - section number
    MACRO PREP

        lda >{1} >> 16
        ldx >{1} >> 8
        ldy [>{1} * $0202020202 & $010884422010] % 1023

        sta PF0
        stx PF1
        sty PF2

    ENDM

; ----- GENERATED SECTION -----

      ; --- Section 0 ---
        SUBROUTINE
        PREP SECTION0

        lda #>.CurrentEnd
        sta SECTIONEND
        lda #<.CurrentEnd
        sta SECTIONENDM

        lda #SECTIONHEIGHT

        jmp SectionPlayer0
.CurrentEnd

      ; --- Section 1 ---
        SUBROUTINE
        PREP SECTION1

        lda #>.CurrentEnd
        sta SECTIONEND
        lda #<.CurrentEnd
        sta SECTIONENDM

        lda #SECTIONHEIGHT

        jmp SectionPlayer0
.CurrentEnd

      ; --- Section 2 ---
        SUBROUTINE
        PREP SECTION2

        lda #>.CurrentEnd
        sta SECTIONEND
        lda #<.CurrentEnd
        sta SECTIONENDM

        lda #SECTIONHEIGHT

        jmp SectionPlayer0
.CurrentEnd

      ; --- Section 3 ---
        SUBROUTINE
        PREP SECTION3

        lda #>.CurrentEnd
        sta SECTIONEND
        lda #<.CurrentEnd
        sta SECTIONENDM

        lda #SECTIONHEIGHT

        jmp SectionPlayer0
.CurrentEnd

      ; --- Section 4 ---
        SUBROUTINE
        PREP SECTION4

        lda #>.CurrentEnd
        sta SECTIONEND
        lda #<.CurrentEnd
        sta SECTIONENDM

        lda #SECTIONHEIGHT

        jmp SectionPlayer0
.CurrentEnd

      ; --- Section 5 ---
        SUBROUTINE
        PREP SECTION5

        lda #>.CurrentEnd
        sta SECTIONEND
        lda #<.CurrentEnd
        sta SECTIONENDM

        lda #SECTIONHEIGHT

        jmp SectionPlayer0
.CurrentEnd
; ----- END OF GENERATED -----

Overscan0:
      ; 30 scanlines of overscan
      ; set timer to 3 at a 1024 cycle interval
      ; do stuff then wait for it to overflow
      ; set timer to 4 at a 64 cycle interval
      ; wait for it to overflow then strobe WSYNC
        lda #3
        sta T1024T

        ldx SWCHA
        
      ; joystick 0 is left
        txa
        and #%01000000
        php
        
        lda #SPEEDLEFT
        ldy #COLORLEFT
        plp

        beq MoveSide0

      ; joystick 0 is right
        txa
        and #%10000000
        php

        lda #SPEEDRIGHT
        ldy #COLORRIGHT
        plp

        beq MoveSide0

Overscan0Vert:
      ; joystick 0 is up
        txa
        and #%10000
        php

        lda PLAYER0Y
        sec
        sbc #SPEEDY
        ldy #COLORUP
        plp

        beq MoveVert0

      ; joystick 0 is down
        txa
        and #%100000
        php

        lda PLAYER0Y
        clc
        adc #SPEEDY
        ldy #COLORDOWN
        plp

        beq MoveVert0
    
Overscan1:
        ldx SWCHA
        
      ; joystick 1 is left
        txa
        and #%100
        php
        
        lda #SPEEDLEFT
        ldy #COLORLEFT
        plp

        beq MoveSide1

      ; joystick 1 is right
        txa
        and #%1000
        php

        lda #SPEEDRIGHT
        ldy #COLORRIGHT
        plp

        beq MoveSide1

Overscan1Vert:
      ; joystick 1 is up
        txa
        and #%1
        php

        lda PLAYER1Y
        sec
        sbc #SPEEDY
        ldy #COLORUP
        plp

        beq MoveVert1

      ; joystick 1 is down
        txa
        and #%10
        php

        lda PLAYER1Y
        clc
        adc #SPEEDY
        ldy #COLORDOWN
        plp

        beq MoveVert1
    
OverscanWaitLong:
        sta WSYNC
        lda INTIM
        bne OverscanWaitLong
        lda #4
        sta TIM64T

OverscanWaitShort:
        sta WSYNC
        lda INTIM
        bne OverscanWaitShort

    jmp StartOfFrame

MoveSide0:
        sta HMP0
        sta WSYNC
        sta HMOVE
        
        sty COLUP0

        jmp Overscan0Vert

MoveVert0:
        sta PLAYER0Y
        sty COLUP0

        jmp Overscan1

MoveSide1:
        sta HMP1
        sta WSYNC
        sta HMOVE
        
        sty COLUP1

        jmp Overscan0Vert

MoveVert1:
        sta PLAYER1Y
        sty COLUP1

        jmp Overscan1
    
; this will wait X scanlines and draw players if needed
; make sure to set SECTIONEND to the return address and 
SectionPlayer0:
        ldy PLAYER0STAT
        bmi SectionPlayer0Dec
        bne SectionPlayer1

        dec PLAYER0UNTIL
        bne SectionPlayer1

        ldy #128
        sty PLAYER0STAT

        ldy #PLAYER0HEIGHT
        sty PLAYER0LEFT

        ldy #$FF
        sty PLAYER0SPRITE

SectionPlayer1:
        ldy PLAYER1STAT
        bmi SectionPlayer1Dec
        bne SectionEnd

        dec PLAYER1UNTIL
        bne SectionEnd

        ldy #128
        sty PLAYER1STAT

        ldy #PLAYER1HEIGHT
        sty PLAYER1LEFT

        ldy #$FF
        sty PLAYER1SPRITE

SectionEnd:
        dex
        sta WSYNC
        ldy PLAYER0SPRITE
        sty GRP0
        ldy PLAYER1SPRITE
        sty GRP1
        bne SectionPlayer0

Return:
        jmp (SECTIONEND)

SectionPlayer0Dec:
        dec PLAYER0LEFT
        bne SectionPlayer0

        ldy #64
        sty PLAYER0STAT
        ldy #0
        sty PLAYER0SPRITE
        jmp SectionPlayer0

SectionPlayer1Dec:
        dec PLAYER1LEFT
        bne SectionPlayer1

        ldy #64
        sty PLAYER1STAT
        ldy #0
        sty PLAYER1SPRITE
        jmp SectionPlayer1


    ORG $FFFA

    .word Reset     ; NMI
    .word Reset     ; RESET
    .word Reset     ; IRQ

