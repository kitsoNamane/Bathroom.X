  
    #include "config.inc"

    cblock 0x00
        HIcnt
        LOcnt
        LOOPcnt

        LCDbuf
        LCDtemp
        d1 
        d2 
        d3

        Digtemp
        Dig1
        Dig2
        Dig3

        temp
    endc


    org	0x00
    GOTO Init


LCDPORT equ PORTA
LCDTRIS equ TRISA

CLKcount equ 0x20
;TIMERcount equ 0x00

EN equ RA5
RS equ RA4

    org	0x08	; External Interrupt Vector:
CHKint
    BTFSC   INTCON,	INT0IF
    GOTO    FlushISR	; Only runs if Flush interrupt triggered

    BTFSC   PIR1,   TMR1IF
    GOTO    CounterISR

    BTFSC   INTCON3,INT1IF
    GOTO    WaterLevelISR  ; Only runs if Water Level High triggered
    RETFIE

    org     0x100
    include "mikroe184.inc"
    include "lcd.inc"

    org 0x200
Init
    CLRF	PORTA
    CLRF	PORTB
    CLRF	PORTC

    ; Configure Interrupt Control Register
    BSF     INTCON, INT0IE	; Enable INT0 interrupt
    BSF     INTCON3,INT1IP	; Set INT1 to high priority
    BSF     INTCON3,INT1IE  ; Enable INT1 enterrupts
    BCF     PIE1,   TMR1IE	; Clear	TMR1 interrupts
    BSF     PIE1,   TMR1IE	; Enable TMR1 interrupts
    BSF     INTCON, PEIE	; Enable Periferal interrrupts
    BSF     INTCON, GIE	; Enable GIE

    ; Configure TIMERS, all in 16-bit mode
    ; TMR0 as a TIMER
    ; TMR1 as a COUNTER
    ; 1:32 Prescaler for TMR0
    ; No prescaler for  TMR1
    ; Use External source on RA0/T0CKI
    MOVLW	0Fh
    MOVWF	ADCON1
    MOVLW	0x07
    MOVWF	CMCON

    ; Configure PortA as all output except TICK0
    MOVLW	B'00000000'    
    MOVWF	TRISA

    ; Configure PortB as all input
    MOVLW	B'00000011'
    MOVWF	TRISB

    
    ; Configure LCD 
    MOVLW .23
    MOVWF temp

    lcdinit
    CALL Greeting
; The main loop of the program
Main BRA Main

Greeting
    lcdcmd 0x01
    lcdtext 1, "Bathroom Water"
    lcdtext 2, "Control System"
    RETURN

WebDelay
    movlw 0x11
    movwf d1
    movlw 0x5D
    movwf d2
    movlw 0x05
    movwf d3
Delay1ss
    decfsz d1, f 
    goto $+2
    decfsz d2, f 
    goto $+2
    decfsz d3, f 
    goto Delay1ss

    RETURN

Delay4s
    CALL WebDelay
    CALL WebDelay
    CALL WebDelay
    CALL WebDelay
    RETURN
   
    org     0x300
; Interrupt responsible for resetting flowmeter counter
; Opens the water inlet valve
FlushISR
    BSF	PORTB, RB2
    lcdcmd 0x01
    lcdtext 1, "Flushing "
    CALL Delay4s
    lcdcmd 0x01
    lcdtext 1, "Done !!!"
    CALL Delay4s
    CALL	OPENvalve	; Open selonoid valve
    BCF	INTCON,	INT0IF  ; Clear interrupt flag
    GOTO    CHKint


; Close water inlet valve once water level is max
; Wait a few seconds, then check level high again
; If not level high, then there is a leak
WaterLevelISR
    CALL    ClOSEvalve
    CALL Delay4s
    GOTO    CHKint


; Count the number of pulses from flow-meter	
; TO DO: Flash an LED
CounterISR
    BCF     PIR1,   TMR1IF
    BCF     T1CON, TMR1ON	; Stop Timer0
    CALL    ClOSEvalve
    GOTO    CHKint

    org	0x400
; System indicator:
; RED if malfunctioned	    RB1
; GREEN if normal operation RB2
; They both cannot be on at the same time
Alarmsfault
    lcdcmd 0x01
    lcdtext 1, "LEAK DETECTED"
    BCF	PORTA,	RA2 ; Toilet Normal Off
    BSF PORTA,  RA3 ; Toilet Abnormal On
    GOTO Fault
AlarmsOK
    lcdcmd 0x01
    lcdtext 1, "Everything Ok"
    BSF	PORTA,	RA2
    BCF	PORTA,	RA3
    ;CALL Greeting
    RETFIE


; Open the selonoid valve to let water in	
OPENvalve
    BSF	PORTB,	RB3
    ;MOVLW	0xFF
    ;MOVWF	TMR1H
    ;MOVLW	0xED
    ;MOVWF	TMR1L
    ;lcdcmd 0x01
    ;BSF     T1CON, TMR1ON	; Start Timer0
    lcdcmd 0x01
    lcdtext 1, "Loading Water..."
    CALL Delay4s
    CALL Delay4s
    CALL Delay4s
    CALL ClOSEvalve
    RETURN


; Close the selonoid valve and cut off water supply into toilet	
ClOSEvalve
    lcdcmd 0x01
    lcdtext 1, "Max Volume"
    lcdtext 2, "Reached"
    BCF	PORTB,	RB2
    BCF	PORTB,	RB3
    CALL Delay4s
    RETURN
    
Fault BCF INTCON3,INT1IE
    BCF OSCCON, IDLEN
    SLEEP
    end
