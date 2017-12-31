.include	"def.inc"
.globl		EffectRoutine0
.globl		EffectRoutine3

EffectRoutine0:                         
        move.w  #0x10, Object.Z(a4)     | 0, hit spark
        move.w  #0x20, Object.ChCode(a4)
        move.w  Object.selfBuf2(a4), Object.ActCode(a4)
        movea.l Object.ParentObj(a4), a3
        btst    #4, Object.RoleStatusFlags(a3) | bit0: 1, 出招中
                                        | bit1: 1, 空中
                                        | bit2: 1, 蹲
                                        | bit3: 1, 小跳
                                        | bit4: 1, 曝气中
                                        | bit5: 1, thrower
                                        | bit6: 1, throwee
                                        | bit7: 1, 影跳
        beq.w   EffectRoutineContinue
        addq.w  #3, Object.ActCode(a4)
        bra.w   EffectRoutineContinue

EffectRoutine3:

EffectRoutineContinue:
