digbyte macro arg0
	local Pon0
	local Exit1
	local Exit2
	local Pozitiv

	clrf Dig1
	clrf Dig2
	clrf Dig3
Pozitiv	
	movf arg0,w
	movwf Digtemp
	movlw .100
Pon0	
	incf Dig1,f
	subwf Digtemp,f
	btfsc STATUS,C
	goto Pon0
	decf Dig1,f
	addwf Digtemp,f
Exit1	movlw .10
	incf Dig2,f
	subwf Digtemp,f
	btfsc STATUS,C
	goto Exit1
	decf Dig2,f
	addwf Digtemp,f
Exit2
	movf Digtemp,w
	movwf Dig3
	endm
	
pausems macro arg1
    local Loop1
    local dechi
    local Delay1ms
    local Loop2
    local Kraj
	ifndef OSC
	#define OSC 4
	endif 

	movlw high (arg1*OSC/4)
	movwf HIcnt
	movlw low (arg1*OSC/4)
	movwf LOcnt
Loop1
	movf LOcnt,f
	btfsc STATUS,Z
	goto dechi	
	call Delay1ms
	decf LOcnt,f
	goto Loop1	
dechi
	movf HIcnt,f
	btfsc STATUS,Z
	goto Kraj
	call Delay1ms
	decf HIcnt,f
	decf LOcnt,f

	goto  Loop1
	
Delay1ms:

	movlw .100
	movwf LOOPcnt
Loop2:
	nop		
	nop 
	nop
	nop	
	nop 
	nop
	nop
	
	decfsz LOOPcnt,f
	goto Loop2

	return

Kraj
    endm