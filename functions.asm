    ; INTRO TO MICROCOMPUTERS LAB (Lab04)
    ; HASAN YASEN - 152120191030
    ; METIN KONUK - 152120201078
    LIST 	P=16F877A
    INCLUDE	P16F877.INC
    __CONFIG _CP_OFF &_WDT_OFF & _BODEN_ON & _PWRTE_ON & _XT_OSC & _WRT_ENABLE_OFF & _LVP_OFF & _DEBUG_OFF & _CPD_OFF

SUM	EQU	0x20
COUNT	EQU	0x21
X	EQU	0x22
Y	EQU	0x23
N	EQU	0x24
AUX	EQU	0x25
M_RES	EQU	0x26	; return result of Multiply(x, y)
R_L	EQU	0x27	;  low byte of multiplication result
R_H	EQU	0x28	; high byte of multiplication result
I	EQU	0x29	; iterator for multiplication & divison processes
AUX_2	EQU	0x2A	; needed for division
D_RES	EQU	0x2B	; return result of Divide(x, y)
REM	EQU	0x2C	; remainder of divison

A	EQU	0x2D	; [0x2D, 0x2D+COUNT)	
    org 0x00
	
; function calls
MAIN
    MOVLW   d'224'
    MOVWF   X	    ; X = 112

    MOVLW   d'211'
    MOVWF   Y	    ; Y = 100

    MOVLW   d'235'
    MOVWF   N	    ; N = 125

    ; X, Y, N must be set here
    CALL    GENERATE_NUMBERS

    ; count & A must be set here, inside GENERATE_NUMBERS()
    CALL    ADD_NUMBERS

    ; sum must be set here, inside ADD_NUMBERS()
    CALL DISPLAY

    GOTO    FINISH_BLOCK
    ;END, MAIN()
	
; function declarations
GENERATE_NUMBERS:
    CLRF    COUNT	; COUNT = 0
    MOVLW   A		; WREG = A
    MOVWF   FSR		; FSR = &A
    ; while x < N or y < N
    LOOP_BEGIN
	; check if x < N
	MOVF	N, W	    ; WREG = N
	SUBWF	X, W	    ; WREG = X - N
	BTFSC	STATUS, C   ; skip next if x < N
	GOTO	IFYLTNBLOCK

	IF_BLOCK ; inside while, condition provided
	    ; check if (x + y) is odd
	    MOVF    X, W    ; WREG = X
	    ADDWF   Y, W    ; WREG = X + Y
	    MOVWF   AUX	    ; AUX = X + Y
	    BTFSC   AUX, 0  ; skip next if AUX is even
	    GOTO    ODD

	    EVEN
		; A[count++] = (x + y) / 3
		MOVF	X, W	    ; WREG = X
		ADDWF	Y, W	    ; WREG = X + Y

		; WREG = (x + y) / 3 here
		; AUX = x + y, AUX_2 = 3

		MOVFW	X	    ; WREG = X
		ADDWF	Y, W	    ; WREG = X + Y
		MOVWF	AUX	    ; AUX = X + Y

		MOVLW	d'3'	    ; WREG = 3
		MOVWF	AUX_2	    ; AUX_2 = 3

		CALL	DIVIDE
		MOVF	D_RES, W    ; WREG = D_RES = (x + y) / 3


		MOVWF	INDF	    ; A[FSR] = (X + Y) / 3
		; (X + Y) might overflow
		INCF	FSR, F	    ; FSR += 1
		INCF	COUNT, F    ; COUNT += 1
		MOVLW	d'3'
		ADDWF	Y, F	    ; Y += 3
		GOTO	LOOP_BEGIN  ; go out of while loop

	    ODD
		; A[count++] = Multiply(x, y)
		CALL MULTIPLY
		MOVF	M_RES, W    ; WREG = Multiply(x, y)	
		MOVWF	INDF	    ; A[FSR] = Multiply(x, y)
		INCF	FSR, F	    ; FSR += 1
		INCF	COUNT, F    ; COUNT += 1
		INCF	X, F	    ; X += 1
		GOTO	LOOP_BEGIN  ; go out of while loop

	IFYLTNBLOCK ; check if y < N if x >= N
	    MOVF    N, W	; WREG = N
	    SUBWF   Y, W	; WREG = Y - N
	    BTFSS   STATUS, C	; skip next if y >= N
	    GOTO    IF_BLOCK
	ELSE_BLOCK
	    MOVF    COUNT, W	; WREG = COUNT
	    RETURN
; END, GENERATE_NUMBERS()
		    	    
ADD_NUMBERS:
    CLRF    SUM		; SUM = 0
    MOVLW   A		; WREG = &A[0]
    MOVWF   FSR		; FSR = &A[0]

LOOP_START
    MOVF    INDF, W ; WREG = FSR
    ADDWF   SUM, F  ; SUM += FSR

    INCF    FSR, F  ; FSR += 1
    DECFSZ  COUNT, F; COUNT -= 1, if COUNT == 0 skip next
    GOTO    LOOP_START
    RETURN
; END, ADD_NUMBERS()
	 
MULTIPLY:
    CLRF    I		; I = 0
    BSF	    I, 3	; I = b'100' = 8
    CLRF    R_H		; R_H = 0
    MOVFW   Y		; WREG = Y
    MOVWF   R_L		; R_L = Y
    MOVFW   X		; WREG = X
    RRF	    R_L, F	; R_L >>= 1

MULT_LOOP
    BTFSC	STATUS, C   ; least sig. bit of Y == 1 ?
    ADDWF	R_H, F	    ; R_H += X
    RRF	R_H, F		    ; RH >>= 1
    RRF	R_L, F		    ; R_L >>= 1

    DECFSZ	I	    ; iterator--
    GOTO	MULT_LOOP

    ; return 2*p[0] + p1[0]
    ; return 2*R_L + R_H
    MOVFW	R_L	; WREG = R_L
    ADDWF	R_L, W	; WREG = WREG + R_L = 2 * R_L
    MOVWF	M_RES	; M_RES = 2 * R_L

    MOVFW	R_H	; WREG = R_H
    ADDWF	M_RES, F; M_RES = 2*R_L + R_H
    RETURN
; END, MULTIPLY()
			
; computes D_RES = AUX / AUX_2
; Q = D_RES, X = AUX, Y = AUX_2
DIVIDE:
    MOVF    AUX_2, F
    BTFSC   STATUS, Z	; is AUX_2 == 0 ?
    RETURN

    MOVLW   8
    MOVWF   I	    ; iterator = 8
    CLRF    REM	    ; REM = 0
    MOVF    AUX, W  
    MOVWF   D_RES   ; D_RES = AUX

PROCESS
    BCF	    STATUS, C
    RLF	    D_RES, F	; D_RES <<= 1
    RLF	    REM, F	; REM <<= 1
    MOVF    AUX_2, W
    SUBWF   REM, W	; WREG = REM - Y
    BTFSS   STATUS, C
    GOTO    COUNTDOWN
    BSF	    D_RES, 0
    MOVWF   REM

COUNTDOWN
    DECFSZ  I, F
    GOTO    PROCESS
    RETURN
; END, DIVIDE()
    
DELAY:
    MOVLW   d'250'
    MOVWF   X
DELAY_OUTERLOOP:
    MOVLW   d'250'
    MOVWF   Y
DELAY_INNERLOOP:
    NOP
    DECFSZ  Y, F
    GOTO    DELAY_INNERLOOP

    DECFSZ  X, F
    GOTO    DELAY_OUTERLOOP
    MOVLW   -d'1'
    RETURN
; END, DELAY()
    
DISPLAY:
    BSF	    STATUS, RP0 ; SELECT BANK1
    BSF	    TRISB, 3    ; BUTTON3, INPUT MODE
    CLRF    TRISD	; PORTD, ALL PINS OUTPUT
    
    BCF	    STATUS, RP0	; SELECT BANK0
    CLRF    PORTD	; PORTD, ALL LEDS OFF
    
    MOVLW   A		; WREG = &A
    MOVWF   FSR		; FSR = &A
    
    MOVFW   SUM		; WREG = SUM
    MOVWF   PORTD	; PORTD = SUM
    CLRF    I		; I = 0
INFINITE
    BTFSC   PORTB, 3	; FIRE NEXT IF BUTTON3 NOT PRESSED
    GOTO    INFINITE	; while(true)
    MOVF    INDF, W	; WREG = A[I]
    MOVWF   PORTD	; PORTD = A[I]
    CALL    DELAY
    INCF    I, F	; I += 1
    INCF    FSR, F	; FSR += 1
    
    MOVLW   d'5'	; WREG = 5
    SUBWF   I, W	; WREG = I - 5
    BTFSS   STATUS, C	; FIRE NEXT IF I < 5
    GOTO INFINITE
; END, DISPLAY()

FINISH_BLOCK
LOOP    GOTO $
     END