
;************************ EQU - DEF Definition **************************
.nolist
.include "m8535def.inc"
.include	"Macro.asm"
.list
.listmac

.DSEG			; Start data segment 
.org	SRAM_Start
BufferADC:	.byte 8
LastPWM1:	.byte 1
LastPWM2:	.byte 1
CounterRAMP1:	.byte 1
CounterRAMP2:	.byte 1
DataPWM1:	.byte 1
DataPWM2:	.byte 1
StatusRAMP:	.byte 1			;bit 0 = RAMP 1
							;bit 1 = RAMP 2
							;bit 2 = RAMP turun 1
							;bit 3 = RAMP turun 2

.equ	batasan	= $60
.equ	DataRAMP1	= $2
.equ	DataRAMP2	= $2
.equ	BesarPerubahan = 8		;Besar perubahan di mana RAMP mulai bekerja



.def	A=R16
.def	B=R17





;**************************** Main Program ******************************
.CSEG			; Start code segment
.org     0

Start:	LDX	RAMEND		; X <= Stack Pointer init address to End of internal RAM
	
	out 	SPL,XL		; Setup Stack Pointer Low byte
	out 	SPH,XH		; Setup Stack Pointer High byte

	Ldi		R16,Low($FF)
	Out		DDRD,R16
	Ldi		R16,Low($FF)
	Out		DDRB,R16

	Rcall	InitSerial

	Rcall	AmbilADC0			;Set Nilai awal lastpwm 1 dan 2
	In		R25,ADCH			;
	Sts		LastPWM1,R25		;

	Rcall	AmbilADC1			;
	In		R25,ADCH			;
	Sts		LastPWM2,R25		;
	Ldi		R25,Low($00)		;Reset Counter RAMP
	Sts		CounterRAMP1,R25			;
	Sts		CounterRAMP2,R25			;
	Ldi		R25,Low($FF)
	Sts		StatusRAMP,R25		;

	Rcall	PWM9OC1
;	Rcall	PWM9OC2
;	rjmp	hold

	Ldi		R18,0b01100000		;Voltage Reference Selection = AVCC with external VREF
	Ldi		R16,$00				;No ADC Interrupt & Prescaler Clock x 2

;	rjmp	loopadc

Loop:
	Rcall	AmbilData2
	Rcall	KonversikePWM
;	Rcall	Delay3

	Rjmp	Loop



loopadc:
	Rcall	AmbilADC0
	rcall	delay3
	in		r25,adch
	rcall	serial_out

	Rcall	AmbilADC1
	rcall	delay3

	In		R25,ADCH
	rcall	serial_out	
;	Rcall	OutADC	


	Rjmp	LoopADC

RAMP2:
	Lds		R25,DataPWM2
;	rcall	serial_out
	Ldi		R24,($0078)
	Cp		R25,R24
	Brcs	CekRAMP2
	Ldi		R24,($0088)
	Cp		R25,R24
	Brcc	CekRAMP2
	
	Lds		R23,StatusRAMP
	Sbrs	R23,3
	Rjmp	CekRAMP2

;	Push	R25
;	ldi		r25,low($09)
;	rcall	serial_out
;	pop		r25

	Sts		LastPWM2,R25
	Clr		R24
	STS		CounterRAMP2,R24
	Ret

CekRAMP2:
	Lds		R24,LastPWM2
	Cp		R25,R24
	Brsh	KurangiPWM2s
	Push	R25						;Kalau kecepatan turun maka tidak RAMP dan simpan Last PWM
	Sub		R24,R25					;Last PWM - Data Baru
	Brcc	SkipReset21				;Last PWM < Data Baru, abaikan
	Pop		R25					
SkipRAMP2:
	Sts		LastPWM2,R25
	Ret

KurangiPWM2s:
	Rjmp	KurangiPWM2

SkipReset21:
	Ldi		R23,($0008)			;Cek bila perubahan kecil tidak RAMP
	Cp		R24,R23							;
	Brsh	TetapRAMP21						;
	Pop		R25							;
	Ret

TetapRAMP21:
	Mov		R25,R24
	Lds		R24,CounterRAMP2		;(Last PWM - Data Baru) x n / Data RAMP1
	Mul		R25,R24					;
	
	Mov 	Rd1h,r1				;
	Mov 	Rd1l,r0				;	

	Ldi 	rmp,Low(DataRAMP2)		;			;
	Mov 	rd2,rmp					;
	Rcall	Div8					;
	Pop		R25
	Lds		R25,LastPWM2
	Sub		R25,Rel					;Data Lama - (Last PWM - Data Baru) x n / Data RAMP1
	Brcc	XRAMP2
	Clr		R25

XRAMP2:
	Lds		R24,CounterRAMP2		;Counter RAMP1 + 1
	Inc		R24						;
	Push	R25
	Mov		R25,R24
	Rcall	Serial_Out
	Rcall	Delay2
	ldi		r23,($0003)
	cp		r25,r23
	Pop		R25


	Ldi		R23,Low(DataRAMP2)		;Counter RAMP 1 = Data RAMP1?
	Cp		R24,R23					;
	Brne	SkipResetCounterRAMP2	;
	
	push	r25
	ldi		r25,low($55)
	rcall	serial_out
	pop	r25

	Clr		R24						;Kalau ya Reset Counter RAMP1
	Lds		R23,StatusRAMP			;Clear Status RAMP 1
	Set
;	Bld		R23,2					;Clear status RAMP turun 1
	Bld		R23,3					;Clear status RAMP turun 2
	Sts		StatusRAMP,R23			;
	Sts		LastPWM2,R25
	

SkipResetCounterRAMP2:
	Sts		CounterRAMP2,R24		;
;	Rcall	Delay3
	Ret


;================ RAMP Turun ==========
KurangiPWM2:
	Push	R25
	Sub		R25,R24				;Data Baru - Data Lama
	Brcc	SkipReset22			;Kalau terjadi kecepatan naik lagi maka
	Pop		R25					;Simpan Last PWM dan tidak RAMP
	Rjmp	SkipRAMP2			;

SkipReset22:
	Ldi		R23,($0008)
	Cp		R25,R23
	Brsh	TetapRAMP22
	Pop		R25
	Ret

TetapRAMP22:


	Lds		R23,StatusRAMP			;Aktifkan RAMP turun 2
	Clt								;
	Bld		R23,3					;
;	rjmp	hold

	Sts		StatusRAMP,R23			;
	Lds		R24,CounterRAMP2		;(Data Baru - Last PWM) x n / Data RAMP1
	Mul		R25,R24					;
	
	Mov 	Rd1h,r1				;
	Mov 	Rd1l,r0				;	

	Ldi 	rmp,Low(DataRAMP2)		;			;
	Mov 	rd2,rmp					;
	Rcall	Div8					;
	Pop		R25
	Lds		R25,LastPWM2
	Add		R25,Rel

SkipSet2:
	Rjmp	XRAMP2



RAMP1:
	Lds		R25,DataPWM1			;Cek data PWM di antara 78 dan 88 tidak Cek RAMP
	Ldi		R24,Low($78)			;
	Cp		R25,R24					;
	Brcs	CekRaMP1				;
	Ldi		R24,Low($88)			;
	Cp		R25,R24					;
	Brcc	CekRAMP1				;

	Lds		R23,StatusRAMP			;Cek bila Status RAMP turun tidak aktif maka tidak cek RAMP
	Sbrs	R23,2					;Tapi bila aktif maka Cek RAMP
	Rjmp	CekRAMP1				;

	Sts		LastPWM1,R25

	Clr		R24						;
	Sts		CounterRAMP1,R24		;
	Ret

CekRAMP1:							;Bagian ini untuk cek RAMP naik atau turu
	Lds		R24,LastPWM1			;
	Cp		R25,R24
	Brsh	KurangiPWM1s				;


;============== RAMP Naik
	Push	R25						;Kalau kecepatan turun maka tidak RAMP dan simpan Last PWM
	Sub		R24,R25					;Last PWM - Data Baru
	Brcc	SkipReset				;Last PWM < Data Baru, abaikan
	Pop		R25					
SkipRAMP1:
	Sts		LastPWM1,R25
	Ret

KurangiPWM1s:
	Rjmp	KurangiPWM1

SkipReset:
	Ldi		R23,Low(BesarPerubahan)			;Cek bila perubahan kecil tidak RAMP
	Cp		R24,R23							;
	Brsh	TetapRAMP						;
	Pop		R25							;
	Ret

TetapRAMP:
	Mov		R25,R24
	Lds		R24,CounterRAMP1		;(Last PWM - Data Baru) x n / Data RAMP1
	Mul		R25,R24					;
	
	Mov 	Rd1h,r1				;
	Mov 	Rd1l,r0				;	

	Ldi 	rmp,Low(DataRAMP1)		;			;
	Mov 	rd2,rmp					;
	Rcall	Div8					;
	Pop		R25
	Lds		R25,LastPWM1
	Sub		R25,Rel					;Data Lama - (Last PWM - Data Baru) x n / Data RAMP1
	Brcc	XRAMP1
	Clr		R25

XRAMP1:
	Lds		R24,CounterRAMP1		;Counter RAMP1 + 1
	Inc		R24						;
	Push	R25
	Mov		R25,R24
;	Rcall	Serial_Out
	Rcall	Delay2
	ldi		r23,low($3)
	cp		r25,r23
	Pop		R25


	Ldi		R23,Low(DataRAMP1)		;Counter RAMP 1 = Data RAMP1?
	Cp		R24,R23					;
	Brne	SkipResetCounterRAMP1	;
	
	push	r25
	ldi		r25,low($55)
	rcall	serial_out
	pop	r25

	Clr		R24						;Kalau ya Reset Counter RAMP1
	Lds		R23,StatusRAMP			;Clear Status RAMP 1
	Set
	Bld		R23,2					;Clear status RAMP turun 1
;	Bld		R23,3					;Clear status RAMP turun 2
	Sts		StatusRAMP,R23			;
	Sts		LastPWM1,R25
	

SkipResetCounterRAMP1:
	Sts		CounterRAMP1,R24		;
;	Rcall	Delay3
	Ret

holds:
	pop	r25
	rcall	serial_out
	Rjmp	hold

;================ RAMP Turun ==========
KurangiPWM1:
	Push	R25
	Sub		R25,R24				;Data Baru - Data Lama
	Brcc	SkipReset2			;Kalau terjadi kecepatan naik lagi maka
	Pop		R25					;Simpan Last PWM dan tidak RAMP
	Rjmp	SkipRAMP1			;

SkipReset2:
	Ldi		R23,Low($08)
	Cp		R25,R23
	Brsh	TetapRAMP2
	Pop		R25
	Ret

TetapRAMP2:


	Lds		R23,StatusRAMP			;Aktifkan RAMP turun 1
	Clt								;
	Bld		R23,2					;
	Sts		StatusRAMP,R23			;
	Lds		R24,CounterRAMP1		;(Data Baru - Last PWM) x n / Data RAMP1
	Mul		R25,R24					;
	
	Mov 	Rd1h,r1				;
	Mov 	Rd1l,r0				;	

	Ldi 	rmp,Low(DataRAMP1)		;			;
	Mov 	rd2,rmp					;
	Rcall	Div8					;
	Pop		R25
	Lds		R25,LastPWM1
	Add		R25,Rel

SkipSet:
	Rjmp	XRAMP1


KonversikePWM:
	Lds		R25,BufferADC			;Ambil data motor 1

	Rcall	SetPWM					;Set PWM
	Rcall	SetBatasKecepatan		;Set batas kecepatan
	Push	R25						;Simpan hasil kecepatan di stack

	Lds		R25,BufferADC			;Cek posisi joystick, bila didekat netral, tidak perlu cek direction
	Rcall	CekZeroJoy1				;
	Brcc	SkipCekArah				;

	Ldi		R24,Low($80)			;Cek Arah motor 1
	Lds		R25,BufferADC			;
	Cp		R25,R24					;
	Brlo	CWMotor1				;
	Cbi		PortB,1					;
	Rjmp	SetMotor1				;

CWMotor1:
	Sbi		PortB,1					;

SkipCekArah:
SetMotor1:							;
	Pop		R25						;Ambil hasil kecepatan dari stack
	Sts		DataPWM1,R25			;

	Rcall	RAMP1					;

	Ldi		R24,Low($4)
	Mul		R25,R24
	Out		OCR1AH,R1
	Out		OCR1AL,R0	

;===============================
; MOTOR 2

	Lds		R25,BufferADC+1
;	rcall	serial_out

	Rcall	SetPWM
	Rcall	SetBatasKecepatan
	Push	R25						;Simpan hasil kecepatan di stack

	Lds		R25,BufferADC+1			;Cek posisi joystick, bila didekat netral, tidak perlu cek direction
	Rcall	CekZeroJoy2				;
	Brcc	SkipCekArah2				;



	Ldi		R24,Low($80)
	Lds		R25,BufferADC+1
	Cp		R25,R24
	Brlo	CWMotor2
	Cbi		PortB,0
	Rjmp	SetMotor2	

CWMotor2:
	Sbi		PortB,0
SkipCekArah2:
SetMotor2:
	Pop		R25						;Ambil hasil kecepatan dari stack
	Sts		DataPWM2,R25
	Rcall	RAMP2

	Ldi		R24,Low($4)
	Mul		R25,R24


	Out		OCR1BH,R1
	Out		OCR1BL,R0
	Ret

;=======================================================
; Konversi data adc joystick ke PWM
; - Bila di atas $80 maka $FF-$80
; - Bila di bawah $80 maka tidak diapa2kan

SetPWM:
	Ldi		R24,Low($80)
	CP		R25,R24
	Brlo	TidakdikurangkankeFF
	Ldi		R24,Low($FF)
	Sub		R24,R25
	Mov		R25,R24

TidakdikurangkankeFF:
	Ret

CekZeroJoy1:
	Push	R25
	Ldi		R23,($0078)
	Clc	
	Sub		R25,R23
	Pop		R25
	Brcc	CekBatasAtas
	Sec
	Ret

CekBatasAtas:
	Push	R25
	Ldi		R23,($0088)
	Clc
	Sub		R25,R23
	Pop		R25
	Brcs	DalamBatas
	Sec	
	Ret

DalamBatas:
	Clc	
	Ret

CekZeroJoy2:
	Push	R25
	Ldi		R23,($0078)
	Clc	
	Sub		R25,R23
	Pop		R25
	Brcc	CekBatasAtas2
	Sec
	Ret

CekBatasAtas2:
	Push	R25
	Ldi		R23,($0088)
	Clc
	Sub		R25,R23
	Pop		R25
	Brcs	DalamBatas2
	Sec	
	Ret

DalamBatas2:
	Clc	
	Ret


;================================================
; Bagian Pengatur Batas Kecepatan
; Data = (7F - nilai) * Batasan / 7F
; Input di R25
; Output di R25

SetBatasKecepatan:
	Push	R25
	Ldi		R24,Low($7F)			;7F - nilai
	Sub		R24,R25					;
	Mov		R25,R24


	Ldi		R24,Low(Batasan)		;(7F - nilai) * batasan
	Mul		R25,R24					;
									;((7F - nilai) * batasan) / 7F
	Mov 	rd1h,r1				;
	Mov 	rd1l,r0				;	

	Ldi 	rmp,$7F					;
	Mov 	rd2,rmp					;
	Rcall	Div8					;

	Pop		R25						;
	Add		R25,Rel

	Ret



Hold:
	Rjmp	Hold

PWM9OC2:
	Sbi		DDRB,7
	Ldi		R16,Low($00)
	Out		ASSR,R16
	Ldi		R16,Low($6E)
	Out		TCCR2,R16
	Ldi		R16,Low($00)
	Out		TCNT2,R16
	Ldi		R16,Low($FF)
	Out		OCR2,R16
	Ret

PWM9OC1:
	Sbi		DDRD,4	
	Sbi		DDRD,5
	Ldi		R16,Low($A2)
	Out		TCCR1A,R16
	Ldi		R16,Low($0C)
	Out		TCCR1B,R16

	Ldi		R16,Low($FF)
	Out		OCR1AH,R16
	out		OCR1AL,R16

	Ret

;=============================================================================================
; Ambil ADC 8 bit dari 8 kanal dan simpan di buffer ADC
; Kanal 0 = BufferADC
; Kanal 1 = BufferADC+1
; ...................
; Kanal 8 = BufferADC+7

AmbilData2:
	Ldx		BufferADC
	Rcall	AmbilADC0
	In		R25,ADCH
	St		X+,R25
;	Rcall	Delay3
	Rcall	AmbilADC1
	In		R25,ADCH
;	Rcall	Serial_Out
	St		X+,R25
	Rcall	AmbilADC2
	In		R25,ADCH
	St		X+,R25
	Rcall	AmbilADC3
	In		R25,ADCH
	St		X+,R25
	Rcall	AmbilADC4
	In		R25,ADCH
	St		X+,R25
	Rcall	AmbilADC5
	In		R25,ADCH
	St		X+,R25
	Rcall	AmbilADC6
	In		R25,ADCH
	St		X+,R25
	Rcall	AmbilADC7
	In		R25,ADCH
	St		X+,R25
	Ret


AmbilADC0:
	Ldi		R17,$00				;ADC Single Ended Channel 0
	Ldi		R18,0b01100000		;Voltage Reference Selection = AVCC with external VREF
	Ldi		R16,$00				;No ADC Interrupt & Prescaler Clock x 2
	Rcall	InitADC
	Rcall	AmbilADC
	Ret

AmbilADC1:
	Ldi		R17,$01				;ADC Single Ended Channel 1
	Ldi		R18,0b01100000		;Voltage Reference Selection = AVCC with external VREF
	Ldi		R16,$00				;No ADC Interrupt & Prescaler Clock x 2
	Rcall	InitADC
	Rcall	AmbilADC
	Ret

AmbilADC2:
	Ldi		R17,$02				;ADC Single Ended Channel 2
	Ldi		R18,0b01100000		;Voltage Reference Selection = AVCC with external VREF
	Ldi		R16,$00				;No ADC Interrupt & Prescaler Clock x 2
	Rcall	InitADC
	Rcall	AmbilADC
	Ret

AmbilADC3:
	Ldi		R17,$03				;ADC Single Ended Channel 3
	Ldi		R18,0b01100000		;Voltage Reference Selection = AVCC with external VREF
	Ldi		R16,$00				;No ADC Interrupt & Prescaler Clock x 2
	Rcall	InitADC
	Rcall	AmbilADC
	Ret

AmbilADC4:
	Ldi		R17,$04				;ADC Single Ended Channel 4
	Ldi		R18,0b01100000		;Voltage Reference Selection = AVCC with external VREF
	Ldi		R16,$00				;No ADC Interrupt & Prescaler Clock x 2
	Rcall	InitADC
	Rcall	AmbilADC
	Ret

AmbilADC5:
	Ldi		R17,$05				;ADC Single Ended Channel 5
	Ldi		R18,0b01100000		;Voltage Reference Selection = AVCC with external VREF
	Ldi		R16,$00				;No ADC Interrupt & Prescaler Clock x 2
	Rcall	InitADC
	Rcall	AmbilADC
	Ret

AmbilADC6:
	Ldi		R17,$06				;ADC Single Ended Channel 6
	Ldi		R18,0b01100000		;Voltage Reference Selection = AVCC with external VREF
	Ldi		R16,$00				;No ADC Interrupt & Prescaler Clock x 2
	Rcall	InitADC
	Rcall	AmbilADC
	Ret

AmbilADC7:
	Ldi		R17,$07				;ADC Single Ended Channel 7
	Ldi		R18,0b01100000		;Voltage Reference Selection = AVCC with external VREF
	Ldi		R16,$00				;No ADC Interrupt & Prescaler Clock x 2
	Rcall	InitADC
	Rcall	AmbilADC
	Ret




.include "div.asm"
.include "adc.asm"
.include "serial.asm"
.include "hexascii.asm"
.include "delay.asm"
