Stack SEGMENT PARA Stack
 DB 64 Dup (' ')

Stack ends

DATA segment para 'DATA'
    TIME_AUX DB 0 ;
    BALL_X DW 012h                       ; current X position (column) of the ball
	BALL_Y DW 0A0h                       ; current Y position (column) of the ball 
    BALL_SIZE DW 04H                     ; size of the ball 
    X_Ball_Velocity DW 04H
    Y_Ball_Velocity DW 04H
    SCORE DW 0H
    MAX_HEIGHT DW 0A0h
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
                ; pop bx
				inc si
				cmp si ,5 ; Let the ball go up for 5 seconds
				jg ball_down ; after 5 seconds go down
				jng ball_up
                ; jmp ball_up
                
                JMP CHECK_TIME
            ret 
    main endp

;! UP HANDLER{
	Ball_up proc NEAR:

		; TODO WHEN WE REACH CERTAIN HEIGHT THE CAMERA SHOULD MOVE
		
        mov AX,Y_Ball_Velocity
        sub BALL_Y,AX
        
        call CHECK_SCORE
        
        call Check_Position
        ; MOV AX,X_Ball_Velocity
        ; sub BALL_X,AX
		CALL DRAW_BALL
		jmp CHECK_TIME

	Ball_up endp

    Check_Position proc near: 
        ;  BALL_SIZE DW 04H                     ; size of the ball 
        mov dx , BALL_Y
        cmp dx , 09h
        jle Reset_Camera
        ; dec BALL_Y
        ret

    Check_Position endp

    Reset_Camera proc near:
        ; mov ax , 0A0H
        mov BALL_Y, 0A0H
        ret
    Reset_Camera ENDP
    
    CHECK_SCORE PROC near:
        mov bx , BALL_Y
        mov cx , MAX_HEIGHT
        CMP bx , cx
        jle UPDATE_SCORE
        RET
    CHECK_SCORE ENDP

    UPDATE_SCORE PROC NEAR:
        MOV MAX_HEIGHT,bx
        RET
    UPDATE_SCORE ENDP:


;! }


	Ball_down proc NEAR:

            ; BALL_X DW 0A0h                       ; current X position (column) of the ball
        	; BALL_Y DW 0A0h                       ; current Y position (column) of the ball 


        mov AX,Y_Ball_Velocity
        add BALL_Y,AX
        ; MOV AX,X_Ball_Velocity
        ; add BALL_X,AX

		;TODO => IF IN THIS PROCESS WE HIT A STAGE 
		;TODO => THIS POSITION SHOULD BE NEW BALL_Y AND THE TIME FOR DOWN MUST ENDS
		CALL DRAW_BALL
		cmp si ,10
		je counter_zero
		jmp CHECK_TIME


	Ball_down endp

counter_zero proc near :
       mov si , 0       
       jmp CHECK_TIME

counter_zero endp

PRINT_SCORE proc near:

        mov bx, 000Fh
        mov     ah, 0eh
        mov     al, "S"
        int     10h

        mov bx, 000Fh
        mov     ah, 0eh
        mov     al, "C"
        int     10h

        mov bx, 000Fh
        mov     ah, 0eh
        mov     al, "O"
        int     10h

        mov bx, 000Fh
        mov     ah, 0eh
        mov     al, "R"
        int     10h

        mov bx, 000Fh
        mov     ah, 0eh
        mov     al, "E"
        int     10h

        mov bx, 000Fh
        mov     ah, 0eh
        mov     al, ":"
        int     10h

        CALL    DIVIDE_NUMBER_FOR_PRINT

        ; mov bx, 000Fh
        ; mov     ax, MAX_HEIGHT
        ; mov     ah, 0eh
        ; sub     al,0A0h
        ; int     10h

    ret

PRINT_SCORE endp

DIVIDE_NUMBER_FOR_PRINT PROC NEAR:
 ;mov bx, 000Fh
 MOV CX,0
 MOV BX,0AH        
 
 MOV ax , MAX_HEIGHT 
 mov cx ,0A0h
 sub cx ,ax
 mov ax ,cx
 mov cx ,0
 DIVIDER:
     DIV BL    
     INC CX 
     MOV BH ,0
     MOV BL,AH
     PUSH BX
     MOV BL,0AH 
     MOV AH,0
     CMP AL ,0               
     JE PRINT_IN_CONSOLE     

    JMP DIVIDER
    
DIVIDE_NUMBER_FOR_PRINT ENDP

PRINT_IN_CONSOLE PROC NEAR:
    
  PRINT:   
    
    POP AX 
    mov bx , 000Fh
    mov ah , 0eh
 
    ADD AL , 030H
    INT 10h
    
 LOOP PRINT 

 RET
    
PRINT_IN_CONSOLE ENDP

    DRAW_BALL PROC NEAR:

        ; mov ah ,7h
        ; int 10h
        ; push bx

        mov ah ,0h
        int 10h
        CALL PRINT_SCORE
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