.include "def.inc"
.globl      ClearFixlay
.globl		SetFixlayText
.globl		SetFixlayTextEx
.globl		FixlayOutputHexVal
.globl		ScreenXYToFixMapVRAMAddr
.globl		FixlayVRAMClear
.globl		LoopFixLayOut

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



| params:
|     a0: ptr to fixlay output struct
SetFixlayText:                                                              
        move.w (a0), d0               
        move.w  d0, d2                
| End of function SetFixlayText

| params:
|     a0: ptr to fixlay output struct
|     d2: offset in SCB1
SetFixlayTextEx:                        
                                        
        addq.l  #2, a0
        tst.b   A5Seg.TextOutputDefaultPalIndex(a5) | bit0~4: Pal index
                                        | bit7: 0, use this index
        bmi.s   _SetFixlayTextEx_doNotUseDefaultPal
        move.b  A5Seg.TextOutputDefaultPalIndex(a5), d1 | bit0~4: Pal index
                                        | bit7: 0, use this index
        andi.w  #0xF, d1                | d1: pal index
        ror.w   #4, d1
        move.b  (a0)+, d0               | d0: pal | tilenum.high
        andi.w  #0xF, d0
        move.b  d0, -(sp)
        move.w  (sp)+, d0
        clr.b   d0
        or.w    d1, d0
        bra.s   loc_6F96
| ---------------------------------------------------------------------------

_SetFixlayTextEx_doNotUseDefaultPal:                    | CODE XREF: SetFixlayTextEx+6j
        move.b  (a0)+, d0
        move.b  d0, -(sp)
        move.w  (sp)+, d0
        clr.b   d0

loc_6F96:                                                                      
        move.w  d2, A5Seg.TextOutputOffset(a5)
        move.w  d0, A5Seg.TextOutputEntryHigh(a5)

loc_6F9E:                               | CODE XREF: SetFixlayTextEx+6Ej
        moveq   #0, d1
        move.b  (a0)+, d1
        cmpi.b  #0xD, d1
        bne.s   _SetFixlayTextEx_putChar
        cmpi.b  #0xA, (a0)
        bne.s   _SetFixlayTextEx_putChar
        tst.b   (a0)+                   | 如果是 $D(\r) 或 $A(\n)
        move.w  A5Seg.TextOutputOffset(a5), d2
        addq.w  #1, d2
        move.w  A5Seg.TextOutputEntryHigh(a5), d0
        bra.s   loc_6F96
| ---------------------------------------------------------------------------

_SetFixlayTextEx_putChar:              
                                       
        cmpi.b  #0xFE, d1
        beq   SetFixlayText           | params:
                                        |     a0: ptr to fixlay output struct
        cmpi.b  #0xFF, d1
        beq.s   _SetFixlayTextEx_End
        or.w    d0, d1                  | d1: pal num | tile num
        swap    d2
        move.w  d1, d2
        move.l  d2, (REG_VRAMADDR).l      
        swap    d2
        addi.w  #0x20, d2               | 向右一列
        bra.s   loc_6F9E
| ---------------------------------------------------------------------------

_SetFixlayTextEx_End:                                  
        addq.w  #1, A5Seg.TextOutputOffset(a5)
        rts
| End of function SetFixlayTextEx


| params:
|     d1: hex val
|     d2: addr in VRAM

FixlayOutputHexVal:                                                           
        move.w  d1, d0
        andi.w  #0xF, d0
        andi.w  #0xF0, d1
        lsr.w   #4, d1
        moveq   #0, d3
        move.b  A5Seg.TextOutputDefaultPalIndex(a5), d3 | bit0~4: Pal index
                                        | bit7: 0, use this index
        bpl.s   loc_72E0
        moveq   #0, d3

loc_72E0:                               | CODE XREF: FixlayOutputHexVal+12j
        andi.w  #0xF, d3
        ror.w   #4, d3
        addi.w  #0xF00, d3
        swap    d2
        move.w  d3, d2
        lea     HexCharTable, a0
        move.b  (a0,d1.w), d2           | high nible
        move.l  d2, (REG_VRAMADDR).l
        addi.l  #0x200000, d2
        move.b  (a0,d0.w), d2           | low nible
        move.l  d2, (REG_VRAMADDR).l
        addi.l  #0x200000, d2
        rts

HexCharTable:
		.byte 0x30               
        .byte 0x31 | 1
        .byte 0x32 | 2
        .byte 0x33 | 3
        .byte 0x34 | 4
        .byte 0x35 | 5
        .byte 0x36 | 6
        .byte 0x37 | 7
        .byte 0x38 | 8
        .byte 0x39 | 9
        .byte 0x41 | A
        .byte 0x42 | B
        .byte 0x43 | C
        .byte 0x44 | D
        .byte 0x45 | E
        .byte 0x46 | F


| params:
|     d0: x
|     d1: y
| ret:
|     d0.highword: offset in VRAM

ScreenXYToFixMapVRAMAddr:              
        lsl.w   #5, d0
        add.w   d1, d0
        addi.w  #0x7002, d0             | 2 hidden lines on the top
        swap    d0
        rts
| End of function ScreenXYToFixMapVRAMAddr

| params:
|     d0: x
|     d1: y
|     d2: width
|     d3: height

FixlayVRAMClear:                        
        bsr   ScreenXYToFixMapVRAMAddr | params:
                                        |     d0: x
                                        |     d1: y
                                        | ret:
                                        |     d0.highword: offset in VRAM
        move.w  #0xF20, d0              | Tile num
        move.l  d0, d4
        move.l  #0x200000, d1
        moveq   #0, d6

_FixlayVRAMClear_dbfLoopOut:                            | CODE XREF: FixlayVRAMClear+28j
        move.w  d2, d5

_FixlayVRAMClear_dbfLoopIn:                             | CODE XREF: FixlayVRAMClear+1Aj
        move.l  d0, (0x3C0000).l        | high: REG_VRAMADDR
                                        | low: REG_VRAMRW
        add.l   d1, d0
        dbf     d5, _FixlayVRAMClear_dbfLoopIn          | high: REG_VRAMADDR
                                        | low: REG_VRAMRW
        move.l  d4, d0
        addi.l  #0x10000, d6
        add.l   d6, d0
        dbf     d3, _FixlayVRAMClear_dbfLoopOut
        rts
| End of function FixlayVRAMClear

| params:
|     a0: pChar
|     d0: addr | pal
|     d1: step

LoopFixLayOut:                         
        move.b  (a0)+, d0
        cmpi.b  #0xFF, d0
        beq.w   _LoopFixLayOut_ret
        move.l  d0, (0x3C0000).l
        add.l   d1, d0
        bra   LoopFixLayOut           | params:
                                        |     a0: pChar
                                        |     d0: addr | pal
                                        |     d1: step

_LoopFixLayOut_ret:                                   
        rts
| End of function LoopFixLayOut
