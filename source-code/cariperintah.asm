;Revisi Bug di pointer

;Rutin untuk menerima parameter perintah dari input di R25 dan mengerjaka
;perintah tersebut ke label-label tertentu
;Input perintah di R25
;Tabel di Register Z
;Hasil Carry Flag set bila perintah tidak ditemukan

;Cara penggunaan:
;- Buat tabel dengan formasi
;Tabel:
;	.DB	Perintah1
;	.DW	Label1
;	.DB	Perintah2
;	.DW	Label2
;	.DB	0
;- Tuliskan program untuk perintah 1 di label1 dan perintah 2 di label 2
;Label1:
;	........
;	.........
;	Clc
;	Ret
;
;Label2:
;	.........
;	.........
;	Clc
;	Ret
;- Arahkan Register Z ke tabel x 2 sbb:
;- LDZ	Tabel*2
;- Rcall	CariPerintah


.CSEG
CariPerintah:
LoopCariPerintah:
	Lpm		
	Mov		R24,R0


	Jz		R0,PerintahTidakKetemu
	CP		R24,R25
	Breq	PerintahKetemu


	Adiw	ZH:ZL,4
	Rjmp	LoopCariPerintah

PerintahKetemu:
	Adiw	ZH:ZL,1
	Adiw	ZH:ZL,1
	Lpm
	Mov		R23,R0
	Adiw	ZH:ZL,1
	Lpm
	Mov		R24,R0

	Mov		ZL,R23
	Mov		ZH,R24
	ICall

PerintahTidakKetemu:
	SEC
	Ret
