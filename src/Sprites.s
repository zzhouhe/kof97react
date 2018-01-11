.include	"def.inc"
.globl      UpdateSCB3
.globl      UpdateSCB2
.globl		UpdateBackgroundSCB3_4
.globl		DisplayZbuf

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

| 把 Zbuf 中的 obj 逐个更新到 VRAM 中

DisplayZbuf:                            | CODE XREF: GameLogicMainLoopEntry+104p
        move.w  #1, d0

_DisplayZbuf_switchSpin:                            | CODE XREF: DisplayZbuf+10j
        move.w  d0, (0x2FFFFE).l        | switch bank(1)
        cmp.w   (0x200000).l, d0
        bne.s   _DisplayZbuf_switchSpin
        tst.w   A5Seg.NumInObjZBuf(a5)
        beq.w   _DisplayZbuf_ghost
        lea     A5Seg.ObjZBuf(a5), a6   | size: 0x600
        adda.l  A5Seg.FirstObjIndexInZBuf(a5), a6 | 指示第一个带非0的Obj在Zbuf中的偏移, -2 表示Zbuf为空

_DisplayZbuf_nextObjLoop:                           | CODE XREF: DisplayZbuf+8Ej
        move.l  a5, d0

_DisplayZbuf_noFindLoop:                            | CODE XREF: DisplayZbuf+26j
        move.w  (a6)+, d0
        beq.s   _DisplayZbuf_noFindLoop
        clr.w   -2(a6)
        movea.l d0, a4                  | a4: obj to be draw
        move.l  a6, -(sp)               | a6: current pos in ObjZBuf
        move.b  Object.ExGraphFlags(a4), d0 | bit4: 1, use own Shrinking, do not set InScreenX,Y 倒影用
        btst    #4, d0

        beq.s   loc_5C08
        move.b  Object.RoleShrinkRate(a4), A5Seg.SpriteDrawHoriCoefficient(a5) | 人物整体比例
        move.b  Object.RoleShrinkRate+1(a4), A5Seg.SpriteDrawVertCoefficient(a5) | 人物整体比例
        bra.s   loc_5C44
| ---------------------------------------------------------------------------

loc_5C08:                               | CODE XREF: DisplayZbuf+38j
        bsr.w   SetObjXYinScreen        | params:
                                        |     d0: ExGraphFlags
                                        | ret:
                                        |     a1: pShinking
        move.w  (a1), A5Seg.SpriteDrawHoriCoefficient(a5) | 水平收缩因子, (1字节, 并非直接写入SCB2)
        move.w  8(a1), A5Seg.SpriteDrawVertCoefficient(a5) | 垂直收缩因子
        moveq   #0, d0
        move.b  Object.RoleShrinkRate(a4), d0 | 人物整体比例
        move.w  A5Seg.SpriteDrawHoriCoefficient(a5), d1 | 水平收缩因子, (1字节, 并非直接写入SCB2)
        cmpi.w  #0xFF00, d1
        bcc.s   loc_5C2A
        mulu.w  d1, d0
        swap    d0

loc_5C2A:                               | CODE XREF: DisplayZbuf+64j
        move.b  d0, A5Seg.SpriteDrawHoriCoefficient(a5) | 水平收缩因子, (1字节, 并非直接写入SCB2)
        move.b  Object.RoleShrinkRate+1(a4), d0 | 人物整体比例
        move.w  A5Seg.SpriteDrawVertCoefficient(a5), d1 | 垂直收缩因子
        cmpi.w  #0xFF00, d1
        bcc.s   loc_5C40
        mulu.w  d1, d0
        swap    d0

loc_5C40:                               | CODE XREF: DisplayZbuf+7Aj
        move.b  d0, A5Seg.SpriteDrawVertCoefficient(a5) | 垂直收缩因子

loc_5C44:                               | CODE XREF: DisplayZbuf+46j
        bsr.w   DrawSpriteGroup
        movea.l (sp)+, a6
        subq.w  #1, A5Seg.NumInObjZBuf(a5)
        bne.w   _DisplayZbuf_nextObjLoop

_DisplayZbuf_ghost:                                 | CODE XREF: DisplayZbuf+16j
        move.l  #0x108700, A5Seg.pGhostBuf(a5) | 影跳的影子等
                                        | 指向可用的临时缓冲区用于构造obj头, 每块0x40, 总大小0x2000
        move.l  #0xFFFE, A5Seg.FirstObjIndexInZBuf(a5) | 指示第一个带非0的Obj在Zbuf中的偏移, -2 表示Zbuf为空
        clr.w   A5Seg.NumInObjZBuf(a5)
        |clr.w   A5Seg.NumInObjZBufNoUse(a5) | 似乎没用, 有用的只是NumInObjZBuf
        move.w  #2, d0

loc_5C6E:                               
        move.w  d0, (0x2FFFFE).l
        cmp.w   (0x200000).l, d0
        bne.s   loc_5C6E
        rts
| End of function DisplayZbuf

SetObjXYinScreen:
DrawSpriteGroup: 
