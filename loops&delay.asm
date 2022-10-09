    LIST 	P=16F877A
    INCLUDE	P16F877.INC
    __CONFIG _CP_OFF &_WDT_OFF & _BODEN_ON & _PWRTE_ON & _XT_OSC & _WRT_ENABLE_OFF & _LVP_OFF & _DEBUG_OFF & _CPD_OFF

    ; Reset vector
    org 0x00
    ; ---------- Initialization ---------------------------------
    BSF     STATUS, RP0	 ; Select Bank1
    BSF	    TRISB, 3	 ; TRISB3 = 1: Input Mode
    CLRF    TRISD	 ; Set all pins of PORTD as output
    
    BCF     STATUS, RP0	 ; Select Bank0
    CLRF    PORTD	 ; Turn off all LEDs connected to PORTD
    

    ; ---------- Your code starts here --------------------------
    zib0    EQU	    0x20
    zib1    EQU	    0x21
    zib	    EQU	    0x22
    i	    EQU	    0x23
    N	    EQU	    0x24
	    
    MOVLW   d'1'    ; WREG = 1
    MOVWF   zib0    ; zib0 = 1
    
    MOVLW   d'2'    ; WREG = 2
    MOVWF   zib1    ; zib1 = 2

    MOVWF   i	    ; i = 2
    
    MOVLW   d'13'   ; WREG = 13
    MOVWF   N	    ; N = 13
    
    LOOP_BEGIN:  ; while i <= n
	MOVF	i, W	 ; WREG = i
	SUBWF	N, W	 ; WREG = N - i
	BTFSS	STATUS, C; skip next if i <= n
	GOTO	FINISH_BLOCK
	
    LOOP_BODY:
	; zib: int = (zib1 & 0x3f) + (zib0 | 0x05)
	; zib1 & 0x3f
	MOVF	zib1, W	 ; WREG = zib1
	ANDLW	0x3f	 ; WREG = zib1 & 0x3f
	MOVWF	zib	 ; zib = zib1 & 0x3f
	
	; zib0 & 0x05
	MOVF	zib0, W	 ; WREG = zib0
	IORLW	0x05	 ; WREG = zib0 | 0x05
	ADDWF	zib, F	 ; zib = (zib1 & 0x3f) + (zib0 | 0x05)
	
	MOVF	zib1, W	 ; WREG = zib1
	MOVWF	zib0	 ; zib0 = zib1
	MOVF	zib, W	 ; WREG = zib
	MOVWF	zib1	 ; zib1 = zib
	INCF	i, F	 ; i += 1
	MOVWF	PORTD	 ; print(zib)
	; sleep(0.250)
	CALL DELAY250MS
	;while not is_pressed('button3'): continue
	IF_PRESSED:
	    BTFSC   PORTB, 3 ; skip next if pressed
	    GOTO    IF_PRESSED
	GOTO	LOOP_BEGIN
	
    DELAY250MS:
	x	EQU	0x26
	y	EQU	0x27
	MOVLW   d'250'
	MOVWF   x
	DELAY250MS_OUTERLOOP:
	    MOVLW	d'250'
	    MOVWF	y
	DELAY250MS_INNERLOOP:
	    NOP
	    DECFSZ	y, F
	    GOTO	DELAY250MS_INNERLOOP

	    DECFSZ	x, F
	    GOTO	DELAY250MS_OUTERLOOP
	    MOVLW	-d'1'
	    RETURN
    
    ; ---------- Your code ends here ----------------------------
    FINISH_BLOCK:

	LOOP    GOTO $	; Infinite loop
	     END        ; End of the program