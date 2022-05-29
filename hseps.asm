INCLUDE         C:\LENGUAJE\ASM'S\CONV.INC
CODE_SEG_A      SEGMENT
                ASSUME  CS:CODE_SEG_A, DS:CODE_SEG_A
                ORG     100h
  
PRINCIPIO:
                CALL    PRESENT                 ;
                CALL    L_COMANDO               ;
                CMP     PARAMETROS,1            ;
                JE      PROC_NOM                ;
                MOV     DX,OFFSET SIN_PARAMETRO ;
                CALL    IMP                     ;
                JMP     TERMINA                 ;
PROC_NOM:
                CALL    ARMA_AUX                ;
PREPARA:
                MOV     SI,OFFSET ARCHIN        ;
                MOV     DI,OFFSET NOMBRE1       ;
PREP_0:
                LODSB                           ;
                CMP     AL,'.'                  ;
                JE      PREP_1                  ;
                CMP     AL,0                    ;
                JE      ABRE                    ;
                JMP     PREP_2                  ;
PREP_1:
                MOV     AL,'_'                  ;
PREP_2:
                STOSB                           ;
                JMP     PREP_0                  ;
ABRE:
                MOV     AH,3DH                  ; ABRE EL ARCHIVO
                MOV     AL,0                    ;
                MOV     DX,OFFSET ARCHIN        ; DE ENTRADA
                INT     21H                     ;
                JNC     COPIAHAND               ; NO HUBO ERROR
                MOV     DH,3                    ; UBICA EL CURSOR
                MOV     DL,0                    ;
                CALL    CURPOS                  ;
                MOV     DX,OFFSET ERROR         ; SI HUBO ERROR
                CALL    IMP                     ;
                MOV     DX,OFFSET ARCHIN        ;
                CALL    IMP                     ;
                MOV     DX,OFFSET NADA          ;
                CALL    IMP                     ;
                JMP     TERMINA                 ; FIN !
COPIAHAND:
                MOV     HANDLE1,AX              ; GUARGA EL HANDLE
LEE:
                MOV     AH,3FH                  ; LEER BYTES
                MOV     CX,22                   ; EN CX CUANTOS
                MOV     DX,OFFSET CARACTER      ; BUFFER PARA PONERLO
                MOV     BX,HANDLE1              ; HANDLE DEL ARCHIVO
                INT     21H                     ;
                CMP     AX,0                    ;
                JNE     PROCESA                 ;
                JMP     CIERRA                  ;
PROCESA:
                MOV     SI,OFFSET CARACTER      ;
		ADD	SI,20			;
                MOV     DI,OFFSET CARACTER1     ;
PROCESA_1:
                LODSW                           ;
		sub	  ax,2B8h		;
                BIN_A_HEX AX,ROTULO             ;
		MOV	  DX,OFFSET PAR		;
		CALL	  IMP			;
CIERRA:
                MOV     AH,3EH                  ; CIERRA ARCHIVO
                MOV     BX,HANDLE1              ; DE ENTRADA
                INT     21H                     ;
TERMINA:
                MOV     AX,4C00H                ; FIN !!!
                INT     21H                     ;
;***********************************************;*******************
PRESENT:
                CALL    BORRAPAN                ;
                MOV     DX,OFFSET NOMBRE        ;
                CALL    IMP                     ;
                CALL    COPYRIGHT               ;
                RET                             ;
;***********************************************;
COPYRIGHT:
                MOV     AH,13H                  ; PONE PANTALLA ANSI
                MOV     AL,3                    ;
                MOV     CX,23                   ;
                MOV     DL,0                    ;
                MOV     DH,2                    ;
                MOV     BP,OFFSET AVENGER       ;
                INT     10H                     ;
                MOV     DX,OFFSET BAJA          ;
                CALL    IMP                     ;
                RET                             ;
;***********************************************;
ARMA_AUX:
                MOV     SI,OFFSET BUF_LCOM      ; EL ORIGEN AL BUFFER
                MOV     DI,OFFSET ARCHIN        ; DESTINO AL NOMBRE
                MOV     CX,CONTENIDO            ;
                REP     MOVSB                   ; COPIA
ARCHAUX:
                MOV     SI,OFFSET ARCHIN        ; PREPARA PARA COPIAR
                MOV     DI,OFFSET ARCHOUT       ; AL NOMBRE DE ARCHIVO
                MOV     CX,CONTENIDO            ;
ARCHAUX1:
                MOV     AL,[SI]                 ; COPIA DE A UN CARACTER
                CMP     AL,'.'                  ; HASTA QUE ENCUENTRA
                JE      ARCHAUX2                ; UN PUNTO
                MOV     [DI],AL                 ;
                INC     SI                      ;
                INC     DI                      ;
                LOOP    ARCHAUX1                ;
ARCHAUX2:
                MOV     CX,4                    ; LE COPIA LA EXTENSION
                MOV     SI,OFFSET EXT           ; NUEVA DEL ARCHIVO DE
                REP     MOVSB                   ; SALIDA
                RET                             ;
;***********************************************;
BORRAPAN:
                MOV     AH,0FH                  ; RUTINA QUE BORRA
                INT     10H                     ; LA PANTALLA
                MOV     AH,0                    ;
                INT     10H                     ;
                RET                             ;
;***********************************************;
IMP:
                MOV     AH,9                    ; RUTINA DE IMPRESION
                INT     21H                     ;
                RET                             ;
;***********************************************;
CURSOF:
                MOV     AH,01                   ; SACA EL CURSOR
                MOV     CH,20H                  ;
                INT     10H                     ;
                RET                             ;
;***********************************************;
CURSON:
                MOV     AH,01                   ; PONE EL CURSOR
                MOV     CH,0CH                  ;
                MOV     CL,0DH                  ;
                INT     10H                     ;
                RET                             ;
;***********************************************;
CURPOS:
                MOV     AH,2                    ; PONE CURSOR EN UNA
                INT     10H                     ; DETERMINADA POSISION
                RET                             ; DE LA PANTALLA
;***********************************************;
L_COMANDO:
                MOV     PARAMETROS,0            ;
                MOV     AH,62H                  ; OBTIENE EL SEGMENTO DEL PSP
                INT     21H                     ;
                PUSH    DS                      ;
                MOV     DS,BX                   ;
                MOV     SI,80H                  ; LARGO DEL PARAMETRO
                LODSB                           ; STRING [SI] TO AL
                XOR     CX,CX                   ; PONE A CX EN 0
                MOV     CL,AL                   ; EN CX LARGO DEL PARAMETRO
                CMP     CX,0                    ;
                JE      L_COMANDO_RET           ; SIN PARAMETROS
                MOV     CONTENIDO,CX            ;
                MOV     BX,CX                   ;
                MOV     BYTE PTR [BX+SI],0      ;
                MOV     SI,82H                  ; DESPUES DEL ESPACIO
                MOV     DI,OFFSET BUF_LCOM      ;
                REP     MOVSB                   ;
L_COMANDO1:
                MOV     ES:PARAMETROS,1         ;
L_COMANDO_RET:
                POP     DS                      ;
                RET                             ;
;***********************************************;********************
HANDLE1         DW      0
CONTENIDO       DW      0
PARAMETROS      DB      0
ARCHIN          DB      13 DUP (0)
                DB      13,10,13,10,'$'
ARCHOUT         DB      13 DUP (0),'$'
EXT             DB      '.TA!'
ERROR           DB      13,10,13,10
                DB      'Error no existe el Archivo ===> $'
TRABAJANDO      DB      13,10,13,10
                DB      'Se esta procesando el Archivo: $'
NADA            DB      7,13,10,13,10,'$'
CARACTER        DB      22 DUP(0)
NOMBRE1         DB      '                DB      '
CARACTER1       DB      48 DUP(0)
PAR		DB	'The Jump To Unpacked Image is Located at: '
ROTULO          DB      0,0,0,0
Tito		DB	13,10,13,10,'$'
SIN_PARAMETRO   DB      13,10,13,10
                DB      'ERROR, no se especific¢ el nombre del Archivo .....'
		DB	13,10
		DB	"Syntax   'HSEPS File.EXE'"
                DB      7,13,10,13,10,'$'
BUF_LCOM        DB      30 DUP(0)
BAJA            DB      13,10,13,10,13,10,'$'
NOMBRE          DB      13,10,'HS 1.18b70 Entry Point Searcher',13,10,'$'
AVENGER         DB      '(',14,'c',14,')',14,' ',7
                DB      '1',14,'9',14,'9',14,'8',14,' ',7,'b',14,'y',14,' ',7
                DB      'T',11,'H',11,'E',11,' ',7
                DB      'A',11,'V',11,'E',11,'N',11,'G',11,'E',11,'R',11

CODE_SEG_A      ENDS
                END     PRINCIPIO
