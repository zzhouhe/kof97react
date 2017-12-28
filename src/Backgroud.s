.include	"def.inc"
.globl		InitBackGroundLayer2
.globl		InitBackGroundLayer3
.globl		InitBackGroundLayer4
.globl		InitBackGroundLayer5

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
|     d3: width - 1
|     d4: height - 1
InitBackGroundLayer2:                  
        moveq   #2, d0
        movem.l d1-d5/a2, -(sp)
        lea     BackGroundLayerRoutine, a0
        jsr     (InitBackGroundLayer).l | params:
                                        |     d0: back layer index
                                        |     a0: proc routine
        movem.l (sp)+, d1-d5/a2
        move.w  #0xF40, ScreenObj.VRamBaseOffset(a1) | 0x3d * 0x40
        bra.s   InitLayerEnd
| End of function InitBackGroundLayer2


InitBackGroundLayer3:                   
        moveq   #3, d0
        movem.l d1-d5/a2, -(sp)
        lea     BackGroundLayerRoutine, a0
        jsr     (InitBackGroundLayer).l | params:
                                        |     d0: back layer index
                                        |     a0: proc routine
        movem.l (sp)+, d1-d5/a2
        move.w  #0xA40, ScreenObj.VRamBaseOffset(a1) | 0x29 * 0x40
        bra.s   InitLayerEnd
| End of function InitBackGroundLayer3

InitBackGroundLayer4:                  
        moveq   #4, d0
        movem.l d1-d5/a2, -(sp)
        lea     BackGroundLayerRoutine, a0
        jsr     (InitBackGroundLayer).l | params:
                                        |     d0: back layer index
                                        |     a0: proc routine
        movem.l (sp)+, d1-d5/a2
        move.w  #0x540, ScreenObj.VRamBaseOffset(a1) | 0x15 *0x40
        bra.s   InitLayerEnd
| End of function InitBackGroundLayer4

InitBackGroundLayer5:                   
        moveq   #5, d0
        movem.l d1-d5/a2, -(sp)
        lea     BackGroundLayerRoutine, a0
        jsr     (InitBackGroundLayer).l | params:
                                        |     d0: back layer index
                                        |     a0: proc routine
        movem.l (sp)+, d1-d5/a2
        move.w  #0x40, ScreenObj.VRamBaseOffset(a1)
        bra.w   InitLayerEnd
| End of function InitBackGroundLayer5

| params:
|     d0: back layer index
|     a0: proc routine
InitBackGroundLayer:                   
        lea     A5Seg.BackGroundObjLayer0(a5), a1 | 最顶层背景Obj
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


| params:
|     a0: prt to: widthInTiles, HeightInTiles
|     d0: VRAM base offset
|     d1: MaxNumTiles to use

InitLayerObj:                           
                                        
        move.w  d0, ScreenObj.VRamBaseOffsetInSCB1(a4)
        move.w  d1, ScreenObj.MaxNumOfSpritesToUse(a4)
        lsr.w   #6, d0
        move.w  d0, d1
        addi.w  #-0x8000, d0
        move.w  d0, ScreenObj.SCB2UpdateVramAddr(a4)
        addi.w  #0x200, d0
        move.w  d0, ScreenObj.SCB3UpdateVramAddr(a4)
        addi.w  #0x200, d0
        move.w  d0, ScreenObj.SCB4UpdateVramAddr(a4)
        |move.w  (a0)+, ScreenObj.WidthInTiles(a4) | 图层宽度包含多少个tile
        |move.w  (a0)+, ScreenObj.HeightInTiles(a4) | always $10
        |moveq   #0, d0
        |move.w  (a0)+, d0
        |lsl.w   #4, d0
        |move.w  d0, ScreenObj.X(a4)     | layer's X, neg mean right, in pixels
        |subi.w  #0x10, d0
        |move.w  d0, ScreenObj.LeftPixelsX(a4)
        |addi.w  #0x160, d0
        |move.w  d0, ScreenObj.RightPixelsX(a4)
        |moveq   #0, d0
        |move.w  (a0)+, d0
        |lsl.w   #4, d0
        |move.w  d0, ScreenObj.Y(a4)     | layer's Y, neg mean down, in pixels
        |subi.w  #0x10, d0
        |move.w  d0, ScreenObj.TopPixelsY(a4) | 更新时使用, 16像素对齐
        |clr.l   ScreenObj.YFromGround(a4) | 屏幕的向上滚动偏移
        |addi.w  #0x120, d0
        |move.w  d0, ScreenObj.BottomPixelsY(a4)
        |move.l  a0, ScreenObj.pBackgroundSCB1Data(a4) | p1 rom 中保存的SCB1 静态 rom 数据
        |move.w  #0x20, ScreenObj.BackgroundSpriteHeight(a4)
        move.w  #0xFFFF, ScreenObj.ShrinkRate(a4) | 人物整体比例
        |clr.l   ScreenObj.VertSpriteDeltaYBuf(a4)
        |clr.l   ScreenObj.VertSpriteDeltaYBuf+4(a4)
        |clr.l   ScreenObj.VertSpriteDeltaYBuf+8(a4)
        |clr.l   ScreenObj.VertSpriteDeltaYBuf+0xC(a4)
        |clr.l   ScreenObj.VertSpriteDeltaYBuf+0x10(a4)
        |clr.l   ScreenObj.field_F4(a4)
        |clr.l   ScreenObj.field_F8(a4)
        |clr.l   ScreenObj.field_FC(a4)
        clr.w   A5Seg.GlobalCamaraYDelta(a5) | 全局镜头的Y偏移
        rts
| End of function InitLayerObj


| params:
|     a4: screen obj

LoadShrinkFromScreenObj:                                                      
        move.w  ScreenObj.ShrinkRate(a4), d0
        cmp.w   ScreenObj.LastShrink(a4), d0
        bne.s   _LoadShrinkFromScreenObj_update
        rts
| ---------------------------------------------------------------------------
_LoadShrinkFromScreenObj_update:                                
        move.w  d0, ScreenObj.LastShrink(a4)
        addq.b  #1, A5Seg.ShrinkNumBlocksToUpdate(a5)
        movea.l A5Seg.ShrinkUpdateBlocksStart(a5), a0
        move.w  ScreenObj.SCB2UpdateVramAddr(a4), (a0)+
        move.w  ScreenObj.MaxNumOfSpritesToUse(a4), d0
        move.w  d0, (a0)+
        subq.w  #1, d0
|        lea     (g_HoriShrinkRefineTable).l, a1
|        cmpi.w  #0xFFFF, ScreenObj.ShrinkRate(a4)
|        beq.s   loc_8000
|        moveq   #0, d1
|        moveq   #0, d2
|        move.b  ScreenObj.ShrinkRate+1(a4), d1
|        move.b  ScreenObj.ShrinkRate(a4), d2
|        move.w  d2, d3
|        andi.w  #0xF, d3
|        neg.w   d3
|        addi.w  #0xF, d3
|        lsl.w   #5, d3
|        adda.w  d3, a1
|        lsr.w   #4, d2
|        moveq   #0, d4
|
|_LoadShrinkFromScreenObj_loop:                                 
|        move.w  d2, d3
|        sub.b   (a1)+, d3
|        bpl.s   loc_7FE2
|        clr.w   d3
|        move.b  d3, ScreenObj.field_40(a4,d4.w)
|        addq.w  #1, d4
|        andi.w  #0xF, d4
|        bra.s   loc_7FF2
|| ---------------------------------------------------------------------------
|
|loc_7FE2:                              
|        move.b  d3, -(sp)
|        move.b  d3, ScreenObj.field_40(a4,d4.w)
|        addq.w  #1, d4
|        andi.w  #0xF, d4
|        move.w  (sp)+, d3
|        clr.b   d3
|
|loc_7FF2:                              
|        or.w    d1, d3
|        move.w  d3, (a0)+
|        dbf     d0, _LoadShrinkFromScreenObj_loop
|        move.l  a0, A5Seg.ShrinkUpdateBlocksStart(a5)
|        rts
|| ---------------------------------------------------------------------------
|
loc_8000:                               
        move.w  #0xFFF, d3

_LoadShrinkFromScreenObj_loopNear:                             
        move.w  d3, (a0)+
        dbf     d0, _LoadShrinkFromScreenObj_loopNear
|        move.l  #0xF0F0F0F, ScreenObj.field_40(a4)
|        move.l  #0xF0F0F0F, ScreenObj.XDeltaThisFrame(a4) 
|        move.l  #0xF0F0F0F, ScreenObj.field_48(a4)
|        move.l  #0xF0F0F0F, ScreenObj.field_4C(a4)
|        move.l  a0, A5Seg.ShrinkUpdateBlocksStart(a5)
        rts
| End of function LoadShrinkFromScreenObj



| params:
|     a4: screen obj
|     d0: VRAM addr
|     d2: height - 1
|     d4: width - 1

LoadBckgrdSCB1data:                     
                                        
        lea     (0x3C0002).l, a1        | REG_VRAMRW
        movea.l ScreenObj.pBackgroundSCB1Data(a4), a0
|        move.w  ScreenObj.Player2TilePaletteDelta(a4), d3 | player1: $00
                                        | player2: $20
                                        | 对应 A5Seg.GlobalTilePalette的Palette偏移量
|        clr.b   d3
        move.w  #1, 2(a1)

_LoadBckgrdSCB1data_loopOut:                              
        move.w  d2, d5
        move.w  d0, -2(a1)

_LoadBckgrdSCB1data_loopIn:                               
        move.w  (a0)+, (a1)
        move.w  (a0)+, d1
|        add.w   d3, d1
        move.w  d1, (a1)
        nop
        dbf     d5, _LoadBckgrdSCB1data_loopIn
        addi.w  #0x40, d0
        dbf     d4, _LoadBckgrdSCB1data_loopOut
        rts
| End of function LoadBckgrdSCB1data



| params:
|     a4: screen obj

LoadSCB3_4fromScreenObj:         |0x2004                                               
        addq.b  #1, A5Seg.BackgroundUpdateSCB3_4NumBlocksPending(a5)
        lea     A5Seg.BackgroundSpritesXTempBuf(a5), a1
        move.w  ScreenObj.X(a4), d0     | layer's X, neg mean right, in pixels
        neg.w   d0
        move.w  d0, 0x42(a1)            | 0x42 = (0x20 + 1) * 2
                                        | max sprites use 0x20
        move.w  d0, d1
        lsl.w   #7, d1                  | * 128
        move.w  d1, (a1)
        moveq   #0, d7
|        cmpi.b  #0xFF, ScreenObj.ShrinkRate(a4)

|        add.w   ScreenObj.SpecialRightX(a4), d7 
        lsl.w   #7, d7
        lsl.w   #7, d0                  | X position in SCB4
        move.w  d0, d1
        movea.l A5Seg.pBackgroundUpdateSCB3_4BlocksStart(a5), a0 
        move.w  ScreenObj.SCB4UpdateVramAddr(a4), (a0)+
        move.w  ScreenObj.MaxNumOfSpritesToUse(a4), d0
        move.w  d0, (a0)+
        lea     (a0), a6
        move.l  a0, -(sp)               | push
        move.w  d0, d3
        subq.w  #1, d3

_LoadSCB3_4fromScreenObj_loopForSprites_X:                  
        move.w  d1, (a0)+				| d1: X << 7, a0: block start
        addi.w  #0x800, d1              | 0x10 << 7
        move.w  d1, 2(a1)
        move.w  0x42(a1), 0x44(a1)
        addi.w  #0x10, 0x44(a1)
        addq.l  #2, a1
        dbf     d3, _LoadSCB3_4fromScreenObj_loopForSprites_X

        move.w  d0, d3
        subq.w  #1, d3
        movea.l (sp)+, a1

_LoadSCB3_4fromScreenObj_addLoop:                               
        add.w   d7, (a1)+
        dbf     d3, _LoadSCB3_4fromScreenObj_addLoop

|---------------for Y-----------	 |0x2062     
        move.w  ScreenObj.SCB3UpdateVramAddr(a4), (a0)+	
        move.w  d0, (a0)+
        move.w  d0, d7
        move.w  ScreenObj.Y(a4), d0				| layer's Y, neg mean down, in pixels
        sub.w   ScreenObj.YFromGround(a4), d0	| 屏幕camara的向上滚动偏移
        move.b  ScreenObj.ShrinkRate+1(a4), d1
        lsl.w   #8, d1
|        cmpi.w  #0xFF00, d1

		add.w   A5Seg.GlobalCamaraYDelta(a5), d0 | 全局镜头的Y偏移, 如地震效果等, neg 表示镜头上移
        subi.w  #0x10, d0				| 上方0x10像素不显示区
        lsl.w   #7, d0
        move.w  d0, d1
        move.w  d7, d0	
        lea     A5Seg.BackgroundSpritesXTempBuf(a5), a1
        moveq   #0, d4
        tst.b   A5Seg.VideoSpecialModes(a5) | bit0: 1, not show back obj
                                        | bit1: 1, 显示分数排名
                                        | bit2: 1, demo mod
                                        | bit3: 1, not show coin and difficulty
                                        | bit4: 1, role fast speed
                                        | bit6: 1, 3倍慢速
                                        | bit7: 1, not show background
        bmi.s   _LoadSCB3_4fromScreenObj_testXoverflow
        btst    #0, ScreenObj.Flag(a4)  | bit0: 1, do not show this layer
                                        | bit1: 1, do not scroll X
                                        | bit2: 1, do not scrool Y
                                        | bit5: 1, do not ... ?
                                        | bit6: 1, sticky
                                        | bit7: 0, do not use layer proc
        bne.s   _LoadSCB3_4fromScreenObj_testXoverflow
        move.w  ScreenObj.BackgroundSpriteHeight(a4), d4
        or.w    d1, d4                  | d1: Y << 7

_LoadSCB3_4fromScreenObj_testXoverflow:                        
                                        | LoadSCB3_4fromScreenObj+18Aj
        move.w  (a1)+, d2               | X << 7
        addi.w  #0x780, d2              | F << 7
        cmpi.w  #0xA600, d2             | 14c << 7
        bhi.s   _LoadSCB3_4fromScreenObj_write_size0
        move.w  d4, (a0)+
        bra.s   loc_7C40
| ---------------------------------------------------------------------------
_LoadSCB3_4fromScreenObj_write_size0:                           
        move.w  d1, (a0)+               | write it to SCB3, but with size = 0

loc_7C40:                               | CODE XREF: LoadSCB3_4fromScreenObj+1A0j
        subq.w  #2, d0
        swap    d2
        move.b  ScreenObj.Flag(a4), d2  | bit0: 1, do not show this layer
                                        | bit1: 1, do not scroll X
                                        | bit2: 1, do not scrool Y
                                        | bit5: 1, do not ... ?
                                        | bit6: 1, sticky
                                        | bit7: 0, do not use layer proc
        andi.w  #0x40, d2
        or.w    d2, d1
        or.w    d2, d4
        swap    d2

_LoadSCB3_4fromScreenObj_loopWriteY:                            | CODE XREF: LoadSCB3_4fromScreenObj+1C4j
                                        | LoadSCB3_4fromScreenObj+1CCj
        move.w  (a1)+, d2
        addi.w  #0x780, d2
        cmpi.w  #0xA600, d2
        bhi.s   loc_7C66
        move.w  d4, (a0)+
        dbf     d0, _LoadSCB3_4fromScreenObj_loopWriteY
        bra.s   loc_7C6C
| ---------------------------------------------------------------------------

loc_7C66:                               | CODE XREF: LoadSCB3_4fromScreenObj+1C0j
        move.w  d1, (a0)+
        dbf     d0, _LoadSCB3_4fromScreenObj_loopWriteY

loc_7C6C:                               | CODE XREF: LoadSCB3_4fromScreenObj+1C8j
        move.l  a0, A5Seg.pBackgroundUpdateSCB3_4BlocksStart(a5)
        rts
| End of function LoadSCB3_4fromScreenObj		



| params:
|     d0: addr
|     d1: width - 1
|     d2: height - 1

ZeroSCB1Sprites:                       
                                       
        swap    d0
        lea     (0x3C0000).l, a0        | REG_VRAMADDR

_ZeroSCB1Sprites_loopOut:                              
        move.w  d2, d3

_ZeroSCB1Sprites_loopIn:                               
        move.w  #0, d0
        move.l  d0, (a0)
        addi.l  #0x10000, d0
        move.w  #0, d0
        move.l  d0, (a0)
        addi.l  #0x10000, d0
        dbf     d3, _ZeroSCB1Sprites_loopIn
        dbf     d1, _ZeroSCB1Sprites_loopOut
        rts
| End of function ZeroSCB1Sprites


BackGroundLayerRoutine:  |0x2110                                                     
        move.w  ScreenObj.VRamBaseOffset(a4), d0
        moveq   #0x14, d1
|        lea     (word_A8C96).l, a0
        jsr     (InitLayerObj).l        | params:
                                        |     a0: prt to: widthInTiles, HeightInTiles
                                        |     d0: VRAM base offset
                                        |     d1: MaxNumTiles to use
        move.w  ScreenObj.BackgroundSpriteHeightFromParam(a4), ScreenObj.BackgroundSpriteHeight(a4)
        addi.w  #1, ScreenObj.BackgroundSpriteHeight(a4)
        move.w  ScreenObj.XfromParam(a4), ScreenObj.X(a4) | layer's X, neg mean right, in pixels
        move.w  ScreenObj.YfromParam(a4), ScreenObj.Y(a4) | layer's Y, neg mean down, in pixels
        move.w  ScreenObj.VRamBaseOffsetInSCB1(a4), d0
        moveq   #0x13, d1
        moveq   #0x1F, d2
        jsr     ZeroSCB1Sprites         | params:
                                        |     d0: addr
                                        |     d1: width - 1
                                        |     d2: height - 1
        move.l  #_BackGroundLayerRoutine_step2, ScreenObj(a4)  | 主例程

_BackGroundLayerRoutine_step2:                                 
        move.w  ScreenObj.VRamBaseOffsetInSCB1(a4), d0
        move.l  ScreenObj.pDataFromParam(a4), ScreenObj.pBackgroundSCB1Data(a4)
        move.w  ScreenObj.BackgroundSpriteWidthFromParam(a4), d4 | width - 1
        move.w  ScreenObj.BackgroundSpriteHeightFromParam(a4), d2 | height - 1
|        tst.b   ScreenObj.IsFaceToRight(a4) | bit0: Horizontal flip
                                        | bit1: Vertical flip
                                        | bit2: 2bit Auto-anim
                                        | bit3: 3bit Auto-anim
                                        | 实际上是SCB1 tile 第二word 的低字节属性
|        bne.s   _BackGroundLayerRoutine_flip
        jsr     LoadBckgrdSCB1data      | params:
                                        |     a4: screen obj
                                        |     d0: VRAM addr
                                        |     d2: height - 1
                                        |     d4: width - 1
        move.l  #_BackGroundLayerRoutine_step3, (a4)

_BackGroundLayerRoutine_step3:         
|        bclr    #1, A5Seg.layerShowFlag(a5) | bit1: 1, not show this layer
|        beq.s   _BackGroundLayerRoutine_step4
|        ori.b   #1, ScreenObj.Flag(a4)  | bit0: 1, do not show this layer
|                                        | bit1: 1, do not scroll X
|                                        | bit2: 1, do not scrool Y
|                                        | bit5: 1, do not ... ?
|                                        | bit6: 1, sticky
|                                        | bit7: 0, do not use layer proc
|        move.l  #loc_E646, ScreenObj(a4) | 主例程
|        bra.s   _BackGroundLayerRoutine_step4
| ---------------------------------------------------------------------------

|loc_E646:                               | DATA XREF: BackGroundLayerRoutine+70o
|        andi.b  #0x7F, ScreenObj.Flag(a4) | bit0: 1, do not show this layer
|                                        | bit1: 1, do not scroll X
|                                        | bit2: 1, do not scrool Y
|                                        | bit5: 1, do not ... ?
|                                        | bit6: 1, sticky
|                                        | bit7: 0, do not use layer proc
|        move.l  #_BackGroundLayerRoutine_step4, ScreenObj(a4)  | 主例程

_BackGroundLayerRoutine_step4:                                 | CODE XREF: BackGroundLayerRoutine+68j
                                        | BackGroundLayerRoutine+76j
                                        | DATA XREF: ...
        jsr     (LoadShrinkFromScreenObj).l | params:
                                        |     a4: screen obj
        jsr     (LoadSCB3_4fromScreenObj).l | params:
                                        |     a4: screen obj
        rts

