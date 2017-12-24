.include "def.inc"
.globl  FlushUpdatePalette
.globl	Append32PaletteToTail
.globl	LoadAnimationAndPal

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

_flush_end:                               | CODE XREF: FlushUpdatePalette+26j
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
        bra.w   LoadPalEntries          | params:
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
        .word 0x1270
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

LoadPalEntries:                                                                 
        movea.l A5Seg.PAL_IN_POINT(a5), a2
        moveq   #0, d0
        move.w  d1, d0
        lea     (PAL_START).l, a3
        lsl.l   #5, d0
        adda.l  d0, a3
_LoadPalEntries_loop:                               
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
        dbf     d3, _LoadPalEntries_loop
        bra.w   LoadPalEntries_end
| End of function LoadPalEntries

LoadPalEntries_end:                                                             
        move.w  #0xFFFF, (a2)
        move.l  a2, A5Seg.PAL_IN_POINT(a5)
        rts
