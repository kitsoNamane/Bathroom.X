	#include "config.inc"
   

	count EQU 0x00
    
	org 0x00 
    
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
        
        MOVLW b'1111111'
        MOVWF TRISA
        
        MOVLW b'0000000'
        MOVWF TRISB
        
        MOVLW 0x00
        MOVWF count
      
main:   BTFSS PORTA,RA3
        CALL Counter
        BTFSC PORTA,RA3
        BCF PORTB,RB0
        goto main

; Interrupt responsible for resetting flowmeter counter
; Opens the water inlet valve
Flush
	RETURN
	
; Close water inlet valve once water level is max
; Wait a few seconds, then check level high again
; If not level high, then there is a leak
WaterLevel
	RETURN

; A very accurrate 20 seconds delay
Delay
	RETURN

; System indicator:
; RED if malfunctioned	    RB1
; GREEN if normal operation RB2
; They both cannot be on at the same time
Alarms
	RETURN
	
; Count the number of pulses from flow-meter
Counter	BSF PORTB, RB0
	INCF count, 1
	RETURN

        END
      


