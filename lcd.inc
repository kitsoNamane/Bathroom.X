    CONSTANT FUNCTSET8 = b'00110000' ; 8-bit mode, 2 lines
    CONSTANT FUNCTSET4 = b'00100000' ; 4-bit mode, 2 lines
    CONSTANT DDZERO    = b'10000000' ; Write 0 to DDRAM

    CONSTANT LCD2L     = b'00101000'
    CONSTANT LCDCONT   = b'00001100'

    CONSTANT LCDSH     = b'00101000'

 ; Commands for working with LCD display
    CONSTANT LCDCLR = b'00000001' ;clear display, cursor home
    CONSTANT LCDCH  = b'00000010' ;cursor home
    CONSTANT LCDCL  = b'00000100' ;move cursor to the left
    CONSTANT LCDCR  = b'00000110' ;move cursor to the right
    CONSTANT LCDSL  = b'00011000' ;move the content of display
                                  ;to the left
    CONSTANT LCDSR  = b'00011100' ;move the content of display                                  ;to the right
    CONSTANT LCDL1  = b'10000000' ;select line 1
    CONSTANT LCDL2  = b'11000000' ;select line 2


lcdinit macro
    CLRF LCDPORT
    MOVLW B'00000000'
    MOVWF LCDTRIS

    CALL Delay1ms
    CALL Delay1ms
    CALL Delay1ms
    CALL Delay1ms
    MOVLW FUNCTSET8
    CALL SendW
    CALL Delay1ms
    CALL Delay1ms
    MOVLW DDZERO
    CALL SendW

    MOVLW FUNCTSET4
    CALL SendW
;Commands for initializing LCD
    lcdcmd LCD2L 
    lcdcmd LCDCONT
    lcdcmd LCDSH
    lcdcmd LCDCLR
    ENDM

lcdcmd macro LCDcommand
    MOVLW LCDcommand
    CALL LCDcomd 
    ENDM
lcdclr macro
    MOVLW LCDCLR
    CALL LCDcomd 
    ENDM

LCD_DDAdr macro DDRamAddress
local value = DDRamAddress | 0x80
    MOVLW value
    CALL LCDcomd 
    ENDM

LCDcomd CLRF LCDbuf
    GOTO LCDwr

LCDdata CLRF LCDbuf
    BSF LCDbuf,RS
LCDwr MOVWF LCDtemp
    ANDLW b'11110000'
    IORWF LCDbuf,w
    CALL SendW

    SWAPF LCDtemp,w
    ANDLW b'11110000'
    IORWF LCDbuf,w
    CALL SendW
    RETURN

SendW   ; Prints the content of register W on LCD 
    CLRF LCDPORT
    MOVWF LCDPORT
    CALL Delay1ms
    BSF LCDPORT,EN 
    BCF LCDPORT,EN
    CALL Delay1ms
    CLRF LCDPORT
    RETURN

lcdtext macro select, text
    local Message 
    local Start
    local Exit
    ;Customisation starting from here
    local SENDdata
    local Display
    
    GOTO Start
    
Message DB text,0;
Start
    if select==1
    lcdcmd LCDL1
    else
    if select==2
    lcdcmd LCDL2
    endif
    endif
SENDdata MOVLW upper(Message)
    MOVWF TBLPTRU
    MOVLW high(Message)
    MOVWF TBLPTRH
    MOVLW low(Message)
    MOVWF TBLPTRL
Display TBLRD*+
    MOVF TABLAT,W
    IORLW 0x0
    BZ Exit
    CALL LCDdata
    BRA Display
    ;Customisation ends here
Exit
    ENDM


lcdbyte macro arg0
    digbyte arg0

    MOVF Dig1,w
    BTFSC STATUS,Z
    MOVLW 0xf0
    ADDLW 0x30
    CALL LCDdata

    MOVF Dig2,w
    BTFSC STATUS,Z
    MOVLW 0xf0
    ADDLW 0x30
    CALL LCDdata

    MOVF Dig3,w
    ADDLW 0x30
    CALL LCDdata
    ENDM

Delay1ms:
    MOVLW .100
    MOVWF LOOPcnt
Delay10us:
    nop
    nop
    nop
    nop
    nop
    nop
    nop

    DECFSZ LOOPcnt,f
    GOTO Delay10us
    RETURN
