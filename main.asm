    #include "config.inc"
    cblock 0x00
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


    org	0x00
    GOTO Init


LCDPORT equ PORTB
LCDTRIS equ TRISB

CLKcount equ 0x20
TIMERcount equ 0x00

EN equ RB2
RS equ RB3

    org	0x08	; External Interrupt Vector:
CHKint
    BTFSC   INTCON,	INT0IF
    GOTO    FlushISR	; Only runs if Flush interrupt triggered

    BTFSC   PIR1,   TMR1IF
    GOTO    CounterISR

    BTFSC   INTCON3,INT1IF
    GOTO    WaterLevelISR  ; Only runs if Water Level High triggered
    RETFIE


    org	0x40
CHKfault
    CLRF	TIMERcount
    MOVLW	D'8'
    MOVWF	TIMERcount
    CALL	TMRdelay
    BCF	INTCON3,INT1IF  ; Clear interrupt flag
    BTFSS	PORTB,	RB1	; Check if Water level is still high
    GOTO	Alarmsfault
    GOTO	AlarmsOK	; Toilet Working
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
    BCF     PIR1,   TMR1IF	; Clear	TMR1 interrupts
    BSF     PIE1,   TMR1IE	; Enable TMR1 interrupts
    BSF     INTCON, PEIE	; Enable Periferal interrrupts
    BSF     INTCON, GIE	; Enable GIE

    ; Configure TIMERS, all in 16-bit mode
    ; TMR0 as a TIMER
    ; TMR1 as a COUNTER
    ; 1:32 Prescaler for TMR0
    ; No prescaler for  TMR1
    ; Use External source on RA0/T0CKI
    MOVLW	0x05	; Timer0, 16-bit, int clk, 32 prescaler
    MOVWF	T0CON
    MOVLW   0x02	; Timer1, 16-bit, ext clk, no prescaler
    MOVWF	T1CON	; Load T1CON Register
    MOVLW	0x0F
    MOVWF	ADCON1
    MOVLW	0x07
    MOVWF	CMCON

    ; Configure PortA as all output except TICK0
    MOVLW	B'00010000'    
    MOVWF	TRISA

    ; Configure PortB as all input
    MOVLW	B'11111111'
    MOVWF	TRISB

    ; Configure RCO clock input
    BSF	TRISC,	RB0
    
    

    ; Configure LCD 
    MOVLW .23
    MOVWF temp

    lcdinit
    CALL Greeting
    
    
; The main loop of the program
Main GOTO Main
Greeting
    lcdcmd 0x01
    lcdtext 1, "Bathroom Water"
    lcdtext 2, "Control System"
    RETURN
    
    org     0x300
; Interrupt responsible for resetting flowmeter counter
; Opens the water inlet valve
FlushISR
    BSF	PORTA, RA0
    lcdcmd 0x01
    lcdtext 1, "Flushing "
    CLRF	TIMERcount
    MOVLW	D'8'
    MOVWF	TIMERcount
    CALL	TMRdelay
    lcdcmd 0x01
    lcdtext 1, "Done !!!"
    MOVLW	D'5'
    MOVWF	TIMERcount
    CALL	TMRdelay
    
    CALL	OPENvalve	; Open selonoid valve
    BCF	INTCON,	INT0IF  ; Clear interrupt flag
    
    GOTO    CHKint


; Close water inlet valve once water level is max
; Wait a few seconds, then check level high again
; If not level high, then there is a leak
WaterLevelISR
    CALL    ClOSEvalve
    CLRF    TIMERcount
    MOVLW   D'8'
    MOVWF   TIMERcount
    CALL    TMRdelay
    GOTO    CHKfault


; Count the number of pulses from flow-meter	
; TO DO: Flash an LED
CounterISR
    BCF     PIR1,   TMR1IF
    BCF     T1CON, TMR1ON	; Stop Timer0
    CALL    ClOSEvalve
    GOTO    CHKfault
    GOTO    CHKint


; A very accurrate 20 seconds delay
DelayISR
    BCF	T1CON,	TMR0ON
    BCF	PORTA,	RA4
    GOTO	CHKint
	
	
    org	0x400
TMRdelay	
    MOVLW   0x0B
    MOVWF   TMR0H
    MOVLW   0xDC
    MOVWF   TMR0L
    BSF	PORTA, RA4
    BSF     T0CON, TMR0ON
Start	BTFSS	INTCON,	TMR0IF
    GOTO	Start
    DECFSZ    TIMERcount, F
    GOTO	Start
    RETURN


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
    BSF	PORTA,	RA1
    MOVLW	0xFF
    MOVWF	TMR1H
    MOVLW	0xED
    MOVWF	TMR1L
    lcdcmd 0x01
    lcdtext 1, "Volume : "
    BSF     T1CON, TMR1ON	; Start Timer0
    RETURN
	

; Close the selonoid valve and cut off water supply into toilet	
ClOSEvalve
    lcdcmd 0x01
    lcdtext 1, "Max Volume"
    lcdtext 2, "Reached"
    BCF	PORTA,	RA0
    BCF	PORTA,	RA1
    RETURN
    
Fault BCF INTCON3,INT1IE
    BCF OSCCON, IDLEN
    SLEEP
    end
