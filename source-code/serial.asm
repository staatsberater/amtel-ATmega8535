InitSerialDanInterrupt:
	LDI  	R25,LOW(0x98)	//RX & TX Enable, Serial Interrupt Disable
	OUT  	UCSRB,R25		//
	LDI  	R25,LOW(0x33)	//Baudrate 9600 (Crystal 8 MHz)
	OUT  	UBRRL,R25	
	Ret

InitSerial:
	LDI  	R25,LOW(0x18)	//RX & TX Enable, Serial Interrupt Disable
	OUT  	UCSRB,R25		//
	LDI  	R25,LOW(0x8)	//Baudrate 57600 (Crystal 8 MHz)
	OUT  	UBRRL,R25	
	Cbi		DDRD,0
	Cbi		DDRD,1
	SBi		PortD,0
	Sbi		PortD,1
	Ret



Serial_In:
     Sbis UCSRA,RXC		//skip ke perintah selanjutnya bila rxc set
     Rjmp Serial_In
     In   R25,UDR
	Nop
	Nop
	Nop
	RET
Serial_Out:
     Sbis UCSRA,UDRE	//skip ke perintah selanjutnya bila USR set
     Rjmp Serial_Out
     Out  UDR,R25
	Cbi		DDRD,0
	Cbi		DDRD,1
	SBi		PortD,0
	Sbi		PortD,1

	RET	
