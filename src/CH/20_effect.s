.include	"def.inc"
.globl		EffectRoutine0
.globl		EffectRoutine3
.globl		EffectRoutine6
.globl		EffectRoutine7
.globl		EffectRoutine8 
.globl		EffectRoutine9 
.globl		EffectRoutineA 
.globl		EffectRoutineF 
.globl		EffectRoutine10
.globl		EffectRoutine11
.globl		EffectRoutine12
.globl		EffectRoutine17
.globl		EffectRoutine1A
.globl		EffectRoutine1D
.globl		EffectRoutine23
.globl		EffectRoutine25
.globl		EffectRoutine26
.globl		EffectRoutine27
.globl		EffectRoutine28
.globl		EffectRoutine29
.globl		EffectRoutine2A
.globl		EffectRoutine2B
.globl		EffectRoutine2C
.globl		EffectRoutine2D
.globl		EffectRoutine2E
.globl		EffectRoutine2F
.globl		EffectRoutine30
.globl		EffectRoutine31
.globl		EffectRoutine32
.globl		EffectRoutine33               
.globl		EffectRoutine34
.globl		EffectRoutine35
.globl		EffectRoutine36
.globl		EffectRoutine38
.globl		EffectRoutine39
.globl		EffectRoutine3A
.globl		EffectRoutine3C
.globl		EffectRoutine3D
.globl		EffectRoutine3E
.globl		EffectRoutine3F
.globl		EffectRoutine40
.globl		EffectRoutine41
.globl		EffectRoutine42
.globl		EffectRoutine43
.globl		EffectRoutine44
.globl		EffectRoutine45
.globl		EffectRoutine46
.globl		EffectRoutine47
.globl		EffectRoutine48
.globl		EffectRoutine3A
.globl		EffectRoutine4A
.globl		EffectRoutine4B
.globl		EffectRoutine4D
.globl		EffectRoutine4E
.globl		EffectRoutine4F
.globl		EffectRoutine50
.globl		EffectRoutine51
.globl		EffectRoutine52
.globl		EffectRoutine53
.globl		EffectRoutine54
.globl		EffectRoutine55           
.globl		EffectRoutine56           
.globl		EffectRoutine57
.globl		EffectRoutine58
.globl		EffectRoutine59
.globl		EffectRoutine5B
.globl		EffectRoutine60
.globl		EffectRoutine61
.globl		EffectRoutine62
.globl		EffectRoutine63
.globl		EffectRoutine64
.globl		EffectRoutine65
.globl		EffectRoutine66
.globl		EffectRoutine67
.globl		EffectRoutine68
.globl		EffectRoutine69
.globl		EffectRoutine6A
.globl		EffectRoutine6B
.globl		EffectRoutine6C
.globl		EffectRoutine6D
.globl		EffectRoutine6E
.globl		EffectRoutine6F
.globl		EffectRoutine70
.globl		EffectRoutine71
.globl		EffectRoutine72
.globl		EffectRoutine73
.globl		EffectRoutine74
.globl		EffectRoutine75
.globl		EffectRoutine76
.globl		EffectRoutine77
.globl		EffectRoutine78
.globl		EffectRoutine79
.globl		EffectRoutine7A
.globl		EffectRoutine7B
.globl		EffectRoutine7C
.globl		EffectRoutine80
.globl		EffectRoutine81
.globl		EffectRoutine82
.globl		EffectRoutine83
.globl		EffectRoutine84
.globl		EffectRoutine85
.globl		EffectRoutine88
.globl		EffectRoutine8B
.globl		EffectRoutine8C
.globl		EffectRoutine8F
.globl		EffectRoutine90
.globl		EffectRoutine91
.globl		EffectRoutine92
.globl		EffectRoutine93
.globl		EffectRoutine94
.globl		EffectRoutine95
.globl		EffectRoutine96
.globl		EffectRoutine97
.globl		EffectRoutine98
.globl		EffectRoutine99
.globl		EffectRoutine9A
.globl		EffectRoutine9B
.globl		EffectRoutine9C
.globl		EffectRoutine9D
.globl		EffectRoutine9E
.globl		EffectRoutine9F
.globl		EffectRoutineA0
.globl		EffectRoutineA1
.globl		EffectRoutineA2
.globl		EffectRoutineA3
.globl		EffectRoutineA4
.globl		EffectRoutineA5
.globl		EffectRoutineA6
.globl		EffectRoutineA7
.globl		EffectRoutineA8
.globl		EffectRoutineA9
.globl		EffectRoutineAA
.globl		EffectRoutineAB
.globl		EffectRoutineAC
.globl		EffectRoutineAD
.globl		EffectRoutineAE
.globl		EffectRoutineAF
.globl		EffectRoutineB0
.globl		EffectRoutineB1
.globl		EffectRoutineB2
.globl		EffectRoutineB3
.globl		EffectRoutineB4
.globl		EffectRoutineB5
.globl		EffectRoutineB6
.globl		EffectRoutineB7
.globl		EffectRoutineB8
.globl		EffectRoutineB9
.globl		EffectRoutineBA
.globl		EffectRoutineBB
.globl		EffectRoutineBC
.globl		EffectRoutineBD
.globl		EffectRoutineBE
.globl		EffectRoutineBF
.globl		EffectRoutineC0
.globl		EffectRoutineC1
.globl		EffectRoutineC2
.globl		EffectRoutineC3
.globl		EffectRoutineC4
.globl		EffectRoutineC5
.globl		EffectRoutineC6
.globl		EffectRoutineC7
.globl		EffectRoutineC8
.globl		EffectRoutineC9

EffectRoutine0:                         | 0, hit spark
        move.w  #0x10, Object.Z(a4)     
        move.w  #0x20, Object.ChCode(a4)
        move.w  Object.selfBuf2(a4), Object.ActCode(a4)
        movea.l Object.ParentObj(a4), a3
        btst    #4, Object.RoleStatusFlags(a3)  | bit4: 1, 曝气中
        beq.w   EffectRoutineContinue
        addq.w  #3, Object.ActCode(a4)
        bra.w   EffectRoutineContinue

EffectRoutine3:                         | 3, blood spark
        subq.w  #3, Object.selfBuf2(a4) 
|        tst.b   A5Seg.BloodColor(a5)    | bit7: 0, show blood effect
|        bmi.s   EffectRoutine0          | 0, hit spark
        move.w  #0x10, Object.Z(a4)     
        move.w  #0x20, Object.ChCode(a4)
        move.w  Object.selfBuf2(a4), Object.ActCode(a4)
        addi.w  #9, Object.ActCode(a4)
        bra.w   EffectRoutineContinueEX

EffectRoutine6:                         | 6, ice ?
        jsr     GetByteRandVal          
        tst.b   d0
        bpl.w   EffectDestroy
        move.w  #0x10, Object.Z(a4)     
        move.w  #0x20, Object.ChCode(a4)
        move.w  #0x27, Object.ActCode(a4)
        bra.w   EffectRoutineContinueEX

EffectRoutine7:                         | 7, big blood
        jsr     GetByteRandVal          
        tst.b   d0
        bpl.w   EffectDestroy
        move.w  #0x10, Object.Z(a4)     
        move.w  #0x20, Object.ChCode(a4) 
        move.w  #0x28, Object.ActCode(a4)
|        tst.b   A5Seg.BloodColor(a5)    | bit7: 0, show blood effect
|        bmi.w   EffectRoutineContinueEX
        andi.w  #1, d0
        beq.w   EffectRoutineContinueEX
        move.w  #0x2E, Object.ActCode(a4)
        bra.w   EffectRoutineContinueEX

EffectRoutine8:                         | 8, big ice ?
        jsr     GetByteRandVal          
        tst.b   d0
        bpl.w   EffectDestroy
        move.w  #0x10, Object.Z(a4)    
        move.w  #0x20, Object.ChCode(a4)
        move.w  #0x28, Object.ActCode(a4)
|        tst.b   A5Seg.BloodColor(a5)    | bit7: 0, show blood effect
|        bmi.w   EffectRoutineContinueEX
        andi.w  #1, d0
        beq.w   EffectRoutineContinueEX
        move.w  #0x2B, Object.ActCode(a4)
        bra.w   EffectRoutineContinueEX

EffectRoutine9:                         | 9, big hit spark
        move.w  #0x10, Object.Z(a4)     
        move.w  #0x20, Object.ChCode(a4)
        move.w  #2, Object.ActCode(a4)
        movea.l Object.ParentObj(a4), a3
        btst    #4, Object.RoleStatusFlags(a3) | bit4: 1, 曝气中
        beq.w   EffectRoutineContinue
        move.w  #5, Object.ActCode(a4)
        bra.w   EffectRoutineContinue

EffectRoutineA:                         | a, explode
        move.w  #0x10, Object.Z(a4)     
        move.w  #0x20, Object.ChCode(a4)
        move.w  Object.selfBuf2(a4), d0
        addi.w  #0xC, d0
        move.w  d0, Object.ActCode(a4)
        bra.w   EffectRoutineContinueEX

EffectRoutineF:                         | f, small fire
        move.w  #0x10, Object.Z(a4)     
        move.w  #0x20, Object.ChCode(a4)
        move.w  #0x1B, Object.ActCode(a4)
        bra.w   EffectRoutineContinueEX

EffectRoutine10:                        | 10, blow fire
        move.w  #0x10, Object.Z(a4)     
        move.w  #0x20, Object.ChCode(a4)
        move.w  #0x1C, Object.ActCode(a4)
        bra.w   EffectRoutineContinueEX

EffectRoutine11:                        | 11, blow spark
        move.w  #0x10, Object.Z(a4)     
        move.w  #0x20, Object.ChCode(a4)
        move.w  #0xC, Object.ActCode(a4)
        bra.w   EffectRoutineContinueEX

EffectRoutine12:                        | 12, elect
        move.w  #0x10, Object.Z(a4)     

loc_2B4C4:                              
        move.w  #0x20, Object.ChCode(a4)
        move.w  Object.selfBuf2(a4), d0
        addi.w  #0xB, d0
        move.w  d0, Object.ActCode(a4)
        bra.w   EffectRoutineContinueEX
| ---------------------------------------------------------------------------

EffectRoutine17:                        | 17, on ground with sound
        move.w  #0x75, d0               
        jsr     SET_SOUND               
        move.w  #0xFFF0, Object.Z(a4)   
        bra.s   loc_2B4C4

EffectRoutine55:                        | 55, on ground 1
        move.w  #0x20, Object.ChCode(a4) 
        move.w  #0x22, Object.ActCode(a4)
        move.w  #0xFFF0, Object.Z(a4)   
        bra.w   EffectRoutineContinueEX
| ---------------------------------------------------------------------------

EffectRoutine56:                        | 56, on ground 2
        move.w  #0x20, Object.ChCode(a4) 
        move.w  #0x23, Object.ActCode(a4)
        move.w  #0x10, Object.Z(a4)     
        bra.w   EffectRoutineContinueEX
| ---------------------------------------------------------------------------

EffectRoutine57:                        | 57, on ground 3
        move.w  #0x20, Object.ChCode(a4) 
        move.w  #0x24, Object.ActCode(a4)
        move.w  #0xFFF0, Object.Z(a4)  
        bra.w   EffectRoutineContinueEX
| ---------------------------------------------------------------------------

EffectRoutine1A:                        | 1a, dust
        move.w  #0x10, Object.Z(a4)     
        move.w  #0x20, Object.ChCode(a4)
        move.w  Object.selfBuf2(a4), d0
        addi.w  #0x1C, d0
        move.w  d0, Object.ActCode(a4)
        bra.w   EffectRoutineContinueEX
| ---------------------------------------------------------------------------

EffectRoutine1D:                       | 1d, blood explode
        move.w  #0x10, Object.Z(a4)     
        move.w  #0x20, Object.ChCode(a4)
        move.w  Object.selfBuf2(a4), d0
        addi.w  #0x13, d0
        move.w  d0, Object.ActCode(a4)
        bra.w   EffectRoutineContinueEX

EffectRoutine23:                        | 23, explode with dust
        move.w  #0x10, Object.Z(a4)     
        move.w  #0x20, Object.ChCode(a4)
        move.w  Object.selfBuf2(a4), d0
        addi.w  #0x18, d0
        move.w  d0, Object.ActCode(a4)
        bra.w   EffectRoutineContinueEX
| ---------------------------------------------------------------------------

EffectRoutine25:                        | 25, flash creen
        move.b  #1, A5Seg.FlashScreenTypeIndex(a5) 
        jmp     FreeObjBlock           

EffectRoutine26:                        | 26, big ice ?
        move.w  #0x10, Object.Z(a4)     
        move.w  #0x20, Object.ChCode(a4)
        move.w  #0x28, Object.ActCode(a4)
        bra.w   EffectRoutineContinueEX

EffectRoutine27:                       | 27, blow spark
        move.w  #0x10, Object.Z(a4)     
        move.w  #0x20, Object.ChCode(a4)
        move.w  #0x40, Object.ActCode(a4)
        bra.w   EffectRoutineContinueEX
| ---------------------------------------------------------------------------

EffectRoutine28:                        | 28, shake screen 1
        jsr     InitShakeScreenObj      
        jmp     FreeObjBlock            
| ---------------------------------------------------------------------------

EffectRoutine29:                        | 29, shake screen 2
        jsr     InitShakeScreen2Obj     
        jmp     FreeObjBlock           
| ---------------------------------------------------------------------------

EffectRoutine2A:                        | 2a, shake screen 3
        jsr     InitShakeScreen3Obj     
        jmp     FreeObjBlock          

EffectRoutine2B:                        | 2B, adv mode, power max
        move.w  #0x10, Object.Z(a4)     
        move.w  #0x20, Object.ChCode(a4)
        move.w  #0x4B, Object.ActCode(a4)
        bra.w   EffectRoutineContinueEX

EffectRoutine2C:                        | 2c, land on ground sound
        movea.l Object.ParentObj(a4), a0 
        move.w  Object.ChCode(a0), Object.ChCode(a4)
|        jsr     LoadLandGroundSound     | sound when role land on ground from air
        jmp     FreeObjBlock            



EffectRoutine2D:                        | 2d, hit spark with sound (big)
        move.w  #0x68, d0               
        movea.l Object.ParentObj(a4), a3
        btst    #4, Object.RoleStatusFlags(a3)  | bit4: 1, 曝气中
        beq.s   loc_2B628
        move.w  #0x69, d0
        bra.s   loc_2B628
| ---------------------------------------------------------------------------

EffectRoutine2E:                        | 2e, hit spark with sound
        move.w  #0x62, d0               
        movea.l Object.ParentObj(a4), a3
        btst    #4, Object.RoleStatusFlags(a3) | bit4: 1, 曝气中
        beq.s   loc_2B628
        move.w  #0x66, d0

loc_2B628:                              
        jsr     SET_SOUND               
        move.b  #1, A5Seg.FlashScreenTypeIndex(a5)
        move.w  #2, Object.selfBuf2(a4)
        bra.w   EffectRoutine0          | 0, hit spark
| ---------------------------------------------------------------------------
EffectRoutine2F:                        | 2f, hit spark with sound
        move.w  #0x63, d0               
        movea.l Object.ParentObj(a4), a3
        btst    #4, Object.RoleStatusFlags(a3) | bit4: 1, 曝气中
        beq.s   loc_2B628
        move.w  #0x67, d0
        bra.s   loc_2B628

EffectRoutine30:                       | 30, hit spark with sound
        move.w  #0x62, d0               
        movea.l Object.ParentObj(a4), a3
        btst    #4, Object.RoleStatusFlags(a3)| bit4: 1, 曝气中                                      
        beq.s   loc_2B666
        move.w  #0x66, d0

loc_2B666:                              
        jsr     SET_SOUND               
        move.w  #2, Object.selfBuf2(a4)
        bra.w   EffectRoutine0          | 0, hit spark
| ---------------------------------------------------------------------------

EffectRoutine31:                        | 31, hit spark with sound
        move.w  #0x63, d0               
        movea.l Object.ParentObj(a4), a3
        btst    #4, Object.RoleStatusFlags(a3)  | bit4: 1, 曝气中
        beq.s   loc_2B666
        move.w  #0x67, d0
        bra.s   loc_2B666
| ---------------------------------------------------------------------------

EffectRoutine32:                        | 32, hit spark with sound 
        move.w  #0x68, d0              
        movea.l Object.ParentObj(a4), a3
        btst    #4, Object.RoleStatusFlags(a3)  | bit4: 1, 曝气中
        beq.s   loc_2B666
        move.w  #0x69, d0
        bra.s   loc_2B666
| ---------------------------------------------------------------------------

EffectRoutine33:               
EffectRoutine34:
EffectRoutine35:
EffectRoutine36:
EffectRoutine38:
EffectRoutine39:
EffectRoutine3A:
EffectRoutine3C:
EffectRoutine3D:
EffectRoutine3E:
EffectRoutine3F:
EffectRoutine40:
EffectRoutine41:
EffectRoutine42:
EffectRoutine43:
EffectRoutine44:
EffectRoutine45:
EffectRoutine46:
EffectRoutine47:
EffectRoutine48:
EffectRoutine3A:
EffectRoutine4A:
EffectRoutine4B:
EffectRoutine4D:
EffectRoutine4E:
EffectRoutine4F:
EffectRoutine50:
EffectRoutine51:
EffectRoutine52:
EffectRoutine53:
EffectRoutine54:
EffectRoutine58:
EffectRoutine59:
EffectRoutine5B:
EffectRoutine60:
EffectRoutine61:
EffectRoutine62:
EffectRoutine63:
EffectRoutine64:
EffectRoutine65:
EffectRoutine66:
EffectRoutine67:
EffectRoutine68:
EffectRoutine69:
EffectRoutine6A:
EffectRoutine6B:
EffectRoutine6C:
EffectRoutine6D:
EffectRoutine6E:
EffectRoutine6F:
EffectRoutine70:
EffectRoutine71:
EffectRoutine72:
EffectRoutine73:
EffectRoutine74:
EffectRoutine75:
EffectRoutine76:
EffectRoutine77:
EffectRoutine78:
EffectRoutine79:
EffectRoutine7A:
EffectRoutine7B:
EffectRoutine7C:
EffectRoutine80:
EffectRoutine81:
EffectRoutine82:
EffectRoutine83:
EffectRoutine84:
EffectRoutine85:
EffectRoutine88:
EffectRoutine8B:
EffectRoutine8C:
EffectRoutine8F:
EffectRoutine90:
EffectRoutine91:
EffectRoutine92:
EffectRoutine93:
EffectRoutine94:
EffectRoutine95:
EffectRoutine96:
EffectRoutine97:
EffectRoutine98:
EffectRoutine99:
EffectRoutine9A:
EffectRoutine9B:
EffectRoutine9C:
EffectRoutine9D:
EffectRoutine9E:
EffectRoutine9F:
EffectRoutineA0:
EffectRoutineA1:
EffectRoutineA2:
EffectRoutineA3:
EffectRoutineA4:
EffectRoutineA5:
EffectRoutineA6:
EffectRoutineA7:
EffectRoutineA8:
EffectRoutineA9:
EffectRoutineAA:
EffectRoutineAB:
EffectRoutineAC:
EffectRoutineAD:
EffectRoutineAE:
EffectRoutineAF:
EffectRoutineB0:
EffectRoutineB1:
EffectRoutineB2:
EffectRoutineB3:
EffectRoutineB4:
EffectRoutineB5:
EffectRoutineB6:
EffectRoutineB7:
EffectRoutineB8:
EffectRoutineB9:
EffectRoutineBA:
EffectRoutineBB:
EffectRoutineBC:
EffectRoutineBD:
EffectRoutineBE:
EffectRoutineBF:
EffectRoutineC0:
EffectRoutineC1:
EffectRoutineC2:
EffectRoutineC3:
EffectRoutineC4:
EffectRoutineC5:
EffectRoutineC6:
EffectRoutineC7:
EffectRoutineC8:
EffectRoutineC9:
		jmp		NotImplemnent

EffectRoutineContinueEX:                
        movea.l Object.ParentObj(a4), a3

EffectRoutineContinue:                 
        move.w  Object.Z(a3), d0        | bit 0~2: 同一图层中的细比较
                                        | bit4以上: 在 Zbuf 中的索引
        add.w   d0, Object.Z(a4)        | bit 0~2: 同一图层中的细比较
                                        | bit4以上: 在 Zbuf 中的索引
        move.b  Object.IsFaceToRight(a3), Object.IsFaceToRight(a4) | bit0: Horizontal flip
                                        | bit1: Vertical flip
                                        | bit2: 2bit Auto-anim
                                        | bit3: 3bit Auto-anim
                                        | 实际上是SCB1 tile 第二word 的低字节属性
        move.w  Object.OriX(a4), d0     | 贴图原点(十字)的横坐标, 区域逻辑位置, 像素单位
        btst    #0, Object.IsFaceToRight(a3) | bit0: Horizontal flip
                                        | bit1: Vertical flip
                                        | bit2: 2bit Auto-anim
                                        | bit3: 3bit Auto-anim
                                        | 实际上是SCB1 tile 第二word 的低字节属性
        beq.s   loc_2B2A6
        neg.w   d0

loc_2B2A6:                              | CODE XREF: EffectRoutine0-A4j
        add.w   Object.OriX(a3), d0     | 贴图原点(十字)的横坐标, 区域逻辑位置, 像素单位
        move.w  d0, Object.OriX(a4)     | 贴图原点(十字)的横坐标, 区域逻辑位置, 像素单位
        move.w  Object.OriY(a3), d0     | 贴图原点(十字)的纵坐标, 区域逻辑高度, 像素单位
        add.w   d0, Object.OriY(a4)     | 贴图原点(十字)的纵坐标, 区域逻辑高度, 像素单位
        move.w  Object.YFromGround(a3), Object.YFromGround(a4) | 起跳时距离地面高度, 像素单位
        move.b  #0xFF, Object.PrevActCode(a4)
        move.w  #0xFFFF, Object.RoleShrinkRate(a4) | 人物整体比例

SetEffectWait:                         
        move.l  #EffectWait, Object(a4)

EffectWait:                             
        tst.b   Object.HitBoxFlag(a4)   | bit0: 1, have hit box 0
                                        | bit1: 1, have hit box 1
                                        | bit2: 1, have hit box 2
                                        | bit3: 1, have hit box 3
                                        | bit4: 1, 曝气效果, 破空防
                                        | bit5: 1, 飞行道具的非最后1hit
                                        | bit6: 1, 碰撞发生后持续清除box0(不参与下一帧后的检测)
                                        | bit7: 1, Act end
        bmi.s   EffectDestroy
        jsr     GetNextMov              | ret:
                                        |     d0: 0, done;
                                        |        -1, new graph info loaded
        jmp     InsertIntoObjZBuf       | params:
                                        |     a4: obj
                                        | ret:
                                        |     d6: 0, done; -1: fail
| ---------------------------------------------------------------------------

EffectDestroy:                          | CODE XREF: EffectRoutine0-74j
                                        | ROM:0002B32Cj ...
        jmp     FreeObjBlock            | params:
| END OF FUNCTION CHUNK FOR EffectRoutine0 |     a4: Obj


InitShakeScreenObj:                     
        lea     (ShakeScreenRoutine).l, a0
        move.w  #0x50FF, d0
        jsr     (AllocateObjBlock).l    
        move.l  a4, Object.ParentObj(a1)
        move.w  #0xA, Object.selfBuf1(a1) | 持续时间
        move.w  #0xFFFC, Object.selfBuf1+2(a1) | Y镜头偏移
        rts


InitShakeScreen2Obj:                    
        lea     (ShakeScreenRoutine).l, a0
        move.w  #0x50FF, d0
        jsr     (AllocateObjBlock).l    
        move.l  a4, Object.ParentObj(a1)
        move.w  #0xF, Object.selfBuf1(a1)
        move.w  #0xFFFA, Object.selfBuf1+2(a1)
        rts


InitShakeScreen3Obj:                    
        lea     (ShakeScreenRoutine).l, a0
        move.w  #0x50FF, d0
        jsr     (AllocateObjBlock).l   
        move.l  a4, Object.ParentObj(a1)
        move.w  #0x14, Object.selfBuf1(a1)
        move.w  #0xFFF8, Object.selfBuf1+2(a1)
        rts

ShakeScreenRoutine:                     
        move.l  #_ShakeScreenRoutine_step2, Object(a4)
|        moveq   #0, d0
|        move.b  A5Seg.BackgroundId(a5), d0 | 对战场地选择，0～7
|        add.w   d0, d0
|        add.w   d0, d0
|        lea     off_2AAA6, a0
|        movea.l (a0,d0.w), a0
|        jsr     (a0)

_ShakeScreenRoutine_step2:                                 
        move.w  Object.selfBuf1+2(a4), d1 | Y camera delta
        bchg    #0, Object.selfBuf1+4(a4)
        beq.s   loc_2AA90
        moveq   #0, d1

loc_2AA90:                              
        move.w  d1, A5Seg.GlobalCamaraYDelta(a5) | 全局镜头的Y偏移, 如地震效果等, neg 表示镜头上移
        subq.w  #1, Object.selfBuf1(a4) | time
        beq.s   _ShakeScreenRoutine_destroy
        rts
| ---------------------------------------------------------------------------

_ShakeScreenRoutine_destroy:                               
        clr.w   A5Seg.GlobalCamaraYDelta(a5) | 全局镜头的Y偏移, 如地震效果等, neg 表示镜头上移
        jmp     FreeObjBlock            | params:
| End of function ShakeScreenRoutine    |     a4: Obj
