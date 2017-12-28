.include	"def.inc"
.globl      UpdateSCB3
.globl      UpdateSCB2
.globl		UpdateBackgroundSCB3_4

UpdateSCB3:                             
        move.w  #1, (0x3C0004).l        | REG_VRAMMOD
        lea     (0x3C0000).l, a1        | REG_VRAMADDR
        move.b  A5Seg.TileUpdateFlag(a5), d7 | bit0: 1, vert pos need update for buf_main
                                        | bit1: 1, vert pos need update for buf_sub
                                        | bit6: 1, mask update SCB3
                                        | bit7: 1, mask update SCB3
        andi.b  #3, d7
        beq.w   _UpdateSCB3_TestZeroTheBackup
        move    d7, ccr                 | xnzvc
                                        | 43210
        bcc.s   _UpdateSCB3_subBuf
        move.w  A5Seg.TileOffsetInSCB1_Main(a5), d0 | 显存中的待更新基地址(SCB1 中),
                                        | 这个跟前一个word每帧交换一次
        move.w  A5Seg.BackUpTileOffsetInSCB1_Main(a5), A5Seg.TileOffsetInSCB1_Main(a5) | 显存中的待更新基地址(SCB1 中),
                                        | 这个跟前一个word每帧交换一次
        move.w  d0, A5Seg.BackUpTileOffsetInSCB1_Main(a5)
        lsr.w   #6, d0                  | 64 words per entry in SCB1
        move.w  A5Seg.ObjTotalSpriteNumbers_Main(a5), d3 | obj 所占用的sprite总数
        lea     A5Seg.TileVertPositionsBuff_Main(a5), a0 | 主vert buf, 游戏使用
        move.w  d0, d2
        addi.w  #0x8200, d2             | SCB3 (VRAM $8200~$83FF): vertical positions
        move.w  d2, (a1)
        bsr.w   WriteVertPositionsToSCB3 | params:
                                        |     d3: size to write
                                        |     a0: ptr to vertical positions
                                        |     a1: REG_VRAMADDR

_UpdateSCB3_subBuf:                                | CODE XREF: UpdateSCB3+1Cj
|        move    d7, ccr
|        bvc.s   _UpdateSCB3_TestZeroTheBackup
|        move.w  A5Seg.TileOffsetInSCB1_Sub(a5), d0
|        move.w  A5Seg.BackUpTileOffsetInSCB1_Sub(a5), A5Seg.TileOffsetInSCB1_Sub(a5)
|        move.w  d0, A5Seg.BackUpTileOffsetInSCB1_Sub(a5)
|        lsr.w   #6, d0
|        move.w  A5Seg.ObjTotalSpriteNumbers_Sub(a5), d3
|        lea     A5Seg.TileVertPositionsBuff_Sub(a5), a0 | 副 vert buf, 过场动画, 特效等使用, 图层在第三层背景之下
|        move.w  d0, d2
|        addi.w  #0x8200, d2
|        move.w  d2, (a1)
|        bsr.w   WriteVertPositionsToSCB3 | params:
                                        |     d3: size to write
                                        |     a0: ptr to vertical positions
                                        |     a1: REG_VRAMADDR

_UpdateSCB3_TestZeroTheBackup:                                                             
        clr.w   A5Seg.SpriteAlreadyUsed_Main(a5) | 已经使用的sprite个数
|        clr.w   A5Seg.SpriteAlreadyUsed_Sub(a5)
        lea     (0x3C0000).l, a1
        move.w  #1, (0x3C0004).l
        move.b  A5Seg.TileUpdateFlag(a5), d7 | bit0: 1, vert pos need update for buf_main
                                        | bit1: 1, vert pos need update for buf_sub
                                        | bit6: 1, mask update SCB3
                                        | bit7: 1, mask update SCB3
        andi.b  #3, d7
        bne.s   _UpdateSCB3_zeroTheBackup
        rts
| ---------------------------------------------------------------------------

_UpdateSCB3_zeroTheBackup:                         | CODE XREF: UpdateSCB3+88j
        move    d7, ccr
        bcc.s   _UpdateSCB3_zeroSub
        move.w  A5Seg.TileOffsetInSCB1_Main(a5), d0 | 显存中的待更新基地址(SCB1 中),
                                        | 这个跟前一个word每帧交换一次
        move.w  d0, d2
        lsr.w   #6, d2
        addi.w  #0x8200, d2
        move.w  d2, (a1)
        moveq   #0, d2
        move.w  A5Seg.ObjTotalSpriteNumbers_Main(a5), d3 | obj 所占用的sprite总数
        moveq   #0, d0
        bsr.w   ZeroVertPositionsToSCB3Ebd | params:
                                        |     d0: val to write
                                        |     d3: size to write
                                        |     a1: REG_VRAMADDR
        moveq   #0, d0
        moveq   #0xF, d1
        lea     A5Seg.TileVertPositionsBuff_Main(a5), a0 | 主vert buf, 游戏使用

_UpdateSCB3_dbfLoop:                               | CODE XREF: UpdateSCB3+BAj
        move.l  d0, (a0)+
        move.l  d0, (a0)+
        move.l  d0, (a0)+
        move.l  d0, (a0)+
        dbf     d1, _UpdateSCB3_dbfLoop

_UpdateSCB3_zeroSub:                               | CODE XREF: UpdateSCB3+8Ej
|        move    d7, ccr
|        bvc.s   _UpdateSCB3_ret
|        move.w  A5Seg.TileOffsetInSCB1_Sub(a5), d0
|        move.w  d0, d2
|        lsr.w   #6, d2
|        addi.w  #0x8200, d2
|        move.w  d2, (a1)
|        moveq   #0, d2
|        move.w  A5Seg.ObjTotalSpriteNumbers_Sub(a5), d3
|        moveq   #0, d0
|        bsr.w   ZeroVertPositionsToSCB3Ebd | params:
|                                        |     d0: val to write
|                                        |     d3: size to write
|                                        |     a1: REG_VRAMADDR
|        moveq   #0, d0
|        moveq   #0xF, d1
|        lea     A5Seg.TileVertPositionsBuff_Sub(a5), a0 | 副 vert buf, 过场动画, 特效等使用, 图层在第三层背景之下
|
|_UpdateSCB3__UpdateSCB3_dbfLoop:                              | CODE XREF: UpdateSCB3+ECj
|        move.l  d0, (a0)+
|        move.l  d0, (a0)+
|        move.l  d0, (a0)+
|        move.l  d0, (a0)+
|        dbf     d1, _UpdateSCB3__UpdateSCB3_dbfLoop

_UpdateSCB3_ret:                                   | CODE XREF: UpdateSCB3+C0j
        rts
| End of function UpdateSCB3

|params:
|    d3: size to write
|    a0: ptr to vertical positions
|    a1: REG_VRAMADDR
WriteVertPositionsToSCB3:                                                       
        move.w  #0x80, d2
        sub.w   d3, d2
        add.w   d2, d2
        add.w   d2, d2
        jmp     _WriteVertPositionsToSCB3_repeatWrite(pc,d2.w)
| ---------------------------------------------------------------------------
_WriteVertPositionsToSCB3_repeatWrite:
        move.w  (a0)+, 2(a1)	|0
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)	|10
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)	|20
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)	|30
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)	|40
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)	|50
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)	|60
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)	|70
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        move.w  (a0)+, 2(a1)
        rts
| End of function WriteVertPositionsToSCB3

| params:
|     d0: val to write
|     d3: size to write
|     a1: REG_VRAMADDR

ZeroVertPositionsToSCB3Ebd:             | CODE XREF: UpdateSCB3+A6p
                                        | UpdateSCB3+D8p
        move.w  #0x80, d2
        sub.w   d3, d2
        add.w   d2, d2
        add.w   d2, d2
        jmp     _ZeroVertPositionsToSCB3Ebd_repeatWrite(pc,d2.w)
| ---------------------------------------------------------------------------
_ZeroVertPositionsToSCB3Ebd_repeatWrite:
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        move.w  d0, 2(a1)
        rts
| End of function ZeroVertPositionsToSCB3Ebd


| updeate shirnk vals
| 按块更新, 每块最多包含32个entry

UpdateSCB2:                             
        move.l  #0x10BCFE, A5Seg.ShrinkUpdateBlocksStart(a5)
        tst.b   A5Seg.ShrinkNumBlocksToUpdate(a5)
        bne.s   _UpdateSCB2_update
        rts
| ---------------------------------------------------------------------------

_UpdateSCB2_update:                                
        lea     A5Seg.UpdateOffsetInSCB2(a5), a0 | Shrink update index
        move.w  #1, (REG_VRAMMOD).l        

_UpdateSCB2_loop:                          
        lea     (REG_VRAMADDR).l, a1       
        move.w  (a0)+, (a1)+
        moveq   #0x20, d0
        sub.w   (a0)+, d0
        add.w   d0, d0
        jmp     loc_A8FC(pc,d0.w)
| ---------------------------------------------------------------------------

loc_A8FC:
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        subq.b  #1, A5Seg.ShrinkNumBlocksToUpdate(a5)
        bne.w   _UpdateSCB2_loop
        rts
| End of function UpdateSCB2


UpdateBackgroundSCB3_4:                 
        move.l  #0x10B8BE, A5Seg.pBackgroundUpdateSCB3_4BlocksStart(a5)
        tst.b   A5Seg.BackgroundUpdateSCB3_4NumBlocksPending(a5)
        bne.s   _UpdateBackgroundSCB3_4_update
        rts
| ---------------------------------------------------------------------------

_UpdateBackgroundSCB3_4_update:                               
        lea     A5Seg.BackgroundSCB3_4BlocksBuf(a5), a0
        move.w  #1, (REG_VRAMMOD).l       

_UpdateBackgroundSCB3_4_blocksLoop:                           
        lea     (REG_VRAMADDR).l, a1       
        move.w  (a0)+, (a1)+
        move.w  #0x20, d0
        sub.w   (a0)+, d0
        add.w   d0, d0
        jmp     _UpdateBackgroundSCB3_4_SCB4(pc,d0.w)
| ---------------------------------------------------------------------------

_UpdateBackgroundSCB3_4_SCB4:
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        moveq   #0x20, d0               | second block
        move.w  (a0)+, -2(a1)
        sub.w   (a0)+, d0
        add.w   d0, d0
        jmp     _UpdateBackgroundSCB3_4_SCB3(pc,d0.w)
| ---------------------------------------------------------------------------

_UpdateBackgroundSCB3_4_SCB3:
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        move.w  (a0)+, (a1)
        subq.b  #1, A5Seg.BackgroundUpdateSCB3_4NumBlocksPending(a5)
        bne.w   _UpdateBackgroundSCB3_4_blocksLoop             | REG_VRAMADDR
        rts
| End of function UpdateBackgroundSCB3_4
