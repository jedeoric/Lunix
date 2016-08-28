
#ifndef _ORIC_FDC_H
#define _ORIC_FDC_H

;// Jasmin
#ifdef SUPPORT_JASMIN

# define JASMIN_BASE $3f0
# define JASMIN JASMIN_BASE

# define JASMIN_FDC     JASMIN+4   ; 
;XXX

# define JASMIN_SIDESEL JASMIN+8   ; bit0 = side
# define JASMIN_RESET   JASMIN+9   ; writing there resets the FDC
# define JASMIN_OVERLAY JASMIN+10  ; bit0 =1 -> enable overlay ram
# define JASMIN_ROMDIS  JASMIN+11  ; bit0 =1 -> disable rom

#endif

#ifdef SUPPORT_MICRODISC

# define MICRODISC_BASE $310
# define MICRODISC MICRODISC_BASE

# define MICRODISC_CONTROL MICRODISC+4 ; 
# define MICRODISC_IRQF    MICRODISC+4 ; 

; XXX

#endif

#endif
