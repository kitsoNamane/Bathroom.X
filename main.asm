	#include "config.inc"
   

	Counter	EQU 0x00
    
	org 00
	goto init
	
	org 04	    ; External Interrupt Vector: 
	goto Flush  ; Only runs if interrupt triggered
	
	org 0010
    
init:   CLRF PORTA
        CLRF PORTB
	
	; Configure Interrupt Control Register
	; Enable GIE
	MOVLW B'10011000'
	MOVWF INTCON
	
	; Configure TIMER0 in counting mode
	; Prescaler is not used
	; Use External source on RA0/T0CKI
	MOVLW B'11100010'
	MOVWF T0CON
        
        MOVLW 0x0f
        MOVWF ADCON1
        MOVLW 0x07
        MOVWF CMCON
	
	; Configure PortA as all output
	MOVLW B'0000000'
	MOVWF TRISA
	
	; Configure PortB as all input
        MOVLW B'1111111'
        MOVWF TRISB
        
        MOVLW 0x00
        MOVWF Counter
	BSF PORTA, RA1
	
      
main:   BTFSS PORTB,RB1
        CALL Count
        BTFSC PORTB,RB1
        BCF PORTA,RA0
        goto main

; Interrupt responsible for resetting flowmeter counter
; Opens the water inlet valve
Flush	BCF PORTA,  RA1
	; ADD Flowmeter Reset
	CALL OpenValve
	BCF INTCON, INT0IF  ; Clear interrupt flag
	RETFIE
	
; Close water inlet valve once water level is max
; Wait a few seconds, then check level high again
; If not level high, then there is a leak
WaterLevel
	CALL CloseValve
	; ADD Flowmeter Reset
	CALL Delay
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
	RETURN
	
; Close the selonoid valve and cut off water supply into toilet	
CloseValve
	RETURN
	
; Count the number of pulses from flow-meter
Count	BSF PORTA, RA0
	INCF Counter, 1
	RETURN

        END
      


