;// set up hardware before starting the kernel
;// hw detection
#include <oric.h>
#include <system.h>

#include <ksym.h>

		;; disable all IRQs from VIA
		
		lda #$7f
		sta VIA1_IER
		
		;; detect model
		
		ldy #loric_atmos		; assume Atmos for now
		;; check for the "1" from "BASIC v1.1" of Atmos
		;lda #"1"
		;cmp $EDAD
		;; this check is used by Loriciel, might be more reliable (?)
		lda $fff9
		cmp #$01
		beq +
		ldy #loric_oric1
	+	
		jmp check_jasmin

smc_ptrr:
		.word lkf_oric_setmemconf_rom
smc_ptro:
		.word lkf_oric_setmemconf_ovl

		;; detect floppy hardware
		;; and enable overlay RAM
		
check_jasmin:
#ifdef SUPPORT_JASMIN
		;; detect Jasmin drive
		lda VIA1_ACR			; VIA1+11
		tax						; backup
		cmp JASMIN_ROMDIS		; 
		bne has_jasmin
		
		eor #%00000100			; change shift reg mode (unused)
		sta VIA1_ACR
		cmp JASMIN_ROMDIS		; 
		stx VIA1_ACR			; change back (flags unaffected)
		bne has_jasmin
		jmp check_microdisc
		
has_jasmin:
		; patch loader and kernel calls
		lda #<lkf_oric_setmemconf_rom_j
		sta lkf_oric_setmemconf_rom+1
		lda #>lkf_oric_setmemconf_rom_j
		sta lkf_oric_setmemconf_rom+2
		
		lda #<lkf_oric_setmemconf_ovl_j
		sta lkf_oric_setmemconf_ovl+1
		lda #>lkf_oric_setmemconf_ovl_j
		sta lkf_oric_setmemconf_ovl+2
		
		tya
		ora #loric_jasmin
		tay
		jmp got_fdc				; who needs both ?
#endif
		
check_microdisc:
#ifdef SUPPORT_MICRODISC
		;; detect Microdrive/telestrat
		; probe MD
		ldx MICRODISC_IRQF
	-	lda VIA1_T1LO
		cmp VIA1_T1LO
		beq -
		cpx MICRODISC_IRQF
		bne check_telestrat
		
		; patch loader and kernel calls
		lda #<lkf_oric_setmemconf_rom_m
		sta lkf_oric_setmemconf_rom+1
		lda #>lkf_oric_setmemconf_rom_m
		sta lkf_oric_setmemconf_rom+2
		
		lda #<lkf_oric_setmemconf_ovl_m
		sta lkf_oric_setmemconf_ovl+1
		lda #>lkf_oric_setmemconf_ovl_m
		sta lkf_oric_setmemconf_ovl+2
		
		tya
		ora #loric_mdisc
		tay
		
		jmp got_fdc

#endif
check_telestrat:
#ifdef SUPPORT_TELESTRAT
		;; check for 2nd VIA (stratos)
		lda VIA2_DDRA
		cmp #%00010111
		bne +
		cmp VIA1_DDRA
		beq +
		tya
		and #~loric_typemask
		ora #loric_stratos
		tay
		
		; patch loader and kernel calls
		lda #<lkf_oric_setmemconf_rom_t
		sta lkf_oric_setmemconf_rom+1
		lda #>lkf_oric_setmemconf_rom_t
		sta lkf_oric_setmemconf_rom+2
		
		lda #<lkf_oric_setmemconf_ovl_t
		sta lkf_oric_setmemconf_ovl+1
		lda #>lkf_oric_setmemconf_ovl_t
		sta lkf_oric_setmemconf_ovl+2
		
		jmp got_fdc
	+	
#endif
		
		
		;; no floppy:
		;; display an error on status line, some fancy audio,
		;; wait some time and reboot.
no_fdc:
		lda #<_nodrivemsg
		;ldy #>_nodrivemsg ; delayed
		ldx #0
		
		; jump to ROM's STOUT
		; ORIC-1 vs Atmos: cf. Theoric nr 2 page 50
		cpy #loric_oric1
		bne no_fdc_atmos
		
		ldy #>_nodrivemsg
		jsr $f82f				; STOUT
		jsr $fab1				; EXPLD
		jmp +
no_fdc_atmos:
		ldy #>_nodrivemsg
		jsr $f865				; STOUD
		jsr $facb				; EXPLD
	+	
		; spin for a while...
		ldy #$ff
	-	dey
		bne -
		
		; RESET vector
		jmp ($fffc)

		;; we have a floppy, continue
got_fdc:
		; save model and hw flags
		sty lk_oric_arch
		
		;; set archtype (first solution on PAL/NTSC detection)

		ldx #larch_oric		; oric/ntsc
		stx lk_archtype
		
		; switch to overlay RAM
		jsr lkf_oric_setmemconf_ovl
		
		jmp resetdone



_nodrivemsg:
		.text "Jasmin or Microdisc required!"
		.byte $00
		
resetdone:
