.8086
.model              small
.stack              2048

dseg	segment para   public            'data'

                    Erro_Open         db      'Erro ao tentar abrir o ficheiro$'
                    Erro_Ler_Msg      db      'Erro ao tentar ler do ficheiro$'
                    Erro_Close        db      'Erro ao tentar fechar o ficheiro$'
                    Fich              db      'board.txt', 0
                    HandleFich        dw      0
                    car_fich          db      ?

        ; Nomes dos jogadores
                    PromptMessage1    db		'Nome jogador 1: $'
                    PromptMessage2    db		'Nome jogador 2: $'
                    Player1Name       db       15 dup('$')
                    Player2Name       db       15 dup('$')
                    PlayerIndicator   db       '--> $'
                    clearString       db     	'    $'
                    WinnerMessage     db		'The Winner is $'

        ;Peças e Tabuleiro
                    boardSize         equ  3                                                                        ; Tamanho de cada board
                    boards            dw   9 dup(9 dup('1'))                                                        ; Declarar array de boards
                    board             db   9 dup('$')                                                               ; Declarar array de boards
                    Car               db	32                                                                         ; Guarda um caracter do Ecran
                    Cor               db	7                                                                          ; Guarda os atributos de cor do caracter
                    POSy              db	7                                                                          ; a linha pode ir de [1 .. 25]
                    POSx              db	15                                                                         ; POSx pode ir [1..80]
                    PlayerTurn        db   1
                    boardWin          db   0

                    ColorX            db   6                                                                        ; Cor para 'X'
                    ColorO            db   3                                                                        ; Cor para 'O'
                    Token             db   ?
                    POSrow            db   0
                    POScol            db   0
		
        ;winConditions
                ; Linhas
                    winConditions     db                 0, 2, 4
                    db                3, 4, 5
                    db                6, 7, 8
                ; Colunas
                    db                0, 3, 6
                    db                1, 4, 7
                    db                2, 5, 8
                ; Diagonais
                    db                0, 4, 8
                    db                2, 4, 6

dseg                ends

cseg	segment para   public            'code'
assume		cs:cseg,    ds                :dseg                                     

;########################################################################
goto_xy             macro             POSx,POSy
                    mov               ah,02h
                    mov               bh,0                                                                          ; numero da página
                    mov               dl,POSx
                    mov               dh,POSy
                    int               10h
endm

;########################################################################

CHECK_WIN           MACRO             POSrow, POScol
                    LOCAL             row1, row2, row3, col1, col2, col3, diag1, diag2, winMiniBoard, CHECK_WIN_DONE
                    mov               boardWin, 0

row1                PROC
                    goto_xy           POSrow, POScol
                    ; Lê caracter que esta no cursor
                    MOV               AH, 08h
                    INT               10h 

                    cmp               Token, al
                    jne               row2
                    push              ax
                    goto_xy           POSrow + 2, POScol
                    pop               ax

                    MOV               AH, 08h
                    INT               10h

                    cmp               Token, al
                    jne               row2
                    push              ax
                    goto_xy           POSrow + 4, POScol
                    pop               ax

                    MOV               AH, 08h
                    INT               10h
                    cmp               Token, al
                    jne               row2
                    jmp               winMiniBoard
row1                ENDP

row2                PROC
                    push              ax
                    goto_xy           POSrow, POScol + 1
                    pop               ax
                    ; Lê caracter que esta no cursor
                    MOV               AH, 08h
                    INT               10h

                    cmp               Token, al
                    jne               row3
                    push              ax
                    goto_xy           POSrow + 2, POScol + 1
                    pop               ax

                    MOV               AH, 08h
                    INT               10h

                    cmp               Token, al
                    jne               row3
                    push              ax
                    goto_xy           POSrow + 4, POScol + 1
                    pop               ax

                    MOV               AH, 08h
                    INT               10h
                    cmp               Token, al
                    jne               row3
                    jmp               winMiniBoard
row2                ENDP

row3                PROC
                    push              ax
                    goto_xy           POSrow, POScol + 2
                    pop               ax
                    ; Lê caracter que esta no cursor
                    MOV               AH, 08h
                    INT               10h

                    cmp               Token, al
                    jne               col1
                    push              ax
                    goto_xy           POSrow + 2, POScol + 2
                    pop               ax

                    MOV               AH, 08h
                    INT               10h

                    cmp               Token, al
                    jne               col1
                    push              ax
                    goto_xy           POSrow + 4, POScol + 2
                    pop               ax

                    MOV               AH, 08h
                    INT               10h
                    cmp               Token, al
                    jne               col1
                    jmp               winMiniBoard
row3                ENDP

col1                PROC
                    ; Lê caracter que esta no cursor
                    goto_xy           POSrow, POScol
                    MOV               AH, 08h
                    INT               10h

                    cmp               Token, al
                    jne               col2
                    push              ax
                    goto_xy           POSrow, POScol + 1
                    pop               ax

                    MOV               AH, 08h
                    INT               10h

                    cmp               Token, al
                    jne               col2
                    push              ax
                    goto_xy           POSrow, POScol + 2
                    pop               ax

                    MOV               AH, 08h
                    INT               10h
                    cmp               Token, al
                    jne               col2
                    jmp               winMiniBoard
col1                ENDP

col2                PROC
                    push              ax
                    goto_xy           POSrow + 2, POScol
                    pop               ax
                    ; Lê caracter que esta no cursor
                    MOV               AH, 08h
                    INT               10h

                    cmp               Token, al
                    jne               col3
                    push              ax
                    goto_xy           POSrow + 2, POScol + 1
                    pop               ax

                    MOV               AH, 08h
                    INT               10h

                    cmp               Token, al
                    jne               col3
                    push              ax
                    goto_xy           POSrow + 2, POScol + 2
                    pop               ax

                    MOV               AH, 08h
                    INT               10h
                    cmp               Token, al
                    jne               col3
                    jmp               winMiniBoard
col2                ENDP

col3                PROC
                    push              ax
                    goto_xy           POSrow + 4, POScol
                    pop               ax
                    ; Lê caracter que esta no cursor
                    MOV               AH, 08h
                    INT               10h

                    cmp               Token, al
                    jne               diag1
                    push              ax
                    goto_xy           POSrow + 4, POScol + 1
                    pop               ax

                    MOV               AH, 08h
                    INT               10h

                    cmp               Token, al
                    jne               diag1
                    push              ax
                    goto_xy           POSrow + 4, POScol + 2
                    pop               ax

                    MOV               AH, 08h
                    INT               10h
                    cmp               Token, al
                    jne               diag1
                    jmp               winMiniBoard
col3                ENDP

diag1               PROC
                    push              ax
                    goto_xy           POSrow, POScol
                    pop               ax
                    ; Lê caracter que esta no cursor
                    MOV               AH, 08h
                    INT               10h

                    cmp               Token, al
                    jne               diag2
                    push              ax
                    goto_xy           POSrow + 2, POScol + 1
                    pop               ax

                    MOV               AH, 08h
                    INT               10h

                    cmp               Token, al
                    jne               diag2
                    push              ax
                    goto_xy           POSrow + 4, POScol + 2
                    pop               ax

                    MOV               AH, 08h
                    INT               10h

                    cmp               Token, al
                    jne               diag2
                    jmp               winMiniBoard
diag1               endp

diag2               PROC
                    push              ax
                    goto_xy           POSrow + 4, POScol
                    pop               ax
                    ; Lê caracter que esta no cursor
                    MOV               AH, 08h
                    INT               10h

                    cmp               Token, al
                    jne               CHECK_WIN_DONE
                    push              ax
                    goto_xy           POSrow + 2, POScol + 1
                    pop               ax

                    MOV               AH, 08h
                    INT               10h

                    cmp               Token, al
                    jne               CHECK_WIN_DONE
                    push              ax
                    goto_xy           POSrow, POScol + 2
                    pop               ax

                    MOV               AH, 08h
                    INT               10h

                    cmp               Token, al
                    jne               CHECK_WIN_DONE
                    jmp               winMiniBoard
diag2               endp
                    

winMiniBoard        PROC
                    mov               boardWin, 1
                    FILL_BOARD        POSrow, POScol
winMiniBoard        endp

CHECK_WIN_DONE      PROC
CHECK_WIN_DONE      endp

ENDM

WRITE_WINNER_BOARD  MACRO             POSx, POSy
                    LOCAL             fim, corX, prox

                    cmp               boardWin, 0
                    je                fim
                    goto_xy           POSx, POSy

                    mov               cx, 1
                    cmp               Token, 'X'
                    JE                corX
                    mov               bl, 03h
                    jmp               prox
corX:
                    mov               bl, 06h
                    jmp               prox

prox:
                    mov               ah, 09h                                                                       ; Print Token
                    mov               dl, Token
                    int               10h

fim:
ENDM

FILL_BOARD          MACRO             POSrow,POScol

                    cmp               Token, 'X'
                    JE                corX
                    mov               bl, 33h
                    jmp               next
corX:
                    mov               bl, 66h
                    jmp               next

next:
                    goto_xy           POSrow-1, POScol

                    MOV               AH, 09h
                    mov               cx,7
                    mov               al,Token
                    int               10h

                    goto_xy           POSrow-1, POScol + 1

                    MOV               AH, 09h
                    mov               cx,7
                    mov               al,Token
                    int               10h

                    goto_xy           POSrow-1, POScol + 2


                    MOV               AH, 09h
                    mov               cx,7
                    mov               al,Token
                    int               10h
                
                   
ENDM

;ROTINA PARA APAGAR ECRAN

apaga_ecran         PROC
                    mov               ax,0B800h
                    mov               es,ax
                    xor               bx,bx
                    mov               cx,25*80

apaga:              mov               byte ptr es:[bx],' '
                    mov               byte ptr es:[bx+1],7
                    inc               bx
                    inc               bx
                    loop              apaga
                    ret
apaga_ecran         endp


;########################################################################
; IMP_FICH

IMP_FICH            PROC

		;abre ficheiro
                    mov               ah,3dh
                    mov               al,0
                    lea               dx,Fich
                    int               21h
                    jc                erro_abrir
                    mov               HandleFich,ax
                    jmp               ler_ciclo

erro_abrir:
                    mov               ah,09h
                    lea               dx,Erro_Open
                    int               21h
                    jmp               sai_f

ler_ciclo:
                    mov               ah,3fh
                    mov               bx,HandleFich
                    mov               cx,1
                    lea               dx,car_fich
                    int               21h
                    jc                erro_ler
                    cmp               ax,0                                                                          ;EOF?
                    je                fecha_ficheiro
                    mov               ah,02h
                    mov               dl,car_fich
                    int               21h
                    jmp               ler_ciclo

erro_ler:
                    mov               ah,09h
                    lea               dx,Erro_Ler_Msg
                    int               21h

fecha_ficheiro:
                    mov               ah,3eh
                    mov               bx,HandleFich
                    int               21h
                    jnc               sai_f

                    mov               ah,09h
                    lea               dx,Erro_Close
                    Int               21h
sai_f:
                    RET

IMP_FICH            endp


;########################################################################
; LE UMA TECLA

LE_TECLA            PROC

                    mov               ah,08h
                    int               21h
                    mov               ah,0
                    cmp               al,0
                    jne               SAI_TECLA
                    mov               ah, 08h
                    int               21h
                    mov               ah,1
SAI_TECLA:          RET
LE_TECLA            endp



;########################################################################
; Avatar

AVATAR              PROC
                    mov               ax,0B800h
                    mov               es,ax
CICLO:
                    goto_xy           POSx,POSy                                                                     ; Vai para nova posição
                    mov               ah, 08h
                    mov               bh,0                                                                          ; numero da página
                    int               10h
                    mov               Car, al                                                                       ; Guarda o Caracter que está na posição do Cursor
                    mov               Cor, ah                                                                       ; Guarda a cor que está na posição do Cursor

                    goto_xy           POSx,POSy                                                                     ; Vai para posição do cursor



LER_SETA:
                    call              LE_TECLA
                    cmp               ah, 1
                    je                CIMA
                    CMP               al, 27                                                                        ; ESCAPE
                    JE                FIM
                    cmp               al, 0Dh                                                                       ; Check for Enter key press
                    jne               LER_SETA

    ; Check if current position contains a space character
                    mov               ah, 08h
                    int               10h
                    cmp               al, 32
                    jne               LER_SETA

                    cmp               PlayerTurn, 1                                                                 ; Check current player turn
                    je                WRITE_X            
                    jmp               WRITE_O 
                    jmp               CICLO

WRITE_O:

                    mov               cl, 1
                    mov               ah, 09h                                                                       ; Set text color for 'O'
                    mov               bl, ColorO
                    int               10h

                    mov               ah, 02h                                                                       ; Print 'O'
                    mov               dl, 'O'
                    mov               Token, 'O'
                    int               21h
                    ;CALL           GET_BOARD
                    call              CHECK_WIN_LOOP
                    CMP               boardWin, 1
                    je                fim

                    inc               PlayerTurn

                    goto_xy           40, 3
                    mov               ah, 09h  
                    lea               dx, clearString
                    int               21h
                    goto_xy           40, 1
                    mov               ah, 09h  
                    lea               dx, PlayerIndicator
                    int               21h
                    
                    goto_xy           POSx,POSy
                    jmp               LER_SETA

WRITE_X:
                    mov               cl, 1
                    mov               ah, 09h                                                                       ; Set text color for 'X'
                    mov               bl, ColorX
                    int               10h

                    mov               ah, 02h                                                                       ; Print 'X'
                    mov               dl, 'X'
                    mov               Token, 'X'
                    int               21h
                    ;CALL           GET_BOARD
                    call              CHECK_WIN_LOOP
                    CMP               boardWin, 1
                    je                fim

                    dec               PlayerTurn

                    goto_xy           40, 1
                    mov               ah, 09h  
                    lea               dx, clearString
                    int               21h
                    goto_xy           40, 3
                    mov               ah, 09h  
                    lea               dx, PlayerIndicator
                    int               21h

                    goto_xy           POSx,POSy
                    jmp               LER_SETA
	

CIMA:               cmp               al,48h
                    jne               BAIXO
                    cmp               POSy, 2
                    je                CICLO
                    dec               POSy                                                                          ;cima
                    jmp               CICLO

BAIXO:              cmp               al,50h
                    jne               ESQUERDA
                    cmp               POSy, 12
                    je                CICLO
                    inc               POSy                                                                          ;Baixo
                    jmp               CICLO

ESQUERDA:
                    cmp               al,4Bh
                    jne               DIREITA
                    cmp               POSx, 5
                    je                CICLO
                    dec               POSx
                    dec               POSx                                                                          ;Esquerda
                    jmp               CICLO

DIREITA:
                    cmp               al,4Dh
                    jne               LER_SETA
                    cmp               POSx, 25
                    je                CICLO
                    inc               POSx		
                    inc               POSx                                                                          ;Direita
                    jmp               CICLO

fim:
                    RET
AVATAR              endp


;########################################################################

;########################################################################
; Function to get player names

GET_PLAYER_NAMES    PROC
    ; Prompt for Player 1 name
                    mov               ah, 09h 
                    lea               dx, PromptMessage1
                    int               21h

                    mov               ah, 0Ah 
                    mov               dx, offset Player1Name
                    int               21h

                    call              apaga_ecran
                    goto_xy           22,10

    ; Prompt for Player 2 name
                    mov               ah, 09h  
                    lea               dx, PromptMessage2
                    int               21h

                    mov               ah, 0Ah    
                    mov               dx, offset Player2Name
                    int               21h

                    ret
GET_PLAYER_NAMES    endp

DISPLAY_PLAYER_NAMES PROC

                    goto_xy           46,1
                    mov               ah, 09h                                                                       ; Set text color for 'X'
                    mov               cl, 12
                    mov               bl, ColorX
                    int               10h
                    lea               dx, Player1Name+2
                    int               21h

                    goto_xy           46,3

                    mov               ah, 09h                                                                       ; Set text color for 'O'
                    mov               cl, 12
                    mov               bl, ColorO
                    int               10h
                    lea               dx, Player2Name+2
                    int               21h

                    goto_xy           40, 1
                    mov               ah, 09h  
                    lea               dx, PlayerIndicator
                    int               21h

                    mov               cl, 1
                    ret
DISPLAY_PLAYER_NAMES endp


;########################################################################

GET_BOARD           PROC
                    mov               ax, 2
                    mov               bx, 5
                    cmp               POSy, 4
                    jle               GET_BOARD_X
                    add               AL, 4
                    cmp               POSy, 8
                    jle               GET_BOARD_X
                    add               AL, 4
                    jmp               GET_BOARD_X

GET_BOARD_X:
                    cmp               POSx, 9
                    jle               GET_BOARD_DONE
                    add               bl, 8
                    cmp               POSx, 17
                    jle               GET_BOARD_DONE
                    add               bl, 8
                    jmp               GET_BOARD_DONE

GET_BOARD_DONE:
                    mov               POSrow, bl
                    mov               POScol, al
                    CHECK_WIN         POSx, POSy

                    ret                                                                                             ; Mover o cursor para o tabuleiro correto
GET_BOARD           endp


CHECK_WIN_LOOP      PROC
                    CHECK_WIN         5, 2
                    WRITE_WINNER_BOARD 51, 6

                    CHECK_WIN         13, 2
                    WRITE_WINNER_BOARD 53, 6

                    CHECK_WIN         21, 2
                    WRITE_WINNER_BOARD 55, 6
                    
                    CHECK_WIN         5, 6
                    WRITE_WINNER_BOARD 51, 7

                    CHECK_WIN         13, 6
                    WRITE_WINNER_BOARD 53, 7
                    
                    CHECK_WIN         21, 6
                    WRITE_WINNER_BOARD 55, 7

                    CHECK_WIN         5, 10
                    WRITE_WINNER_BOARD 51, 8

                    CHECK_WIN         13, 10
                    WRITE_WINNER_BOARD 53, 8

                    CHECK_WIN         21, 10
                    WRITE_WINNER_BOARD 55, 8

                    CHECK_WIN         51, 6
ret

CHECK_WIN_LOOP      ENDP

endGameMessage      PROC
                    call              apaga_ecran
                    
                    goto_xy           28, 10
                    mov               ah, 09h 
                    lea               dx, WinnerMessage
                    int               21h 

                    cmp               Token, 'X'
                    JE                name1
                    lea               dx, Player2Name+2
                    jmp               prox
name1:
                    lea               dx, Player1Name+2
                    jmp               prox


prox:
                    mov               ah, 09h          
                    int               21h
                    goto_xy           0,0 
                    ret
endGameMessage      endp


;########################################################################

Main                PROC
                    mov               ax, dseg
                    mov               ds,ax

                    mov               ax,0B800h
                    mov               es,ax

                    call              apaga_ecran
                    goto_xy           22,10

                    call              GET_PLAYER_NAMES
                    call              apaga_ecran
                    goto_xy           0,0



                    call              IMP_FICH
                    call              DISPLAY_PLAYER_NAMES
                    mov               PlayerTurn, 1                                                                 ; Set initial player turn to Player 1


                    call              AVATAR
                    call              endGameMessage

                    mov               ah, 4CH
                    int               21H
Main                endp
Cseg                ends
end                 Main