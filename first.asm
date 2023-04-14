Stack SEGMENT PARA Stack
 DB 64 Dup (' ')

Stack ends

DATA segment para 'DATA'
    
    CURRENT_LOCATION_X DW 0A0H
    CURRENT_LOCATION_Y DW 0A0H

    TIME_AUX DB 0 ;
    
    BALL_X DW 0A0h                       ; current X position (column) of the ball
	BALL_Y DW 0A0h                       ; current Y position (column) of the ball 
    BALL_SIZE DW 04H                     ; size of the ball 
    
    Y_Ball_Velocity DW 04H
    
    SCORE DW 00H
    MAX_HEIGHT DW 0A0h
	
    ball_move_time dw  05h
	overflow_flag dw 01h

    Enemy_X DW 090h
    Enemy_Y DW 0A0h
    
    Enemy_SIZE DW 05H                     

    Initial_LAYER_X DW 0A0h 
    Initial_LAYER_Y DW 0A0h 

	Initial_LAYER_WIDTH DW 018h

    LY_F_X DW 0Ah
	LY_F_Y DW 090h
	
	LY_S_X DW 100h
	LY_S_Y DW 030h

    	
	LAYER_WIDTH DW 030h
	LAYER_HEIGHT DW 01h

    Target_Layer_X dw 00h
    Target_Layer_Y dw 00h
    TEMP_Ball_X_ dw 00h
	
	X DW 0h
	Y DW 02h
	
	R DW 02h
	
	D DW  (?)
	
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

        mov cx,Initial_LAYER_X
        mov CURRENT_LOCATION_X,cx

        mov cx,Initial_LAYER_Y
        mov CURRENT_LOCATION_Y,cx

        CALL GENERATE_F_X                
		
		CALL GENERATE_F_Y
			
		CALL GENERATE_S_X
		
		CALL GENERATE_S_Y

            CHECK_TIME:
                mov ah,2ch ; GET THE SYSTEM TIME
                int 21h
                CMP Dl,TIME_AUX
                je CHECK_TIME
                MOV TIME_AUX,Dl
				inc si
				cmp si ,10 ; Let the ball go up for 5 seconds
				jg ball_down ; after 5 seconds go down and if no stage was in the way continue to fall
				jng ball_up ; go up after hitting the stages => 
                ; jmp ball_up

                JMP CHECK_TIME
            ret 
    main endp

;! UP HANDLER{
	Ball_up proc NEAR
        mov AX,Y_Ball_Velocity
        sub BALL_Y,AX
        call KEYBOARD_CHECKER
        CALL ENEMY_HITTING
        call CHECK_SCORE        
        call Check_Position
		CALL DRAW_BALL		
		jmp CHECK_TIME
	Ball_up endp

    Check_Position proc near
        ;  BALL_SIZE DW 04H                     ; size of the ball 
        mov dx , BALL_Y
        cmp dx , 09h               ;* IF Reach the top of the page reset the position of the ball     
        jle Reset_Camera
        ret

    Check_Position endp

    Reset_Camera proc near
        mov BALL_Y, 0B0H
        mov CURRENT_LOCATION_Y,0B0h
        mov ax,BALL_X
        mov current_location_x,ax
        call GENERATE_initial_X
        call GENERATE_initial_Y
        call GENERATE_F_X
        call GENERATE_F_Y
        call GENERATE_S_X
        call GENERATE_S_Y
        mov MAX_HEIGHT,0B0h
        ret
    Reset_Camera ENDP


    CHECK_SCORE PROC near ;if the new Score reached this value will update
        mov bx , BALL_Y
        mov cx , MAX_HEIGHT
        CMP bx , cx
        jle UPDATE_SCORE
        RET
    CHECK_SCORE ENDP

    UPDATE_SCORE PROC NEAR
        ; MOV ax , MAX_HEIGHT  ; Farest point from initial ( point = 0A0H )
        sub cx,bx
        ; mov cx,score
        add score ,cx
        MOV MAX_HEIGHT,bx

        RET
    UPDATE_SCORE ENDP


;! }


	Ball_down proc NEAR
            ; BALL_X DW 0A0h                       ; current X position (column) of the ball
        	; BALL_Y DW 0A0h                       ; current Y position (column) of the ball 
        mov AX,Y_Ball_Velocity
        add BALL_Y,AX
        Call GAME_OVER
        call KEYBOARD_CHECKER
        CALL ENEMY_HITTING
        CALL HITTING_STAGES ;check for hitting the stages and reset the move style        
		CALL DRAW_BALL
		;CALL DRAW_CRCL

		jmp CHECK_TIME

	Ball_down endp

    upadte_STages proc near
        call check_initial
        call check_layer_F
        call check_layer_S
    ret
    upadte_STages endp
    
    check_initial proc near
        mov cx, current_location_Y
        mov dx,Initial_LAYER_Y
        cmp cx , dx
        jl update_initial
        ret
    check_initial endp

    update_initial proc near
        call GENERATE_initial_X
        call GENERATE_initial_Y
        ret
    update_initial endp

    check_layer_F proc near
        mov cx, current_location_Y
        mov dx,LY_F_Y
        cmp cx , dx
        jl update_layer_F
        ret
    check_layer_F endp

    update_layer_F proc near
        call GENERATE_F_X
        call GENERATE_F_Y
        ret
    update_layer_F endp

    check_layer_S proc near
        mov cx, current_location_Y
        mov dx,LY_S_Y
        cmp cx , dx
        jl update_layer_S
        ret
    check_layer_S endp

    update_layer_S proc near
        call GENERATE_S_X
        call GENERATE_S_Y
        ret
    update_layer_S endp


; counter_zero proc near
;        mov si , 0       
;        jmp CHECK_TIME

; counter_zero endp

ENEMY_HITTING PROC NEAR

        mov cx,Enemy_X
        MOV Target_Layer_X , cx ; if the y of the ball and the layer is same we should check for x and need to store them in a temporarily variable

        mov cx,BALL_X
        MOV TEMP_Ball_X_ , cx

        mov cx ,Enemy_Y
        mov Target_Layer_Y,cx

        mov dx ,BALL_Y
        sub cx , dx
        cmp cx , 4
        JlE X_HIT_CHECKER_ENEMY
        RET

        X_HIT_CHECKER_ENEMY:
        ; check if the x is in layer hit the layer and go up 
            MOV cx , TEMP_Ball_X_ 
            mov dx , Target_Layer_X
            add dx, Enemy_SIZE
            CMP cx,dx
            jg ENEMY_NOTHIT
            add cx , BALL_SIZE
            mov dx , Target_Layer_X
            CMP cx,dx
            jl ENEMY_NOTHIT
            JMP EndGame

ENEMY_HITTING ENDP

ENEMY_NOTHIT PROC NEAR
    RET
ENEMY_NOTHIT ENDP

; ! this procecss is the responsible of hitting action[

Hit_Stage_initial proc near 
        mov cx,Initial_LAYER_X
        MOV Target_Layer_X , cx ; if the y of the ball and the layer is same we should check for x and need to store them in a temporarily variable

        mov cx,BALL_X
        MOV TEMP_Ball_X_ , cx

        mov cx ,Initial_LAYER_Y
        mov Target_Layer_Y,cx

    mov dx ,BALL_Y
    sub cx,dx
    cmp cx,03h
    JlE X_HIT_CHECKER
    ret

Hit_Stage_initial endp

Hit_Stage_F proc near

        mov cx,LY_F_X
        MOV Target_Layer_X , cx ; if the y of the ball and the layer is same we should check for x and need to store them in a temporarily variable
        mov cx,BALL_X
        MOV TEMP_Ball_X_ , cx
        mov cx ,LY_F_Y
        mov Target_Layer_Y,cx
        mov dx ,BALL_Y
        sub cx,dx
        cmp cx,03h
        JlE X_HIT_CHECKER
        ret

Hit_Stage_F endp

Hit_Stage_S proc near

        mov cx,LY_S_X
        MOV Target_Layer_X , cx ; if the y of the ball and the layer is same we should check for x and need to store them in a temporarily variable
        mov cx,BALL_X
        MOV TEMP_Ball_X_ , cx
        mov cx ,LY_S_Y
        mov Target_Layer_Y,cx
        mov dx ,BALL_Y
        sub cx,dx
        cmp cx,03h
        JlE X_HIT_CHECKER
        ret

Hit_Stage_S endp

HITTING_STAGES PROC NEAR
        mov si ,11
        ; check Initial_LAYER
        call Hit_Stage_initial
        ; check layer_F
        call Hit_Stage_F
        ; check layer_S
        call Hit_Stage_S
    ret
HITTING_STAGES ENDP

X_HIT_CHECKER PROC NEAR
    ; check if the x is in layer hit the layer and go up 
    MOV cx , TEMP_Ball_X_ 
    mov dx , Target_Layer_X
    add dx, LAYER_WIDTH
    CMP cx,dx
    jg NOTHIT
    add cx , BALL_SIZE
    mov dx , Target_Layer_X
    CMP cx,dx
    jl NOTHIT
    mov si ,0

    mov cx,Target_Layer_Y
    mov CURRENT_LOCATION_Y,cx
    mov BALL_Y,cx

    mov cx , Target_Layer_X
    mov current_location_x,cx
    call upadte_STages
    ret

X_HIT_CHECKER ENDP

NOTHIT proc near
    ret
NOTHIT endp
;!  ]

KEYBOARD_CHECKER PROC NEAR
    mov ah ,0h
    int 10h
    
    mov ah,01h
    int 16h
    jz Exit_Keyboard   
    mov ah ,00h
    int 16h
    CMP Al,'d'
    JE GO_RIGHT
    CMP Al,'D'
    JE GO_RIGHT
    CMP Al , 'A'
    JE GO_LEFT             
    CMP Al , 'a'
    JE GO_LEFT
      
                   
                   ; 4B left Arrow
                   ; 4D Right Arrow
    Exit_Keyboard:
        RET
    ret
KEYBOARD_CHECKER ENDP

GO_LEFT PROC NEAR     
    sub BALL_X,04H   
    RET
GO_LEFT ENDP             
               
GO_RIGHT PROC NEAR
    add BALL_X,04H   
    RET
GO_RIGHT ENDP




PRINT_SCORE proc near;print Score

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

        CALL DIVIDE_NUMBER_FOR_PRINT
    ret
PRINT_SCORE endp

GAME_OVER proc near

        mov bx, BALL_Y
        cmp bx,0C8h
        jge EndGame
        ret
    
    GAME_OVER endp

    EndGame proc near
        mov ah , 4ch
        int 21h
    EndGame endp


DIVIDE_NUMBER_FOR_PRINT PROC NEAR ;print the score digit by digit
 ;mov bx, 000Fh
 MOV CX,0
 MOV BX,0AH        ;bx=10 for dividing
 
 
 mov ax,score 
;  mov bx,score
;  add bx,ax
;  mov ax,bx
;  mov SCORE, bx
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
    ret   
DIVIDE_NUMBER_FOR_PRINT ENDP

PRINT_IN_CONSOLE PROC NEAR
    
  PRINT:   
    
    POP AX 
    mov bx , 000Fh
    mov ah , 0eh
 
    ADD AL , 030H
    INT 10h
    
    LOOP PRINT 

 RET
    
PRINT_IN_CONSOLE ENDP

DRAW_BALL PROC NEAR

        ; mov ah ,7h
        ; int 10h
        ; push bx

        mov ah ,0h
        int 10h
        CALL PRINT_SCORE


        MOV CX, Enemy_X 
		MOV DX, Enemy_Y 
		
		Enemy_Draw:
			MOV AH, 0Ch
			MOV AL, 0fh
			MOV BH, 00h
			INT 10h
			INC CX
            MOV AX, CX
            SUB AX,Enemy_X
            CMP AX,Enemy_SIZE
            jng Enemy_Draw
			MOV cx , Enemy_X ;initial column 
            INC DX
            MOV AX, DX
            SUB AX, Enemy_Y
            CMP AX, Enemy_SIZE
            jng Enemy_Draw


        MOV CX, Initial_LAYER_X 
		MOV DX, Initial_LAYER_Y 
		
		Initial_LAYER:
			MOV AH, 0Ch
			MOV AL, 0Fh
			MOV BH, 00h
			INT 10h
			INC CX
            MOV AX, CX
            SUB AX,Initial_LAYER_X
            CMP AX,LAYER_WIDTH
            jng Initial_LAYER
			MOV cx , Initial_LAYER_X ;initial column 
            INC DX
            MOV AX, DX
            SUB AX, Initial_LAYER_Y
            CMP AX, LAYER_HEIGHT
            jng Initial_LAYER

        


        MOV CX, LY_F_X
		MOV DX, LY_F_Y
		
		DRAW_LAYER_F:
            mov ah , 0Ch
            mov al , 0fh ; Set the color of pixel
            mov bh , 00h
            int 10h
			INC CX
            MOV AX, CX
            SUB AX,LY_F_X
            CMP AX,LAYER_WIDTH
            JNG DRAW_LAYER_F
			MOV cx , LY_F_X ;initial column 
            INC DX
            MOV AX, DX
            SUB AX, LY_F_Y
            CMP AX, LAYER_HEIGHT
            JNG DRAW_LAYER_F
			
		MOV CX, LY_S_X
		MOV DX, LY_S_Y
		
		DRAW_LAYER_S:
			MOV AH, 0Ch
			MOV AL, 0Fh
			MOV BH, 00h
			INT 10h
			INC CX
            MOV AX, CX
            SUB AX,LY_S_X
            CMP AX,LAYER_WIDTH
            jng DRAW_LAYER_S
			MOV cx , LY_S_X ;initial column 
            INC DX
            MOV AX, DX
            SUB AX, LY_S_Y
            CMP AX, LAYER_HEIGHT
            jng DRAW_LAYER_S
			
        CALL DRAW_CRCL
		ret
DRAW_BALL ENDP

	GENERATE_F_X PROC NEAR
        mov ah,2ch ; GET THE SYSTEM TIME
        int 21h
        mov al,dl
        mov ah ,00h
        add ax,CURRENT_LOCATION_X
        add ax,LAYER_WIDTH ;* Now    ax = current_x + ( Random ) + layer-width  checking if ax is out of the screen
        cmp ax, 0140h
        jg GENERATE_F_X
        sub ax,LAYER_WIDTH   ; * ax= current_x + ( Random )
        mov bx,CURRENT_LOCATION_X   
        add bx,LAYER_WIDTH ; * bx= current_x + layer-width
        cmp ax,bx ; * if  ax is out of range of bx so the ball cant reach the layer should ReGenerate the random number
        jg GENERATE_F_X
        mov LY_F_X, ax
		RET

	GENERATE_F_X ENDP 
    GENERATE_F_Y PROC NEAR
	
        mov ah,2ch ; GET THE SYSTEM TIME
        int 21h
        mov al,dl
        mov ah ,00h
        cmp ax, 028h
        jg GENERATE_F_Y
        mov bx,CURRENT_LOCATION_Y
        sub bx,ax
        mov ax,bx ;* ax = current_location_Y - RandomNumber 
	    MOV LY_F_Y, AX            
		RET
	GENERATE_F_Y ENDP
	
	
    GENERATE_initial_X PROC NEAR 
        mov ah,2ch ; GET THE SYSTEM TIME
        int 21h
        mov al,dl
        mov ah ,00h
        add ax,CURRENT_LOCATION_X
        add ax,LAYER_WIDTH ;* Now    ax = current_x + ( Random ) + layer_width  checking if ax is out of the screen
        cmp ax, 0140h
        jg GENERATE_initial_X
        sub ax,LAYER_WIDTH   ; * ax= current_x + ( Random )
        sub ax,LAYER_WIDTH   ; * ax= current_x + ( Random )- width_layer
        mov bx,CURRENT_LOCATION_X   
        add bx,LAYER_WIDTH ; * bx= current_x + layer-width
        cmp ax,bx ; * if  ax is out of range of bx so the ball cant reach the layer should ReGenerate the random number
        jg GENERATE_initial_X
        mov Initial_LAYER_X,ax 
        ret
	GENERATE_initial_X ENDP 
	GENERATE_initial_Y PROC NEAR
        mov ah,2ch ; GET THE SYSTEM TIME
        int 21h
        mov al,dl
        mov ah ,00h
        add al,05h
        cmp ax, 028h
        jg GENERATE_initial_Y
        mov bx,CURRENT_LOCATION_Y
        sub bx,ax
        mov ax,bx ;* ax = current_location_Y - RandomNumber 
	    MOV Initial_LAYER_Y, AX            
		RET
	
    GENERATE_initial_Y ENDP 
	
    

	GENERATE_S_X PROC NEAR

        mov ah,2ch ; GET THE SYSTEM TIME
        int 21h
        mov al,dl
        mov ah ,00h
        mov bx,current_location_x
        sub bx,ax
        mov ax,bx ;* ax = current_location_x - RandomNumber 

        cmp ax, 00h
        jl GENERATE_S_X
        ; sub ax,LAYER_WIDTH
        ; add bx,LAYER_WIDTH
        add ax,LAYER_WIDTH
        mov bx,current_location_x
        cmp ax,bx ; * check if the  current_location_x - RandomNumber + LAYER_WIDTH is < current_location then need to ReGenerate
        jl GENERATE_S_X
        sub ax,LAYER_WIDTH
        MOV LY_S_X, AX
		RET
	GENERATE_S_X ENDP 

	GENERATE_S_Y PROC NEAR
        mov ah,2ch ; GET THE SYSTEM TIME
        int 21h
        mov al,dl
        mov ah ,00h
        add al,010h
        cmp ax, 028h
        jg GENERATE_S_Y
        mov bx,CURRENT_LOCATION_Y
        sub bx,ax
        mov ax,bx ;* ax = current_location_Y - RandomNumber 
	    MOV LY_S_Y, AX            
		RET

	GENERATE_S_Y ENDP 
    
	DRAW_CRCL PROC NEAR
	
		MOV X, 0h ; x = 0
		MOV AX, R ; y = r
		MOV Y, AX
		
		MOV AX, R ; d = 3 - (2 * r)
		MOV BX, 2h
		MUL BX
		MOV BX, AX
		MOV AX, 3h
		SUB AX, BX
		MOV D, AX
		
		
		CALL DRAW_PIXELS
		MOV AX, X
		MOV BX, Y
		MOV DX, D
		CMP AX, BX ; X <= Y
		JNG WHILE_L
		
		WHILE_L:
			
			ADD AX, 1h
			MOV X, AX
			
			MOV DX, D
			CMP DX, 0
			JG IF_C
			JNG ELSE_C
			RET
			
		IF_C:
			SUB BX, 1
			MOV Y, BX
			
			MOV AX, X
			MOV BX, Y 
			SUB AX, BX
			MOV BX, 4h
			MUL BX
			ADD D, AX
			ADD D, 10h
			CALL DRAW_PIXELS
			MOV AX, X
			MOV BX, Y
			MOV DX, D
			CMP AX, BX ; X <= Y
			JNG WHILE_L
			RET
			
		ELSE_C:
			MOV AX, X
			MOV BX, 4h
			MUL BX 
			ADD D, AX 
			ADD D, 6h
			CALL DRAW_PIXELS
			MOV AX, X
			MOV BX, Y
			MOV DX, D
			CMP AX, BX ; X <= Y
			JNG WHILE_L
			MOV AX, X
			MOV BX, Y
			MOV DX, D
			CMP AX, BX ; X <= Y
			JNG WHILE_L
			RET 
		
			
			
		
		
		
		RET 
		
	DRAW_CRCL ENDP
	
	DRAW_PIXELS PROC NEAR
		; 1
		MOV CX, BALL_X ; xc+x
		ADD CX, X
		
		MOV DX, BALL_Y ; yc+y
		ADD DX, Y
		
            mov ah , 0Ch
            mov al , 02h ; Set the color of pixel
            mov bh , 01eh
		int 10h
		
		; 2
		MOV CX, BALL_X ; xc-x
		SUB CX, X
		
		MOV DX, BALL_Y ; yc+y
		ADD DX, Y
		
            mov ah , 0Ch
            mov al , 02h ; Set the color of pixel
            mov bh , 01eh
		int 10h
		
		; 3
		MOV CX, BALL_X ; xc+x
		ADD CX, X
		
		MOV DX, BALL_Y ; yc-y
		SUB DX, Y
		
            mov ah , 0Ch
            mov al , 02h ; Set the color of pixel
            mov bh , 01eh
		int 10h
		
		; 4
		MOV CX, BALL_X ; xc-x
		SUB CX, X
		
		MOV DX, BALL_Y ; yc-y
		SUB DX, Y
		
            mov ah , 0Ch
            mov al , 02h ; Set the color of pixel
            mov bh , 01eh
		int 10h
		
		; 5
		MOV CX, BALL_X ; xc+y
		ADD CX, Y
		
		MOV DX, BALL_Y ; yc+x
		ADD DX, X
		
            mov ah , 0Ch
            mov al , 02h ; Set the color of pixel
            mov bh , 01eh
		int 10h
		
		; 6 
		MOV CX, BALL_X ; xc-y
		SUB CX, Y
		
		MOV DX, BALL_Y ; yc+x
		ADD DX, X
		
            mov ah , 0Ch
            mov al , 02h ; Set the color of pixel
            mov bh , 01eh
		int 10h
		
		; 7
		MOV CX, BALL_X ; xc+y
		ADD CX, Y
		
		MOV DX, BALL_Y ; yc-x
		SUB DX, X
		
            mov ah , 0Ch
            mov al , 02h ; Set the color of pixel
            mov bh , 01eh
		int 10h
		
		; 8
		MOV CX, BALL_X ; xc-y
		SUB CX, Y
		
		MOV DX, BALL_Y ; yc-x
		SUB DX, X
		
            mov ah , 0Ch
            mov al , 02h ; Set the color of pixel
            mov bh , 01eh
		int 10h
		RET
	DRAW_PIXELS ENDP
	
code ends
end