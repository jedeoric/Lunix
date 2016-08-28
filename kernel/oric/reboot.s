		;; leave LUnix (?) reboot system
#include <oric.h>
#include <system.h>

reboot:	
		sei						; disable irq
		
		;; make sure the ROM is mapped in
		lda #MEMCONF_ROM
		jsr oric_setmemconf
		
		;; reset vector
		jmp ($fffc)




		;; utility routines to switch between ROM and overlay
		
		;; lotsa globals to let the bootloader patch stuff to avoid lengthy cmp/bne
oric_memconf:
		.byte MEMCONF_OVL		; bootloader will do this
.global	oric_getmemconf
oric_getmemconf:
		lda oric_memconf
	-	rts
.global	oric_setmemconf
oric_setmemconf:
		cmp oric_memconf
		beq -					;done already
		cmp #MEMCONF_ROM
		bne oric_setmemconf_ovl
.global	oric_setmemconf_rom
oric_setmemconf_rom:
		jmp -
.global	oric_setmemconf_ovl
oric_setmemconf_ovl:
		jmp -

#ifdef SUPPORT_JASMIN
.global oric_setmemconf_rom_j
.global oric_setmemconf_ovl_j
oric_setmemconf_rom_j:			;5 bytes
		lda #%00000000			;
		jmp +
		sta JASMIN_OVERLAY		; enable overlay RAM
		sta JASMIN_ROMDIS		; disable BASIC ROM
		rts
oric_setmemconf_ovl_j:			;9 bytes
		lda #%00000001			;
	+	sta JASMIN_OVERLAY		; enable overlay RAM
		sta JASMIN_ROMDIS		; disable BASIC ROM
		rts
#endif
#ifdef SUPPORT_MICRODISC
.global oric_setmemconf_rom_m
.global oric_setmemconf_ovl_m
oric_setmemconf_rom_m:			;5 bytes
		; XXX: should have a ghost of the reg to avoid screwing up other bits...
		lda #%0000010			; enable EPROM and BASIC ROM
		jmp +
		;sta MICRODISC_CONTROL
		;rts
oric_setmemconf_ovl_m:			;6 bytes
		;this can't work, reading doesn't give the same reg
		;lda MICRODISC_CONTROL
		;ora #%10000000			; disable EPROM
		;and #%11111101			; disable BASIC ROM
		lda #%10000000			; disable EPROM and BASIC ROM (also IRQs)
	+	sta MICRODISC_CONTROL
		rts
#endif
#ifdef SUPPORT_TELESTRAT
.global oric_setmemconf_rom_t
.global oric_setmemconf_ovl_t
oric_setmemconf_rom_t:			;8 bytes
		;; telestrat: select bank 7 (ROM)
		lda #%00000111
		ora VIA2_ORA
		jmp +
		;sta VIA2_ORA
		;rts
oric_setmemconf_ovl_t:			;9 bytes
		;; telestrat: select bank 0 (RAM)
		lda #%11111000
		and VIA2_ORA
	+	sta VIA2_ORA
		rts
#endif

		