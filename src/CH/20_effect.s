.include	"def.inc"
.globl		EffectRoutine0
.globl		EffectRoutine3
.globl		EffectRoutine6
.globl		EffectRoutine7

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

EffectRoutine1a:                        | 1a, dust
        move.w  #0x10, Object.Z(a4)     
        move.w  #0x20, Object.ChCode(a4)
        move.w  Object.selfBuf2(a4), d0
        addi.w  #0x1C, d0
        move.w  d0, Object.ActCode(a4)
        bra.w   EffectRoutineContinueEX
| ---------------------------------------------------------------------------

EffectRoutine1d:                       | 1d, blood explode
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
