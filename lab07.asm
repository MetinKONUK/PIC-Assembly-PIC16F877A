    LIST 	P=16F877A
    INCLUDE	P16F877.INC
    __CONFIG _CP_OFF &_WDT_OFF & _BODEN_ON & _PWRTE_ON & _XT_OSC & _WRT_ENABLE_OFF & _LVP_OFF & _DEBUG_OFF & _CPD_OFF
    
    ; Reset vector
    org 0x00
    GOTO    MAIN
    #include <Delay.inc>	; Delay library (Copy the contents here)
    #include <LcdLib.inc>	; LcdLib.inc (LCD) utility routines
    
MAIN
    BSF	STATUS, RP0 ; select BANK1
    CLRF	TRISA	    ; PORTA, OUTPUT MODE
    CLRF	TRISD	    ; PORTD, OUTPUT MODE
    CLRF	TRISE	    ; PORTE, OUTPUT MODE
    
    MOVLW	0x03
    MOVWF	ADCON1
    
    BCF	STATUS, RP0 ; select BANK0
    CALL    LCD_Initialize  ; initialize the LCD
    CLRF	PORTD	    ; PORTD = 0
    CLRF	PORTA	    ; deselect all SSDs

I	    EQU	    0x20    ; iterator for delay function
J	    EQU	    0x21    ; iterator for delay function
ITERATIONS  EQU	    0x22    ; iterator, belongs to WHILE_LOOP
DIGIT0	    EQU	    0x23    ; value of 2nd SSD from left
DIGIT1	    EQU	    0x24    ; value of 1st SSD from left
COUNTER	    EQU	    0x25    ; iterator, belongs to FOR_LOOP
; 0 = "Counting up...", 1 = "Rolled over to 0"
MESSAGE	    EQU	    0x26    ; message-type
	    

    MOVLW   d'90'
    MOVWF   ITERATIONS
    CLRF    DIGIT0
    CLRF    DIGIT1
    CLRF    MESSAGE
        
WHILE_LOOP  ; while(true)
    BCF	    PORTA, 5	;
    BCF	    PORTA, 4	;

    CALL    DISPLAY_FIRST_LINE
    CALL    LCD_MoveCursor2SecondLine
    CALL    DISPLAY_SECOND_LINE
    
FOR_LOOP    ; while(i < ITERATIONS)
    ; display the first digit
    BSF	    PORTA, 5	; select the 4th SSD from left
    BCF	    PORTA, 4	; deselect the 3rd SSD from left
    
    MOVFW   DIGIT0	; WREG = DIGIT0
    CALL    GETCODE	; get the code for digit0
    
    MOVWF   PORTD	; display the first digit
    CALL    DELAY	; 5 millisecond delay
    
    
    ; display the second digit
    BSF	    PORTA, 4	; select 3rd SSD from left
    BCF	    PORTA, 5	; deselect the 4th SSD from left
    
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
    CLRF    MESSAGE	; MESSAGE = "Counting up..."
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
    MOVLW   d'1'
    MOVWF   MESSAGE
    ;INCF    MESSAGE, F	; MESSAGE = "Rolled over to 0"
    RETURN
    ; END IFF_BLOCK
    
    
IF_BLOCK:   ; if digit0 == 10
    CLRF    DIGIT0	; DIGIT0 = 0
    INCF    DIGIT1, F	; DIGIT1++
    RETURN
    ; END IF_BLOCK
    
DISPLAY_ROLLED_OVER_TEXT:
    MOVLW   'R'
    CALL    LCD_Send_Char
    RETURN
    

DISPLAY_COUNTING_UP_TEXT:
    MOVLW   'C'
    CALL    LCD_Send_Char
    RETURN
    
    
DISPLAY_SECOND_LINE:
    BTFSS   MESSAGE, 0
    GOTO    IFF
    
    CALL    DISPLAY_ROLLED_OVER_TEXT
    GOTO END_BLOCK
    
    IFF
	CALL DISPLAY_COUNTING_UP_TEXT

    END_BLOCK
        RETURN
	

    
    
DISPLAY_FIRST_LINE:
    CALL    LCD_Clear
    
    MOVLW   'C'
    CALL    LCD_Send_Char
    
    MOVLW   'o'
    CALL    LCD_Send_Char

    MOVLW   'u'
    CALL    LCD_Send_Char
    
    MOVLW   'n'
    CALL    LCD_Send_Char
    
    MOVLW   't'
    CALL    LCD_Send_Char
    
    MOVLW   'e'
    CALL    LCD_Send_Char
    
    MOVLW   'r'
    CALL    LCD_Send_Char
    
    MOVLW   ' '
    CALL    LCD_Send_Char
    
    MOVLW   'V'
    CALL    LCD_Send_Char
    
    MOVLW   'a'
    CALL    LCD_Send_Char
    
    MOVLW   'l'
    CALL    LCD_Send_Char
    
    MOVLW   ':'
    CALL    LCD_Send_Char
    
    MOVLW   ' '
    CALL    LCD_Send_Char
    
    MOVFW   DIGIT1	    ; WREG = DIGIT1
    ADDLW   '0'
    CALL    LCD_Send_Char
    
    MOVFW   DIGIT0	    ; WREG = DIGIT0
    ADDLW   '0'
    CALL    LCD_Send_Char
    
    RETURN	; END DISPLAY_FIRST_LINE

    
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
    
    END
	 