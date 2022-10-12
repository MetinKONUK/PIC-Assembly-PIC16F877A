    LIST 	P=16F877A
    INCLUDE	P16F877.INC
    __CONFIG _CP_OFF &_WDT_OFF & _BODEN_ON & _PWRTE_ON & _XT_OSC & _WRT_ENABLE_OFF & _LVP_OFF & _DEBUG_OFF & _CPD_OFF

    org 0x00
    
    ; ---------- Initialization ---------------------------------
    BSF     STATUS, RP0	 ; Select Bank1
    CLRF    TRISB	 ; Set all pins of PORTB as output
    CLRF    TRISD	 ; Set all pins of PORTD as output
    BCF     STATUS, RP0	 ; Select Bank0    
    CLRF    PORTB	 ; Turn off all LEDs connected to PORTB
    CLRF    PORTD	 ; Turn off all LEDs connected to PORTD
    
    ; ---------- Your code starts here --------------------------
	;variable declarations
	
	DIRECTION   EQU	    0x20
	VAL	    EQU	    0x21
	COUNT	    EQU	    0x22
	    
	A	    EQU	    0x23
	X	    EQU	    0x24
	Y	    EQU	    0x25

	; function calls
	MAIN:
	    CALL    RESET_VARIABLES
	    CALL    SOLVE
	
	; function declarations
	SOLVE:
	    LOOP
		MOVFW	VAL	; WREG = VAL
		MOVWF	PORTD	; PORTD = VAL
		CALL	DELAY
		INCF	COUNT, F; COUNT += 1
		
		; if COUNT == 15
		MOVLW	d'15'
		SUBWF	COUNT, W    ; WREG = COUNT - 15
		BTFSC	STATUS, Z   ; skip next if COUNT != 15
		GOTO	CYCLE_COMPLETED
		
		; cycle not completed, here
		MOVLW	0x80
		SUBWF	VAL, W	    ; WREG = VAL - 0x80
		BTFSC	STATUS, Z   ; skip next if VAL != 0x80
		INCF	DIRECTION, F; DIRECTION = 1
		
		; if direction == 0
		BCF	STATUS, C
		BTFSS	DIRECTION, 0; skip next if DIR = 1
		RLF	VAL, F	    ; VAL <<= 1
		
		BTFSC	DIRECTION, 0; skip next if DIR = 0
		; if direction == 1
		RRF	VAL, F	    ; VAL >>= 1
		
		
	    GOTO LOOP

	CYCLE_COMPLETED:
	    ; flash the LEDs twice, here
	    MOVLW   d'0'
	    MOVWF   PORTD   ; PORTD = 0
	    CALL    DELAY
	    
	    MOVLW   0xFF
	    MOVWF   PORTD   ; PORTD = 0xFF
	    CALL    DELAY
	    
	    MOVLW   d'0'
	    MOVWF   PORTD   ; PORTD = 0
	    CALL    DELAY
	    
	    MOVLW   0xFF
	    MOVWF   PORTD   ; PORTD = 0xFF
	    CALL    DELAY
	    
	    MOVLW   d'0'
	    MOVWF   PORTD   ; PORTD = 0
	    CALL    DELAY
	    
	    CALL RESET_VARIABLES
	    RETURN
	
    
	RESET_VARIABLES:
	    CLRF    DIRECTION	; DIRECTION = 0, move left
	    CLRF    COUNT	; COUNT = 0
	    MOVLW   0x1
	    MOVWF   VAL		; VAL = 0x1
	    
	    RETURN
	DELAY:
	    ;CALL    DELAY250MS
	    CALL    DELAY500MS
	    RETURN
	
	DELAY500MS:
	    MOVLW   d'2'
	    MOVWF   A	
	    
	    DELAY500MS_MAINLOOP
		MOVLW	d'250'
		MOVWF	Y
	    
	    DELAY500MS_OUTERLOOP
		MOVLW	d'250'
		MOVWF	X
	    
	    DELAY500MS_INNERLOOP
		NOP
		DECFSZ	X, F	; X -= 1
		GOTO	DELAY500MS_INNERLOOP
		
		DECFSZ	Y, F	; Y -= 1
		GOTO	DELAY500MS_OUTERLOOP
		
		DECFSZ	A, F	; A -= 1
		GOTO	DELAY500MS_MAINLOOP
		RETURN
	
	DELAY250MS:
	    MOVLW   d'250'
	    MOVWF   X
	    
	    DELAY250MS_OUTERLOOP
		MOVLW	d'250'
		MOVWF	Y
	    
	    DELAY250MS_INNERLOOP
		NOP
		DECFSZ	Y, F
		GOTO	DELAY250MS_INNERLOOP
		
		DECFSZ	X, F
		GOTO	DELAY250MS_OUTERLOOP
		RETURN
	END