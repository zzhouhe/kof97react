.include	"def.inc"
.globl		GetNextMov

| ret:
|     d0: 0, done;
|        -1, new graph info loaded

GetNextMov:                             
        move.w  Object.ChCode(a4), d0
        move.w  Object.ActCode(a4), d1
        cmp.w   Object.PrevChCode(a4), d0
        bne.s   _GetNextMov_newAct
        cmp.w   Object.PrevActCode(a4), d1
        beq.s   _GetNextMov_sameAct
        move.w  d1, Object.PrevActCode(a4)

_GetNextMov_newAct:                                
        move.w  d0, Object.PrevChCode(a4)
        clr.w   Object.MovOffsetFromActBase(a4) | 在 bank(2), 基于 ACT base 的偏移
        clr.b   Object.SpanTime(a4)     | clear spanTime
        clr.b   Object.HitBoxFlag(a4)   | clear HitFlag
        clr.b   Object.RecoveryFlags(a4) | clear FreezeTime
        clr.w   Object.MovIndexInAct(a4) | 当前执行到的mov编号, (在整个ACT中0,1,2...排列)
        bsr.w   _GetNextMov_loadNewMov
        moveq   #0, d0
        rts
| ---------------------------------------------------------------------------

_GetNextMov_sameAct:                    
        tst.b   Object.HitBoxFlag(a4)   | bit0: 1, have hit box 0
                                        | bit1: 1, have hit box 1
                                        | bit2: 1, have hit box 2
                                        | bit3: 1, have hit box 3
                                        | bit7: 1, Act end
        bmi.s   _GetNextMov_zeroRet
        tst.b   Object.SpanTime(a4)
        beq.s   _GetNextMov_nextMov
        tst.b   Object.FreezeDelayTime(a4)
        beq.s   _GetNextMov_decTime
        subq.b  #1, Object.FreezeDelayTime(a4)
        moveq   #0, d0
        rts
| ---------------------------------------------------------------------------

_GetNextMov_decTime:                               | CODE XREF: GetNextMov+48j
        subq.b  #1, Object.SpanTime(a4)

_GetNextMov_zeroRet:                               | CODE XREF: GetNextMov+3Cj
        moveq   #0, d0
        rts
| ---------------------------------------------------------------------------

_GetNextMov_nextMov:                               | CODE XREF: GetNextMov+42j
        addq.w  #6, Object.MovOffsetFromActBase(a4) | 在 bank(2), 基于 ACT base 的偏移

_GetNextMov_loadNewMov:                            | CODE XREF: GetNextMov+30p
        jsr     GetMovOffset            | ret:
                                        |     a0: Mov offset
        clr.w   d0
        move.b  (a0), d0
        bpl.s   _GetNextMov_setSpanTime
        neg.b   d0                      | 取绝对值
        subq.w  #1, d0                  | 减一
        add.w   d0, d0
        add.w   d0, d0                  | 乘4作为索引值
        movea.l off_58C4(pc,d0.w), a2
        jsr     (a2)
        bra.s   _GetNextMov_sameAct
| ---------------------------------------------------------------------------
off_58C4:.long _GetNextMov_againThisAct            | FF表示当前Act是循环执行的
        .long _GetNextMov_endThisAct               | FE表示当前Act结束
        .long _GetNextMov_getBox                   | FD, 判定标志，这6个字节包含了判定方式和判定框
        .long _GetNextMov_loadSound                | FC 音效标志
        .long _GetNextMov_deltaX                   | FB 位移标志
        .long _GetNextMov_loadGraph                | FA 附加图像标志
| ---------------------------------------------------------------------------

_GetNextMov_setSpanTime:                           | CODE XREF: GetNextMov+66j
        move.b  d0, Object.SpanTime(a4)
        move.b  1(a0), Object.HitSpecialStatus(a4) | bits0--1: 3, 攻击无后弹
                                        | bit2: 1, 破站防
                                        | bit3: 1, 破蹲防                                        
                                        |                     10=喷血
                                        |                     20=火焰1
                                        |                     30=紫焰
                                        |                     40=电击
                                        |                     50=火焰2/火焰音效
                                        |                     60=铁球音效
                                        |                     70=随机Critical Hit
                                        |                     80=防御破坏
        move.b  4(a0), Object.HitBoxFlag(a4) | bit0: 1, have hit box 0
                                        | bit1: 1, have hit box 1
                                        | bit2: 1, have hit box 2
                                        | bit3: 1, have hit box 3
                                        | bit4: 1, 曝气效果, 破空防
                                        | bit5: 1, 飞行道具的非最后1hit
                                        | bit6: 1, 碰撞发生后持续清除box0(不参与下一帧后的检测)
                                        | bit7: 1, Act end
        move.b  5(a0), Object.RecoveryFlags(a4) | bits0-1: 1, 禁对空追打; 2, 倒地追加
                                        | bit2: 1, 可cancel接必杀技
                                        | bit3: 1, 可cancel接特殊技
                                        | bits4-6: 硬直类型
        addq.w  #1, Object.MovIndexInAct(a4) | 当前执行到的mov编号, (在整个ACT中0,1,2...排列)
        move.w  2(a0), d1               | graph Index
        move.w  Object.ChCode(a4), d2
        move.w  #1, d0

_GetNextMov_bankSwitchLoop:                        
        move.w  d0, (0x2FFFFE).l        | BankSwitch(1)
        cmp.w   (0x200000).l, d0
        bne.s   _GetNextMov_bankSwitchLoop
        lea     (0x200002).l, a0
        add.w   d2, d2
        add.w   d2, d2
        movea.l (a0,d2.w), a0
        mulu.w  #6, d1
        adda.w  d1, a0
        move.l  a0, Object.pGraphInfoEntry(a4) | 先指向4字节Xoffset,Yoffset
                                        | 然后是一个word的 SCB1 data offset from obj data base
        move.w  #2, d0

_GetNextMov__GetNextMov_bankSwitchLoop:                       | CODE XREF: GetNextMov+ECj
        move.w  d0, (0x2FFFFE).l        | BankSwitch(2)
        cmp.w   (0x200000).l, d0
        bne.s   _GetNextMov__GetNextMov_bankSwitchLoop        | BankSwitch(2)
        moveq   #0xFFFFFFFF, d0
        rts


_GetNextMov_againThisAct:                          
        move.w  #0xFFFA, Object.MovOffsetFromActBase(a4) | -6
        clr.w   Object.MovIndexInAct(a4) | 当前执行到的mov编号, (在整个ACT中0,1,2...排列)
        rts
| ---------------------------------------------------------------------------

_GetNextMov_endThisAct:                            
        subq.w  #6, Object.MovOffsetFromActBase(a4) | -= 6
        ori.b   #0x80, Object.HitBoxFlag(a4) | HitFlag |= ACT_END
        rts
| ---------------------------------------------------------------------------

_GetNextMov_loadSound:                             
        move.w  2(a0), d0
        movem.l d1-d2/a0-a1, -(sp)
        jsr     SET_SOUND               | params:
                                        |     d0: sound index
        movem.l (sp)+, d1-d2/a0-a1
        lea     6(a0), a0
        rts


_GetNextMov_deltaX:                                
        move.w  2(a0), d0
        btst    #0, Object.IsFaceToRight(a4) | bit0: Horizontal flip
                                        | bit1: Vertical flip
                                        | bit2: 2bit Auto-anim
                                        | bit3: 3bit Auto-anim
                                        | 实际上是SCB1 tile 第二word 的低字节属性
        beq.s   _GetNextMov_loc_59B0
        neg.w   d0

_GetNextMov_loc_59B0:                              
        add.w   d0, Object.OriX(a4)     | 贴图原点(十字)的横坐标, 区域逻辑位置, 像素单位
        addq.l  #6, a0
        rts
| ---------------------------------------------------------------------------

_GetNextMov_loadGraph:                             | DATA XREF: GetNextMov+8Co
        btst    #1, Object.ExGraphFlags(a4) | bit0: 1, need to update SCB1
                                        | bit1: 1, do not use extra graph
                                        | bit2: 1, 使用缓移层背景
                                        | bit3: ?
                                        | bit4: 1, use own Shrinking, do not set InScreenX,Y 倒影用
                                        | bit5: 1, visible during freeze
                                        | bit7: 1, use sub SCB3 buf
        bne.s   _GetNextMov_skipRet
        movem.l d1/a1, -(sp)            | pushad
        move.l  a0, -(sp)               | push a0
                                        | a0: 6字节组首地址
        move.w  (a0), d0
        andi.w  #0xFF, d0               | d0.low: 附加效果字节
        add.w   d0, d0
        add.w   d0, d0
        lea     (ExtendEffectPropareTable).l, a0
        movea.l (a0,d0.w), a0
        jsr     (a0)                    | set level and FA_Mask
        lea     (ExtendEffectRoutineTable).l, a0
        movea.l (a0,d0.w), a0
        move.w  A5Seg.TempGraphLevel(a5), d0
        jsr     AllocateObjBlock        | params:
                                        |     a0: PActionRoutine
                                        |     d0: level
                                        | ret:
                                        |     a1: newObj
        move.l  a4, Object.ParentObj(a1)
        move.b  A5Seg.TempExGraphMask(a5), d0
        or.b    d0, Object.ExGraphFlags(a1) | bit0: 1, need to update SCB1
                                        | bit1: 1, do not use extra graph
                                        | bit2: 1, 使用缓移层背景
                                        | bit3: ?
                                        | bit4: 1, use own Shrinking, do not set InScreenX,Y 倒影用
                                        | bit5: 1, visible during freeze
                                        | bit7: 1, use sub SCB3 buf
        movea.l (sp)+, a0               | pop a0
        move.b  1(a0), Object.selfBuf2+1(a1)
        move.w  2(a0), Object.OriX(a1)  | 贴图原点(十字)的横坐标, 区域逻辑位置, 像素单位
        move.w  4(a0), Object.OriY(a1)  | 贴图原点(十字)的纵坐标, 区域逻辑高度, 像素单位
        movem.l (sp)+, d1/a1            | popad

_GetNextMov_skipRet:                               | CODE XREF: GetNextMov+172j
        addq.l  #6, a0
        rts
| ---------------------------------------------------------------------------

_GetNextMov_getBox:                                
        move.w  (a0), d0                | FD
        andi.w  #3, d0                  | d0: type | box index (2 bits)
        mulu.w  #5, d0
        move.l  a1, -(sp)               | push a1
        lea     Object.Box0(a4), a1
        adda.w  d0, a1
        move.w  (a0)+, d0
        andi.w  #0xFC, d0
        lsr.w   #2, d0                  | /4
        move.b  d0, (a1)+               | box.Type
        move.b  (a0)+, (a1)+            | box.X
        move.b  (a0)+, (a1)+            | box.Y
        move.b  (a0)+, (a1)+            | box.width
        move.b  (a0)+, (a1)+            | box.height
        movea.l (sp)+, a1               | pop a1
        rts
| End of function GetNextMov


GetMovOffset:


Set_5050_0:                             
        move.w  #0x5050, A5Seg.TempGraphLevel(a5)
        clr.b   A5Seg.TempExGraphMask(a5)
        rts
| ---------------------------------------------------------------------------

Set_5001_20:                           
        move.w  #0x5001, A5Seg.TempGraphLevel(a5)
        move.b  #0x20, A5Seg.TempExGraphMask(a5)
        rts
| ---------------------------------------------------------------------------

Set_5050_20:                           
        move.w  #0x5050, A5Seg.TempGraphLevel(a5)
        move.b  #0x20, A5Seg.TempExGraphMask(a5)
        rts


ExtendEffectPropareTable:
		.long Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0| 0                                        
        .long Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0| 16
        .long Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0| 32
        .long Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5001_20, Set_5001_20, Set_5050_0, Set_5050_0, Set_5001_20, Set_5001_20, Set_5001_20, Set_5001_20| 48
        .long Set_5001_20, Set_5001_20, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_20, Set_5001_20, Set_5050_0, Set_5001_20, Set_5050_0| 64
        .long Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0| 80
        .long Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0| 96
        .long Set_5050_0, Set_5050_0, Set_5001_20, Set_5001_20, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5001_20, Set_5001_20, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0| 112
        .long Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0| 128
        .long Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5001_20, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0| 144
        .long Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0| 160
        .long Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0| 176
        .long Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0| 192
        .long Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0| 208
        .long Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0| 224
        .long Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0, Set_5050_0| 240
| ---------------------------------------------------------------------------

ExtendEffectRoutineTable:
		.long EffectRoutine0            | 0, hit spark
        .long EffectRoutine0            | 0, hit spark
        .long EffectRoutine0            | 0, hit spark
        .long EffectRoutine3            | 3, blood spark
        .long EffectRoutine3            | 3, blood spark
        .long EffectRoutine3            | 3, blood spark
