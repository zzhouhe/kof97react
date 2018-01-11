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
        tst.b   Object.HitBoxFlag(a4)      | bit7: 1, Act end
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

_GetNextMov_setSpanTime:                          
        move.b  d0, Object.SpanTime(a4)
        move.b  1(a0), Object.HitSpecialStatus(a4) 
        move.b  4(a0), Object.HitBoxFlag(a4) 
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
        jsr     SET_SOUND              
        movem.l (sp)+, d1-d2/a0-a1
        lea     6(a0), a0
        rts


_GetNextMov_deltaX:                                
        move.w  2(a0), d0
        btst    #0, Object.IsFaceToRight(a4) | bit0: Horizontal flip
        beq.s   _GetNextMov_loc_59B0
        neg.w   d0

_GetNextMov_loc_59B0:                              
        add.w   d0, Object.OriX(a4)     
        addq.l  #6, a0
        rts
| ---------------------------------------------------------------------------

_GetNextMov_loadGraph:                             
        btst    #1, Object.ExGraphFlags(a4) | bit1: 1, do not use extra graph
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


| ret:
|     a0: Mov offset

GetMovOffset:                           
        move.w  Object.ChCode(a4), d1
        move.w  Object.ActCode(a4), d2
        lea     (CHActionTableDirectory).l, a0
        add.w   d1, d1
        add.w   d1, d1
        movea.l (a0,d1.w), a0           | a0: ACT table
        add.w   d2, d2
        move.w  (a0,d2.w), d2           | d2: ACT entry
        move.w  #1, d0

_GetMovOffset_swithLoop:                             | CODE XREF: GetMovOffset+2Cj
        move.w  d0, (0x2FFFFE).l        | BankSwitch(1)
                                        | 将p2 rom 从 100000 offset 载入到 0x200000, 0x2FFFFF 位置
                                        | p2 rom 未加密, 此时检测内存 0x200000 位置可以看到 p2 rom 的 100000 offset 镜像
        cmp.w   (0x200000).l, d0
        bne.s   _GetMovOffset_swithLoop              | switch 失败则重新加载
        lea     (0x250000).l, a0        | == p2rom offset: 150000
        move.l  (a0,d1.w), Object.pGraphDataSubmenuBase(a4) | 此 Obj 的 SCB1 数据的起始地址
                                        | (调色盘, 解析方法, 宽度, 高度, 数据...)
        move.w  #2, d0

__GetMovOffset_swithLoop:                            | CODE XREF: GetMovOffset+4Aj
        move.w  d0, (0x2FFFFE).l        | BankSwitch(2)
        cmp.w   (0x200000).l, d0
        bne.s   __GetMovOffset_swithLoop             | BankSwitch(2)
        lea     (0x200002).l, a0        | == p2rom offset: 200002
        movea.l (a0,d1.w), a0           | 人物初始地址
        add.w   d2, d2
        add.w   d2, d2
        movea.l (a0,d2.w), a0           | a0: Act Base
        adda.w  Object.MovOffsetFromActBase(a4), a0 | 在 bank(2), 基于 ACT base 的偏移
        rts
| End of function GetMovOffset


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
        .long EffectRoutine6            | 6, ice ?
        .long EffectRoutine7            | 7, big blood
        .long EffectRoutine8            | 8, big ice ?
        .long EffectRoutine9            | 9, big hit spark
        .long EffectRoutineA            | a, explode
        .long EffectRoutineA            | a, explode
        .long EffectRoutineA            | a, explode
        .long EffectRoutineA            | a, explode
        .long EffectRoutineA            | a, explode
        .long EffectRoutineF            | f, small fire
        .long EffectRoutine10           | 10, blow fire
        .long EffectRoutine11           | 11, blow spark
        .long EffectRoutine12           | 12, elect
        .long EffectRoutine12           | 12, elect
        .long EffectRoutine12           | 12, elect
        .long EffectRoutine12           | 12, elect
        .long EffectRoutine12           | 12, elect
        .long EffectRoutine17           | 17, on ground with sound
        .long EffectRoutine12           | 12, elect
        .long EffectRoutine17           | 17, on ground with sound
        .long EffectRoutine1A           | 1a, dust
        .long EffectRoutine1A           | 1a, dust
        .long EffectRoutine1A           | 1a, dust
        .long EffectRoutine1D           | 1d, blood explode
        .long EffectRoutine1D           | 1d, blood explode
        .long EffectRoutine1D           | 1d, blood explode
        .long EffectRoutine1D           | 1d, blood explode
        .long EffectRoutine1D           | 1d, blood explode
        .long EffectRoutine1D           | 1d, blood explode
        .long EffectRoutine23           | 23, explode with dust
        .long EffectRoutine23           | 23, explode with dust
        .long EffectRoutine25           | 25, flash creen
        .long EffectRoutine26           | 26, big ice ?
        .long EffectRoutine27           | 27, blow spark
        .long EffectRoutine28           | 28, shake screen 1
        .long EffectRoutine29           | 29, shake screen 2
        .long EffectRoutine2A           | 2a, shake screen 3
        .long EffectRoutine2B           | 2B, adv mode, power max
        .long EffectRoutine2C           | 2c, land on ground sound
        .long EffectRoutine2D           | 2d, hit spark with sound (big)
        .long EffectRoutine2E           | 2e, hit spark with sound
        .long EffectRoutine2F           | 2f, hit spark with sound
        .long EffectRoutine30           | 30, hit spark with sound
                                        | Kyo, 6C
        .long EffectRoutine31           | 31, hit spark with sound
                                        | Joe, 6C
        .long EffectRoutine32           | 32, hit spark with sound
                                        | Joe, 6C, last hit
        .long EffectRoutine33           | 33, blood hit spark with sound
                                        | Leona, 6C
        .long EffectRoutine34           | 34, Kyo 6C, throw confirm
        .long EffectRoutine35           | 35, Benimaru 6246C, throw confirm
        .long EffectRoutine36           | 36, 37, Ralf, ACT 165
        .long EffectRoutine36           | 36, 37, Ralf, ACT 165
        .long EffectRoutine38           | 38, chao bi sha rays
        .long EffectRoutine39
        .long EffectRoutine3A
        .long EffectRoutine3A
        .long EffectRoutine3C
        .long EffectRoutine3D
        .long EffectRoutine3E
        .long EffectRoutine3F
        .long EffectRoutine40
        .long EffectRoutine41
        .long EffectRoutine42
        .long EffectRoutine43
        .long EffectRoutine44
        .long EffectRoutine45
        .long EffectRoutine46
        .long EffectRoutine47
        .long EffectRoutine48
        .long EffectRoutine3A
        .long EffectRoutine4A
        .long EffectRoutine4B
        .long EffectRoutine4B
        .long EffectRoutine4D
        .long EffectRoutine4E
        .long EffectRoutine4F
        .long EffectRoutine50
        .long EffectRoutine51
        .long EffectRoutine52
        .long EffectRoutine53
        .long EffectRoutine54
        .long EffectRoutine55           | 55, on ground 1
        .long EffectRoutine56           | 56, on ground 2
        .long EffectRoutine57           | 57, on ground 3
        .long EffectRoutine58
        .long EffectRoutine59
        .long EffectRoutine52
        .long EffectRoutine5B
        .long EffectRoutine5B
        .long EffectRoutine5B
        .long EffectRoutine5B
        .long EffectRoutine5B
        .long EffectRoutine60
        .long EffectRoutine61
        .long EffectRoutine62
        .long EffectRoutine63
        .long EffectRoutine64
        .long EffectRoutine65
        .long EffectRoutine66
        .long EffectRoutine67
        .long EffectRoutine68
        .long EffectRoutine69
        .long EffectRoutine6A
        .long EffectRoutine6B
        .long EffectRoutine6C
        .long EffectRoutine6D
        .long EffectRoutine6E
        .long EffectRoutine6F
        .long EffectRoutine70
        .long EffectRoutine71
        .long EffectRoutine72
        .long EffectRoutine73
        .long EffectRoutine74
        .long EffectRoutine75
        .long EffectRoutine76
        .long EffectRoutine77
        .long EffectRoutine78
        .long EffectRoutine79
        .long EffectRoutine7A
        .long EffectRoutine7B
        .long EffectRoutine7C
        .long EffectRoutine7C
        .long EffectRoutine7C
        .long EffectRoutine7C
        .long EffectRoutine80
        .long EffectRoutine81
        .long EffectRoutine82
        .long EffectRoutine83
        .long EffectRoutine84
        .long EffectRoutine85
        .long EffectRoutine85
        .long EffectRoutine85
        .long EffectRoutine88
        .long EffectRoutine88
        .long EffectRoutine88
        .long EffectRoutine8B
        .long EffectRoutine8C
        .long EffectRoutine8C
        .long EffectRoutine8C
        .long EffectRoutine8F
        .long EffectRoutine90
        .long EffectRoutine91
        .long EffectRoutine92
        .long EffectRoutine93
        .long EffectRoutine94
        .long EffectRoutine95
        .long EffectRoutine96
        .long EffectRoutine97
        .long EffectRoutine98
        .long EffectRoutine99
        .long EffectRoutine9A
        .long EffectRoutine9B
        .long EffectRoutine9C
        .long EffectRoutine9D
        .long EffectRoutine9E
        .long EffectRoutine9F
        .long EffectRoutineA0
        .long EffectRoutineA1
        .long EffectRoutineA2
        .long EffectRoutineA3
        .long EffectRoutineA4
        .long EffectRoutineA5
        .long EffectRoutineA6
        .long EffectRoutineA7
        .long EffectRoutineA8
        .long EffectRoutineA9
        .long EffectRoutineAA
        .long EffectRoutineAB
        .long EffectRoutineAC
        .long EffectRoutineAD
        .long EffectRoutineAE
        .long EffectRoutineAF
        .long EffectRoutineB0
        .long EffectRoutineB1
        .long EffectRoutineB2
        .long EffectRoutineB3
        .long EffectRoutineB4
        .long EffectRoutineB5
        .long EffectRoutineB6
        .long EffectRoutineB7
        .long EffectRoutineB8
        .long EffectRoutineB9
        .long EffectRoutineBA
        .long EffectRoutineBB
        .long EffectRoutineBC
        .long EffectRoutineBD
        .long EffectRoutineBE
        .long EffectRoutineBF
        .long EffectRoutineC0
        .long EffectRoutineC1
        .long EffectRoutineC2
        .long EffectRoutineC3
        .long EffectRoutineC4
        .long EffectRoutineC5
        .long EffectRoutineC6
        .long EffectRoutineC7
        .long EffectRoutineC8
        .long EffectRoutineC9
        .long EffectRoutineC9
        .long EffectRoutineC9

CHActionTableDirectory:
		.long ACTRoleTable 
        .long ACTRoleTable
        .long ACTRoleTable
        .long ACTRoleTable
        .long ACTRoleTable
        .long ACTRoleTable
        .long ACTRoleTable
        .long ACTRoleTable
        .long ACTRoleTable
        .long ACTRoleTable
        .long ACTRoleTable
        .long ACTRoleTable
        .long ACTRoleTable
        .long ACTRoleTable
        .long ACTRoleTable
        .long ACTRoleTable
        .long ACTRoleTable
        .long ACTRoleTable
        .long ACTRoleTable
        .long ACTRoleTable
        .long ACTRoleTable
        .long ACTRoleTable
        .long ACTRoleTable
        .long ACTRoleTable
        .long ACTRoleTable
        .long ACTRoleTable
        .long ACTRoleTable
        .long ACTRoleTable
        .long ACTRoleTable
        .long ACTRoleTable
        .long ACTRoleTable
        .long ACTRoleTable
        .long ACTExtraGraphTable
        .long ACTExtraGraphTable
        .long ACTExtraGraphTable
ACTRoleTable:
		.word 0, 1, 2, 3, 5, 6, 4, 3, 7, 8, 4, 3, 9, 0xA, 4, 0xB| 0
        .word 0xC, 0xD, 0xE, 0xF, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B| 16
        .word 0x1C, 0x1D, 0x1E, 0x1F, 0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x2A, 0x2B, 0x2C, 0x2D, 0x2E, 0x2F| 32
        .word 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3A, 0x3B, 0x3C, 0x3D, 0x3E, 0x3F| 48
        .word 0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4A, 0x4B, 0x4C, 0x4D, 0x4E, 0x4F| 64
        .word 0x50, 0x51, 0x52, 0x52, 0x53, 0x53, 0x53, 0x53, 0x54, 0x55, 0x56, 0x57, 0x57, 0x58, 0x58, 0x58| 80
        .word 0x58, 0x59, 0x5A, 0x5B, 0x5C, 0x5C, 0x5D, 0x5D, 0x5D, 0x5D, 0x5E, 0x5F, 0x60, 0x61, 0x61, 0x62| 96
        .word 0x62, 0x62, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6A, 0x6B, 0x6C, 0x6D, 0x6E, 0x6F| 112
        .word 0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89, 0x8A, 0x8B, 0x8C, 0x8D, 0x8E, 0x8F| 128
        .word 0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97, 0x98, 0x99, 0x9A, 0x9B, 0x9C, 0x9D, 0x9E, 0x9F| 144
        .word 0xA0, 0xA1, 0xA2, 0xA3, 0xA4, 0xA5, 0xA6, 0xA7, 0xA8, 0xA9, 0xAA, 0xAB, 0xAC, 0xAD, 0xAE, 0xAF| 160
        .word 0xB0, 0xB1, 0xB2, 0xB3, 0xB4, 0xB5, 0xB6, 0xB7, 0xB8, 0xB9, 0xBA, 0xBB, 0xBC, 0xBD, 0xBE, 0xBF| 176
        .word 0xC0, 0xC1, 0xC2, 0xC3, 0xC4, 0xC5, 0xC6, 0xC7, 0xC8, 0xC9, 0xCA, 0xCB, 0xCC, 0xCD, 0xCE, 0xCF| 192
        .word 0xD0, 0xD1, 0xD2, 0xD3, 0xD4, 0xD5, 0xD6, 0xD7, 0xD8, 0xD9, 0xDA, 0xDB, 0xDC, 0xDD, 0xDE, 0xDF| 208
        .word 0xE0, 0xE1, 0xE2, 0xE3, 0xE4, 0xE5, 0xE6, 0xE7, 0xE8, 0xE9, 0xEA, 0xEB, 0xEC, 0xED, 0xEE, 0xEF| 224
        .word 0xF0, 0xF1, 0xF2, 0xF3, 0xF4, 0xF5, 0xF6, 0xF7, 0xF8, 0xF9, 0xFA, 0xFB, 0xFC, 0xFD, 0xFE, 0xFF| 240
        .word 0x100, 0x101, 0x102, 0x103, 0x104, 0x105, 0x106, 0x107, 0x108, 0x109, 0x10A, 0x10B, 0x10C, 0x10D, 0x10E, 0x10F| 256
        .word 0x110, 0x111, 0x112, 0x113, 0x114, 0x115, 0x116, 0x117, 0x118, 0x119, 0x11A, 0x11B, 0x11C, 0x11D, 0x11E, 0x11F| 272
        .word 0x120, 0x121, 0x122, 0x123, 0x124, 0x125, 0x126, 0x127, 0x128, 0x129, 0x12A, 0x12B, 0x12C, 0x12D, 0x12E, 0x12F| 288
        .word 0x130, 0x131, 0x132, 0x133, 0x134, 0x135, 0x136, 0x137, 0x138, 0x139, 0x13A, 0x13B, 0x13C, 0x13D, 0x13E, 0x13F| 304
        .word 0x140, 0x141, 0x142, 0x143, 0x144, 0x145, 0x146, 0x147, 0x148, 0x149, 0x14A, 0x14B, 0x14C, 0x14D, 0x14E, 0x14F| 320
        .word 0x150, 0x151, 0x152, 0x153, 0x154, 0x155, 0x156, 0x157, 0x158, 0x159, 0x15A, 0x15B, 0x15C, 0x15D, 0x15E, 0x15F| 336
        .word 0x160, 0x161, 0x162, 0x163, 0x164, 0x165, 0x166, 0x167, 0x168, 0x169, 0x16A, 0x16B, 0x16C, 0x16D, 0x16E, 0x16F| 352
        .word 0x170, 0x171, 0x172, 0x173, 0x174, 0x175, 0x176, 0x177, 0x178, 0x179, 0x17A, 0x17B, 0x17C, 0x17D, 0x17E, 0x17F| 368
        .word 0x180, 0x181, 0x182, 0x183, 0x184, 0x185, 0x186, 0x187, 0x188, 0x189, 0x18A, 0x18B, 0x18C, 0x18D, 0x18E, 0x18F| 384
        .word 0x190, 0x191, 0x192, 0x193, 0x194, 0x195, 0x196, 0x197, 0x198, 0x199, 0x19A, 0x19B, 0x19C, 0x19D, 0x19E, 0x19F| 400
        .word 0x1A0, 0x1A1, 0x1A2, 0x1A3, 0x1A4, 0x1A5, 0x1A6, 0x1A7, 0x1A8, 0x1A9, 0x1AA, 0x1AB, 0x1AC, 0x1AD, 0x1AE, 0x1AF| 416
        .word 0x1B0, 0x1B1, 0x1B2, 0x1B3, 0x1B4, 0x1B5, 0x1B6, 0x1B7, 0x1B8, 0x1B9, 0x1BA, 0x1BB, 0x1BC, 0x1BD, 0x1BE, 0x1BF| 432
        .word 0x1C0, 0x1C1, 0x1C2, 0x1C3, 0x1C4, 0x1C5, 0x1C6, 0x1C7, 0x1C8, 0x1C9, 0x1CA, 0x1CB, 0x1CC, 0x1CD, 0x1CE, 0x1CF| 448
        .word 0x1D0, 0x1D1, 0x1D2, 0x1D3, 0x1D4, 0x1D5, 0x1D6, 0x1D7, 0x1D8, 0x1D9, 0x1DA, 0x1DB, 0x1DC, 0x1DD, 0x1DE, 0x1DF| 464
        .word 0x1E0, 0x1E1, 0x1E2, 0x1E3, 0x1E4, 0x1E5, 0x1E6, 0x1E7, 0x1E8, 0x1E9, 0x1EA, 0x1EB, 0x1EC, 0x1ED, 0x1EE, 0x1EF| 480
        .word 0x1F0, 0x1F1, 0x1F2, 0x1F3, 0x1F4, 0x1F5, 0x1F6, 0x1F7, 0x1F8, 0x1F9, 0x1FA, 0x1FB, 0x1FC, 0x1FD, 0x1FE, 0x1FF| 496
ACTExtraGraphTable:
		.word 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0xA, 0xB, 0xC, 0xD, 0xE, 0xF| 0
        .word 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F| 16
        .word 0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2A, 0x2B, 0x2C, 0x2D, 0x2E, 0x2F| 32
        .word 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3A, 0x3B, 0x3C, 0x3D, 0x3E, 0x3F| 48
        .word 0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4A, 0x4B, 0x4C, 0x4D, 0x4E, 0x4F| 64
        .word 0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x5A, 0x5B, 0x5C, 0x5D, 0x5E, 0x5F| 80
        .word 0x60, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6A, 0x6B, 0x6C, 0x6D, 0x6E, 0x6F| 96
        .word 0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7A, 0x7B, 0x7C, 0x7D, 0x7E, 0x7F| 112
        .word 0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89, 0x8A, 0x8B, 0x8C, 0x8D, 0x8E, 0x8F| 128
        .word 0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97, 0x98, 0x99, 0x9A, 0x9B, 0x9C, 0x9D, 0x9E, 0x9F| 144
        .word 0xA0, 0xA1, 0xA2, 0xA3, 0xA4, 0xA5, 0xA6, 0xA7, 0xA8, 0xA9, 0xAA, 0xAB, 0xAC, 0xAD, 0xAE, 0xAF| 160
        .word 0xB0, 0xB1, 0xB2, 0xB3, 0xB4, 0xB5, 0xB6, 0xB7, 0xB8, 0xB9, 0xBA, 0xBB, 0xBC, 0xBD, 0xBE, 0xBF| 176
        .word 0xC0, 0xC1, 0xC2, 0xC3, 0xC4, 0xC5, 0xC6, 0xC7, 0xC8, 0xC9, 0xCA, 0xCB, 0xCC, 0xCD, 0xCE, 0xCF| 192
        .word 0xD0, 0xD1, 0xD2, 0xD3, 0xD4, 0xD5, 0xD6, 0xD7, 0xD8, 0xD9, 0xDA, 0xDB, 0xDC, 0xDD, 0xDE, 0xDF| 208
        .word 0xE0, 0xE1, 0xE2, 0xE3, 0xE4, 0xE5, 0xE6, 0xE7, 0xE8, 0xE9, 0xEA, 0xEB, 0xEC, 0xED, 0xEE, 0xEF| 224
        .word 0xF0, 0xF1, 0xF2, 0xF3, 0xF4, 0xF5, 0xF6, 0xF7, 0xF8, 0xF9, 0xFA, 0xFB, 0xFC, 0xFD, 0xFE, 0xFF| 240
        .word 0x100, 0x101, 0x102, 0x103, 0x104, 0x105, 0x106, 0x107, 0x108, 0x109, 0x10A, 0x10B, 0x10C, 0x10D, 0x10E, 0x10F| 256
        .word 0x110, 0x111, 0x112, 0x113, 0x114, 0x115, 0x116, 0x117, 0x118, 0x119, 0x11A, 0x11B, 0x11C, 0x11D, 0x11E, 0x11F| 272
        .word 0x120, 0x121, 0x122, 0x123, 0x124, 0x125, 0x126, 0x127, 0x128, 0x129, 0x12A, 0x12B, 0x12C, 0x12D, 0x12E, 0x12F| 288
        .word 0x130, 0x131, 0x132, 0x133, 0x134, 0x135, 0x136, 0x137, 0x138, 0x139, 0x13A, 0x13B, 0x13C, 0x13D, 0x13E, 0x13F| 304
        .word 0x140, 0x141, 0x142, 0x143, 0x144, 0x145, 0x146, 0x147, 0x148, 0x149, 0x14A, 0x14B, 0x14C, 0x14D, 0x14E, 0x14F| 320
        .word 0x150, 0x151, 0x152, 0x153, 0x154, 0x155, 0x156, 0x157, 0x158, 0x159, 0x15A, 0x15B, 0x15C, 0x15D, 0x15E, 0x15F| 336
        .word 0x160, 0x161, 0x162, 0x163, 0x164, 0x165, 0x166, 0x167, 0x168, 0x169, 0x16A, 0x16B, 0x16C, 0x16D, 0x16E, 0x16F| 352
        .word 0x170, 0x171, 0x172, 0x173, 0x174, 0x175, 0x176, 0x177, 0x178, 0x179, 0x17A, 0x17B, 0x17C, 0x17D, 0x17E, 0x17F| 368
        .word 0x180, 0x181, 0x182, 0x183, 0x184, 0x185, 0x186, 0x187, 0x188, 0x189, 0x18A, 0x18B, 0x18C, 0x18D, 0x18E, 0x18F| 384
        .word 0x190, 0x191, 0x192, 0x193, 0x194, 0x195, 0x196, 0x197, 0x198, 0x199, 0x19A, 0x19B, 0x19C, 0x19D, 0x19E, 0x19F| 400
        .word 0x1A0, 0x1A1, 0x1A2, 0x1A3, 0x1A4, 0x1A5, 0x1A6, 0x1A7, 0x1A8, 0x1A9, 0x1AA, 0x1AB, 0x1AC, 0x1AD, 0x1AE, 0x1AF| 416
        .word 0x1B0, 0x1B1, 0x1B2, 0x1B3, 0x1B4, 0x1B5, 0x1B6, 0x1B7, 0x1B8, 0x1B9, 0x1BA, 0x1BB, 0x1BC, 0x1BD, 0x1BE, 0x1BF| 432
        .word 0x1C0, 0x1C1, 0x1C2, 0x1C3, 0x1C4, 0x1C5, 0x1C6, 0x1C7, 0x1C8, 0x1C9, 0x1CA, 0x1CB, 0x1CC, 0x1CD, 0x1CE, 0x1CF| 448
        .word 0x1D0, 0x1D1, 0x1D2, 0x1D3, 0x1D4, 0x1D5, 0x1D6, 0x1D7, 0x1D8, 0x1D9, 0x1DA, 0x1DB, 0x1DC, 0x1DD, 0x1DE, 0x1DF| 464
        .word 0x1E0, 0x1E1, 0x1E2, 0x1E3, 0x1E4, 0x1E5, 0x1E6, 0x1E7, 0x1E8, 0x1E9, 0x1EA, 0x1EB, 0x1EC, 0x1ED, 0x1EE, 0x1EF| 480
        .word 0x1F0, 0x1F1, 0x1F2, 0x1F3, 0x1F4, 0x1F5, 0x1F6, 0x1F7, 0x1F8, 0x1F9, 0x1FA, 0x1FB, 0x1FC, 0x1FD, 0x1FE, 0x1FF| 496

