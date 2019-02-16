	#include "config.inc"
   

	;Counter	EQU 0x00
    
	ORG	0x00
	GOTO	init
	
	ORG	0x08   ; External Interrupt Vector:
	BTFSC   INTCON,	INT0IF
	GOTO    Flush	; Only runs if Flush interrupt triggered
	BTFSC   INTCON3,	INT1IF
        GOTO    WaterLevel	; Only runs if Water Level High triggered
    
init:   CLRF	PORTA
        CLRF	PORTB
	
	; Configure Interrupt Control Register
	MOVLW	B'10000000'
	MOVWF	INTCON	    ; Enable GIE
	MOVLW	B'11000000' ; INT1 and INT2 both @ high priority
	MOVWF	INTCON3	    ; RB1/INT1 and RB2/INT2
	
	; Configure TIMER0 in counting mode
	; 1:8 Prescaler is not used
	; Use External source on RA0/T0CKI
	; 
	MOVLW	B'01110010'
	MOVWF	T0CON
	
        
        MOVLW	0x0f
        MOVWF	ADCON1
        MOVLW	0x07
        MOVWF	CMCON
	
	; Configure PortA as all output except TICK0
	MOVLW	B'00010000'    
	MOVWF	TRISA
			      
	
	; Configure PortB as all input
        MOVLW	B'11111111'
        MOVWF	TRISB
        
        ;MOVLW	0x00
        ;MOVWF	Counter
	
      
main:   BTFSS	PORTB,	RB3
	BSF	PORTA,	RA3
        BTFSC	PORTB,	RB3
        BCF	PORTA,	RA3
        GOTO	main

; Interrupt responsible for resetting flowmeter counter
; Opens the water inlet valve
Flush	CALL	OpenValve	; Open selonoid valve
	BSF	INTCON, TMR0ON	; Start Timer0
	CALL	Count		; count pulses from flow-meter
	BCF	INTCON,	INT0IF  ; Clear interrupt flag
	RETFIE
	
; Close water inlet valve once water level is max
; Wait a few seconds, then check level high again
; If not level high, then there is a leak
WaterLevel
	BSF	PORTA,	RA2
	CALL	CloseValve
	; ADD Flowmeter Reset
	;CALL	Delay
	;BCF	PORTA,	RA2
	BCF	INTCON3,INT1IF  ; Clear interrupt flag
	RETFIE

; A very accurrate 20 seconds delay
Delay
	RETURN

; System indicator:
; RED if malfunctioned	    RB1
; GREEN if normal operation RB2
; They both cannot be on at the same time
Alarms
	RETURN

; Open the selonoid valve to let water in	
OpenValve
	BSF	PORTA,	RA1
	MOVLW	0x50
	MOVWF	TMR0 ;
	RETURN
	
; Close the selonoid valve and cut off water supply into toilet	
CloseValve
	BCF	INTCON, TMR0ON	; Stop Timer0
	BCF	PORTA,	RA1
	RETURN
	
; Count the number of pulses from flow-meter
Count	BTG	PORTA, RA0	
	BTFSC	INTCON,INT0IF
	GOTO	Count
	CALL	CloseValve
	RETURN
	
        END
      


