.include "def.inc"
.globl  FlushUpdatePalette
.globl	Append32PaletteToTail
.globl	LoadAnimationAndPal
.globl	PalGradObjInitRoutine
.globl	LoadPalBlockEntries

FlushUpdatePalette:                     
      
        lea     A5Seg.PaletteTempQueueStart(a5), a0 | 10c022
        move.w  (a0)+, d0
        bmi.s   _flush_end                | 为负数则转移

_flush_loop:                                  | CODE XREF: FlushUpdatePalette+46j
        lea     (0x400000).l, a1        | Palette base
        lsl.w   #5, d0                  | times 32
        adda.w  d0, a1                  | 注意 $402000 之后是镜像, 向这里写入 entry 是跟向 $400000 部分写入没区别
        clr.w   (a1)+
        move.w  (a0)+, (a1)+
        move.l  (a0)+, (a1)+
        move.l  (a0)+, (a1)+
        move.l  (a0)+, (a1)+
        move.l  (a0)+, (a1)+
        move.l  (a0)+, (a1)+
        move.l  (a0)+, (a1)+
        move.l  (a0)+, (a1)+
        move.w  (a0)+, d0
        bpl.s   _flush_loop                   | Palette base

_flush_end:                               
        move.l  #PaletteTempQueueStart, A5Seg.PAL_IN_POINT(a5)
        move.w  #0xFFFF, A5Seg.PaletteTempQueueStart(a5)
        rts
| End of function FlushUpdatePalette


| params:
|     d0: sub group index, (0x20 pals per group)

Append32PaletteToTail:                  
                                        
        lea     (PAL_START).l, a0        | Palette Rom Start
        andi.w  #0xFF, d0
        swap    d0
        lsr.l   #6, d0
        adda.l  d0, a0
        movea.l A5Seg.PAL_IN_POINT(a5), a1
        move.w  #0x1F, d0               | 0x20 个 Palette

_pal_append:                               
        move.l  (a0)+, (a1)+
        move.l  (a0)+, (a1)+
        move.l  (a0)+, (a1)+
        move.l  (a0)+, (a1)+
        move.l  (a0)+, (a1)+
        move.l  (a0)+, (a1)+
        move.l  (a0)+, (a1)+
        move.l  (a0)+, (a1)+
        dbf     d0, _pal_append
        move.w  #0xFFFF, (a1)
        move.l  a1, A5Seg.PAL_IN_POINT(a5)
        rts
| End of function Append32PaletteToTail


| params:
|     d0: index

LoadAnimationAndPal:                    
                                        
        lsl.w   #3, d0
        lea     AUTO_ANIMATION_TABLE, a0
        adda.w  d0, a0
        move.w  (a0)+, d1
        move.w  (a0)+, d2
        move.w  (a0)+, d3
        subq.w  #1, d3
        move.w  (a0), (0x3C0006).l      | set animation speed
        bra.w   LoadPalBlockEntries          | params:
| End of function LoadAnimationAndPal   |     d1: pal entry index
                                        |     d2: des index
                                        |     d3: entry nums - 1

AUTO_ANIMATION_TABLE:
		.word 0x50						| pal entry index
        .word 0x50                      | des index
        .word 0x40                      | entry nums
        .word 0x800                     | enimation speed
        .word 0x1050
        .word 0x50
        .word 0x40
        .word 0x800
        .word 0x1090
        .word 0x50
        .word 0x40
        .word 0x800
        .word 0x10D0
        .word 0x50
        .word 0x40
        .word 0x800
        .word 0x1110
        .word 0x50
        .word 0x40
        .word 0x800
        .word 0x1150
        .word 0x50
        .word 0x60
        .word 0x800
        .word 0x11B0
        .word 0x90
        .word 0x60
        .word 0x800
        .word 0x1210
        .word 0x50
        .word 0x40
        .word 0x800
        .word 0x1270				|8 for title
        .word 0x90
        .word 0x60
        .word 0x800
        .word 0x10
        .word 0x10
        .word 0x40
        .word 0x800

| params:
|     d1: pal entry index
|     d2: des index
|     d3: entry nums - 1

LoadPalBlockEntries:                                                                 
        movea.l A5Seg.PAL_IN_POINT(a5), a2
        moveq   #0, d0
        move.w  d1, d0
        lea     (PAL_START).l, a3
        lsl.l   #5, d0
        adda.l  d0, a3
LoadPalBlockEntries_loop:                               
        andi.w  #0xFF, d2
        move.w  d2, (a2)+
        addq.w  #1, d2
        addq.l  #2, a3
        move.w  (a3)+, (a2)+
        move.l  (a3)+, (a2)+
        move.l  (a3)+, (a2)+
        move.l  (a3)+, (a2)+
        move.l  (a3)+, (a2)+
        move.l  (a3)+, (a2)+
        move.l  (a3)+, (a2)+
        move.l  (a3)+, (a2)+
        dbf     d3, LoadPalBlockEntries_loop
        bra.w   LoadPalEntries_end
| End of function LoadPalEntries

| params:
|     a0: prt to: pal index, des index, ..., 0xFFFF

LoadPalEntries:                         
                                        
        movea.l A5Seg.PAL_IN_POINT(a5), a2

_LoadPalEntries_loop:                                 
        moveq   #0, d0
        move.w  (a0)+, d0
        bmi.s   LoadPalEntries_end
        move.w  (a0)+, (a2)
        andi.w  #0xFF, (a2)+
        lea     (PAL_START).l, a1
        lsl.l   #5, d0
        adda.l  d0, a1
        addq.l  #2, a1
        move.w  (a1)+, (a2)+
        move.l  (a1)+, (a2)+
        move.l  (a1)+, (a2)+
        move.l  (a1)+, (a2)+
        move.l  (a1)+, (a2)+
        move.l  (a1)+, (a2)+
        move.l  (a1)+, (a2)+
        move.l  (a1)+, (a2)+
        bra.s   _LoadPalEntries_loop
| End of function LoadPalEntries

LoadPalEntries_end:                                                             
        move.w  #0xFFFF, (a2)
        move.l  a2, A5Seg.PAL_IN_POINT(a5)
        rts



InitPalGradObj:                         
        movea.l PalGradObj.pEntryIndex1(a4), a0
        movea.l PalGradObj.pEntryIndex2(a4), a1
        lea     PalGradObj.RGBbuf1(a4), a2 | target index, then B,G,R ...
        lea     PalGradObj.RGBbuf2(a4), a3 | index in P2 rom, then B,G,R ...

_InitPalGradObj_loopLoad:                              
        tst.w   (a0)
        bmi.w   _InitPalGradObj_end
        lea     (0x2CFFF0).l, a6        | PAL_START
        moveq   #0, d0
        move.w  (a0)+, d0
        lsl.l   #5, d0                  | * 32
        adda.l  d0, a6                  | d6: pEntry
        addq.l  #2, a6
        move.w  (a0)+, (a2)
        move.l  a6, A5Seg.pPalGradEntry1(a5)
        lea     (0x2CFFF0).l, a6
        moveq   #0, d0
        move.w  (a1)+, d0
        lsl.l   #5, d0
        adda.l  d0, a6
        move.w  (a6)+, (a3)
        move.l  a6, A5Seg.pPalGradEntry2(a5)
        addq.l  #3, a2
        addq.l  #3, a3
        moveq   #0xE, d6                | loop 0xf times for 15 color vals in a pal entry

_InitPalGradObj_loadOne:                               | CODE XREF: InitPalGradObj+72j
        movea.l A5Seg.pPalGradEntry1(a5), a6
        move.b  (a6), d4
        move.w  (a6)+, d3
        move.l  a6, A5Seg.pPalGradEntry1(a5)
        bsr.w   PalEntryToRGB           | params:
                                        |     d4: entry.high
                                        |     d3: entry.low
                                        | ret:
                                        |     d4: R
                                        |     d3: G
                                        |     d2: B
        move.b  d2, (a2)+
        move.b  d3, (a2)+
        move.b  d4, (a2)+
        movea.l A5Seg.pPalGradEntry2(a5), a6
        move.b  (a6), d4
        move.w  (a6)+, d3
        move.l  a6, A5Seg.pPalGradEntry2(a5)
        bsr.w   PalEntryToRGB           | params:
                                        |     d4: entry.high
                                        |     d3: entry.low
                                        | ret:
                                        |     d4: R
                                        |     d3: G
                                        |     d2: B
        move.b  d2, (a3)+
        move.b  d3, (a3)+
        move.b  d4, (a3)+
        dbf     d6, _InitPalGradObj_loadOne
        bra.s   _InitPalGradObj_loopLoad
| ---------------------------------------------------------------------------

_InitPalGradObj_end:                                   | CODE XREF: InitPalGradObj+12j
        move.w  #0xFFFF, (a2)
        move.w  #0xFFFF, (a3)
        rts
| End of function InitPalGradObj


PalGradObjInitRoutine:             |7d0     
        bsr.w   InitPalGradObj

        lea     PalGradObj.RGBbuf1(a4), a0 | target index, then B,G,R ...
        lea     PalGradObj.RGBbuf2(a4), a1 | index in P2 rom, then B,G,R ...
        move.l  a0, PalGradObj.pEntryIndex1(a4)
        move.l  a1, PalGradObj.pEntryIndex2(a4)
        clr.w   PalGradObj.GradDeltaR(a4)
        clr.w   PalGradObj.GradDeltaG(a4)
        clr.w   PalGradObj.GradDeltaB(a4)
        move.b  PalGradObj.CounterResetVal(a4), PalGradObj.Counter(a4) | grade frequency
        move.l  #_PalGradObjInitRoutine_step2, PalGradObj(a4)

_PalGradObjInitRoutine_step2:                                 | DATA XREF: PalGradObjInitRoutine+32o
        subq.b  #1, PalGradObj.Counter(a4)
        bcc.s   _PalGradObjInitRoutine_ret
        move.b  PalGradObj.CounterResetVal(a4), PalGradObj.Counter(a4) | grade frequency
        movea.l PalGradObj.pEntryIndex1(a4), a0
        movea.l PalGradObj.pEntryIndex2(a4), a1
        bsr.s   DoGradPalEx             | params:
                                        |     a0: ptr to: target idx, B,G,R, ...
                                        |     a1: ptr to: p2 rom idx, B,G,R, ...
        tst.l   A5Seg.ColorTargetReachedFlag(a5) | 1: target not reached
        beq.s   _PalGradObjInitRoutine_targetReached
        subq.b  #1, PalGradObj.MaxGradSteps(a4)
        bmi.s   _PalGradObjInitRoutine_targetReached

_PalGradObjInitRoutine_ret:                                   | CODE XREF: PalGradObjInitRoutine+3Cj
        rts
| ---------------------------------------------------------------------------

_PalGradObjInitRoutine_targetReached:                         
                                        | PalGradObjInitRoutine+58j
|        ori.b   #4, A5Seg.PaletteUpdateFlag(a5) | bit0: 0: use bank Index 1; 1: use bank Index 0
                                        | bit1: 1, mask flush screen
                                        | bit6: 1, mask palette update
                                        | bit7: 1, only update current palette bank
        move.b  #0xFF, PalGradObj.CounterResetVal(a4) | grade frequency
        move.l  #j_FreeObjBlock, PalGradObj(a4)
        rts
| End of function PalGradObjInitRoutine


| params:
|     a0: ptr to: target idx, B,G,R, ...
|     a1: ptr to: p2 rom idx, B,G,R, ...

DoGradPalEx:                            |832
        move.w  PalGradObj.GradDeltaR(a4), A5Seg.PalGradDeltaR(a5)
        move.w  PalGradObj.GradDeltaG(a4), A5Seg.PalGradDeltaG(a5)
        move.w  PalGradObj.GradDeltaB(a4), A5Seg.PalGradDeltaB(a5)
        bsr.w   DoGradPal               | params:
                                        |     a0: ptr to: target idx, B,G,R, ...
                                        |     a1: ptr to: p2 rom idx, B,G,R, ...
        move.w  PalGradObj.GradDDR(a4), d0
        move.w  PalGradObj.GradDDG(a4), d1
        move.w  PalGradObj.GradDDB(a4), d2
        add.w   d0, PalGradObj.GradDeltaR(a4)
        add.w   d1, PalGradObj.GradDeltaG(a4)
        add.w   d2, PalGradObj.GradDeltaB(a4)
        rts
| End of function DoGradPalEx


j_FreeObjBlock:                         
        jmp     (FreeObjBlock).l        
| End of function j_FreeObjBlock  



| params:
|     d4: entry.high
|     d3: entry.low
| ret:
|     d4: R
|     d3: G
|     d2: B

PalEntryToRGB:                          
                                        
        move.b  d4, d7
        move.b  d3, d2
        andi.w  #0xF, d2
        roxl.b  #4, d7
        roxl.b  #1, d2
        lsr.b   #3, d3
        andi.w  #0x1E, d3
        move.w  d7, d5
        andi.w  #1, d5
        or.w    d5, d3
        roxr.b  #2, d7
        roxl.b  #1, d4
        andi.w  #0x1F, d4
        rts
| End of function PalEntryToRGB


_DoGradPal_end:                                   
        move.w  #0xFFFF, (a2)
        move.l  a2, A5Seg.PAL_IN_POINT(a5)
        rts

| params:
|     a0: ptr to: target idx, B,G,R, ...
|     a1: ptr to: p2 rom idx, B,G,R, ...

DoGradPal:          

        movea.l A5Seg.PAL_IN_POINT(a5), a2
        clr.l   A5Seg.ColorTargetReachedFlag(a5) | 1: target not reached

_DoGradPal_loopForEntries:                        | CODE XREF: DoGradPal+C0j
        tst.w   (a0)
        bmi.s   _DoGradPal_end
        move.w  (a0), (a2)+
        addq.l  #3, a0
        addq.l  #3, a1
        moveq   #0xE, d6

_DoGradPal_loopFor15colors:                       | CODE XREF: DoGradPal+BCj
        moveq   #0, d2
        moveq   #0, d3
        moveq   #0, d4
        move.b  (a0)+, d2               | B
        move.b  (a0)+, d3               | G
        move.b  (a0)+, d4               | R
        move.b  (a1)+, A5Seg.PalGradTargetB+1(a5)
        move.b  (a1)+, A5Seg.PalGradTargetG+1(a5)
        move.b  (a1)+, A5Seg.PalGradTargetR+1(a5)
        cmp.w   A5Seg.PalGradTargetB(a5), d2
        beq.s   _DoGradPal_forGreen
        bhi.s   loc_517E
        add.w   A5Seg.PalGradDeltaB(a5), d2
        cmp.w   A5Seg.PalGradTargetB(a5), d2
        ble.s   loc_518E
        move.w  A5Seg.PalGradTargetB(a5), d2
        bra.s   _DoGradPal_forGreen
| ---------------------------------------------------------------------------

loc_517E:                               | CODE XREF: DoGradPal+32j
        sub.w   A5Seg.PalGradDeltaB(a5), d2
        cmp.w   A5Seg.PalGradTargetB(a5), d2
        bge.s   loc_518E
        move.w  A5Seg.PalGradTargetB(a5), d2
        bra.s   _DoGradPal_forGreen
| ---------------------------------------------------------------------------

loc_518E:                               | CODE XREF: DoGradPal+3Cj
                                        | DoGradPal+4Cj
        move.w  #1, A5Seg.ColorTargetReachedFlag+2(a5) | 1: target not reached

_DoGradPal_forGreen:                              | CODE XREF: DoGradPal+30j
                                        | DoGradPal+42j ...
        cmp.w   A5Seg.PalGradTargetG(a5), d3
        beq.s   _DoGradPal_forRed
        bhi.s   loc_51AC
        add.w   A5Seg.PalGradDeltaG(a5), d3
        cmp.w   A5Seg.PalGradTargetG(a5), d3
        ble.s   loc_51BC
        move.w  A5Seg.PalGradTargetG(a5), d3
        bra.s   _DoGradPal_forRed
| ---------------------------------------------------------------------------

loc_51AC:                               | CODE XREF: DoGradPal+60j
        sub.w   A5Seg.PalGradDeltaG(a5), d3
        cmp.w   A5Seg.PalGradTargetG(a5), d3
        bge.s   loc_51BC
        move.w  A5Seg.PalGradTargetG(a5), d3
        bra.s   _DoGradPal_forRed
| ---------------------------------------------------------------------------

loc_51BC:                               | CODE XREF: DoGradPal+6Aj
                                        | DoGradPal+7Aj
        move.w  #1, A5Seg.ColorTargetReachedFlag+2(a5) | 1: target not reached

_DoGradPal_forRed:                                | CODE XREF: DoGradPal+5Ej
                                        | DoGradPal+70j ...
        cmp.w   A5Seg.PalGradTargetR(a5), d4
        beq.s   loc_51F0
        bhi.s   loc_51DA
        add.w   A5Seg.PalGradDeltaR(a5), d4
        cmp.w   A5Seg.PalGradTargetR(a5), d4
        ble.s   loc_51EA
        move.w  A5Seg.PalGradTargetR(a5), d4
        bra.s   loc_51F0
| ---------------------------------------------------------------------------

loc_51DA:                               | CODE XREF: DoGradPal+8Ej
        sub.w   A5Seg.PalGradDeltaR(a5), d4
        cmp.w   A5Seg.PalGradTargetR(a5), d4
        bge.s   loc_51EA
        move.w  A5Seg.PalGradTargetR(a5), d4
        bra.s   loc_51F0
| ---------------------------------------------------------------------------

loc_51EA:                               | CODE XREF: DoGradPal+98j
                                        | DoGradPal+A8j
        move.w  #1, A5Seg.ColorTargetReachedFlag+2(a5) | 1: target not reached

loc_51F0:                               | CODE XREF: DoGradPal+8Cj
                                        | DoGradPal+9Ej ...
        bsr.w   PalRGBto5bitsColor      | params:
                                        |     d4: R
                                        |     d3: G
                                        |     d2: B
                                        | ret:
                                        |     d1: 5 bits color
        move.w  d1, (a2)+
        dbf     d6, _DoGradPal_loopFor15colors
        bra.w   _DoGradPal_loopForEntries
| End of function DoGradPal


TO_COLOR_B_TABLE:
		.word 0, 0x1000, 1, 0x1001, 2, 0x1002, 3, 0x1003, 4, 0x1004, 5| 0
        .word 0x1005, 6, 0x1006, 7, 0x1007, 8, 0x1008, 9, 0x1009, 0xA| 11
        .word 0x100A, 0xB, 0x100B, 0xC, 0x100C, 0xD, 0x100D, 0xE, 0x100E| 21
        .word 0xF, 0x100F               | 30

| params:
|     d4: R
|     d3: G
|     d2: B
| ret:
|     d1: 5 bits color

PalRGBto5bitsColor:                     
        add.w   d2, d2
        move.w  TO_COLOR_B_TABLE(pc,d2.w), d1
        add.w   d3, d3
        or.w    TO_COLOR_G_TABLE(pc,d3.w), d1
        add.w   d4, d4
        or.w    TO_COLOR_R_TABLE(pc,d4.w), d1
        rts
| End of function PalRGBto5bitsColor

| ---------------------------------------------------------------------------
TO_COLOR_G_TABLE:
		.word 0, 0x2000, 0x10, 0x2010, 0x20, 0x2020, 0x30, 0x2030, 0x40| 0
        .word 0x2040, 0x50, 0x2050, 0x60, 0x2060, 0x70, 0x2070, 0x80, 0x2080| 9
        .word 0x90, 0x2090, 0xA0, 0x20A0, 0xB0, 0x20B0, 0xC0, 0x20C0, 0xD0| 18
        .word 0x20D0, 0xE0, 0x20E0, 0xF0, 0x20F0| 27
TO_COLOR_R_TABLE:
		.word 0, 0x4000, 0x100, 0x4100, 0x200, 0x4200, 0x300, 0x4300, 0x400| 0
        .word 0x4400, 0x500, 0x4500, 0x600, 0x4600, 0x700, 0x4700, 0x800| 9
        .word 0x4800, 0x900, 0x4900, 0xA00, 0x4A00, 0xB00, 0x4B00, 0xC00| 17
        .word 0x4C00, 0xD00, 0x4D00, 0xE00, 0x4E00, 0xF00, 0x4F00| 25



