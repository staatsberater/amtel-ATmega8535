;Subroutine Protokol Akses Delta Sub System
;File cariperintah.asm harus diincludekan di main program
;Fungsi subroutine:
;- Delta SubSerialInput:
;  * Mengambil data serial sesuai protokol Delta Subsystem
;  * Membalas ACK sesuai checksum
;  * Proses Perintah bila ACK OK
;  * Abaikan perintah bila ACK tidak OK
;- KirimPaketData
;  * Mengirim paket data dari buffer dalam protokol Delta Sub System
;  * Tentukan panjang paket (variabel buffer)
;  * Isi buffer
;  * Tentukan Target Type dan Target Num, bila paket data adalah balasan perintah maka
;    pindahkan source type ke target type dan source num ke target num
;  * Panggil subroutine kirimpaketdata


.DSEG

DeviceNumber:	.Byte 1
PanjangData:	.Byte 1
Buffer:			.Byte 25
Checksum:		.Byte 1
SourceNum:		.Byte 1
SourceType:		.Byte 1
TargetType:		.Byte 1
TargetNum:		.Byte 1

.CSEG
AddChecksum:
	Push	R25
	Push	R24
	Lds		R24,Checksum
	Add		R25,R24
	Sts		Checksum,R25
	Pop		R24
	Pop		R25
	Ret

SimpankeBuffer:
	Sts		PanjangData,R25		//

	LDI		R26,LOW(Buffer)		//Siapkan alamat buffer
	LDI		R27,HIGH(Buffer)	//
	Lds		R24,PanjangData		//
	St		X+,R25

LoopBuffer:	
	Rcall	Serial_In			//
	St		X+,R25
	Rcall	AddChecksum
	Mov		R25,R24
	Djnz	R24,LoopBuffer
	Ret

KirimACK:
	In		R23,SREG
	Ldi		R25,STX
	Rcall	Serial_Out
	Sts		Checksum,R25
	Lds		R25,SourceType
	Rcall	Serial_Out
	Rcall	AddChecksum
	Lds		R25,SourceNum
	Rcall	Serial_Out
	Rcall	AddChecksum
	Ldi		R25,DeviceID
	Rcall	Serial_Out
	Rcall	AddChecksum
	Lds		R25,DeviceNumber
	Rcall	Serial_Out
	Rcall	AddChecksum
	Ldi		R25,Low(02)
	Rcall	Serial_Out
	Rcall	AddChecksum
	Ldi		R25,Low(06)
	Rcall	Serial_Out
	Rcall	AddChecksum
	Out		SREG,R23
	Brcs	ErrorACK
	Ldi		R25,Low('O')

ChecksumACK:
	Rcall	Serial_out
	Rcall	AddChecksum
	Lds		R25,Checksum
	Neg		R25
	Rcall	Serial_Out
	Ret

ErrorACK:
	Ldi		R25,Low('E')
	Rjmp	ChecksumACK

DeltaSubSerialInput2:
	Rcall	Serial_In
	Ldi		R24,Low(STX)
	Sts		Checksum,R24
	Cpse	R24,R25
	Rjmp	DeltaSubSerialInput2
	Rcall	Serial_In


	Rcall	AddChecksum
	Ldi		R24,Low(DeviceID)	//
	Cpse	R24,R25				//
	Rjmp	AbaikanDeviceID		//Bila tidak sama abaikan

	Rcall	Serial_In			//Ambil Device number
	Rcall	AddChecksum
	Lds		R24,DeviceNumber	//
	CPSE	R24,R25				//
	Rjmp	AbaikanDeviceNumber		//Bila tidak sama abaikan

	Rcall	Serial_In			//Ambil ID pengirim



	Sts		SourceType,R25
	Rcall	AddChecksum

	Rcall	Serial_In			//Ambil nomor urut pengirim


	Sts		SourceNum,R25
	Rcall	AddChecksum

	Rcall	Serial_In			//Ambil panjang data
	Rcall	AddChecksum
	Rcall	SimpankeBuffer

	Lds		R24,Checksum
	Neg		R24
	Rcall	Serial_In
	Cpse	R24,R25
	Rjmp	ErrorChecksum2
	Clc	
	Ret
ErrorChecksum2:
	SEC
	Ret


DeltaSubSerialInput:
    In   	R25,UDR				//Ambil data serial
	Ldi		R24,Low(STX)		//Apakah sama dengan STX?
	Sts		Checksum,R24
	CPSE	R24,R25				//
	Rjmp	AbaikanSerial		//Bila tidak abaikan

	Rcall	Serial_In			//Ambil device ID
	Rcall	AddChecksum

	Ldi		R24,Low(DeviceID)	//
	CPSE	R24,R25				//
	Rjmp	AbaikanDeviceID		//Bila tidak sama abaikan

	Rcall	Serial_In			//Ambil Device number
	Rcall	AddChecksum
	Lds		R24,DeviceNumber	//
	CPSE	R24,R25				//
	Rjmp	AbaikanDeviceNumber		//Bila tidak sama abaikan

	Rcall	Serial_In			//Ambil ID pengirim
	Sts		SourceType,R25
	Rcall	AddChecksum

	Rcall	Serial_In			//Ambil nomor urut pengirim
	Sts		SourceNum,R25
	Rcall	AddChecksum

	Rcall	Serial_In			//Ambil panjang data
	Rcall	AddChecksum
	Rcall	SimpankeBuffer

	Lds		R24,Checksum
	Neg		R24
	Rcall	Serial_In
	Cpse	R24,R25
	Rjmp	ErrorChecksum
	Clc	

	Rcall	KirimACK
	Out		SREG,R23	
	Brcs	AbaikanSerial
	Ldz		TabelPerintahDeltaSub*2
	Lds		R25,Buffer+1
	Rcall	CariPerintah

	Ret



ErrorChecksum:
	Sec
	Rcall	KirimACK
	Ret


AbaikanDeviceID:
	Rcall	Serial_In		//Buang Device Number

AbaikanDeviceNumber:
	Rcall	Serial_In		//Buang Source Type
	Rcall	Serial_In		//Buang Source Number
	Rcall	SimpankeBuffer	
	Rcall	Serial_In		//Buang Checksum

AbaikanSerial:
	Ret




KirimPaketData:
	Ldi		R25,Low(STX)			;Kirim STX
	Sts		Checksum,R25			;
	Rcall	Serial_out				;

	Lds		R25,TargetType		;Kirim Device ID
	Rcall	Serial_Out				;
	Rcall	AddChecksum				;
	Lds		R25,TargetNum		;Kirim Device Number
	Rcall	Serial_Out				;
	Rcall	AddChecksum				;
	Ldi		R25,Low(DeviceID)			;Kirim Target Type
	Rcall	Serial_Out				;
	Rcall	AddChecksum				;
	Lds		R25,DeviceNumber			;Kirim Target Num
	Rcall	Serial_Out				;
	Rcall	AddChecksum				;
	Lds		R25,Buffer				;Kirim Buffer
	Rcall	Serial_Out				;
	Rcall	AddChecksum				;
	Mov		R24,R25					;
	Ldx		Buffer+1					;
LoopPaketData:
	Ld		R25,X+					;Kirim isi buffer
	Rcall	Serial_Out				;
	Rcall	AddChecksum				;
	Djnz	R24,LoopPaketData		;
	Lds		R25,Checksum
	Neg		R25
	Rcall	Serial_Out
	Ret
