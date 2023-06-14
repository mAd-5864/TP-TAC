.8086
.model small
.stack 2048

dseg	segment para public 'data'

;

        Erro_Open       db      'Erro ao tentar abrir o ficheiro$'
        Erro_Ler_Msg    db      'Erro ao tentar ler do ficheiro$'
        Erro_Close      db      'Erro ao tentar fechar o ficheiro$'
        Fich         	db      'board.txt', 0
        HandleFich      dw      0
        car_fich        db      ?

        ; Nomes dos jogadores
		PromptMessage1  db		'Nome jogador 1: $'
    	PromptMessage2  db		'Nome jogador 2: $'
        Player1Name     db      15 dup('$')
        Player2Name     db      15 dup('$')
        PlayerIndicator db      '--> $'
        clearString 	db     	'    $'

		Car				db	32	; Guarda um caracter do Ecran
		Cor				db	7	; Guarda os atributos de cor do caracter
		POSy			db	7	; a linha pode ir de [1 .. 25]
		POSx			db	15 ; POSx pode ir [1..80]
		PlayerTurn      db  1

        ColorX          db  1       ; Color attribute for 'X'
        ColorO          db  4      ; Color attribute for 'O'

dseg	ends

cseg	segment para public 'code'
assume		cs:cseg, ds:dseg



;########################################################################
goto_xy	macro		POSx,POSy
		mov		ah,02h
		mov		bh,0		; numero da página
		mov		dl,POSx
		mov		dh,POSy
		int		10h
endm


;ROTINA PARA APAGAR ECRAN

apaga_ecran	proc
			mov		ax,0B800h
			mov		es,ax
			xor		bx,bx
			mov		cx,25*80

apaga:		mov		byte ptr es:[bx],' '
			mov		byte ptr es:[bx+1],7
			inc		bx
			inc 	bx
			loop	apaga
			ret
apaga_ecran	endp


;########################################################################
; IMP_FICH

IMP_FICH	PROC

		;abre ficheiro
        mov     ah,3dh
        mov     al,0
        lea     dx,Fich
        int     21h
        jc      erro_abrir
        mov     HandleFich,ax
        jmp     ler_ciclo

erro_abrir:
        mov     ah,09h
        lea     dx,Erro_Open
        int     21h
        jmp     sai_f

ler_ciclo:
        mov     ah,3fh
        mov     bx,HandleFich
        mov     cx,1
        lea     dx,car_fich
        int     21h
		jc		erro_ler
		cmp		ax,0		;EOF?
		je		fecha_ficheiro
        mov     ah,02h
		mov		dl,car_fich
		int		21h
		jmp		ler_ciclo

erro_ler:
        mov     ah,09h
        lea     dx,Erro_Ler_Msg
        int     21h

fecha_ficheiro:
        mov     ah,3eh
        mov     bx,HandleFich
                int     21h
        jnc     sai_f

        mov     ah,09h
        lea     dx,Erro_Close
        Int     21h
sai_f:
		RET

IMP_FICH	endp


;########################################################################
; LE UMA TECLA

LE_TECLA	PROC

		mov		ah,08h
		int		21h
		mov		ah,0
		cmp		al,0
		jne		SAI_TECLA
		mov		ah, 08h
		int		21h
		mov		ah,1
SAI_TECLA:	RET
LE_TECLA	endp



;########################################################################
; Avatar

AVATAR	PROC
			mov		ax,0B800h
			mov		es,ax
CICLO:
			goto_xy	POSx,POSy		; Vai para nova posição
			mov 	ah, 08h
			mov		bh,0			; numero da página
			int		10h
			mov		Car, al			; Guarda o Caracter que está na posição do Cursor
			mov		Cor, ah			; Guarda a cor que está na posição do Cursor

			goto_xy	78,0			; Mostra o caractr que estava na posição do AVATAR
			mov		ah, 02h			; IMPRIME caracter da posição no canto
			mov		dl, Car
			int		21H

			goto_xy	POSx,POSy	; Vai para posição do cursor



LER_SETA:
    call 	LE_TECLA
	cmp		ah, 1
	je		CIMA
	CMP 	al, 27		; ESCAPE
	JE		FIM
    cmp 	al, 0Dh     ; Check for Enter key press
    jne 	LER_SETA

    ; Check if current position contains a space character
    mov 	ah, 08h
	int 	10h
    cmp 	al, 32
    jne 	LER_SETA

    cmp 	PlayerTurn, 1     ; Check current player turn
    je 		WRITE_X            
    jmp 	WRITE_O 
	jmp 	CICLO

WRITE_O:

    mov 	ah, 09h       ; Set text color for 'O'
    mov 	bl, ColorO
    int 	10h

    mov 	ah, 02h       ; Print 'O'
    mov 	dl, 'O'
    int 	21h
	inc 	PlayerTurn
	goto_xy 40, 3
	mov     ah, 09h  
	lea 	dx, clearString
	int 	21h
	goto_xy 40, 1
	mov     ah, 09h  
    lea     dx, PlayerIndicator
    int     21h
	goto_xy	POSx,POSy
	jmp LER_SETA

WRITE_X:
	mov 	ah, 09h       ; Set text color for 'X'
    mov 	bl, ColorX
    int 	10h

    mov 	ah, 02h       ; Print 'X'
    mov 	dl, 'X'
    int 	21h
	dec 	PlayerTurn

	goto_xy 40, 1
	mov     ah, 09h  
	lea 	dx, clearString
	int 	21h
	goto_xy 40, 3
	mov     ah, 09h  
    lea     dx, PlayerIndicator
    int     21h
	goto_xy	POSx,POSy
	jmp LER_SETA
	

CIMA:		cmp 	al,48h
			jne		BAIXO
			cmp 	POSy, 2
			je		CICLO
			dec		POSy		;cima
			jmp		CICLO

BAIXO:		cmp		al,50h
			jne		ESQUERDA
			cmp 	POSy, 12
			je		CICLO
			inc 	POSy		;Baixo
			jmp		CICLO

ESQUERDA:
			cmp		al,4Bh
			jne		DIREITA
			cmp 	POSx, 5
			je		CICLO
			dec		POSx
			dec		POSx		;Esquerda
			jmp		CICLO

DIREITA:
			cmp		al,4Dh
			jne		LER_SETA
			cmp 	POSx, 25
			je		CICLO
			inc		POSx		
			inc		POSx		;Direita
			jmp		CICLO

fim:
			RET
AVATAR		endp


;########################################################################

;########################################################################
; Function to get player names

GET_PLAYER_NAMES proc
    ; Prompt for Player 1 name
    mov     ah, 09h 
    lea     dx, PromptMessage1
    int     21h

    mov     ah, 0Ah 
    mov     dx, offset Player1Name
    int     21h

    call    apaga_ecran
	goto_xy		22,10

    ; Prompt for Player 2 name
    mov     ah, 09h  
    lea     dx, PromptMessage2
    int     21h

    mov     ah, 0Ah    
    mov     dx, offset Player2Name
    int     21h

    ret
GET_PLAYER_NAMES endp

DISPLAY_PLAYER_NAMES proc

	goto_xy		46,1
    mov     ah, 09h 
	mov ah, 09h       ; Set text color for 'X'
	mov cl, 12
    mov bl, ColorX
    int 10h
    lea     dx, Player1Name+2
    int     21h

	goto_xy		46,3

    mov     ah, 09h  
	mov ah, 09h       ; Set text color for 'O'
	mov cl, 12
    mov bl, ColorO
    int 10h
    lea     dx, Player2Name+2
    int     21h

	goto_xy		40, 1
	mov     ah, 09h  
    lea     dx, PlayerIndicator
    int     21h

	mov cl, 1
    ret
DISPLAY_PLAYER_NAMES endp


;########################################################################



;########################################################################

Main  proc
		mov			ax, dseg
		mov			ds,ax

		mov			ax,0B800h
		mov			es,ax

		call		apaga_ecran
		goto_xy		22,10

		call    GET_PLAYER_NAMES
		call    apaga_ecran
		goto_xy		0,0



		call		IMP_FICH
		call		DISPLAY_PLAYER_NAMES
		mov PlayerTurn, 1      ; Set initial player turn to Player 1


    call    AVATAR

    mov     ah, 4CH
    int     21H
Main endp
Cseg	ends
end	Main