****************************************
* Days 3 through 5 - Flag/Wave         *
*                                      *
*  Dagen Brock <dagenbrock@gmail.com>  *
*  2014-07-05                          *
****************************************
               lst   off
               org   $2000            ; start at $2000 (all ProDOS8 system files)
               typ   $ff              ; set P8 type ($ff = "SYS") for output file
               xc    off              ; 
               xc    off
               dsk   wave.system      ; tell compiler output filename

               jsr   DL_SetDLRMode
               jsr   DrawFlag
               jsr   WaitKey

:LOOP
	jsr UpdateWave
	jsr WaveScreen
	lda   KEY
              bmi   :keyHit
	jmp :LOOP


:keyHit	sta   STROBE
              jsr   DrawCar
	jsr   WaitKey

:LOOP2
	jsr UpdateWave
	jsr WaveScreen
	lda   KEY
              bmi   :exit
	jmp :LOOP2

:exit	sta STROBE
              jmp   Quit

_colIdx	db 0
_sinIdx	db 0
_curOff	db 0
_curSin	db 0
WaveScreen	
	lda SineLUTIndex
	sta _sinIdx
	lda #0
	sta _colIdx

:waveLoop	
	ldy _sinIdx
	lda SineLUT,y	; get desired offset
	sta _curSin
	ldx _colIdx
	lda ColumnOffsets,x	; get current offset of columnt
	cmp _curSin
	beq :noChange

	SEC       ; prepare carry for SBC
	SBC _curSin   ; A-NUM
	BVC :LABEL ; if V is 0, N eor V = N, otherwise N eor V = N eor 1
	EOR #$80  ; A = A eor $80, and N = N eor 1
:LABEL
	bpl :greater


:less	inc ColumnOffsets,x
	txa
	jsr DL_ShiftColUp
	jmp :next
:greater	dec ColumnOffsets,x
	txa
	jsr DL_ShiftColDown

:next
:noChange	
	inc _sinIdx
	lda _sinIdx
	cmp #SineLUTLen
	bne :next2
	lda #0
	sta _sinIdx
:next2	inc _colIdx
	lda _colIdx
	cmp #80
	bne :waveLoop
	rts



UpdateWave	lda SineLUTIndex
	bne :notZero
	lda #SineLUTLen-1
	sta SineLUTIndex
	jmp :done
:notZero	dec SineLUTIndex

:done	rts




ColumnOffsets	ds 80
SineLUTIndex	db 0
SineLUT	hex 00,FF,FE,FE,FD,FD,FD,FE,FE,FF,00,01,02,02,03,03,03,02,02,01
SineLUTLen	equ *-SineLUT

_maskPixel	db 0





DL_SplatUp	MAC
	lda ]2,y	; First we merge the top pixel (low nibble) in lower byte
	asl	; with the byte above, moving it into
	asl	; the bottom pixel location (high nibble)
	asl
	asl	; shift left because DLR :P
	ora ]1,y	; previous pixel data should already be masked %00001111
	sta ]1,y	; merged

	lda ]2,y	; Second, we move the bottom pixel of the lower byte
	lsr	; into the top pixel (low nibble) location
	lsr
	lsr
	lsr
	sta ]2,y	;shift right because DLR :P
	EOM

DL_ShiftColUp 
	clc
	ror	; side effect is divide by 2, which we want
	bcc :even
:odd	sta TXTPAGE1
	jmp :shift
:even	sta TXTPAGE2
:shift	tay	; our index is now /2 which we need for DLR interlacing		

	lda Lo01,y
	lsr
	lsr
	lsr
	lsr	; shift right because DLR :P
	sta Lo01,y
	DL_SplatUp Lo01;Lo02
	DL_SplatUp Lo02;Lo03
	DL_SplatUp Lo03;Lo04
	DL_SplatUp Lo04;Lo05
	DL_SplatUp Lo05;Lo06
	DL_SplatUp Lo06;Lo07
	DL_SplatUp Lo07;Lo08
	DL_SplatUp Lo08;Lo09
	DL_SplatUp Lo09;Lo10
	DL_SplatUp Lo10;Lo11
	DL_SplatUp Lo11;Lo12
	DL_SplatUp Lo12;Lo13
	DL_SplatUp Lo13;Lo14
	DL_SplatUp Lo14;Lo15
	DL_SplatUp Lo15;Lo16
	DL_SplatUp Lo16;Lo17
	DL_SplatUp Lo17;Lo18
	DL_SplatUp Lo18;Lo19
	DL_SplatUp Lo19;Lo20
	DL_SplatUp Lo20;Lo21
	DL_SplatUp Lo21;Lo22
	DL_SplatUp Lo22;Lo23
	DL_SplatUp Lo23;Lo24
	lda Lo24,y
	asl
	asl
	asl
	asl
	ora Lo24,y
	sta Lo24,y	; copy pixel back down (high nibble) and ora it to stretch last pixel
	rts
	

DL_SplatDown	MAC
	lda ]2,y	; First we merge the top pixel (low nibble) in lower byte
	lsr	; with the byte above, moving it into
	lsr	; the bottom pixel location (high nibble)
	lsr
	lsr	; shift left because DLR :P
	ora ]1,y	; previous pixel data should already be masked %00001111
	sta ]1,y	; merged

	lda ]2,y	; Second, we move the bottom pixel of the lower byte
	asl	; into the top pixel (low nibble) location
	asl
	asl
	asl
	sta ]2,y	;shift right because DLR :P
	EOM

DL_ShiftColDown 
	clc
	ror	; side effect is divide by 2, which we want
	bcc :even
:odd	sta TXTPAGE1
	jmp :shift
:even	sta TXTPAGE2
:shift	tay	; our index is now /2 which we need for DLR interlacing		

	lda Lo24,y
	asl
	asl
	asl
	asl	; shift left because DLR :P
	sta Lo24,y	; now is masked on top pixel (low nibble)
	DL_SplatDown Lo24;Lo23
	DL_SplatDown Lo23;Lo22
	DL_SplatDown Lo22;Lo21
	DL_SplatDown Lo21;Lo20
	DL_SplatDown Lo20;Lo19
	DL_SplatDown Lo19;Lo18
	DL_SplatDown Lo18;Lo17
	DL_SplatDown Lo17;Lo16
	DL_SplatDown Lo16;Lo15
	DL_SplatDown Lo15;Lo14
	DL_SplatDown Lo14;Lo13
	DL_SplatDown Lo13;Lo12
	DL_SplatDown Lo12;Lo11
	DL_SplatDown Lo11;Lo10
	DL_SplatDown Lo10;Lo09
	DL_SplatDown Lo09;Lo08
	DL_SplatDown Lo08;Lo07
	DL_SplatDown Lo07;Lo06
	DL_SplatDown Lo06;Lo05
	DL_SplatDown Lo05;Lo04
	DL_SplatDown Lo04;Lo03
	DL_SplatDown Lo03;Lo02
	DL_SplatDown Lo02;Lo01
	lda Lo01,y
	lsr
	lsr
	lsr
	lsr
	ora Lo01,y
	sta Lo01,y	; copy pixel back down (high nibble) and ora it to stretch last pixel
	rts

DrawFlag       lda   #0
               sta   _line
               lda   #<FLAGPIXEL
               sta   $2
               lda   #>FLAGPIXEL
	 sta   $3
	 jmp DrawStripeImage

DrawCar        lda   #0
               sta   _line
               lda   #<carPIXEL
               sta   $2
               lda   #>carPIXEL
	 sta   $3
	 jmp DrawStripeImage

DrawStripeImage
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
:w

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

	use flag
