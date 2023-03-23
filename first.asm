Stack SEGMENT PARA Stack
 DB 64 Dup (' ')

Stack ends

DATA segment para 'DATA'
Data ends


code segment para 'CODE'
    main proc fAR
        ; mov dl ,'A'
        ; mov ah,6h
        ; int 21h

        mov ah , 00h
        mov al , 13h
        int 10h

        mov ah , 0bh
        mov bh , 00h
        mov bl , Dh
        int 10h

        mov ah , 0Ch
        ; mov al , 07h ; Set the color of pixel
        mov bh , 00h
        mov cx , 0Ah
        mov dx , 0Ah
        int 10h
        ret 
    main endp


code ends
end