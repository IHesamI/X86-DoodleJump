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
	ball_move_time dw  05h
	overflow_flag dw 01h
	
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
                CMP Dl,TIME_AUX
                je CHECK_TIME
                MOV TIME_AUX,Dl
				; add TIME_AUX,04h
				inc bl
				cmp bl ,5 ; Let the ball go up for 5 seconds
				jg ball_down ; after 5 seconds go down
				jng ball_up
                JMP CHECK_TIME
            ret 
    main endp

	Ball_up proc NEAR:

		; TODO WHEN WE REACH CERTAIN HEIGHT THE CAMERA SHOULD MOVE
		
        mov AX,Y_Ball_Velocity
        sub BALL_Y,AX
        ; MOV AX,X_Ball_Velocity
        ; sub BALL_X,AX
		CALL DRAW_BALL
		jmp CHECK_TIME

	Ball_up endp

	Ball_down proc NEAR:

        mov AX,Y_Ball_Velocity
        add BALL_Y,AX
        ; MOV AX,X_Ball_Velocity
        ; add BALL_X,AX
		;TODO => IF IN THIS PROCESS WE HIT A STAGE 
		;TODO => THIS POSITION SHOULD NEW BALL_Y AND THE TIME FOR DOWN MUST ENDS
		CALL DRAW_BALL
		cmp bl ,10
		je counter_zero
		jmp CHECK_TIME


	Ball_down endp

counter_zero :
       mov bl , 0       
       jmp CHECK_TIME

    DRAW_BALL PROC NEAR:
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

code ends
end