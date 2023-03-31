Stack SEGMENT PARA Stack
 DB 64 Dup (' ')

Stack ends

DATA segment para 'DATA'
    TIME_AUX DB 0 ;
    BALL_X DW 0A0h                       ; current X position (column) of the ball
	BALL_Y DW 0A0h                       ; current Y position (column) of the ball 
    BALL_SIZE DW 04H                     ; size of the ball 
    X_Ball_Velocity DW 04H
    Y_Ball_Velocity DW 04H
	
	LAYER_X DW 0Ah
	LAYER_Y DW 0Ah
	randomNum_X DW 0
	randomNum_Y DW 0
	LAYER_WIDTH DW 0Ah
	LAYER_HEIGHT DW 0Fh
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

            CHECK_TIME:
                mov ah,2ch ; GET THE SYSTEM TIME
                int 21h
                CMP DL,TIME_AUX
                je CHECK_TIME
                MOV TIME_AUX,DL
                mov AX,Y_Ball_Velocity
                sub BALL_Y,AX
                MOV AX,X_Ball_Velocity
                sub BALL_X,AX
                
				CALL CLEAR_RCREEN
				
				CALL DRAW_BALL
				
				CALL DRAW_LAYAER
				
                JMP CHECK_TIME

            ret 

    main endp

    DRAW_BALL PROC NEAR
        ; mov ah ,7h
        ; int 10h

        mov ah ,0h
        int 10h

        mov cx , BALL_X ;initial column 
        mov dx , BALL_Y ;initial line
        DRAW_BALL_Horizontal:
            mov ah , 0Ch
            mov al , 02h ; Set the color of pixel
            mov bh , 00h
            int 10h
            inc cx
            MOV ax, cx
            SUB ax,BALL_X
            cmp ax,BALL_SIZE
            jng DRAW_BALL_Horizontal
            mov cx , BALL_X ;initial column 
            inc dx 
            MOV ax, dx
            SUB ax,BALL_Y
            cmp ax,BALL_SIZE
            jng DRAW_BALL_Horizontal

        DRAW_BALL_VERTICAL:
        RET
    DRAW_BALL ENDP
	
	
	
	
	DRAW_LAYAER PROC NEAR
		
		CALL GENERATE_X
		MOV CX, randomNum_X ; set the layer x
		CALL GENERATE_Y
		MOV DX, randomNum_Y ; set the layer y
		
		DRAW_LAYAER_HORIZ:
			MOV AH, 0Ch ; set configuration to pixel
			MOV AL, 02h ; choose white as color 
			MOV BH, 00h ; set the page number
			INT 10h ; execute the configuration
			INC CX ; cx = cx + 1
			
			
			MOV AX, CX ; cx - BALL_X > BALL_SIZE -> go to the next line of the ball height pixles !!!!!!
			SUB AX, LAYER_X
			CMP AX, LAYER_HEIGHT
			JNG DRAW_LAYAER_HORIZ
			
			
			MOV CX, LAYER_X ; the cx reg goes back to the initial X
			INC DX ; dx = dx + 1
			
			
			MOV AX, DX ; dx - BALL_Y > BALL_SIZE -> exit the procedure
			SUB AX, LAYER_Y
			CMP AX, LAYER_WIDTH
			JNG DRAW_LAYAER_HORIZ	
		
		
	
		RET
		
	DRAW_LAYAER ENDP
	
	GENERATE_X PROC NEAR
    
	MOV AH, 0h ; intterupt to get system time
		INT 1Ah ; save clock ticks in DX
		
		MOV AX, DX
		MOV DX, 0h
		MOV BX, 010d 
		DIV BX ; range the number between 0 to 9 dividing by 10
		MOV AL, DL
		MOV AH, 0
		MOV BX, 0500d ; multiply the random number to screen X
		MUL BX 
		MOV DX, 0
		
		MOV randomNum_X, AX
		
		RET
	GENERATE_X ENDP
	
	GENERATE_Y PROC NEAR
    	
		MOV AH, 0h ; intterupt to get system time
		INT 1Ah ;save clock ticks in DX
		
		MOV AX, DX
		MOV DX, 0h
		MOV BX, 010d    
		DIV BX ; range the number between 0 to 9 dividing by 10
		MOV AL, DL
		MOV AH, 0
		MOV BX, 0200d ; multiply the random number to screen Y
		MUL BX 
		MOV DX, 0
		
		MOV randomNum_Y, AX
		
		RET
	GENERATE_Y ENDP
	
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

code ends
end