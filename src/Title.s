.include "def.inc"
.globl  GameTitle

 GameTitle:                              
         moveq   #8, d0
         jsr     LoadAnimationAndPal     | params:
                                         |     d0: index
         jsr     InitObjectPool
         jsr     ClearFixlay
		 jsr     0xC004C8				 |Set up sprites. seems no use

		 bsr.w   InitTilesSprites
		 rts

InitTilesSprites:                      
        move.w  #0x5040, A5Seg.BackUpTileOffsetInSCB1_Main(a5)			|0x141 * 0x40
        move.w  #0x5540, A5Seg.TileOffsetInSCB1_Main(a5)				|0x155 * 0x40
        move.w  #0x14, A5Seg.ObjTotalSpriteNumbers_Main(a5) 
|        move.w  #0x1440, A5Seg.BackUpTileOffsetInSCB1_Sub(a5)			|0x51 * 0x40
|        move.w  #0x2AC0, A5Seg.TileOffsetInSCB1_Sub(a5)					|0xB2 * 0x40
|        move.w  #0x5A, A5Seg.ObjTotalSpriteNumbers_Sub(a5)

|loc_E500:                               
|        move.b  #3, A5Seg.TileUpdateFlag(a5) | bit0: 1, vert pos need update for buf_main
|                                        | bit1: 1, vert pos need update for buf_sub
|                                        | bit6: 1, mask update SCB3
|                                        | bit7: 1, mask update SCB3
|        clr.w   A5Seg+0x592E(a5)
|        clr.w   A5Seg+0x5930(a5)
|        clr.w   A5Seg.field_5932(a5)
|        clr.l   A5Seg.ScreenLeftX(a5)   | 显示区域最左端横坐标, 像素单位 0-1C0
|        clr.l   A5Seg.ScreenTopY(a5)    | 像素单位, 根据场景不同起点不同
|                                        | 顶层背景
|        move.w  #0xFF00, A5Seg.SomeGlobalHoriShrinking(a5) | always ff00
|        move.w  #0xFF00, A5Seg.SomeGlobalVertShrinking(a5) | always ff00
|        clr.l   Object.spACT5(a4)       | 接 D2 处, 缓冲区的用途根据具体必杀技决定
|        clr.l   Object.spACT5+4(a4)     | 接 D2 处, 缓冲区的用途根据具体必杀技决定
|        clr.l   Object.spACT5+8(a4)     | 接 D2 处, 缓冲区的用途根据具体必杀技决定
|        clr.l   Object.field_CE(a4)
|        andi.b  #0xFD, A5Seg.PaletteUpdateFlag(a5) | bit0: 0: use bank Index 1; 1: use bank Index 0
|                                        | bit1: 1, mask flush screen
|                                        | bit6: 1, mask palette update
|                                        | bit7: 1, only update current palette bank
|        clr.w   A5Seg.BackDoorColor(a5)
        rts
| END OF FUNCTION CHUNK FOR sub_870A8
