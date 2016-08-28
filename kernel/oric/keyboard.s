;
; Atmos keyboard handler
; François 'mmu_man' Revol <revol@free.fr>
; 25.12.2000, 04.03.2003
;

; - check keyboard maps & update for all extended functions & characters like `
; - OPTION=alt, START=ex1, SELECT=ex2, HELP=ex3, CAPS

btab2i:		.byte $fe, $fd, $fb, $f7, $ef, $df, $bf, $7f

		;; table for $e? keys
locktab:	.byte keyb_ctrl, keyb_lshift|keyb_rshift, keyb_caps, keyb_ex3

		;; UNIX (ascii) decoding tables

#define dunno $7f
#define none_c		dunno
; other defines for special characters in tables below (later)
; internal codes $81-84 - cursors, $df/$f0 console toggle (prev/next), $f1-$f7 - goto console
; $e0-$ef internal flags for altflag toggle, $f8-$ff is reserved to maintain code similarity
; to c64 keyboard
#define ctrl_c		$e0		; internal code -> keyb_ctrl
#define shift_c		$e1		; internal code -> keyb_shift
#define caps_c		$e2		; internal code -> keyb_caps
#define help_c		$e3		; internal code -> keyb_ex3
#define option_c	$e4		; internal code -> keyb_alt	; not used, handled below
#define start_c		$e5		; internal code -> keyb_ex1	; not used, handled below
#define select_c	$e6		; internal code -> keyb_ex2	; not used, handled below
#define break_c		$03		; break is equal to CTRL+C
#define esc_c		$1b
#define return_c	$0a
#define space_c		$20
#define bkspc_c		$08
#define tab_c		$09
#define inv_c		dunno
#define shelp_c		dunno
#define sesc_c		dunno
#define sreturn_c	dunno
#define sspace_c	dunno
#define clear_c		dunno
#define insert_c	dunno
#define del_c		$08
#define stab_c		dunno
#define sinv_c		dunno
#define scaps_c		dunno
#define backslash_c	"\\"

#define csr_up_c	$81		; internal code -> cursor up
#define csr_down_c	$82		; down
#define csr_left_c	$83		; left
#define csr_right_c	$84		; right

;// ORIC specifics
#define pound_c		$5f
;// Atmos' FUNCT key... alt ?
#define func_c		option_c

;	.byte "L", "J", ";", $03, $04, "K", "+", "*"
;	.byte "O", $09, "P", "U", return_c, "I", "-", "="
;	.byte "V", help_c, "C", $03, $04, "B", "X", "Z"
;	.byte "4", $09, "3", "6", esc_c, "5", "2", "1"
;	.byte ",", space_c, ".", "N", $04, "M", "/", caps_c
;	.byte "R", $09, "E", "Y", tab_c, "T", "W", "Q"
;	.byte "9", $01, "0", "7", bkspc_c, "8", "<", ">"
;	.byte "F", "H", "D", $0b, caps_c, "G", "S", "A"

_keytab_normal:
	.byte "7",        "n",        "5",         "v",       none_c,      "1",       "x",       "3"
	.byte "j",        "t",        "r",         "f",       none_c,      esc_c,     "q",       "d"
	.byte "m",        "6",        "b",         "4",       ctrl_c,      "z",       "2",       "c"
	.byte "k",        "9",        ";",         "-",       none_c,      none_c,    "\\",      "'"
	.byte " ",        ",",        ".",         csr_up_c,  shift_c,     csr_left_c,csr_down_c,csr_right_c
	.byte "u",        "i",        "o",         "p",       func_c,      del_c,     "]",       "["
	.byte "y",        "h",        "g",         "e",       none_c,      "a",       "s",       "w"
	.byte "8",        "l",        "0",         "/",       shift_c,     return_c,  none_c,    "="
#if 0
	.byte $6c, $6a, ";", none_c, none_c, $6b, "+", "*"
	.byte $6f, none_c, $70, $75, return_c, $69, "-", "="
	.byte $76, help_c, $63, none_c, none_c, $62, $78, $7a
	.byte "4", none_c, "3", "6", esc_c, "5", "2", "1"
	.byte ",", space_c, ".", $6e, none_c, $6d, "/", inv_c
	.byte $72, none_c, $65, $79, tab_c, $74, $77, $71
	.byte "9", none_c, "0", "7", bkspc_c, "8", "<", ">"
	.byte $66, $68, $64, none_c, caps_c, $67, $73, $61
#endif
_keytab_shift:
	.byte "&",        "N",        "%",         "V",       none_c,      "!",       "X",       "#"
	.byte "J",        "T",        "R",         "F",       none_c,      esc_c,     "Q",       "D"
	.byte "M",        "^",        "b",         "$",       ctrl_c,      "Z",       "@",       "C"
	.byte "K",        "(",        ":",         pound_c,   none_c,      none_c,    "|",       "\""
	.byte " ",        "<",        ">",         csr_up_c,  shift_c,     csr_left_c,csr_down_c,csr_right_c
	.byte "U",        "I",        "O",         "P",       func_c,      del_c,     "}",       "{"
	.byte "Y",        "H",        "G",         "E",       none_c,      "A",       "S",       "W"
	.byte "*",        "L",        ")",         "?",       shift_c,     return_c,  none_c,    "+"
#if 0
	.byte $4c, $4a, ":", none_c, none_c, $4b, backslash_c, "^"
	.byte $4f, none_c, $50, $55, sreturn_c, $49, "_", "|"
	.byte $56, shelp_c, $43, none_c, none_c, $42, $58, $5a
	.byte "$", none_c, "#", "&", sesc_c, "%", $22, "!"
	.byte "[", sspace_c, "]", $4e, none_c, $4d, "?", sinv_c
	.byte $52, none_c, $45, $59, stab_c, $54, $57, $51
	.byte "(", none_c, ")", "'", del_c, "@", clear_c, insert_c
	.byte $46, $48, $44, none_c, scaps_c, $47, $53, $41
#endif
;_keytab_control:
;	.byte $0c, $0a, ";", none_c, none_c, $0b, csr_left_c, csr_right_c
;	.byte $0f, none_c, $10, $15, return_c, $09, csr_up_c, csr_down_c
;	.byte $16, help_c, $03, none_c, none_c, $02, $18, $1a
;	.byte "4", none_c, "3", "6", esc_c, "5", "2", "1"
;	.byte ",", space_c, ".", $0e, none_c, $0d, "/", inv_c
;	.byte $12, none_c, $05, $19, tab_c, $14, $17, $11
;	.byte "9", none_c, "0", "7", bkspc_c, "8", "<", ">"
;	.byte $06, $08, $04, none_c, caps_c, $07, $13, $01

; console (START+OPTION) modifiers - 'lock' keys
_cons_toggle:	; none, START, OPTION, START+OPTION
		.byte	0, keyb_ex1, keyb_ex2, keyb_ex1|keyb_ex2

; to speedup trigger translation
_trig_toggle:
		.byte	%11100000, %11110000

;lastcons:	.byte 0
curcol:		.byte 0		; current column
kcnt:	.byte 0
;colmask:	.byte $fe	; column bitmask (1st col)
;;; ZEROpage: done 8
;;; ZEROpage: last 8
;done:			.buf 8			; map of done keys
;last:			.buf 8			; map as it was scanned the last time

;;; ZEROpage: keycode 1
;keycode:		.buf 1			; keycode (equal to $cb in C64 ROM)

flag:			.byte 0			; must be zero at startup


		;; to save the time this is called only on timer IRQ
.global joys_scan

joys_scan:
		; no joystick yet
		rts


keyb_scan:
		;; keyboard scanning begins here
		
;	lda $bb80+40+31
;	and #%00100000
;	ora #"S"
;	eor #%00100000
;	sta $bb80+40+31

		;; changing the row is way simpler than changing the col,
		;; so we'll shift the column once every interrupt,
		;; and scan all 8 rows for that col.
		;; that should be enough for a start

		ldx curcol
		
		cpx #4						; row 4: clear modifiers, we'll check them now
		bne kbnocaf
		lda #keyb_ctrl|keyb_rshift|keyb_lshift|keyb_alt
		eor #$ff
		and altflags
		sta altflags
kbnocaf:
		;; check each row
;	txa
;	clc
;	adc #"0"
;	sta $bb80+40+34
	
		ldy #7						; start from row 7 downwards
		lda VIA1_ORB
		ora #$07					; set last 3 bits (start at line 7)
		sta VIA1_ORB
		
kbnxtlin:
;	tya
;	clc
;	adc #"0"
;	sta $bb80+40+35
;	lda $bb80+40+32
;	and #%00100000
;	ora #"L"
;	eor #%00100000
;	sta $bb80+40+32
		lda VIA1_ORB
		and #$08					; is the key pressed ?
		bne +						; yes
		lda btab2i,x					; no: make sure we remember
		and last,y
		sta last,y
		jmp kbalready
		
	+	lda btab2i,x					; yes: check if it's new
		eor #$ff
		and last,y
		bne kbalready
		
		;; new modifier: don't generate keycodes, just update altflags
		cpx #4
		beq kbchkmods
		
		;; newly pressed... handle
		lda btab2i,x
		eor #$ff
		ora last,y					; remember pressed state
		sta last,y
		
		;; calculate keycode: code = row * 8 + col
		tya						; row
		asl a
		asl a
		asl a						; *= 8
		ora curcol					; += curcol
		sta keycode
		jmp kbalready
kbchkmods:
		lda #0
		cpy #2
		bne +
		lda #keyb_ctrl
	+	cpy #4
		bne +
		lda #keyb_lshift
	+	cpy #5
		bne +
		lda #keyb_alt
	+	cpy #7
		bne +
		lda #keyb_rshift
	+	ora altflags
		sta altflags
;	and #7
;	clc
;	adc #"0"
;	sta $bb80+40+37
kbalready:
		dey
		bmi +
		dec VIA1_ORB
		jmp kbnxtlin
	+	
		;cmp #8
		;inc VIA1_ORB
		;lda #0
		
		
;kbnxtcol:
		;; shift the column
		
		ldx curcol
		inx
		cpx #8
		bne +
		ldx #0
	+	stx curcol
		lda btab2i,x
		tax
		lda #$0e				; register 14 of PSG
		sta VIA1_ORA_NH
		lda #$ff				; ??
		sta VIA1_PCR
		ldy #$dd				; ??
		sty VIA1_PCR
		stx VIA1_ORA_NH
		lda #$fd
		sta VIA1_PCR
		
		;cpx #$fe				; back to first col ?
		;bne done_keyb			; yes
		
		;; check keypresses
		
		lda keycode
		cmp #$40
		bmi dokey
done_keyb:
		rts
		
dokey:
	
		;;; DONE!
		; queue key into keybuffer
		;; machine-dependent code returns with keycode offset in X register
		ldx  keycode
		lda #$41
		sta keycode

;	lda $bb80+40+33
;	and #%00100000
;	ora #"D"
;	eor #%00100000
;	sta $bb80+40+33

;	txa
;	lsr a
;	lsr a
;	lsr a
;	clc
;	adc #"0"
;	sta $bb80+40+36
	
;	txa
;	and #$07
;	clc
;	adc #"0"
;	sta $bb80+40+37

		;; machine-dependent code returns with keycode in X register




