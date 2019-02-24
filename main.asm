        #include "config.inc"
	CLK_COUNT   EQU	 0x20
	TIMER_COUNT EQU	 D'0'
        ORG	0000H
        GOTO	INIT
        
        ORG	0008H	; External Interrupt Vector:
	GOTO	CHK_INT
	
	ORG	0040H
CHK_INT
        BTFSC   INTCON,	INT0IF
        GOTO    FLUSH_ISR	; Only runs if Flush interrupt triggered

        BTFSC   PIR1,   TMR1IF
        GOTO    COUNTER_ISR

        BTFSC   INTCON3,INT1IF
        GOTO    WATERLEVEL_ISR  ; Only runs if Water Level High triggered
        
	RETFIE
	
CHK_DELAY
	MOVLW	D'40'
	CALL	DELAY
	BTFSS	PORTB,	RB1
	CALL	ALARMS
	RETFIE


        ORG     00100H
INIT    CLRF	PORTA
        CLRF	PORTB
	CLRF	PORTC
	
        ; Configure Interrupt Control Register
        BSF     INTCON, INT0IE	; Enable INT0 interrupt

        BSF     INTCON3,INT1IP	; Set INT1 to high priority
        BSF     INTCON3,INT1IE  ; Enable INT1 enterrupt

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
	
        
        ; Configure PortA as all outputs
        MOVLW	B'00010000'    
        MOVWF	TRISA
                    
        
        ; Configure PortB as all input
        MOVLW	B'11111111'
        MOVWF	TRISB

        ; Configure RCO clock input
        BSF	TRISC,	RB0   
	     

; The main loop of the program
MAIN    GOTO	MAIN

	
	ORG     200H
; Interrupt responsible for resetting flowmeter counter
; Opens the water inlet valve
	
FLUSH_ISR
        CALL	OPEN_VALVE	; Open selonoid valve
	BCF	INTCON,	INT0IF  ; Clear interrupt flag
        GOTO	CHK_INT
	
; Close water inlet valve once water level is max
; Wait a few seconds, then check level high again
; If not level high, then there is a leak
WATERLEVEL_ISR
        CALL	CLOSE_VALVE
	BCF	INTCON3,INT1IF  ; Clear interrupt flag
        GOTO    CHK_DELAY


; Count the number of pulses from flow-meter	
; TO DO: Flash an LED
COUNTER_ISR
        CALL    CLOSE_VALVE
	BCF     PIR1,   TMR1IF
        GOTO    CHK_INT


; A very accurrate 20 seconds delay
DELAY_ISR
        BCF	PORTA,	RA4
	BCF	T0CON,	TMR0ON
        GOTO	CHK_INT
	
	
	ORG	300H
DELAY	
	MOVWF	TIMER_COUNT
	MOVLW   0x0B
	MOVWF   TMR1H
	MOVLW   0xDC
	MOVWF   TMR1L
	BSF	PORTA, RA4
	BSF     T0CON, TMR0ON
START	BTFSS	INTCON,	TMR0IF
	GOTO	START
INCREMENT   DECFSZ    TIMER_COUNT, F
	GOTO	START
	RETURN

; System indicator:
; RED if malfunctioned	    RB1
; GREEN if normal operation RB2
; They both cannot be on at the same time
ALARMS
	BCF	PORTA,	RA1
        ;BSF     PORTA,  RA4
        RETURN

; Open the selonoid valve to let water in	
OPEN_VALVE
        BSF	PORTA,	RA0
        MOVLW	0xFF
        MOVWF	TMR1H
        MOVLW	0xED
        MOVWF	TMR1L
	; Delay a few few seconds before opening the valve
	MOVLW	D'4'
	CALL	DELAY
	BSF	PORTA,	RA1
        BSF     T1CON, TMR1ON	; Start Timer0
        RETURN
	
; Close the selonoid valve and cut off water supply into toilet	
CLOSE_VALVE
        BCF     T1CON, TMR1ON	; Stop Timer0
        BCF	PORTA,	RA0
	BCF	PORTA,	RA1
        RETURN


        END
