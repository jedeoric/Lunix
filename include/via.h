
#ifndef _VIA_H
#define _VIA_H

;// VIA related stuff
;// Atmos has only 1 VIA, Stratos has a 2nd one
;// it's actually mirrored 16 times in page 3
;// but other I/O take its place

#ifndef VIA1_BASE
#define VIA1_BASE $300
#endif
#define VIA1 VIA1_BASE

#define VIA1_ORB     VIA1+0       ; port register B (i/o)
#define VIA1_ORA     VIA1+1       ; port register A (i/o)
#define VIA1_DDRB    VIA1+2       ; data direction register B  (0=input,
#define VIA1_DDRA    VIA1+3       ; data direction register A   1=output)
;//XXX:FIXME
#define VIA1_T1LO    VIA1+4       ; timer 1 bits 0-7 (lo byte)
#define VIA1_T1HI    VIA1+5       ; timer 1 bits 8-15 (hi byte)
#define VIA1_T1LLO   VIA1+6       ; timer 1 latch bits 0-7 (lo byte)
#define VIA1_T1LHI   VIA1+7       ; timer 1 latch bits 8-15 (hi byte)
#define VIA1_T2LO    VIA1+8       ; timer 2
#define VIA1_T2HI    VIA1+9       ; timer 2
#define VIA1_SR      VIA1+10      ; shift register
#define VIA1_ACR     VIA1+11      ; aux control register
#define VIA1_PCR     VIA1+12      ; peripheral control register
#define VIA1_IFR     VIA1+13      ; interrupt flag register
#define VIA1_IER     VIA1+14      ; interrupt enable register
#define VIA1_ORA_NH  VIA1+15      ; port register A (no handshake)

;// aliases
#define VIA1_IRA     VIA1_ORA
#define VIA1_IRB     VIA1_ORB
;// CIA-like aliases
#define VIA1_PRA     VIA1_ORA
#define VIA1_PRB     VIA1_ORB
#define VIA1_TALO    VIA1_T1LO
#define VIA1_TAHI    VIA1_T1HI



#ifdef HAVE_VIA2

#ifndef VIA2_BASE
#define VIA2_BASE $320
#endif
#define VIA2 VIA2_BASE

#define VIA2_ORB     VIA2+0       ; port register B (i/o)
#define VIA2_ORA     VIA2+1       ; port register A (i/o)
#define VIA2_DDRB    VIA2+2       ; data direction register B  (0=input,
#define VIA2_DDRA    VIA2+3       ; data direction register A   1=output)
;//XXX:FIXME
#define VIA2_T1LO    VIA2+4       ; timer 1 bits 0-7 (lo byte)
#define VIA2_T1HI    VIA2+5       ; timer 1 bits 8-15 (hi byte)
#define VIA2_T1LLO   VIA2+6       ; timer 1 latch bits 0-7 (lo byte)
#define VIA2_T1LHI   VIA2+7       ; timer 1 latch bits 8-15 (hi byte)
#define VIA2_T2LO    VIA2+8       ; timer 2
#define VIA2_T2HI    VIA2+9       ; timer 2
#define VIA2_SR      VIA2+10      ; shift register
#define VIA2_ACR     VIA2+11      ; aux control register
#define VIA2_PCR     VIA2+12      ; peripheral control register
#define VIA2_IFR     VIA2+13      ; interrupt flag register
#define VIA2_IER     VIA2+14      ; interrupt enable register
#define VIA2_ORA_NH  VIA2+15      ; port register A (no handshake)

;// aliases
#define VIA2_IRA     VIA2_ORA
#define VIA2_IRB     VIA2_ORB
;// CIA-like aliases
#define VIA2_PRA     VIA2_ORA
#define VIA2_PRB     VIA2_ORB
#define VIA2_TALO    VIA2_T1LO
#define VIA2_TAHI    VIA2_T1HI

#endif

#endif
