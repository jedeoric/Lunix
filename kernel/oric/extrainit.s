#ifdef WANT_INIT_CMD_STRING
		;; init prompt help
		.text "test (k)assette / dump (m)emory allocs"
#else
		cmp #"k"
		beq k7test
		cmp #"m"
		beq dump_mem
		jmp bad_cmd
		
	-	nop
	jmp -
k7test:
		;; ATMOS only test
		lda #MEMCONF_ROM
		jsr oric_setmemconf
		ldy #16
		jsr $e735			; GETSYN
	-	jsr $e6c9			; RDBYTE
		jsr hexout
		dey
		bpl -
		ldy #16
		lda #$0a
		jsr printk
		jmp -

freecnt:
		.byte 0

dump_mem:
		ldy #0
		sty freecnt
dm1:
		lda lk_memmap,y
		ldx #8
	-	
		rol a
		pha
		lda #"."			; used block
		bcc +
		lda #"F"			; free block
		inc freecnt
	+	jsr printk
		pla
		
		dex
		bne -
		
		tya
		and #01
		beq +
		lda #$0a
		jsr printk
	+	
		iny
		cpy #32
		bne dm1
		
		lda #"$"
		jsr printk
		lda freecnt
		jsr hexout
		ldx console_fd
		bit freemsg
		jsr strout
		jmp ploop
freemsg:
		.text " free pages",$0a,0

bad_cmd:
	
#endif
