
;************************ EQU - DEF Definition **************************
.nolist
.include "m8535def.inc"
.include	"Macro.asm"
.list
.listmac

.DSEG			; Start data segment 
.org	SRAM_Start


.def	A=R16
.def	B=R17



.equ	STX	= $1E
.equ	DeviceID	=$00

;**************************** Main Program ******************************
.CSEG			; Start code segment
.org     0

;Output UVTRON = PortC.6
;Busy = PortC.5

;Control = PortC.4

Start:	LDX	RAMEND		; X <= Stack Pointer init address to End of internal RAM
	
	out 	SPL,XL		; Setup Stack Pointer Low byte
	out 	SPH,XH		; Setup Stack Pointer High byte

	Ldi		R24,Low(0b00010000)
	Out		DDRC,R24


	Rcall	InitSerial
	Ldi		R25,Low($01)
	Sts		DeviceNumber,R25
	Rcall	PerintahScanUVTRON



TungguInfoUVTRON:	
	Sbic	PinC,6
	Rjmp	TungguInfoUVTRON

	Rcall	PerintahAktivasiKipas


Hold:
	Rjmp	Hold

TungguSmartUVTRONSiap:					;Saat Busy = 1, tunggu Smart UVTRON
	Sbic	PortC,5					;
	Rjmp	TungguSmartUVTRONSiap		;
	Cbi		PortC,4						;Enable control Smart UVTRON
	Ret

;===============================================================================
; Perintah Untuk Scan UVTRON
; - Panjang data = 02
; - Jenis Perintah = 05
; - 0 = Scan non aktif, 1 = Scan aktif

PerintahScanUVTRON:
	Rcall	TungguSmartUVTRONSiap
	Ldi		R24,Low($02)				;Panjang data
	Sts		Buffer,R24					;
	Ldi		R24,Low($05)				;Jenis perintah = Kendali Scan
	Sts		Buffer+1,R24				;
	Ldi		R24,Low($01)				;Scan aktif = 1, non aktif = 0
	Sts		Buffer+2,R24				;


	Ldi		R24,Low($30)				;Target type = Smart UVTRON
	Sts		TargetType,R24				;
	Ldi		R24,Low($01)				;Target number = 01
	Sts		TargetNum,R24				;
	Rcall	KirimPaketData				;
	Rcall	DeltaSubSerialInput2		;Wait ACK
	Ret


;===============================================================================
; Perintah Untuk Aktifkan Kipas
; - Panjang data = 02
; - Jenis Perintah = 03
; - 0 = Kipas non aktif, 1 = Kipas aktif

PerintahAktivasiKipas:
	Rcall	TungguSmartUVTRONSiap
	Ldi		R24,Low($02)				;Panjang data
	Sts		Buffer,R24					;
	Ldi		R24,Low($03)				;Jenis perintah = Kendali Kipas
	Sts		Buffer+1,R24				;
	Ldi		R24,Low($01)				;Kipas aktif = 1, non aktif = 0
	Sts		Buffer+2,R24				;


	Ldi		R24,Low($30)				;Target type = Smart UVTRON
	Sts		TargetType,R24				;
	Ldi		R24,Low($01)				;Target number = 01
	Sts		TargetNum,R24				;
	Rcall	KirimPaketData				;
	Rcall	DeltaSubSerialInput2		;Wait ACK
	Ret


;===============================================================================
; Perintah Untuk Aktifkan Kipas
; - Panjang data = 02
; - Jenis Perintah = 04
; - 0 = Kipas non aktif, scan non aktif, 1 = Kipas aktif scan aktif

PerintahAktivasiKipasdanScan:
	Rcall	TungguSmartUVTRONSiap
	Ldi		R24,Low($02)				;Panjang data
	Sts		Buffer,R24					;
	Ldi		R24,Low($04)				;Jenis perintah = Kendali Kipas dan scan
	Sts		Buffer+1,R24				;
	Ldi		R24,Low($00)				;Kipas aktif = 1, non aktif = 0
	Sts		Buffer+2,R24				;


	Ldi		R24,Low($30)				;Target type = Smart UVTRON
	Sts		TargetType,R24				;
	Ldi		R24,Low($01)				;Target number = 01
	Sts		TargetNum,R24				;
	Rcall	KirimPaketData				;
	Rcall	DeltaSubSerialInput2		;Wait ACK
	Ret

;===============================================================================
; Perintah Untuk Minta info
; - Panjang data = 01
; - Jenis Perintah = 02
; - Ambil balasan setelah ACK

; Hasil:
; - Data Durasi gerak di Buffer+2
; - Data Nilai Setting Api di Buffer+3
; - Data Nilai Api Hilang di Buffer+4
; - Data Nilai Api Ketemu di Buffer+5
; - Data Intensitas api di Buffer+6
; - Data Posisi sudut di buffer+7

PerintahMIntaInfo:
	Rcall	TungguSmartUVTRONSiap
	Ldi		R24,Low($01)				;Panjang data
	Sts		Buffer,R24					;
	Ldi		R24,Low($02)				;Jenis perintah = Minta Info
	Sts		Buffer+1,R24				;

	Ldi		R24,Low($30)				;Target type = Smart UVTRON
	Sts		TargetType,R24				;
	Ldi		R24,Low($01)				;Target number = 01
	Sts		TargetNum,R24				;
	Rcall	KirimPaketData				;
	Rcall	DeltaSubSerialInput2		;Wait ACK
	Rcall	DeltaSubSerialInput2		;Ambil balasan
	Ret

;===============================================================================
; Perintah Untuk Setting Smart UVTRON
; - Panjang data = 08
; - Jenis Perintah = 01
; - Buffer+2 = Durasi Gerakan Servo (default 80h) silahkan diubah sesuai kebutuhan dg ref dari manual
; - Buffer+3 = Nilai Setting Api (default 08) silahkan diubah sesuai kebutuhan dg ref dari manual
; - Buffer+4 = Nilai Api dianggap Hilang (default 03) silahkan diubah sesuai kebutuhan dg ref dari manual
; - Buffer+5 = Nilai Api dianggap Ketemu (default 03) silahkan diubah sesuai kebutuhan dg ref dari manual
; - Buffer+6 = Aktivasi kipas saat api ketemu, (00 = tidak aktif, 01=langsung aktif) silahkan diubah sesuai kebutuhan dg ref dari manual


PerintahSetting:
	Rcall	TungguSmartUVTRONSiap
	Ldi		R24,Low($01)				;Panjang data
	Sts		Buffer,R24					;
	Ldi		R24,Low($02)				;Jenis perintah = Minta Info
	Sts		Buffer+1,R24				;
	Ldi		R24,Low($80)				;Durasi gerak = 80h
	Sts		Buffer+2,R24				;
	Ldi		R24,Low($08)				;Nilai Setting api = 08
	Sts		Buffer+3,R24				;
	Ldi		R24,Low($03)				;Nilai Api dianggap hilang = 03
	Sts		Buffer+4,R24				;
	Ldi		R24,Low($03)				;Nilai Api dianggap ketemu = 03
	Sts		Buffer+5,R24				;
	Ldi		R24,Low($01)				;Aktifkan kipas saat api ketemu
	Sts		Buffer+6,R24				;


	Ldi		R24,Low($30)				;Target type = Smart UVTRON
	Sts		TargetType,R24				;
	Ldi		R24,Low($01)				;Target number = 01
	Sts		TargetNum,R24				;
	Rcall	KirimPaketData				;
	Rcall	DeltaSubSerialInput2		;Wait ACK
	Ret



TabelPerintahDeltaSub:


.include "serial.asm"
.include "hexascii.asm"
.include "delay.asm"
.include "deltasub.asm"
.include "cariperintah.asm"
