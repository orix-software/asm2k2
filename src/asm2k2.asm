.org $800-20
; include header
        .byt $01,$00		; non-C64 marker like o65 format
        .byt "o", "r", "i"      ; "ori" MAGIC number :$6f, $36, $35 like o65 format
        .byt $01                ; version of this header
cpu_mode:
        .byt $00                ; CPU see below for description
os_type:
        ; 0 : Orix
        ; 1 : Sedoric
        ; 2 : Stratsed
        ; 3 : FTDOS
        .byt $00	        ; 
        .byt $00                ; reserved
 
        .byt $00		; reserved
        .byt $00	        ; operating system id for telemon $00 means telemon 3.0 version
        .byt $00	        ; reserved
        .byt $00                ; reserved
type_of_file:
        ; bit 0 : basic
        ; bit 1 : machine langage
        .byt %00000000                   ; 
        .byt <start_adress,>start_adress ; loading adress
        .byt <EndOfMemory,>EndOfMemory   ; end of loading adress
        .byt <start_adress,>start_adress ; starting adress
 
.include "telestrat.inc"

start_adress:

    sei
    lda     #$00
    sta     $321
    ldx     #$00
@L1:    
    lda     loaderbin,x
    sta     $FC00,x
    lda     loaderbin+256,x
    sta     $FD00,x    
    inx
    bne     @L1


SOFT_HIRES:
	LDY #$00		;COPY CHARSET
HM_03:
	LDA $B500,Y
	STA $9900,Y
	LDA $B600,Y
	STA $9A00,Y
	LDA $B700,Y
	STA $9B00,Y
	LDA $B900,Y
	STA $9D00,Y
	LDA $BA00,Y
	STA $9E00,Y
	LDA $BB00,Y
	STA $9F00,Y
	DEY
	BNE HM_03
	LDA #$A0             ;CLEAR DOWN ALL MEMORY AREA WITH ZERO
    STA $01
	LDA #$00
    STA $00
	LDX #$20
HM_01:
    STA ($00),Y
	INY
	BNE HM_01
	INC $01
	DEX
	BNE HM_01
	LDA #30		;WRITE HIRES SWITCH
	STA $BF40
	LDA #$A0		;CLEAR HIRES WITH #$40
	STA $01
	LDX #$20
	LDX #64
HM_04:
	LDY #124
HM_05:
	LDA #$40
	STA ($00),Y
	DEY
	BPL HM_05
	LDA $00
	ADC #125
	STA $00
	BCC HM_02
	INC $01
HM_02:
    DEX
	BNE HM_04

    lda     #$a0
    sta     $01
    lda     #$00
    sta     $00    

    lda     #<$8AE
    sta     $02
    lda     #>$8AE
    sta     $03 

    LDY     #$00
    ldx     #31
L1:    
    lda     ($02),y
    sta     ($00),y
    iny
    bne     L1
    inc     $01
    inc     $03
    dex
    BNE     L1

    jsr     wait


    
    jmp     $FC00

wait:
    ldx #$00
    ldy #$00
@L1:
    nop
    nop
    nop
    nop
    dex
    bne @L1
    dey
    bne @L1
    rts
    
picture:
    .incbin "picture.hir"
music:
    .incbin "music.bin"
loaderbin:   
    .incbin  "loader.o"    
.out     .sprintf("Picture : $%x",picture ) 
.out     .sprintf("music : $%x",music ) 

;.incbin "loader.o"    
EndOfMemory:
