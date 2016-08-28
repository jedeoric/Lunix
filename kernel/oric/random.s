		;; function:	update_random
		;; Update random number generator
		;; < nothing
		;; > nothing

; This can be accomplished by a function of long period (like in the bottom)
; or by using hardware. lastrnd is 16 bit, but only lower 8 bits are used

		lda lastrnd
		adc VIA1_TALO
		adc VIA1_TAHI
		;; SID stuff?
		sta lastrnd
		rts

