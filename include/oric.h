#ifndef _ORIC_H
#define _ORIC_H

;// hardware related
;// see oric.ifrance.com/oric/programming.h

;// unneeded memory config stuff
;// actually some is needed...
; ORIC specific
#define MEMCONF_ROM  0
#define MEMCONF_OVL  1
;extern oric_getmemconf
;extern oric_setmemconf
; but the kernel doesn't need to know
;#define GETMEMCONF  jsr oric_getmemconf
;#define SETMEMCONF  jsr oric_setmemconf
#define GETMEMCONF  ;nop
#define SETMEMCONF  ;nop
#define MEMCONF_SYS  0
#define MEMCONF_USER 0
#define MEMCONF_FONT 0

;; model and drive identification
;extern lk_oric_arch
;#define lk_oric_arch lk_archmodel
#define lk_oric_arch    $fff1
#define loric_typemask  %00000011
#define loric_oric1     0
#define loric_atmos     1
#define loric_stratos   2    ;// = telestrat
#define loric_diskmask  %00001100
#define loric_none      %00000000
#define loric_jasmin    %00000100
#define loric_mdisc     %00001000
;//#define loric_cumana    3

#define lk_oric_conf lk_archconf
#define loric_joymask   %00000001
#define loric_uart      %00000010


;// I/O
#define HAVE_VIA
#define HAVE_VIA2
#include <via.h>

;// Sound (+ keyboard)
#define HAVE_

;// video controller
#define HAVE_ULA
#include <ula.h>

;// serial port (stratos / exp)
;#define HAVE_ACIA
;#include "acia.h"

;// both Jasmin and Microdrive
#include <oric_fdc.h>

;// we have an ORIC-specific console (ULA)
#define ORIC_CONSOLE

#endif
