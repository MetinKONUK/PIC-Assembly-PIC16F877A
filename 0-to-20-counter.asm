    LIST 	P=16F877A
    INCLUDE	P16F877.INC
    __CONFIG _CP_OFF &_WDT_OFF & _BODEN_ON & _PWRTE_ON & _XT_OSC & _WRT_ENABLE_OFF & _LVP_OFF & _DEBUG_OFF & _CPD_OFF
    
    ; Reset vector
    org 0x00
    ; ---------- Initialization ---------------------------------
    BSF	STATUS, RP0 ; select BANK1
    CLRF	TRISA	    ; PORTA, OUTPUT MODE
    CLRF	TRISD	    ; PORTD, OUTPUT MODE
    
    BCF	STATUS, RP0 ; select BANK0

    CLRF	PORTD	    ; PORTD = 0
    CLRF	PORTA	    ; deselect all SSDs
    ;BSF	PORTA, 4    ; select 3rd SSD from left

    ; ---------- Your code starts here --------------------------
I	    EQU	    0x20    ; iterator for delay function
J	    EQU	    0x21    ; iterator for delay function
ITERATIONS  EQU	    0x22    ; iterator, belongs to WHILE_LOOP
DIGIT0	    EQU	    0x23    ; value of 2nd SSD from left
DIGIT1	    EQU	    0x24    ; value of 1st SSD from left
COUNTER	    EQU	    0x25    ; iterator, belongs to FOR_LOOP

    MOVLW   d'90'
    MOVWF   ITERATIONS
    CLRF    DIGIT0
    CLRF    DIGIT1
    
WHILE_LOOP  ; while(true)
FOR_LOOP    ; while(i < ITERATIONS)
    ; display the first digit
    BSF	    PORTA, 3	; select the 2nd SSD from left
    BCF	    PORTA, 2	; deselect the 1st SSD from left
    
    MOVFW   DIGIT0	; WREG = DIGIT0
    CALL    GETCODE	; get the code for digit0
    
    MOVWF   PORTD	; display the first digit
    CALL    DELAY	; 5 millisecond delay
    
    
    ; display the second digit
    BSF	    PORTA, 2	; select 1st SSD from left
    BCF	    PORTA, 3	; deselect the 2nd SSD from left
    
    MOVFW   DIGIT1	; WREG = DIGIT1
    CALL    GETCODE	; get the code for digit1
    
    MOVWF   PORTD	; display the second digit
    CALL    DELAY	; 5 millisecond delay
    
    MOVFW   COUNTER	; WREG = COUNTER
    SUBWF   ITERATIONS, W   ; WREG = ITERATIONS - COUNTER
    INCF    COUNTER, F	; COUNTER++
    BTFSC   STATUS, C	    ; skip next if ITERATIONS <= COUNTER
    GOTO    FOR_LOOP
    ; END FOR_LOOP
    
    CLRF    COUNTER	; COUNTER = 0
    
    INCF    DIGIT0, F	; DIGIT0++
    
    ; if (digit0 == 10)
    MOVLW   d'10'
    SUBWF   DIGIT0, W	; WREG = DIGIT0 - 10
    BTFSC   STATUS, Z	; skip next if DIGIT0 - 10 != 0
    CALL    IF_BLOCK
    
    ; if(digit1 == 2 and digit0 == 1)
    ; if(digit1 == 2)
    MOVLW   d'2'
    SUBWF   DIGIT1, W	; WREG = DIGIT1 - 2
    BTFSS   STATUS, Z	; fire next if DIGIT1 - 2 != 0
    GOTO    WHILE_LOOP	; short circuit evaluation, possible END WHILE_LOOP
    
    ; if(digit0 == 1)
    MOVLW   d'1'
    SUBWF   DIGIT0, W	; WREG = DIGIT0 - 1
    BTFSC   STATUS, Z	; skip next if DIGIT0 - 1 != 0
    CALL    IFF_BLOCK
    
    GOTO    WHILE_LOOP  ; END WHILE_LOOP
    
IFF_BLOCK:  ; if digit1 == 2 and digit0 == 1
    CLRF    DIGIT0	; DIGIT0 = 0
    CLRF    DIGIT1	; DIGIT1 = 0
    RETURN
    ; END IFF_BLOCK
    
    
IF_BLOCK:   ; if digit0 == 10
    CLRF    DIGIT0	; DIGIT0 = 0
    INCF    DIGIT1, F	; DIGIT1++
    RETURN
    ; END IF_BLOCK
    
    
GETCODE:    ; returns the proper binary code value for digit in WREG
    ADDWF   PCL, F  ; PROGRAM COUNTER REGISTER += WREG
    RETLW   B'00111111'		; 0
    RETLW   B'00000110'		; 1
    RETLW   B'01011011'		; 2
    RETLW   B'01001111'		; 3
    RETLW   B'01100110'		; 4
    RETLW   B'01101101'		; 5
    RETLW   B'01111101'		; 6
    RETLW   B'00000111'		; 7
    RETLW   B'01111111'		; 8
    RETLW   B'01101111'		; 9  


DELAY:	    ; freeze programme for 5 milliseconds
    MOVLW	d'5'
    MOVWF	I
DELAY_OUTERLOOP
    MOVLW   d'250'
    MOVWF   J
DELAY_INNERLOOP
    NOP
    DECFSZ  J, F
    GOTO    DELAY_INNERLOOP

    DECFSZ  I, F
    GOTO    DELAY_OUTERLOOP
    RETURN
    
    
    ; ---------- Your code ends here ----------------------------    

LOOP    GOTO $	; Infinite loop, (unnecessary)
     END                               ; End of the program
	 