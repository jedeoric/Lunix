
#ifndef _ACIA_H
#define _ACIA_H

;// 
#ifndef ACIA1_BASE
;// telestrat
#define ACIA1_BASE $31c
#endif
#define ACIA1 ACIA1_BASE

;// ACIA1 register map
#define ACIA1_DR      CIA1+0       ; data register (i/o)
#define ACIA1_SR      CIA1+1       ; status register
#define ACIA1_CMDR    CIA1+2       ; command register
#define ACIA1_CTLR    CIA1+3       ; control register

#endif

