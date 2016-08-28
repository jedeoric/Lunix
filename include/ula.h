#ifndef _ULA_H
#define _ULA_H

;// TODO: HIRES definitions ?

#ifdef ORIC16K
;// likely never supported anyway
#define ULA_BASE $3400
#error
#else
#define ULA_BASE $B400
#endif

;// standard charset bitmaps
#define ULA_TEXT_STDCHR ULA_BASE
#define ULA_TEXT_STDCHR_SZ $400

;// alt charset bitmaps
#define ULA_TEXT_ALTCHR (ULA_TEXT_STDCHR+ULA_TEXT_STDCHR_SZ)
#define ULA_TEXT_ALTCHR_SZ $380

;// text screen
;//#define ULA_TEXT_BASE (ULA_TEXT_ALTCHR+ULA_TEXT_ALTCHR_SZ)
;//asm doesn't like
#define ULA_TEXT_BASE $BB80


;//
;// ULA attributes
;//

;// separate bits

;// can apply to any character
#define UATTR_INVERT     $80
;// only in an attribute char (< 32)
#define UATTR_STDCHR     $00 ; standard charset
#define UATTR_ALTCHR     $01 ; alternate charset
#define UATTR_DBL_HGT    $02 ; double height
#define UATTR_BLINK      $04 ; blinking

;// foreground
#define UATTR_FG_BLACK   $00
#define UATTR_FG_RED     $01
#define UATTR_FG_GREEN   $02
#define UATTR_FG_YELLOW  $03
#define UATTR_FG_BLUE    $04
#define UATTR_FG_MAGENTA $05
#define UATTR_FG_CYAN    $06
#define UATTR_FG_WHITE   $07

;// background
#define UATTR_BG_BLACK   $10
#define UATTR_BG_RED     $11
#define UATTR_BG_GREEN   $12
#define UATTR_BG_YELLOW  $13
#define UATTR_BG_BLUE    $14
#define UATTR_BG_MAGENTA $15
#define UATTR_BG_CYAN    $16
#define UATTR_BG_WHITE   $17

;// video mode
#define UATTR_TEXT_60HZ    $18
#define UATTR_TEXT_50HZ    $1a
#define UATTR_HIRES_60HZ    $1c
#define UATTR_HIRES_50HZ    $1e




#endif
