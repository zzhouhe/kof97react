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
		jsr     DisplaySubTitle


        move.w  #6, d0
        jsr     SET_SOUND               | params:
                                        |     d0: sound index
        move.w  #0x3A, d0
        jsr     SET_SOUND               | params:
                                        |     d0: sound index

		move.l  #_GameTitle_step2, Object(a4)

_GameTitle_step2:   
        lea     (TITLE_TIME).l, a0
        jsr     SetFixlayText       
        moveq   #0, d1
        move.b  (BIOS_SELECT_TIMER).l, d1     | BIOS_SELECT_TIMER
        st      A5Seg.TextOutputDefaultPalIndex(a5) | bit0~4: Pal index
                                        | bit7: 0, use this index
        jsr     FixlayOutputHexVal      | params:
                                        |     d1: hex val
                                        |     d2: addr in VRAM
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

DisplaySubTitle:                        | CODE XREF: GameTitle+38p
                                        | ROM:0000E93Cp
        move.b  #0xFF, A5Seg.TextOutputDefaultPalIndex(a5) | bit0~4: Pal index
                                        | bit7: 0, use this index
        lea     (SNK_LOGO).l, a0
        bsr.w   DisplaySNKlogo          | params:
|                                       |     a0: prt to: addr(w), width(b)-1, height(b)-1, data(w)
|        lea     (word_A1572).l, a0
|        cmpi.b  #0, A5Seg.CountryCodeAndLanguage(a5) | 0:Japan,
|                                        | 1:USA,
|                                        | 2:Europe
|        beq.s   loc_7640
|        lea     (word_A158B).l, a0
        lea     (SNK_CORP).l, a0
|
|loc_7640:                               | CODE XREF: DisplaySubTitle+1Cj
        bsr.w   SetFixlayText           | params:
|                                        |     a0: ptr to fixlay output struct
        rts
| End of function DisplaySubTitle

| params:
|     a0: prt to: addr(w), width(b)-1, height(b)-1, data(w)

DisplaySNKlogo:                        
        move.w  (a0)+, d0
                              
        moveq   #0, d2
        moveq   #0, d3
        move.b  (a0)+, d2
        move.b  (a0)+, d3
_DisplaySNKlogo_loopOut:                                | CODE XREF: DisplaySNKlogo+2Cj
        move.w  d0, d1
        move.w  d2, d4

_DisplaySNKlogo_loopIn:                                 | CODE XREF: DisplaySNKlogo+26j
        swap    d1
        move.w  (a0)+, d1
        move.l  d1, (0x3C0000).l        | REG_VRAMADDR
        swap    d1
        addi.w  #0x20, d1
        dbf     d4, _DisplaySNKlogo_loopIn
        addq.w  #1, d0
        dbf     d3, _DisplaySNKlogo_loopOut
        rts
| End of function DisplaySNKlogo

SNK_LOGO:.word 0x7058                   | DATA XREF: DisplaySubTitle+6o
        .byte 9
        .byte    2
        .word 0xF200
        .word 0xF201
        .word 0xF202
        .word 0xF203
        .word 0xF204
        .word 0xF205
        .word 0xF206
        .word 0xF207
        .word 0xF208
        .word 0xF209
        .word 0xF20A
        .word 0xF20B
        .word 0xF20C
        .word 0xF20D
        .word 0xF20E
        .word 0xF20F
        .word 0xF214
        .word 0xF215
        .word 0xF216
        .word 0xF217
        .word 0xF218
        .word 0xF219
        .word 0xF21A
        .word 0xF21B
        .word 0xF21C
        .word 0xF21D
        .word 0xF21E
        .word 0xF21F
        .word 0xF240
        .word 0xF25E

SNK_CORP:
		.word 0x719A                  
        .byte 0x13
        .byte 0x7F 
aSnkCorp_ofAmerica1997:
		.ascii "SNK CORP.OF AMERICA 1997"
        .byte 0xFF, 0xFF

TITLE_TIME:
		.word 0x723C                 
        .byte  0xF
		.ascii "TIME "
        .byte 0xFF
        .byte 0xFF
