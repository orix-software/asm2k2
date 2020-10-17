



.importzp ptr3,ptr1,ptr2

.org $FC00


Initialize:
	sei ; Stop IRQ CPU
	lda #$7F ; Stop VIA interrupt
	sta $030D



    

; music
    ldy     #$00

    lda     #$C0
    sta     $01
    lda     #$00
    sta     $00    

    lda     #<$27EE
    sta     $02
    lda     #>$27EE
    sta     $03 

    ldx     #50
LL2:    
    lda     ($02),y
    sta     ($00),y
    iny
    bne     LL2
    inc     $01
    inc     $03
    dex
    BNE     LL2

    jsr     _twil_program_rambank
  ;  jmp     $600
nextme:
jmp    next



    lda     #$06
    sta     $01
    lda     #$00
    sta     $00    

    lda     #<$27EE
    sta     $02
    lda     #>$27EE
    sta     $03 

    LDY     #$00
    ldx     #100
L1:    
    lda     ($02),y
    sta     ($00),y
    iny
    bne     L1
    inc     $01
    inc     $03
    dex
    BNE     L1
    ;jsr start_6522 
    ;cli
    jmp     $600


next:




;	ldx #0 ; load the Music
;	jsr begin_loading

;	ldx #2
;	jsr begin_loading

	lda #$60 ; ?
	sta $400 ; ?

	

	jsr start_6522 ;this will setup the 6522 (Not the music, as u said!)
	lda #<new_irq ;Redirect (Low) IRQ vector to the address of new_irq
	sta $fffe
	lda #>new_irq ;Redirect (High) IRQ vector to the address of new_irq
	sta $ffff
	jsr $c010 ;This will setup for Music Pattern 1, and CLI!!

    jmp $600





;	jsr $600


new_irq:
	PHA
	TXA
	PHA
	TYA
	PHA
	JSR $400 ;No need to worry about restoring registers!
	LDA $0304
	pla
	tay
	pla
	tax
	pla
	jmp $c035 ;This will process music then finish the irq (RTI)
	;


start_6522:
    lda #247
    sta $302
    LDA #255
    STA $0303 ;SET DDRA TO ALL OUT
    LDA #$7F ;DISABLE ALL IRQ'S
    STA $030E
    LDA #$C0 ;ENABLE JUST T1 IRQ
    STA $030E
    LDA #$40 ;SET T1 MODE TO CONTINUOUS IRQ'S
    STA $030B
    LDA #$10 ;SET T1 LATCH TO 10,000
    STA $0306
    LDA #$27
    STA $0307
    LDA #$DD
    STA $030C
    rts

irq_reset:
	.byt $40 ; RTI opcode
path:
    .asciiz "/usr/share/asm2k2/loadere.bin"
file:
    .asciiz "/loadere.bin"

opcode_rti:
	.byt $40


.include "../dependencies/ch376-lib/src/_ch376_wait_response.s"
.include "../dependencies/ch376-lib/src/_ch376_set_bytes_read.s"
.include "../dependencies/ch376-lib/src/_ch376_file_open.s"

.proc _twil_program_rambank


    lda     #<path
    ldx     #>path
	sta     ptr1
	stx		ptr1+1


    lda     #CH376_SET_FILE_NAME        ;$2f
    sta     CH376_COMMAND
    lda     #'/'

    sta     CH376_DATA
	lda		#$00
    sta     CH376_DATA
	jsr		_ch376_file_open


reset_label:

    lda     #CH376_SET_FILE_NAME        ;$2f
    sta     CH376_COMMAND

	ldy		#$00
@L1:	
	lda     (ptr1),y
    beq 	@S1

    cmp     #'/'
    beq     @open_slash
  	
  	cmp     #'a'                        ; 'a'
  	bcc     @do_not_uppercase
  	cmp     #'z'+1                        ; 'z'
  	bcs     @do_not_uppercase
  	sbc     #$1F
@do_not_uppercase:
	sta		CH376_DATA
	iny
	bne		@L1
	lda		#$00
@S1:
	sta		CH376_DATA
	
	jsr		_ch376_file_open

    cmp		#CH376_ERR_MISS_FILE
    bne 	start

	rts
@open_slash:
    lda     #$00
	sta		CH376_DATA
	sty     savey
	jsr		_ch376_file_open

    lda     #CH376_SET_FILE_NAME        ;$2f
    sta     CH376_COMMAND

    ldy     savey
    iny
    
    cmp		#CH376_ERR_MISS_FILE
    bne 	@L1

    rts    
savey:
    .res 1
start:



	lda		#$00
	sta		ptr3

	lda		#$06
	sta		ptr3+1	

    lda		#$00
    ldy     #$9A
    jsr		_ch376_set_bytes_read

@loop:
    cmp		#CH376_USB_INT_DISK_READ
    bne		@finished

    lda		#CH376_RD_USB_DATA0
    sta		CH376_COMMAND
    lda		CH376_DATA
	sta		nb_bytes
    ; Tester si userzp == 0?

    ldy    #$00

  @read_byte:
	
    lda		CH376_DATA
	sta		(ptr3),y
    iny

@skip_change_bank:

    dec		nb_bytes
    bne		@read_byte
    
    tya     
    clc
    adc     ptr3
    bcc     @skip_inc
    inc     ptr3+1
@skip_inc:
    sta     ptr3    

    lda		#CH376_BYTE_RD_GO
    sta		CH376_COMMAND
    jsr		_ch376_wait_response

    ; _ch376_wait_response renvoie 1 en cas d'erreur et le CH376 ne renvoie pas de valeur 0
    ; donc le bne devient un saut inconditionnel!
    bne		@loop
 @finished:





	rts


str_slash:
	.asciiz "/"

.endproc

nb_bytes:
    .res    1