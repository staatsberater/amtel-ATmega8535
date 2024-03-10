; **************************************************************************
; ** 		AVR Macro Collection for LG-VR Eternal System		  **
; **		Design by   : Fr. Lucky Gun (Excelcis@Telkom.net)	  **
; **		Last Update : 6 November 2004				  **
; **									  **
; ** 		These Macros are free and may be used 			  **
; **		for personal and educational purposes only. 		  **
;***************************************************************************



;----------------------------------------------------------------------
;---------------- LOW CASE is already available in AVR ----------------
; add,adc,sub,sbc=0-31, subi,sbci=16-31
;----------------------------------------------------------------------
; ADDI	 R16,$0F(subi)	subi	R16,$0F	      	(R=16-31)

; adiw	 R24,63	       	sbiw	R24,63		(R=24-31 k=0-63)
; ADDWI	 R17,R16,$00FF 	SUBWI	R17,R16,$00FF 	(R=16-31 k=0-FFFF)
;   subi&sbci		  subi&sbci
; ADDXI	 $1000		SUBXI	$1000
; ADDYI	 $1000		SUBYI	$1000
; ADDZI	 $1000		SUBZI	$1000

; add	 R1,R0		sub	R1,R0		(R=0-31)
; ADDW   R1,R0,R17,R16	SUBW	R1,R0,R17,R16   (R=0-31)
;   add&adc		  sub&sbc
; ADDX	 R1,R0		SUBX	R1,R0           (R=0-31)
; ADDY	 R1,R0		SUBY	R1,R0           (R=0-31)
; ADDZ	 R1,R0		SUBZ	R1,R0           (R=0-31)

; ADDW8  R1,R0,R31	SUBW8	R17,R16,R0	(RW=16-31,R=0-31)  (ADDW8 R=0-31)
;   clr&add&adc		  sub&sbci
; ADDX8	 R0		SUBX8	R0           	(R=0-31)
; ADDY8	 R0		SUBY8	R0           	(R=0-31)
; ADDZ8	 R0		SUBZ8	R0           	(R=0-31)
;   Hints for ADDW8 without temp:
;       1. (add @1,@2) (push @0) (clr @0) (adc @H,@0) (pop @0) => 5 cycles
;   Hints for SUBW8 for RW=0-31:
; 	1. (clr temp) (sub @1,@2) (sbc @0,temp)	=> 3 cycles

; LDW	 R17,R16,$00FF	(R=16-31)
;   ldi&ldi
; LDX	 $00FF
; LDY	 $00FF
; LDZ	 $00FF

; CLRW	 R1,R0          SERW	 R17,R16     	CLRW(R=0-31) SERW(R=16=31)
;   clr&clr		  ser&ser
; CLRX			SERX
; CLRY                  SERY
; CLRZ                  SERZ

; INCW	 R17,R16	DECW	 R17,R16	(R=16-31)
;   subi&sbci		  subi&sbci				=> 2 cycles
;   Hints for inc/dec 16 for R0-15:
;      (inc/dec @L) (in temp,SREG) (sbrc temp,1) (inc/dec @H)	=> 3/4 cycles
; INCX			DECX
; INCY			DECY
; INCZ			DECZ
; tips : INCX/Y/Z sama dengan pake sbiw XL/YL/ZL,1	=> 2 cycles
;	 tapi bisa pake ld R?,X+/Y+/Z+			=> 1 cycles, tapi pake 1 register

; PUSHX			POPX
; PUSHY			POPY
; PUSHZ			POPZ

; neg R0	(R=16-31)
; NEGW R0,R1	(R=16-31)
;   comw, incw
; NEGX
; NEGY
; NEGZ

; CPWR 	R1,R0,R17,R16	(R=0-31)
;   cp&cpc
; CPXR	R1,R0
; CPYR  R1,R0
; CPZR  R1,R0

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;! ! ! !  This macros use R25 as temporary register  ! ! ! !
;-----------------------------------------------------------
; CPWI 	R17,R16,$00FF	(R=16-31)	cpi&ldi-temp&cpc		=> 3 cycles
;   Hints for CPWI for R0-15:
;      (ldi tmp,low(@2)) (cp @1,temp) (ldi temp,high(@2)) (cpc @0,temp) => 4 cycles
; CPXI	$00FF
; CPYI  $00FF
; CPZI  $00FF

; cpse	R0,R16		(R=0-31)
; CPISE	R0,$F0		(R=0-31)
;   ldi-temp&cpse
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;-----------------------------------------------------------

; CJE	R0,R16,next		CJNE	R0,R16,next	    (R=0-31)
;   cp&breq			  cp&brne
; CWJE	R1,R0,R17,R16,next	CWJNE	R1,R0,R17,R16,next  (R=0-31)
;   cpwr(cp&cpc)&breq		  cpwr(cp&cpc)&brne

; CIJE	R16,$0F,next		CIJNE	R16,$0F,next (R=16-31)
;   cpi&breq		  	  cpi&brne


;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;! ! ! !  This macros use R25 as temporary register  ! ! ! !
;-----------------------------------------------------------
; CWIJE	R17,R16,$0F0F,next	CWIJNE	R17,R16,$FF00,next  (R=16-31)
;   cpwi(cpi&ldi-temp&cpc)&breq   cpwi(cpi&ldi-temp&cpc)&brne

;  Hints for CWIJE for R0-15: => see Hints for CPWI for R0-15:
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;-----------------------------------------------------------

;JZ	R0,Next		JNZ	R0,Next		(R=0-31)
;  tst,breq		  tst,brne
;JB	R0,7,Next	JNB	R0,7,Next	(R=0-31)
;  sbrc,rjmp		  sbrs,rjmp

;DJZ	R0,Next		DJNZ	R0,Next		(R=0-31)
;  dec,breq		  dec,brne
;DWJZ	R17,R16,Next	DJNZW	R17,R16,Next	(R=16-31)
;  subi,sbci,breq	  subi,sbci,brne 



;*********************** MACRO PROGRAMS ************************************
.def	Temp	= R25

;***************************************************************************
.macro	ADDI			;Add 8 bits immediate to 8 bits register
	subi	@0,-@1		;subtract negative value
.endmacro
;Example ->	ADDI	r16,$F0	;Add $F0 to r16

;***************************************************************************
; Command SUBI already exist
;Example ->	SUBI	r16,$F0	;Subtract $F0 from r16

;***************************************************************************
.macro	ADDWI			;Add 16 bits immediate to 16 bits register
	subi	@1,low(-@2)	;Add low byte
	sbci	@0,high(-@2)	;Add high byte with carry
.endmacro
;Example ->	ADDWI	r17,r16,$00FF	;Add $00FF to r17:r16

;***************************************************************************
.macro	SUBWI			;Subtract 16 bits immediate from 16 bits register
	subi	@1,low(@2)	;Subtract low byte
	sbci	@0,high(@2)	;Subtract high byte with carry
.endmacro
;Example ->	SUBWI	r17,r16,10000	;Subtract 10000 from r17:r16

;***************************************************************************
.macro 	ADDXI 			;Add 16 bits immediate to the X-pointer
	subi 	XL,low(-@0)	;Add immediate low byte to XL
	sbci	XH,high(-@0)	;Add immediate high byte with carry to XH
.endmacro
;Example ->	ADDXI	750	;Increase X-pointer by 750

;***************************************************************************
.macro 	SUBXI 			;Subtract 16 bits immediate from the X-pointer
	subi 	XL,low(@0)	;Subtract immediate low byte from XL
	sbci 	XH,high(@0)	;Subtract immediate high byte with carry from XH
.endmacro
;Example ->	SUBXI	REC	;Decrease X-pointer by value REC

;***************************************************************************
.macro 	ADDYI 			;Add 16 bits immediate to the Y-pointer
	subi 	YL,low(-@0)	;Add immediate low byte to YL
	sbci	YH,high(-@0)	;Add immediate high byte with carry to YH
.endmacro

;***************************************************************************
.macro 	SUBYI 			;Subtract 16 bits immediate from the Y-pointer
	subi 	YL,low(@0)	;Subtract immediate low byte from YL
	sbci 	YH,high(@0)	;Subtract immediate high byte with carry from YH
.endmacro

;***************************************************************************
.macro 	ADDZI 			;Add 16 bits immediate to the Z-pointer
	subi 	ZL,low(-@0)	;Add immediate low byte to ZL
	sbci	ZH,high(-@0)	;Add immediate high byte with carry to ZH
.endmacro

;***************************************************************************
.macro 	SUBZI 			;Subtract 16 bits immediate from the Z-pointer
	subi 	ZL,low(@0)	;Subtract immediate low byte from ZL
	sbci 	ZH,high(@0)	;Subtract immediate high byte with carry from ZH
.endmacro




;***************************************************************************
.macro	ADDW			; Add 16 bits register to 16 bits register
	add	@1, @3		; add low byte register
	adc	@0, @2		; add high byte register with carry
.endmacro
;Example ->	ADDW	R1,R0,R17,R16	; add register R17:R16 to R1:R0

;***************************************************************************
.macro	SUBW			; Subtract 16 bits register from 16 bits register
	sub	@1, @3		; subtract low byte register
	sbc	@0, @2		; subtract high byte register with carry
.endmacro
;Example ->	SUBW	R1,R0,R17,R16	; subtract register R17:R16 from R1:R0

;***************************************************************************
.macro	ADDX			; add 16 bits register to register X
	add	XL, @1		; add low byte
	adc	XH, @0		; add high byte with carry
.endmacro
;Example ->	ADDX	R1,R0	; add R1:R0 to X

;***************************************************************************
.macro	SUBX			; subtract 16 bits register from register X
	sub	XL, @1		; subtract low byte
	sbc	XH, @0		; subtract high byte with carry
.endmacro
;Example ->	SUBX	R1,R0	; subtract R1:R0 from X

;***************************************************************************
.macro	ADDY			; add 16 bits register to register Y
	add	YL, @1		; add low byte
	adc	YH, @0		; add high byte with carry
.endmacro

;***************************************************************************
.macro	SUBY			; subtract 16 bits register from register Y
	sub	YL, @1		; subtract low byte
	sbc	YH, @0		; subtract high byte with carry
.endmacro

;***************************************************************************
.macro	ADDZ			; add 16 bits register to register Z
	add	ZL, @1		; add low byte
	adc	ZH, @0		; add high byte with carry
.endmacro

;***************************************************************************
.macro	SUBZ			; subtract 16 bits register from register Z
	sub	ZL, @1		; subtract low byte
	sbc	ZH, @0		; subtract high byte with carry
.endmacro




;***************************************************************************
.macro	ADDW8			; Add 8 bits register to 16 bits register
	clr	temp
	add	@1, @2		; add low byte
	adc	@0, temp	; add high byte with carry
.endmacro
;Example ->	ADDW8	R17,R16,R0  ; add R0 to R17:R16

;***************************************************************************
.macro	SUBW8			; subtract 8 bits register from 16 bits register
	sub	@1, @2		; subtract low byte
	sbci	@0, 0		; subtract high byte with carry
.endmacro
;Example ->	SUBW8	R17,R16,R0  ; subtract R0 from R17:R16

;***************************************************************************
.macro	ADDX8			; add 8 bits register to 16 bits register
	clr	temp
	add	XL, @0		; add low byte
	adc	XH, temp	; add high byte with carry
.endmacro
;Example ->	ADDX8	R0	; add  in register R0 to X

;***************************************************************************
.macro	SUBX8			; Subtract 8 bits register from 16 bits register
	sub	XL, @0		; Subtract low byte
	sbci	XH, 0		; Subtract high byte with carry
.endmacro
;Example ->	SUBX8	R0	; Subtract in register R0 to X

;***************************************************************************
.macro	ADDY8			; add 8 bits register to register Y
	clr	temp
	add	YL, @0		; add low byte
	adc	YH, temp	; add high byte with carry
.endmacro

;***************************************************************************
.macro	SUBY8			; Subtract 8 bits register from register Y
	sub	YL, @0		; Subtract low byte
	sbci	YH, 0		; Subtract high byte with carry
.endmacro

;***************************************************************************
.macro	ADDZ8			; add 8 bits register to register Z
	clr	temp
	add	ZL, @0		; add low byte
	adc	ZH, temp	; add high byte with carry
.endmacro

;***************************************************************************
.macro	SUBZ8			; Subtract 8 bits register from register Z
	sub	ZL, @0		; Subtract low byte
	sbci	ZH, 0		; Subtract high byte with carry
.endmacro




;***************************************************************************
.macro	LDW			;Load 16 bits immediate to 16 bits register
	ldi	@1,low(@2)	;Load low byte
	ldi	@0,high(@2)	;Load high byte
.endmacro
;Example ->	LDW	r17,r16,-4555	; Load r17:r16 with -4555

;***************************************************************************
.macro 	LDX 			;Load 16 bits immediate to register X
	ldi 	XL,low(@0)	;Load low byte
	ldi	XH,high(@0)	;Load high byte
.endmacro
;Example ->	LDX 	$0060	;X points to start of internal SRAM

;***************************************************************************
.macro 	LDY 			;Load 16 bits immediate to register Y
	ldi 	YL,low(@0)	;Load low byte
	ldi 	YH,high(@0)	;Load high byte
.endmacro
;Example ->	LDY 	$FFFF	;Y points to end of external SRAM

;***************************************************************************
.macro 	LDZ 			;Load 16 bits immediate to register X
	ldi 	ZL,low(@0)	;Load low byte
	ldi 	ZH,high(@0)	;Load high byte
.endmacro
;Example ->	LDZ 	TABLE	;Z points to label TABLE





;***************************************************************************
.macro 	CLRW	 		;Clear 16 bits register
	clr 	@1		;Clear low byte
	clr 	@0		;Clear high byte
.endmacro
;Example ->	CLRW 	R1,R0	;Clear register R1:R0

;***************************************************************************
.macro 	SERW	 		;Set 16 bits register
	ser 	@1		;Set low byte
	ser 	@0		;Set high byte
.endmacro
;Example ->	SERW 	R1,R0	;Set register R1:R0

;***************************************************************************
.macro 	CLRX	 		;Clear X-pointer
	clr 	XL		;Clear X-pointer low byte
	clr 	XH		;Clear X-pointer high byte
.endmacro

;***************************************************************************
.macro 	SERX	 		;Set X-pointer
	ser 	XL		;Set X-pointer low byte
	ser 	XH		;Set X-pointer high byte
.endmacro

;***************************************************************************
.macro 	CLRY 			;Clear Y-pointer
	clr 	YL		;clear Y-pointer low byte
	clr 	YH		;Clear Y-pointer high byte
.endmacro

;***************************************************************************
.macro 	SERY	 		;Set Y-pointer
	ser 	YL		;Set Y-pointer low byte
	ser 	YH		;Set Y-pointer high byte
.endmacro

;***************************************************************************
.macro 	CLRZ 			;Clear Z-pointer
	clr 	ZL		;Clear Z-pointer low byte
	clr 	ZH		;Clear Z-pointer high byte
.endmacro

;***************************************************************************
.macro 	SERZ	 		;Set Z-pointer
	ser 	ZL		;Set Z-pointer low byte
	ser 	ZH		;Set Z-pointer high byte
.endmacro




;***************************************************************************
.macro 	INCW			;Increment 16 bits register
	subi 	@1,low(-1)	;Increment low byte
	sbci	@0,high(-1)	;Increment high byte with carry
.endmacro
;Example ->	INCW R17,R16	;Increment 16 bits register R17:R16

;***************************************************************************
.macro 	DECW			;Decrement 16 bits register
	subi 	@1,1		;Decrement low byte
	sbci	@0,0		;Decrement high byte with carry
.endmacro
;Example ->	DECW R17,R16	;Decrement 16 bits register R17:R16

;***************************************************************************
.macro 	INCX			;Increment X-pointer
	subi 	XL,low(-1)	;Increment X-pointer low byte
	sbci	XH,high(-1)	;Increment X-pointer high byte with carry
.endmacro

;***************************************************************************
.macro 	DECX			;Decrement X-pointer
	subi 	XL,1		;Decrement X-pointer low byte
	sbci	XH,0		;Decrement X-pointer high byte with carry
.endmacro

;***************************************************************************
.macro 	INCY			;Increment Y-pointer
	subi 	YL,low(-1)	;Increment Y-pointer low byte
	sbci	YH,high(-1)	;Increment Y-pointer high byte with carry
.endmacro

;***************************************************************************
.macro 	DECY			;Decrement Y-pointer
	subi 	YL,1		;Decrement Y-pointer low byte
	sbci	YH,0		;Decrement Y-pointer high byte with carry
.endmacro

;***************************************************************************
.macro 	INCZ			;Increment Z-pointer
	subi 	ZL,low(-1)	;Increment Z-pointer low byte
	sbci	ZH,high(-1)	;Increment Z-pointer high byte with carry
.endmacro

;***************************************************************************
.macro 	DECZ			;Decrement Z-pointer
	subi 	ZL,1		;Decrement Z-pointer low byte
	sbci	ZH,0		;Decrement Z-pointer high byte with carry
.endmacro



;***************************************************************************
.macro 	PUSHX			;Puxh X-pointer
	push	XH		;push X-pointer low byte
	push	XL		;push X-pointer high byte
.endmacro

;***************************************************************************
.macro 	POPX			;Pop X-pointer
	pop	XL		;pop X-pointer low byte
	pop	XH		;pop X-pointer high byte
.endmacro

;***************************************************************************
.macro 	PUSHY			;Puxh Y-pointer
	push	YH		;push Y-pointer low byte
	push	YL		;push Y-pointer high byte
.endmacro

;***************************************************************************
.macro 	POPY			;Pop Y-pointer
	pop	YL		;pop Y-pointer low byte
	pop	YH		;pop Y-pointer high byte
.endmacro

;***************************************************************************
.macro 	PUSHZ			;Puxh Z-pointer
	push	ZH		;push Z-pointer low byte
	push	ZL		;push Z-pointer high byte
.endmacro

;***************************************************************************
.macro 	POPZ			;Pop Z-pointer
	pop	ZL		;pop Z-pointer low byte
	pop	ZH		;pop Z-pointer high byte
.endmacro



;***************************************************************************
.macro 	NEGW			;Negative 16 bits register
; incverting all bits then adding one (0x0001)
	com	@1		;Invert low byte
	com	@0		;Invert high byte
	subi	@1,low(-1)	;Add 0x0001, low byte
	sbci	@0,high(-1)	;Add high byte
.endmacro
;Example ->	NEGW	R1,R0	; Negative R1:R0

;***************************************************************************
.macro 	NEGX			;Negative X-Pointer
	com	XL		;Invert low byte
	com	XH		;Invert high byte
	subi	XL,low(-1)	;Add 0x0001, low byte
	sbci	XH,high(-1)	;Add high byte
.endmacro
;Example ->	NEGX		; Negative X-Pointer

;***************************************************************************
.macro 	NEGY			;Negative Y-Pointer
	com	YL		;Invert low byte
	com	YH		;Invert high byte
	subi	YL,low(-1)	;Add 0Y0001, low byte
	sbci	YH,high(-1)	;Add high byte
.endmacro
;Example ->	NEGY		; Negative Y-Pointer

;***************************************************************************
.macro 	NEGZ			;Negative Z-Pointer
	com	ZL		;Invert low byte
	com	ZH		;Invert high byte
	subi	ZL,low(-1)	;Add 0Z0001, low byte
	sbci	ZH,high(-1)	;Add high byte
.endmacro
;Example ->	NEGZ		; Negative Z-Pointer



;***************************************************************************
.macro	CPWR			;Compare the 16 bits register with 16 bits register
	cp	@1,@3		;Compare low register
	cpc	@0,@2		;Compare high register and carry
.endmacro
;Example ->	CPWR	R1,R0,R17,R16	; Compare R1:R0 with R17:R16
;		brne	start		; Branch to 'start' if not equal

;***************************************************************************
.macro	CPXR			;Compare X-pointer with 16 bits register
	cp	XL,@1		;Compare XL with low register
	cpc	XH,@0		;Compare XH and carry with high register
.endmacro
;Example ->	CPXI	R1,R0	;Compare the X-pointer with R1:R0
;		brne	start	;Branch to 'start' if not equal

;***************************************************************************
.macro	CPYR			;Compare Y-pointer with 16 bits register
	cp	YL,@1		;Compare YL with low register
	cpc	YH,@0		;Compare YH and carry with high register
.endmacro

;***************************************************************************
.macro	CPZR			;Compare Z-pointer with 16 bits register
	cp	ZL,@1		;Compare ZL with low register
	cpc	ZH,@0		;Compare ZH and carry with high register
.endmacro





;***************************************************************************
.macro	CPWI			;Compare 16 bits register with 16 bits immediate
	cpi	@1,low(@2)	;Compare immediate low byte with Low Register
	ldi	temp,high(@2)
	cpc	@0,temp		;Compare immediate high byte with High Register and carry
.endmacro
;Example ->	CPWI	R17,R16,$00FF	; Compare R17:R16 with $00FF
;		brne	start		; Branch to 'start' if not equal

;***************************************************************************
.macro	CPXI			;Compare X-pointer with 16 bits immediate
	cpi	XL,low(@0)	;Compare immediate low byte with XL
	ldi	temp,high(@0)
	cpc	XH,temp		;Compare immediate high byte and carry with XH
.endmacro
;Example ->	CPXI	$00FF	;Compare the X-pointer with $00FF
;		breq	start	;Branch to 'start' if equal

;***************************************************************************
.macro	CPYI			;Compare Y-pointer with 16 bits immediate
	cpi	YL,low(@0)	;Compare immediate low byte with YL
	ldi	temp,high(@0)
	cpc	YH,temp		;Compare immediate high byte and carry with YH
.endmacro

;***************************************************************************
.macro	CPZI			;Compare Z-pointer with 16 bits immediate
	cpi	ZL,low(@0)	;Compare immediate low byte with ZL
	ldi	temp,high(@0)
	cpc	ZH,temp		;Compare immediate high byte and carry with XH
.endmacro





;***************************************************************************
; Command CPSE already exist
;Example ->	CPSE	R0,R16	;if R0 equal R16 then skip next instruction

;***************************************************************************
.macro	CPISE			;Compare 8 bits register with 8 bits Immediate skip if equal
	ldi	Temp,@1
	cpse	@0,Temp
.endmacro
;Example ->	CPISE	R0,$F0	;if R0 equal $F0 then skip next instruction





;***************************************************************************
.macro	CJE			;Compare 8 bits register Jump if Equal
	cp	@0,@1		;Compare both register
	breq	@2		;Jump if Equal
.endmacro
;Example ->	CJE	R0,R16,next  ;if R0 equal R16 then jump to next

;***************************************************************************
.macro	CJNE			;Compare 8 bits register Jump if Not Equal
	cp	@0,@1           ;Compare both register
	brne	@2		;Jump if Not Equal
.endmacro
;Example ->	CJNE	R0,R16,next  ;if R0 not equal R16 then jump to next

;***************************************************************************
.macro	CWJE			;Compare 16 bits register Jump if Equal
	cp	@1,@3		;Compare low byte register
	cpc	@0,@2		;Compare high byte register and carry
	breq	@4
.endmacro
;Example ->	CWJE	R1,R0,R17,R16,next  ;if R1:R0 equal R17:R16 then jump to next

;***************************************************************************
.macro	CWJNE			;Compare 16 bits register Jump if Not Equal
	cp	@1,@3		;Compare low byte register
	cpc	@0,@2		;Compare high byte register and carry
	brne	@4
.endmacro
;Example ->	CWJNE	R1,R0,R17,R16,next  ;if R1:R0 not equal R17:R16 then jump to next





;***************************************************************************
.macro	CIJE			;Compare 8 bits register with 8 bits Immediate Jump if Equal
	cpi	@0,@1           ;Compare 8 bits register with 8 bits Immediate
	breq	@2		;Jump if Equal
.endmacro
;Example ->	CIJE	R16,$0F,next  ;if R16 equal $0F then jump to next

;***************************************************************************
.macro	CIJNE			;Compare 8 bits register with 8 bits Immediate Jump if Not Equal
	cpi	@0,@1           ;Compare 8 bits register with 8 bits Immediate
	brne	@2		;Jump if Not Equal
.endmacro
;Example ->	CIJNE	R16,$F0,next  ;if R16 not equal $F0 then jump to next

;***************************************************************************
.macro	CWIJE			;Compare 16 bits register with 16 bits Immediate Jump if Equal
	cpi	@1,low(@2)	;Compare low byte register with low byte immediate
	ldi	temp,high(@2)
	cpc	@0,temp		;Compare high byte register with high byte immediate and carry
	breq	@3
.endmacro
;Example ->	CWIJE	R17,R16,$0F0F,next  ;if R17:R16 equal with $0F0F then jump to next

;***************************************************************************
.macro	CWIJNE			;Compare 16 bits register with 16 bits Immediate Jump if not Equal
	cpi	@1,low(@2)	;Compare low byte register with low byte immediate
	ldi	temp,high(@2)
	cpc	@0,temp		;Compare high byte register with high byte immediate and carry
	brne	@3
.endmacro
;Example ->	CWIJNE	R17,R16,$FF00,next  ;if R17:R16 not equal with $FF00 then jump to next



;***************************************************************************
.Macro JZ
	tst	@0		; compare 8 bit-s register with zero
	breq	@1		; jump if zero flag set
.endmacro
;Example ->	JZ  R0,Next	; If R0=0 then jump to Next

;***************************************************************************
.Macro JNZ
	tst	@0		; compare 8 bit-s register with zero
	brne	@1		; jump if zero flag clear
.endmacro
;Example ->	JNZ  R0,Next	; If R0<>0 then jump to Next

;***************************************************************************
.Macro JB
	sbrc	@0,@1		; If @0 bit @1 set, then
	rjmp	@2		; jump to @2
.endmacro
;Example ->	JB  R0,7,Next	; If R0.7=1 then jump to Next

;***************************************************************************
.Macro JNB
	sbrs	@0,@1		; If @0 bit @1 Clear, then
	rjmp	@2		; jump to @2
.endmacro
;Example ->	JNB  R0,7,Next	; If R0.7=0 then jump to Next

;***************************************************************************
.Macro DJZ
	dec	@0		; Decrement 8 bit-s register
	breq	@1		; jump if zero flag set	(register=0)
.endmacro
;Example ->	DJZ  R0,Next	; Dec R0, If R0=0 then jump to Next

;***************************************************************************
.Macro DJNZ
	dec	@0		; Decrement 8 bit-s register
	brne	@1		; jump if zero flag clear (register <>0)
.endmacro
;Example ->	DJNZ  R0,Next	; Dec R0, If R0<>0 then jump to Next

;***************************************************************************
.Macro DJZW
	subi 	@1,1		; Decrement low byte
	sbci	@0,0		; Decrement high byte with carry
	breq	@2		; jump if zero flag set	(register=0)
.endmacro
;Example ->	DJZW   R17,R16,Next	; Dec R17:R16, If 0 then jump to Next

;***************************************************************************
.Macro DJNZW
	subi 	@1,1		; Decrement low byte
	sbci	@0,0		; Decrement high byte with carry
	brne	@2		; jump if zero flag clear (register <>0)
.endmacro
;Example ->	DJNZW	R17,R16,Next	; Dec R17:R16, If A<>0 then jump to Next