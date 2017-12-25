.include "def.inc"
.globl		InitBackGroundLayer2

InitLayerEnd:                           
        move.l  a2, ScreenObj.pDataFromParam(a1)
        move.w  d1, ScreenObj.XfromParam(a1)
        move.w  d2, ScreenObj.YfromParam(a1)
        move.w  d3, ScreenObj.BackgroundSpriteWidthFromParam(a1)
        move.w  d4, ScreenObj.BackgroundSpriteHeightFromParam(a1)
        rts

| params:
|     d1: X
|     d2: Y
|     d3: width
|     d4: height

InitBackGroundLayer2:                  
        moveq   #2, d0
        movem.l d1-d5/a2, -(sp)
        |lea     BackGroundLayerRoutine, a0
        jsr     (InitBackGroundLayer).l | params:
                                        |     d0: back layer index
                                        |     a0: proc routine
        movem.l (sp)+, d1-d5/a2
        move.w  #0xF40, ScreenObj.VRamBaseOffset(a1) | 0x3d * 0x40
        bra.s   InitLayerEnd
| End of function InitBackGroundLayer2



| params:
|     d0: back layer index
|     a0: proc routine

InitBackGroundLayer:                   
        lea     A5Seg.BackGroundObjLayer0(a5), a1 | ×î¶¥²ã±³¾°Obj
        move.w  d0, -(sp)
        lsl.w   #8, d0                  | * 256
        adda.w  d0, a1                  | a1: the layer obj
        lea     (a1), a2
        move.w  #0xF, d0

_InitBackGroundLayer_dbfloop:                               
        clr.l   (a2)+
        clr.l   (a2)+
        clr.l   (a2)+
        clr.l   (a2)+
        dbf     d0, _InitBackGroundLayer_dbfloop
        move.l  a0, (a1)
        move.w  (sp)+, d0
        ori.b   #0x80, ScreenObj.Flag(a1) | bit1: 1, do not show this layer
                                        | bit1: 1, do not scroll X
                                        | bit2: 1, do not scrool Y
                                        | bit5: 1, do not ... ?
                                        | bit6: 1, sticky
                                        | bit7: 0, do not use layer proc
        rts
| End of function InitBackGroundLayer

