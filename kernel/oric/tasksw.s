		;; For emacs: -*- MODE: asm; tab-width: 4; -*-

	lda VIA1_TALO

		lda  lk_ipid
		bmi  _idle			; skip next, if we're idle

		;; add CPU time spent to task's time
		;;  5 bytes -> overflow after 12 days, 22 hours, 4 minutes, ...

;		;; This is disabled since Atari has no precise timer to read
;		;; 1/[56]0s timer could be used to provide some kind of generalization
;		;; But who the fuck cares? All in all tsp_time is currently for information
;		;; purposes only
;		lda  #0
;		sta  CIA1_CRB           ; stop timer2 of CIA1
;		ldy  #tsp_time
;		sec
;		lda  (lk_tsp),y
;		sbc  CIA1_TBLO
;		sta  (lk_tsp),y         ; add to time0
;		iny
;		lda  (lk_tsp),y
;		sbc  CIA1_TBHI
;		sta  (lk_tsp),y         ; add to time1
;		ldx  #3
;	-	bcc  +
;		iny
;		lda  (lk_tsp),y
;		adc  #0
;		sta  (lk_tsp),y         ; increase time2,3,4
;		dex
;		bne  -

		dec  lk_timer
		beq  do_taskswitch		; end of time slice, so switch

_checktimer:
;	lda #%00000001
;	sta $BB80+40+28
;	lda #%00010000
;	sta $BB80+40+29
;	lda $BB80+40+30
;	and #%00100000
;	ora #"I"
;	eor #%00100000
;	sta $BB80+40+30
		lda  VIA1_IFR			; check IRQ source
		tax
		and  #%01000000			; was it timer IRQ?
		bne  +				; yes!
		jmp +

		txa
		and  #%00100000		; timer 2
		beq  _irq_end			; it wasn't timer2 IRQ either - forget it
		txa
;		jsr  keyb_scan
		jmp  _irq_end
	+
		;jsr  keyb_scan
		inc  lk_systic			; system ticks (overflow after 72.8h)
		bne  +
		inc  lk_systic+1		; (nearly counts seconds/4)
		bne  +
		inc  lk_systic+2
	+	inc  lk_sleepcnt		; time to wakeup a sleeping task ?
		bne  _irq_jobptr		; (not jet)
		inc  lk_sleepcnt+1
		bne  _irq_jobptr		; (not jet)
		jsr  _wakeup			; Yes!

_irq_jobptr:
		bit  $ffff			; placeholder for up to 3 IRQ routines
		bit  $ffff			; all called once every 1/64 second
		bit  $ffff

_irq_end:
	- +	lda  VIA1_T1LO			; acknowledge timer 1 interrupt
		;lda  #%11000000			; acknowledge timer 1 interrupts
		;sta  VIA1_IFR
		pla
		SETMEMCONF			; switch to task's memory configuration
		pla
		tay
		pla
		tax
		pla
		rti

		;; this is dummy, Atmos has no timer to alarm (yet) :(
_irq_alertptr:
		bit  $ffff				; placeholder for 1 alarm handler
		jmp  -
