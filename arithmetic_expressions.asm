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
    ;variables
    x EQU 0x20
    y EQU 0x21
    z EQU 0x22
 
    ;equations
    r1 EQU 0x23
    r2 EQU 0x24
    r3 EQU 0x25
    r4 EQU 0x26
    r  EQU 0x27
  
    ;auxilary space
    aux EQU 0x28
  
    MOVLW d'5'
    MOVWF x
    
    MOVLW d'6'
    MOVWF y
    
    MOVLW d'7'
    MOVWF z
    
    ;first-equation (5 * x - 2 * y + z - 3)
    ;5 * x
    MOVF    x, W	; WREG = x
    MOVWF   r1		; r1 = x
    BCF	    STATUS, C	; Clear the Carry bit of the STATUS register
    RLF	    r1, F	; r1 = 2 * x
    BCF	    STATUS, C	; Clear the Carry bit of the STATUS register
    RLF	    r1, F	; r1 = 4 * x
    ADDWF   r1, F	; r1 = 4 * x + x = 5 * x
    ;-2 * y
    MOVF    y, W	; WREG = y
    MOVWF   aux		; aux = y
    ADDWF   aux, W	; WREG = 2 * y
    SUBWF   r1, F	; r1 = 5 * x - 2 * y
    ;+z
    MOVF    z, W	; WREG = z
    ADDWF   r1, F	; r1 = 5 * x - 2 * y + z
    ;-3
    MOVLW   d'3'	; WREG = 3
    SUBWF   r1, F	; r1 = 5 * x - 2 * y + z - 3

    ;second-equation (x + 5) * 4 - 3 * y + z
    ;4 * (x + 5)
    MOVLW   d'5'	; WREG = 5
    ADDWF   x, W	; WREG = x + 5
    MOVWF   r2		; r2 = x + 5
    BCF	    STATUS, C	; Clear the Carry bit of the STATUS register
    RLF	    r2, F	; r2 = 2 * (x + 5)
    BCF	    STATUS, C	; Clear the Carry bit of the STATUS register
    RLF	    r2, F	; r2 = 4 * (x + 5)
    ;-3 * y
    MOVF    y, W	; WREG = y
    MOVWF   aux		; aux = y
    BCF	    STATUS, C	; Clear the Carry bit of the STATUS register
    RLF	    aux, F	; aux = 2 * y
    ADDWF   aux, F	; aux = 3 * y
    MOVF    aux, W	; WREG = 3 * y
    SUBWF   r2, F	; r2 = 4 * (x + 5) - 3 * y
    ;+z
    MOVF    z, W	; WREG = z
    ADDWF   r2, F	; r2 = 4 * (x + 5) - 3 * y + z
    
    ;third-equation x / 2 + y / 2 + z / 4
    ;x / 2
    BCF	    STATUS, C	; Clear the Carry bit
    RRF	    x, W	; WREG = x / 2
    MOVWF   r3		; r3 = x / 2
    
    ;y / 2
    BCF	    STATUS, C	; Clear the Carry bit
    RRF	    y, W	; WREG = y / 2
    ADDWF   r3, F	; r3 = x / 2 + y / 2
    
    ;z / 4
    MOVF    z, W	; WREG = z
    MOVWF   aux		; aux = z
    BCF	    STATUS, C	; Clear the Carry bit
    RRF	    aux, F	; aux = z / 2
    BCF	    STATUS, C	; Clear the Carry bit
    RRF	    aux, F	; aux = z / 4
    
    MOVF    aux, W	; WREG = aux
    ADDWF   r3, F	; r3 = x / 2 + y / 2 + z / 4
    
    ;fourth-equation (3 * x - y - 3 * z) * 2 - 30
    ;3 * x - y - 3 * z
    MOVF    x, W	; WREG = x
    MOVWF   r4		; r4 = x
    BCF	    STATUS, C	; Clear the Carry bit of the STATUS register
    RLF	    r4, F	; r4 = 2 * x
    ADDWF   r4, F	; r4 = 3 * x
    ;-y
    MOVF    y, W	; WREG = y
    SUBWF   r4, F	; r4 = 3 * x - y
    ;-3 * z
    MOVF    z, W	; WREG = z
    MOVWF   aux		; aux = z
    BCF	    STATUS, C	; Clear the Carry bit of the STATUS register
    RLF	    aux, F	; aux = 2 * z
    ADDWF   aux, F	; aux = 3 * z
    MOVF    aux, W	; WREG = 3 * z
    SUBWF   r4, F	; r4 = 3 * x - y - 3 * z
    ;2 * (3 * x - y - 3 * z)
    BCF	    STATUS, C	; Clear the Carry bit of the STATUS register
    RLF	    r4, F	; r4 = 2 * (3 * x - y - 3 * z)
    ;-30
    MOVLW   d'30'
    SUBWF   r4, F	; r4 = 2 * (3 * x - y - 3 * z) - 30
    
    ;result-equation 3 * r1 + 2 * r2 - r3 / 2 - r4
    ;3 * r1
    MOVF    r1, W	; WREG = r1
    MOVWF   r		; r = r1
    BCF	    STATUS, C	; Clear the Carry bit of the STATUS register
    RLF	    r, F	; r = 2 * r1
    ADDWF   r, F	; r = 3 * r1
    ;2 * r2
    MOVF    r2, W	; WREG = r2
    MOVWF   aux		; aux = r2
    BCF	    STATUS, C	; Clear the Carry bit of the STATUS register
    RLF	    aux, F	; aux = 2 * r2
    MOVF    aux, W	; WREG = 2 * r2
    ADDWF   r, F	; r = 3 * r1 + 2 * r2
    ;-r3 / 2
    MOVF    r3, W	; WREG = r3
    MOVWF   aux		; aux = r3
    BCF	    STATUS, C	; Clear the Carry bit of the STATUS register
    RRF	    aux, F	; aux = r3 / 2
    MOVF    aux, W	; WREG = r3 / 2
    SUBWF   r, F	; r = 3 * r1 + 2 * r2 - r3 / 2
    ;-r4
    MOVF    r4, W	; WREG = r4
    SUBWF   r,	F	; r = 3 * r1 + 2 * r2 - r3 / 2 - r4
    
    MOVF    r, W	; WREG = r, which is required for LEDs to light up
    
    ; ---------- Your code ends here ----------------------------    
    MOVWF   PORTD    	; Send the result stored in WREG to PORTD to display it on the LEDs

    LOOP    GOTO $	; Infinite loop
	 END                               ; End of the program
