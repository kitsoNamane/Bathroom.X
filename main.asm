	#include "config.inc"
   

	Flushed	EQU 0
    
	ORG	0x00
	GOTO	init
	
	ORG	0x08	; External Interrupt Vector:
	BTFSC   INTCON,	INT0IF
	GOTO    Flush	; Only runs if Flush interrupt triggered
	;BTFSS	INTCON, INT0IF
	;BSF	T0CON, TMR0ON	; Start Timer0
	;GOTO	Count
	BTFSC   INTCON3,INT1IF
        GOTO    WaterLevel  ; Only runs if Water Level High triggered
    
init:   CLRF	PORTA
        CLRF	PORTB
	
	; Configure Interrupt Control Register
	BSF	INTCON, INT0IE	; Enable INT0 interrupt
	BSF	INTCON3,INT1IP	; Set INT1 to high priority
	BSF	INTCON3,INT1IE ; Enable INT1 enterrupt
	BSF	INTCON, GIE	; Enable GIE
	
	; Configure TIMER0 in counting mode
	; 1:8 Prescaler is used
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

test:	BTFSS   Flushed, 1
	BSF	T0CON, TMR0ON	; Stop Timer0
	GOTO    count
	GOTO	main
	
count:	BTG	PORTA,	RA0	
	BTFSS	INTCON, TMR0IF	; Logic for this part is  
	BRA	count
	CALL	CloseValve
	     
main:   BTFSS	PORTB,	RB3
	BSF	PORTA,	RA3
        BTFSC	PORTB,	RB3
        BCF	PORTA,	RA3
        GOTO	main

; Interrupt responsible for resetting flowmeter counter
; Opens the water inlet valve
Flush	CALL	OpenValve	; Open selonoid valve
	MOVLW	INT0IF		
	MOVWF	Flushed		; Copy of Flush interrupt
	BCF	INTCON,	INT0IF  ; Clear interrupt flag
	BSF	PORTA,	RA0
	RETFIE
	
; Close water inlet valve once water level is max
; Wait a few seconds, then check level high again
; If not level high, then there is a leak
WaterLevel
	BSF	PORTA,	RA2
	CALL	CloseValve
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
	BCF	T0CON, TMR0ON	; Stop Timer0
	BCF	PORTA,	RA1
	RETURN
	
; Count the number of pulses from flow-meter
	
        END
      


