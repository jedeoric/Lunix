;
; Atari keyboard init
; Maciej 'YTM/Alliance' Witkowiak <ytm@friko.onet.pl>
; 25.12.2000
;

#include <config.h>
#include <system.h>
#include MACHINE_H
#include <keyboard.h>
#include <zp.h>

		;; initialize and install keyboard scanning routine
keyboard_init:

		; XXX: make sure VIA is setup correctly
		; XXX:FIXME:don't screw up other bits in the VIA
		; braindeadness due to the keyboard columns being wired
		; on the IO port of the AY8912, which is accessed through
		; the VIA...
		
		lda #0					; row 0 
		ldx #$fe					; col 0 (bitmask)
		sta VIA1_ORB
		lda #$0e				; register 14 of PSG
		sta VIA1_ORA_NH
		lda #$ff				; ??
		sta VIA1_PCR
		ldy #$dd				; ??
		sty VIA1_PCR
		stx VIA1_ORA_NH
		lda #$fd
		sta VIA1_PCR
		; this checks if the key is down
		;sty VIA1_PCR
		;lda VIA1_ORB
		;and #08
		
		ldx  #<lkf_keyb_scan
		ldy  #>lkf_keyb_scan
		jsr  lkf_hook_irq		; hook into system

		ldx #0
		stx altflags

		lda #$41			; invalid keycode
		sta keycode

	-	lda  _startmsg,x
		beq  +
		jsr  lkf_printk
		inx
		bne  -
	+	rts

_startmsg:
		.text "Atmos keyboard module version 0.1"
		.byte $0a,$00
