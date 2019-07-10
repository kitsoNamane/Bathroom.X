; PIC20F2550 Configuration Bit Settings
; Assembly source line config statements

    LIST P=18F2550
    #include "p18f2550.inc"


    ; CONFIG1L
    ;CONFIG DEBUG=ON
    ;CONFIG  PLLDIV = 1            ; PLL Prescaler Selection bits (No prescale (4 MHz oscillator input drives PLL directly))
    ;CONFIG  CPUDIV = OSC1_PLL2    ; System Clock Postscaler Selection bits ([Primary Oscillator Src: /1][96 MHz PLL Src: /2])
    ;CONFIG  USBDIV = 1            ; USB Clock Selection bit (used in Full-Speed USB mode only; UCFG:FSEN = 1) (USB clock source comes directly from the primary oscillator block with no postscale)

    ; CONFIG1H
    CONFIG  FOSC = INTOSC_HS             ; Oscillator Selection bits (HS oscillator (HS))
    ;CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enable bit (Fail-Safe Clock Monitor disabled)
    ;CONFIG  IESO = OFF            ; Internal/External Oscillator Switchover bit (Oscillator Switchover mode disabled)

    ; CONFIG2L
    CONFIG  PWRT = OFF            ; Power-up Timer Enable bit (PWRT disabled)
    CONFIG  BOR = OFF             ; Brown-out Reset Enable bits (Brown-out Reset disabled in hardware and software)
    ;CONFIG  BORV = 3              ; Brown-out Reset Voltage bits (Minimum setting 2.05V)
    ;CONFIG  VREGEN = OFF          ; USB Voltage Regulator Enable bit (USB voltage regulator disabled)

    ; CONFIG2H
    CONFIG  WDT = OFF             ; Watchdog Timer Enable bit (WDT disabled (control is placed on the SWDTEN bit))
    ;CONFIG  WDTPS = 32768         ; Watchdog Timer Postscale Select bits (1:32768)

    ; CONFIG3H
    ;CONFIG  CCP2MX = ON           ; CCP2 MUX bit (CCP2 input/output is multiplexed with RC1)
    ;CONFIG  PBADEN = OFF          ; PORTB A/D Enable bit (PORTB<4:0> pins are configured as digital I/O on Reset)
    ;CONFIG  LPT1OSC = OFF         ; Low-Power Timer 1 Oscillator Enable bit (Timer1 configured for higher power operation)
    CONFIG  MCLRE = ON            ; MCLR Pin Enable bit (MCLR pin enabled; RE3 input pin disabled)

    ; CONFIG4L
    ;CONFIG  STVREN = ON           ; Stack Full/Underflow Reset Enable bit (Stack full/underflow will cause Reset)
    CONFIG  LVP = OFF             ; Single-Supply ICSP Enable bit (Single-Supply ICSP disabled)
    ;CONFIG  XINST = ON           ; Extended Instruction Set Enable bit (Instruction set extension and Indexed Addressing mode disabled (Legacy mode))

    ; CONFIG5L
    ;CONFIG  CP0 = OFF             ; Code Protection bit (Block 0 (000800-001FFFh) is not code-protected)
    ;CONFIG  CP1 = OFF             ; Code Protection bit (Block 1 (002000-003FFFh) is not code-protected)
    ;CONFIG  CP2 = OFF             ; Code Protection bit (Block 2 (004000-005FFFh) is not code-protected)
    ;CONFIG  CP3 = OFF             ; Code Protection bit (Block 3 (006000-007FFFh) is not code-protected)

    ; CONFIG5H
    ;CONFIG  CPB = OFF             ; Boot Block Code Protection bit (Boot block (000000-0007FFh) is not code-protected)
    ;CONFIG  CPD = OFF             ; Data EEPROM Code Protection bit (Data EEPROM is not code-protected)

    ; CONFIG6L
    ;CONFIG  WRT0 = OFF            ; Write Protection bit (Block 0 (000800-001FFFh) is not write-protected)
    ;CONFIG  WRT1 = OFF            ; Write Protection bit (Block 1 (002000-003FFFh) is not write-protected)
    ;CONFIG  WRT2 = OFF            ; Write Protection bit (Block 2 (004000-005FFFh) is not write-protected)
    ;CONFIG  WRT3 = OFF            ; Write Protection bit (Block 3 (006000-007FFFh) is not write-protected)

    ; CONFIG6H
    ;CONFIG  WRTC = OFF            ; Configuration Register Write Protection bit (Configuration registers (300000-3000FFh) are not write-protected)
    ;CONFIG  WRTB = OFF            ; Boot Block Write Protection bit (Boot block (000000-0007FFh) is not write-protected)
    ;CONFIG  WRTD = OFF            ; Data EEPROM Write Protection bit (Data EEPROM is not write-protected)

    ; CONFIG7L
    ;CONFIG  EBTR0 = OFF           ; Table Read Protection bit (Block 0 (000800-001FFFh) is not protected from table reads executed in other blocks)
    ;CONFIG  EBTR1 = OFF           ; Table Read Protection bit (Block 1 (002000-003FFFh) is not protected from table reads executed in other blocks)
    ;CONFIG  EBTR2 = OFF           ; Table Read Protection bit (Block 2 (004000-005FFFh) is not protected from table reads executed in other blocks)
    ;CONFIG  EBTR3 = OFF           ; Table Read Protection bit (Block 3 (006000-007FFFh) is not protected from table reads executed in other blocks)

    ; CONFIG7H
    ;CONFIG  EBTRB = OFF           ; Boot Block Table Read Protection bit (Boot block (000000-0007FFh) is not protected from table reads executed in other blocks)
    ;#include "config.inc"

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
        TIMERcount

        temp
    endc


    org	0x00
    GOTO Init


LCDPORT equ PORTC
LCDTRIS equ TRISC

CLKcount equ 0x20
;TIMERcount equ 0x00

EN equ RB3
RS equ RB2

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

    org 0x200
Init
    CLRF	PORTA
    CLRF	PORTB
    CLRF	PORTC

    ; Configure Interrupt Control Register
    BSF     INTCON, INT0IE	; Enable INT0 interrupt
    BSF     INTCON3,INT1IP	; Set INT1 to high priority
    BSF     INTCON3,INT1IE  ; Enable INT1 enterrupts
    BSF     INTCON, PEIE	; Enable Periferal interrrupts
    BCF     PIE1,   TMR1IE	; Clear	TMR1 interrupts
    BSF     PIE1,   TMR1IE	; Enable TMR1 interrupts
    BSF     INTCON, GIE	; Enable GIE

    ; Configure TIMERS, all in 16-bit mode
    ; TMR0 as a TIMER
    ; TMR1 as a COUNTER
    ; 1:16 Prescaler for TMR0
    ; No prescaler for  TMR1
    ; Use External source on RA0/T0CKI
    MOVLW	B'00001000'	; Timer0, 16-bit, int clk, 32 prescaler
    MOVWF	T0CON
    MOVLW   B'10000000'	; Timer1, 16-bit, ext clk, no prescaler
    MOVWF	T1CON	; Load T1CON Register
    MOVLW	0x0F
    MOVWF	ADCON1
    MOVLW	0x07
    MOVWF	CMCON

    ; Configure PortA as all output except TICK0
    MOVLW	B'00010000'    
    MOVWF	TRISA

    ; Configure PortB
    MOVLW	B'11110011'
    MOVWF	TRISB
    
    ; Configure PortC
    MOVLW	B'00000000'
    MOVWF	TRISC

    ; Configure RCO clock input
    BSF	TRISC,	RC0
    
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
    ;MOVLW	D'8'
    ;MOVWF	TIMERcount
    ;;CALL	TMRdelay
    CALL Delay4s
    
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
    CLRF TMR0H
    CLRF TMR0L

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
    BSF     T1CON, TMR1ON	; Start Timer0
    lcdcmd 0x01
    lcdtext 1, "Loading Water..."
    RETURN


; Close the selonoid valve and cut off water supply into toilet	
ClOSEvalve
    lcdcmd 0x01
    lcdtext 1, "Max Volume"
    lcdtext 2, "Reached"
    BCF	PORTA,	RA0
    BCF	PORTA,	RA1
    CLRF TIMERcount
    MOVLW   D'8'
    MOVWF   TIMERcount
    CALL    TMRdelay
    RETURN
    
Fault BCF INTCON3,INT1IE
    BCF OSCCON, IDLEN
    SLEEP
    RETURN
    
    end
