.include "def.inc"
.globl      ClearFixlay

ClearFixlay:                                                                    
        lea     (REG_VRAMRW).l, a0        | REG_VRAMRW
        move.w  #0x7002, d0
        move.w  d0, d3
        moveq   #0x27, d1               | loop time 0x28

_fix_out_dbfLoop:                              
        moveq   #0x1B, d2               | loop time 0x1c

_fix_in_dbfLoop:                               
        move.w  d3, -2(a0)              | REG_VRAMADDR
        move.w  #0xF20, (a0)
        addq.w  #1, d3
        dbf     d2, _fix_in_dbfLoop            
        addi.w  #0x20, d0               | to next cloumn
        move.w  d0, d3
        dbf     d1, _fix_out_dbfLoop          | loop time 0x1c

        st      A5Seg.TextOutputDefaultPalIndex(a5) | bit0~4: Pal index
                                        | bit7: 0, use this index
        rts