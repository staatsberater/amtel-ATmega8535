Delay:
	Push	R22
	Ldi		R22,Low($40)
;	Ldi		R22,High($01)
LoopDelay:
	Djnz	R22,LoopDelay
	Pop		R22
	Ret

Delay2:
	Push	R22
	Ldi		R22,Low($01)
	Ldi		R22,High($01)
Loop2Delay:
	Rcall	Delay
	Djnz	R22,Loop2Delay
	Pop		R22
	Ret

Delay4:
	Rcall	Delay2
	Rcall	Delay2
	Ret

Delay3:
	Push	R22
	Ldi		R22,Low($40)
Loop3Delay:
	Rcall	Delay2
	Djnz	R22,Loop3Delay
	Pop		R22
	Ret
