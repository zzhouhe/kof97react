.include "def.inc"
.globl  FlushUpdatePalette
.globl	Append32PaletteToTail

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
