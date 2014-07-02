****************************************
* Day 1                                *
*                                      *
*  Dagen Brock <dagenbrock@gmail.com>  *
*  2014-07-01                          *
****************************************
               lst   off
               org   $2000            ; start at $2000 (all ProDOS8 system files)
               typ   $ff              ; set P8 type ($ff = "SYS") for output file
               xc    off              ; 
               xc    off
               dsk   day1.system      ; tell compiler output filename

               jsr   DL_SetDLRMode
               jsr   DrawLogo

               jsr   WaitKey
               jmp   Quit

DrawLogo       lda   #0
               sta   _line
               lda   #<RCLOGOPIXEL
               sta   $2
               lda   #>RCLOGOPIXEL
               sta   $3
:line
               lda   _line
               cmp   #24
               bcs   :done
               asl                    ;*2
               tay
               lda   LoLineTable,y
               sta   $0
               lda   LoLineTable+1,y
               sta   $1
               sta   TXTPAGE2
               ldy   #39
:auxLoop       lda   ($02),y
               sta   ($00),y
               dey
               bpl   :auxLoop

               lda   $2
               clc
               adc   #40              ;add "line" to pixel pointer
               sta   $2
               bcc   :nocarry1
               inc   $3
:nocarry1


               sta   TXTPAGE1
               ldy   #39
:mainLoop      lda   ($02),y
               sta   ($00),y
               dey
               bpl   :mainLoop
               lda   $2
               clc
               adc   #40              ;add "line" to pixel pointer
               sta   $2
               bcc   :nocarry
               inc   $3
:nocarry       inc   _line
               bpl   :line



:done          rts

_line          db    0

WaitKey
:kloop         lda   KEY
               bpl   :kloop
               sta   STROBE
               rts
Quit
               sta   TXTPAGE1         ; Don't forget to give them back the right page!
P8Quit
               jsr   MLI              ; first actual command, call ProDOS vector
               dfb   $65              ; QUIT P8 request ($65)
               da    QuitParm
               bcs   Error
               brk   $00              ; shouldn't ever  here!
Error          brk   $00              ; shouldn't be here either

QuitParm       dfb   4                ; number of parameters
               dfb   0                ; standard quit type
               da    $0000            ; not needed when using standard quit
               dfb   0                ; not used
               da    $0000            ; not used


DL_SetDLRMode  lda   LORES            ;set lores
               lda   SETAN3           ;enables DLR
               sta   SET80VID

               sta   C80STOREON       ; enable aux/page1,2 mapping
               sta   MIXCLR           ;make sure graphics-only mode
               rts

**************************************************
* Lores/Text lines
**************************************************
Lo01           equ   $400
Lo02           equ   $480
Lo03           equ   $500
Lo04           equ   $580
Lo05           equ   $600
Lo06           equ   $680
Lo07           equ   $700
Lo08           equ   $780
Lo09           equ   $428
Lo10           equ   $4a8
Lo11           equ   $528
Lo12           equ   $5a8
Lo13           equ   $628
Lo14           equ   $6a8
Lo15           equ   $728
Lo16           equ   $7a8
Lo17           equ   $450
Lo18           equ   $4d0
Lo19           equ   $550
Lo20           equ   $5d0
* the "plus four" lines
Lo21           equ   $650
Lo22           equ   $6d0
Lo23           equ   $750
Lo24           equ   $7d0

LoLineTable    da    Lo01,Lo02,Lo03,Lo04,Lo05,Lo06
               da    Lo07,Lo08,Lo09,Lo10,Lo11,Lo12
               da    Lo13,Lo14,Lo15,Lo16,Lo17,Lo18
               da    Lo19,Lo20,Lo21,Lo22,Lo23,Lo24

**************************************************
* Apple Standard Memory Locations
**************************************************
CLRLORES       equ   $F832
LORES          equ   $C050
TXTSET         equ   $C051
MIXCLR         equ   $C052
MIXSET         equ   $C053
TXTPAGE1       equ   $C054
TXTPAGE2       equ   $C055
KEY            equ   $C000
C80STOREOFF    equ   $C000
C80STOREON     equ   $C001
STROBE         equ   $C010
SPEAKER        equ   $C030
SETAN3         equ   $C05E            ;Set annunciator-3 output to 0
SET80VID       equ   $C00D            ;enable 80-column display mode (WR-only)
* P8 Entry Point
MLI            equ   $bf00


***** EVEN then ODD, i.e. AUX then MAIN
RCLOGOPIXEL
               hex   EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE
               hex   EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE
               hex   DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD
               hex   DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD
               hex   EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE
               hex   EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE
               hex   DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD
               hex   DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD
               hex   EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE
               hex   EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE,EE
               hex   DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD
               hex   DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD,DD
               hex   EE,EE,EC,EE,EE,EC,EE,EE,EC,EE,EE,EC,EE,EE,EC,EE,EE,EC,EE,EE
               hex   EC,EE,EE,EC,EE,EE,EC,EE,EE,EC,EE,EE,EC,EE,EE,EC,EE,EE,EC,CE
               hex   9D,9D,DD,D9,9D,DD,D9,9D,DD,D9,9D,DD,D9,9D,DD,D9,9D,DD,D9,9D
               hex   DD,D9,9D,DD,D9,9D,DD,D9,9D,DD,D9,9D,DD,D9,9D,DD,D9,9D,DD,DD
               hex   EE,EE,EE,CE,EE,EE,CE,EE,EE,CE,EE,EE,CE,EE,EE,CE,EE,EE,CE,EE
               hex   EE,CE,EE,EE,CE,EE,EE,CE,EE,EE,CE,EE,EE,CE,EE,EE,CE,EE,EC,CE,9D
               hex   9D,D9,D9,9D,D9,D9,9D,D9,D9,9D,D9,D9,9D,D9,D9,9D,D9,D9,9D,D9,D9
               hex   9D,D9,D9,9D,D9,D9,9D,D9,D9,9D,D9,D9,9D,D9,D9,9D,DD,DD
               hex   CE,CE,CE,CE,CE,CE,CE,CE,CE,CE,CE,CE,CE,CE,CE,CE,CE,CE,CE,CE
               hex   CE,CE,CE,CE,CE,CE,CE,CE,CE,CE,CE,CE,CE,CE,CE,CE,CE,CE,CE,CE,D9
               hex   D9,D9,D9,D9,D9,D9,D9,D9,D9,D9,D9,D9,D9,D9,D9,D9,D9,D9,D9,D9,D9
               hex   D9,D9,D9,D9,D9,D9,D9,D9,D9,D9,D9,D9,D9,D9,D9,D9,D9,D9
               hex   CE,CE,CE,CE,CE,CE,CE,CE,CE,CE,FE,FE,FE,CE,DE,FE,DE,FE,FE,DE
               hex   DE,FE,DE,CE,DE,FE,CE,CE,CE,FE,DE,CE,CE,CE,CE,CE,CE,CE,CE,CE,99
               hex   99,99,99,99,99,99,99,99,B9,F9,F9,B9,99,F9,F9,B9,F9,F9,99,F9,F9
               hex   99,99,F9,B9,99,99,B9,F9,99,99,99,99,99,99,99,99,99,D9
               hex   CC,CC,CC,CC,CC,CC,CC,CC,CC,CC,00,00,00,FD,0F,00,FF,00,00,0F
               hex   FF,00,0F,DC,FF,00,CC,CC,FD,00,FF,CC,CC,CC,CC,CC,CC,CC,CC,CC,9D
               hex   9D,9D,9D,9D,9D,9D,9D,9D,FF,00,00,0F,FF,00,00,FF,00,00,FF,00,00
               hex   FF,BD,00,FF,9D,BD,0F,00,9D,9D,9D,9D,9D,9D,9D,9D,9D,99
               hex   CC,CC,CC,CC,CC,CC,CC,CC,CC,CC,00,FF,00,FF,00,DF,CD,CF,FF,00
               hex   00,FF,00,FF,F0,00,CC,FD,F0,00,FF,CC,CC,CC,CC,CC,CC,CC,CC,CC,9D
               hex   99,9D,99,9D,99,9D,99,9D,FF,00,FF,00,00,F0,9F,9F,BF,00,FF,00,FF
               hex   00,BF,00,FF,BD,0F,FF,00,9D,99,9D,99,9D,99,9D,99,9D,99
               hex   CC,CC,CC,CC,CC,CC,CC,CC,CC,CC,00,00,00,FF,00,DC,CC,FD,00,DF
               hex   00,FF,00,FF,FF,00,CC,00,0F,00,0F,CC,CC,CC,CC,CC,CC,CC,CC,CC,99
               hex   99,99,99,99,99,99,99,99,FF,00,00,FF,00,FF,99,B9,0F,F0,FF,00,FF
               hex   00,99,00,FF,FF,0F,0F,00,FB,99,99,99,99,99,99,99,99,99
               hex   CC,CC,CC,CC,CC,CC,CC,CC,CC,CC,00,FF,00,FF,00,0F,FD,00,0F,0F
               hex   F0,0F,00,DF,FF,00,CC,F0,F0,00,F0,CC,CC,CC,CC,CC,CC,CC,CC,CC,99
               hex   99,99,99,99,99,99,99,99,FF,00,F0,00,F0,00,0F,FF,00,0F,FF,00,0F
               hex   F0,99,00,FF,BF,F0,F0,00,BF,99,99,99,99,99,99,99,99,99
               hex   CC,CC,CC,CC,CC,CC,CC,CC,CC,CC,F0,FF,F0,FF,DF,F0,FF,F0,F0,F0
               hex   FF,F0,DF,FC,FF,F0,FC,FC,FC,F0,DF,CC,CC,CC,CC,CC,CC,CC,CC,CC,99
               hex   99,99,99,99,99,99,99,99,BF,F0,BF,F0,BB,F0,F0,FF,F0,F0,BF,F0,F0
               hex   FB,B9,F0,FF,B9,F9,FF,F0,99,99,99,99,99,99,99,99,99,99
               hex   BB,BB,BB,BB,BB,BB,BB,BB,BB,FF,00,00,FF,00,FF,00,00,0F,0F,00
               hex   00,0F,0F,00,00,00,00,00,00,00,FF,BB,BB,BB,BB,BB,BB,BB,BB,BB,77
               hex   77,77,77,77,77,77,77,77,0F,00,FF,00,FF,00,FF,00,FF,00,FF,00,FF
               hex   00,FF,00,00,FF,00,00,0F,77,77,77,77,77,77,77,77,77,77
               hex   BB,BB,BB,BB,BB,BB,BB,BB,BB,FF,00,FF,FF,00,FF,00,00,00,00,00
               hex   00,00,00,00,00,0F,0F,00,FF,00,FF,BB,BB,BB,BB,BB,BB,BB,BB,BB,77
               hex   77,77,77,77,77,77,77,77,00,0F,FF,00,FF,00,FF,00,0F,00,FF,00,0F
               hex   00,FF,00,0F,FF,00,FF,00,77,77,77,77,77,77,77,77,77,77
               hex   BB,BB,BB,BB,BB,BB,BB,BB,BB,BF,F0,00,FF,00,FF,00,00,F0,F0,00
               hex   00,F0,F0,00,00,F0,F0,00,00,00,5F,BB,BB,BB,BB,BB,BB,BB,BB,BB,77
               hex   77,77,77,77,77,77,77,77,AF,F0,00,00,FF,00,FF,00,00,00,FF,00,00
               hex   00,FF,00,F0,FF,00,00,FF,77,77,77,77,77,77,77,77,77,77
               hex   BB,BB,BB,BB,BB,BB,BB,BB,BB,FF,0F,00,FF,00,0F,00,00,FF,FF,00
               hex   00,FF,FF,00,00,0F,0F,00,FF,00,FF,BB,BB,BB,BB,BB,BB,BB,BB,BB,77
               hex   77,77,77,77,77,77,77,77,0F,0F,00,00,0F,00,FF,00,F0,00,FF,00,F0
               hex   00,FF,00,0F,FF,00,F0,00,77,77,77,77,77,77,77,77,77,77
               hex   BB,BB,B3,3B,B3,3B,B3,3B,B3,BF,F0,F0,BB,F0,F0,BF,F0,BF,FF,F0
               hex   F0,BF,FF,F0,F0,F0,F0,F0,FF,F0,FF,3B,B3,3B,B3,3B,B3,3B,B3,3B,67
               hex   77,77,77,77,77,77,77,77,F0,F0,FF,FF,F0,F0,FF,F0,77,F0,FF,F0,77
               hex   F0,FF,F0,F0,FF,F0,AF,F0,77,77,77,77,77,77,77,77,77,77
               hex   BB,B3,B3,3B,B3,3B,B3,3B,B3,3B,B3,3B,B3,3B,B3,3B,B3,3B,B3,3B
               hex   B3,3B,B3,3B,B3,3B,B3,3B,B3,3B,B3,3B,B3,3B,B3,3B,B3,3B,B3,3B,67
               hex   77,77,77,77,77,77,77,77,77,77,77,77,77,77,77,77,77,77,77,77,77
               hex   77,77,77,77,77,77,77,77,77,77,77,77,77,77,77,77,77,77
               hex   3B,33,33,3B,3B,3B,33,3B,3B,3B,33,3B,3B,3B,33,3B,3B,3B,33,3B
               hex   3B,3B,33,3B,3B,3B,33,3B,3B,3B,33,3B,3B,3B,33,3B,3B,3B,33,B3,77
               hex   77,77,76,76,77,77,76,76,77,77,76,76,77,77,76,76,77,77,76,76,77
               hex   77,76,76,77,77,76,76,77,77,76,76,77,77,76,76,77,77,67
               hex   B3,B3,B3,B3,B3,B3,B3,B3,B3,B3,B3,B3,B3,B3,B3,B3,B3,B3,B3,B3
               hex   B3,B3,B3,B3,B3,B3,B3,B3,B3,B3,B3,B3,B3,B3,B3,B3,B3,B3,B3,B3,67
               hex   67,67,67,67,67,67,67,67,67,67,67,67,67,67,67,67,67,67,67,67,67
               hex   67,67,67,67,67,67,67,67,67,67,67,67,67,67,67,67,67,67
               hex   33,33,B3,33,33,B3,33,33,B3,33,33,33,33,B3,33,33,33,33,B3,33
               hex   33,B3,33,33,B3,33,33,B3,33,33,33,33,B3,33,33,33,33,B3,33,B3,77
               hex   67,67,77,67,67,77,67,67,77,67,77,67,67,77,67,77,67,67,77,67,67
               hex   77,67,67,77,67,67,77,67,77,67,67,77,67,77,67,67,67,67
               hex   33,3B,B3,33,3B,B3,33,3B,B3,33,33,33,3B,B3,33,33,33,3B,B3,33
               hex   3B,B3,33,3B,B3,33,3B,B3,33,33,33,3B,B3,33,33,33,3B,B3,3B,B3,76
               hex   66,67,76,66,67,76,66,67,76,67,76,66,67,76,67,76,66,67,76,66,67
               hex   76,66,67,76,66,67,76,67,76,66,67,76,67,76,66,66,66,66
               hex   33,33,33,33,33,33,33,33,33,33,33,33,33,33,33,33,33,33,33,33
               hex   33,33,33,33,33,33,33,33,33,33,33,33,33,33,33,33,3B,B3,3B,B3,76
               hex   66,67,76,66,67,76,66,67,76,67,76,66,67,76,67,76,66,67,76,66,67
               hex   76,66,67,76,66,67,76,67,76,66,67,76,67,66,66,66,66,66
               hex   33,33,3B,33,33,3B,33,33,3B,33,33,33,33,3B,33,33,33,33,3B,33
               hex   33,3B,33,33,3B,33,33,3B,33,33,33,33,3B,33,33,33,33,33,B3,33,66
               hex   66,66,66,66,66,66,66,66,66,76,66,66,66,66,76,66,66,66,66,66,66
               hex   66,66,66,66,66,66,66,76,66,66,66,66,76,67,66,66,66,66










