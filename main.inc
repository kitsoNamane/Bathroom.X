	#include "config.inc"

; Declaring Variables
    cblock 0x0c
	HIcnt
	LOcnt
	LOOPcnt

	LCDbuf
	LCDtemp

	Digtemp
	Dig1
	Dig2
	Dig3

	temp
    endc

    org 0x00
    GOTO Main
    org 0x08
    GOTO Main

    include "mikroe184.inc"
    include "LCD.inc"

LCDPORT equ PORTB
RS equ RB2
EN equ RB3

Main
    MOVLW .23
    MOVWF temp

    lcdinit

Loop
    lcdcmd 0x01
    lcdtext 1,"bathroomwater"
    lcdtext 2,"Control LCD"
    pausems .2000
    lcdcmd 0x01
    lcdtext 1,"Leak Detection"
    lcdtext 2,"leak="
    lcdbyte temp
    lcdtext 0,"C"
    pausems .2000

    GOTO Loop

    END

