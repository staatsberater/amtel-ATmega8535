	.CSEG
Hex_ASCII2:
	push	A		;Simpan Reg A ke Stack
	rcall	Hex_ASCII1	;Konversi 1 nibble
	mov	B,A		;Simpan nibble bawah di Reg B
	pop	A		;Ambil Reg A dari Stack
	swap	A		;Tukar
	rcall	Hex_ASCII1	;Konversi 1 nibble
	ret

Hex_ASCII1:
	andi	A,$F		;Hapus Nibble Atas
	cpi	A,10
	brge	Bukan_Angka	;Reg A >=10  bukan angka 
Plus30:	ADDI	A,$30		;Reg A < tambah $30
	Ret
Bukan_Angka:
	ADDI	A,$37
	ret
	
