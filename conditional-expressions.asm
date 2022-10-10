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
	x   EQU	0x20
	y   EQU 0x21
	box EQU 0x22
 
	MOVLW	d'0'
	MOVWF	x
	
	MOVLW	d'4'
	MOVWF	y
	
	MOVLW	d'0'
	MOVWF	box
	
	; x >= 0 && x <= 11
	
	;IF_X_GE_0_BLOCK:
	BTFSC	x, 7 ; x >= 0 ise geç
	GOTO	ELSE_BLOCK
	
	;IF_X_LE_11_BLOCK:
	MOVF	x, W
	SUBLW	d'11' ; 11 - x
	BTFSS	STATUS, C ; x <= 11 ise geç
	GOTO	ELSE_BLOCK
	
	;IF_Y_GE_0_BLOCK:
	BTFSC	y, 7 ; y >= ise geç
	GOTO	ELSE_BLOCK
	
	;IF_Y_LE_10_BLOCK:
	MOVF	y, W
	SUBLW	d'10'
	BTFSS	STATUS, C ; y <= 10 ise geç
	GOTO	ELSE_BLOCK
	        
	IF_BLOCK:
	    MOVF    x, W
	    SUBLW   d'3'    ; 3 - x
	    BTFSC   STATUS, C
	    GOTO    IFF_BLOCK
	    
	    MOVF    x, W
	    SUBLW   d'7'
	    BTFSC   STATUS, C
	    GOTO    ELSEE_IFF_BLOCK
	    
	    ELSEE_BLOCK:
		MOVF    y, W
		SUBLW   d'2'    ; 2 - y
		BTFSC   STATUS, C
		GOTO    IFF2_BLOCK

		MOVF    y, W
		SUBLW   d'6'    ; 6 - y
		BTFSC   STATUS, C
		GOTO    ELSEE_IFF20_BLOCK

		MOVF    y, W
		SUBLW   d'8'
		BTFSC   STATUS, C
		GOTO    ELSEE_IFF21_BLOCK

		ELSEE2_BLOCK:
		    MOVLW	d'6'
		    MOVWF	box
		    GOTO	FINISH_BLOCK

		ELSEE_IFF21_BLOCK:
		    MOVLW	d'7'
		    MOVWF	box
		    GOTO	FINISH_BLOCK

		ELSEE_IFF20_BLOCK:
		    MOVLW	d'8'
		    MOVWF	box
		    GOTO	FINISH_BLOCK

		IFF2_BLOCK:
		    MOVLW	d'9'
		    MOVWF	box
		    GOTO	FINISH_BLOCK
	    
	    ELSEE_IFF_BLOCK:
		MOVF    y, W
		SUBLW   d'5' ; 5 - y
		BTFSC   STATUS, C
		GOTO    IFF1_BLOCK

		ELSEE1_BLOCK:
		    MOVLW	d'4'
		    MOVWF	box
		    GOTO	FINISH_BLOCK

		IFF1_BLOCK:
		    MOVLW	d'5'
		    MOVWF	box
		    GOTO	FINISH_BLOCK
	    
	    IFF_BLOCK:
		MOVF	y, W
		SUBLW	d'1'	;1 - y
		BTFSC	STATUS, C
		GOTO	IFF0_BLOCK
		
		MOVF	y, W
		SUBLW	d'4'	;4 - y
		BTFSC	STATUS, C
		GOTO	ELSEE0_IFF_BLOCK
		
		ELSEE0_BLOCK:
		    MOVLW   d'1'
		    MOVWF   box
		    GOTO    FINISH_BLOCK
		
		ELSEE0_IFF_BLOCK:
		    MOVLW   d'2'
		    MOVWF   box
		    GOTO    FINISH_BLOCK
		
		IFF0_BLOCK:
		    MOVLW   d'3'
		    MOVWF   box
		    GOTO    FINISH_BLOCK
	
	
	ELSE_BLOCK:
	    MOVLW	-d'1'
	    MOVWF	box

	FINISH_BLOCK:
	    ; ---------- Your code ends here ----------------------------    
	    MOVWF   PORTD    	; Send the result stored in WREG to PORTD to display it on the LEDs

	    LOOP    GOTO $	; Infinite loop
		 END                               ; End of the program

	    
	
	
	
	
	
	   
	 
	

    
	
    
