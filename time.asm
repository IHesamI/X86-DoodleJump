Stack SEGMENT PARA Stack
 DB 64 Dup (' ')

Stack ends

DATA segment para 'DATA'
    TIME_AUX DB 0 ;
	
	
	
	
	
	LY_F_X DW 0Ah
	LY_F_Y DW 090h
	
	LY_S_X DW 100h
	LY_S_Y DW 030h
	
	LY_T_X DW 03Ah
	LY_T_Y DW 050h
	
	LY_FO_X DW 100h
	LY_FO_Y DW 050h
	
	
	
	LAYER_WIDTH DW 030h
	LAYER_HEIGHT DW 01h
	
	
	; org 100h
	; RAND_X dw 5 dup(?) 
	; ORG 110h
	; RAND_Y dw 5 dup(?)

Data ends


code segment para 'CODE'
    main proc fAR
	    ASSUME CS:CODE,DS:DATA,SS:STACK      ;assume as code,data and stack segments the respective registers
	    PUSH DS                              ;push to the stack the DS segment
	    SUB AX,AX                            ;clean the AX register
	    PUSH AX                              ;push AX to the stack
        MOV AX,DATA                          ;save on the AX register the contents of the DATA segment
        MOV DS,AX                            ;save on the DS segment the contents of AX
        POP AX                               ;release the top item from the stack to the AX register
        POP AX                               ;release the top item from the stack to the AX register
        mov ah ,0h
        int 10h   
	
		
		
		CALL GENERATE_F
		MOV LY_F_X, AX
		CALL GENERATE_F
		MOV LY_F_Y, AX		
		CALL GENERATE_F
		MOV LY_S_X, AX
		CALL GENERATE_S
		MOV LY_S_Y, AX
        
		CHECK_TIME:
                mov ah,2ch ; GET THE SYSTEM TIME
                int 21h
                CMP DL,TIME_AUX
                je CHECK_TIME
                MOV TIME_AUX,DL
				
				
                
				CALL CLEAR_RCREEN
				
				CALL DRAW_LAYER
				
				
                JMP CHECK_TIME
				

            ret 

    main endp

    
	
	

	
	CLEAR_RCREEN PROC NEAR
		MOV AH, 00h ; set the configuration to video mode 
		MOV AL, 13h ; choose the video mode
		INT 10h ; execute  the configuration
		
		MOV AH, 0Bh ; set the configuration
		MOV BH, 00h ; to the background color
		MOV BL, 00h ; set color to green
		INT 10h ; execute the configuration
		
		RET
	CLEAR_RCREEN ENDP
	
	
	GENERATE_F PROC NEAR
	
		
		MOV AH, 0h ; intterupt to get system time
		INT 1Ah ; save clock ticks in DX
			
		MOV AX, DX
		MOV DX, 0h
		MOV BX, 010d 
		DIV BX ; range the number between 0 to 9 dividing by 10
		MOV AL, DL
		MOV AH, 0
		MOV BX, 032d ; multiply the random number to screen X
		MUL BX 
		ADD AX, 040d
		MOV DX, 0
		;MOV [SI], AX
		RET
	GENERATE_F ENDP 
	
	GENERATE_S PROC NEAR
	
		
		MOV AH, 0h ; intterupt to get system time
		INT 1Ah ; save clock ticks in DX
			
		MOV AX, DX
		MOV DX, 0h
		MOV BX, 010d 
		DIV BX ; range the number between 0 to 9 dividing by 10
		MOV AL, DL
		MOV AH, 0
		MOV BX, 032d ; multiply the random number to screen X
		MUL BX 
		ADD AX, 0288d
		MOV DX, 0
		;MOV [SI], AX
		RET
	GENERATE_S ENDP 

code ends
end
