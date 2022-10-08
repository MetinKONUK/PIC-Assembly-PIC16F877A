    LIST 	P=16F877A
    INCLUDE	P16F877.INC
    __CONFIG _CP_OFF &_WDT_OFF & _BODEN_ON & _PWRTE_ON & _XT_OSC & _WRT_ENABLE_OFF & _LVP_OFF & _DEBUG_OFF & _CPD_OFF

    ; Reset vector
    org 0x00
    ; ---------- Initialization ---------------------------------
    BSF     STATUS, RP0	 ; Select Bank1
    CLRF    TRISB	               ; Set all pins of PORTB as output
    CLRF    TRISD	               ; Set all pins of PORTD as output
    BCF     STATUS, RP0	 ; Select Bank0    
    CLRF    PORTB	               ; Turn off all LEDs connected to PORTB
    CLRF    PORTD	; Turn off all LEDs connected to PORTD

    ; ---------- Your code starts here --------------------------
	zib0	EQU	0x20
	zib1	EQU	0x21
	zib	EQU	0x22
	i	EQU	0x23
	N	EQU	0x24
	aux	EQU	0x25
	
	MOVLW	d'2'
	MOVWF	N   ; N = 2
	outer_loop_begin:	; while N < 13
	    MOVF    zib, W
	    SUBLW   d'0'
	    BTFSS   STATUS, Z
	    CALL light_it_up
	    
	    MOVF    N, W	; WREG = N
	    SUBLW   d'13'	; WREG = 13 - N
	     
	    BTFSS   STATUS, C	; goto end if n > 13
	    GOTO    outer_loop_end
	    
	    INCF    N, F    ; N += 1

	outer_loop_body:
	    MOVLW   d'1'    ; WREG = 1
	    MOVWF   zib0    ; zib0 = 1
	    
	    MOVLW   d'2'    ; WREG = 2
	    MOVWF   zib1    ; zib1 = 2
	    
	    MOVLW   -d'1'   ; WREG = -1
	    MOVWF   zib	    ; zib = -1
	    
	    MOVLW   d'2'    ; WREG = 2
	    MOVWF   i	    ; i = 2
	    
	    inner_loop_begin:	; while i < N
		MOVF	N, W	; WREG = N
		SUBWF	i, W	; WREG = i - N
		
		
		BTFSC	STATUS, C  ; goto outer loop begin if i >= N
		GOTO	outer_loop_begin
		
	    inner_loop_body:
    		MOVF	zib1, W	; WREG = zib1
		ANDLW	0x3f	; WREG = 0x3f & zib1
		MOVWF	zib	; zib = 0x3f & zib1

		MOVF	zib0, W	; WREG = zib0
		IORLW	0x05	; WREG = 0x05 | zib0
		ADDWF	zib, F	; zib = (0x05 | zib0) + (0x3f & zib1)
		
		
		MOVF	zib1, W	; WREG = zib1
		MOVWF	aux	; aux = zib1

		MOVF	zib, W	; WREG = zib
		MOVWF	zib1	; zib1 = zib

		MOVF	aux, W	; WREG = zib1
		MOVWF	zib0	; zib0 = zib1
		INCF	i, F	; i += 1
	    
	    
	    GOTO    inner_loop_begin
	    
	outer_loop_end:
	    GOTO    FINISH_BLOCK
	    
	light_it_up:
	    MOVF    zib, W
	    MOVWF   PORTD
	    CALL    Delay250ms
	    
	    
	Delay250ms:
	    x	EQU	0x26
	    y	EQU	0x27
	    MOVLW   d'250'
	    MOVWF   x
	    Delay250ms_OuterLoop:
		MOVLW	d'250'
		MOVWF	y
	    Delay250ms_InnerLoop:
		NOP
		DECFSZ	y, F
		GOTO	Delay250ms_InnerLoop
		
		DECFSZ	x, F
		GOTO	Delay250ms_OuterLoop
		MOVLW	-d'1'
		RETURN
    
	

	

	FINISH_BLOCK:
	    ; ---------- Your code ends here ----------------------------
	    ;MOVLW   d'2'
	    ;MOVWF   PORTD    	; Send the result stored in WREG to PORTD to display it on the LEDs

	    LOOP    GOTO $	; Infinite loop
		 END                               ; End of the program