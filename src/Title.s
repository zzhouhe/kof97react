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

        lea     (KING_OF_FIGHTERS_TITLE_SPRITES).l, a2
        move.w  #0xFFE8, d1
        move.w  #0xFFB0, d2
        move.w  #0xC, d3
        move.w  #3, d4
        bsr.w   InitBackGroundLayer2    

		lea     (TITLE_FIRE_LOGO_SPRITES).l, a2
        move.w  #0xFFD0, d1
        move.w  #0xFFE0, d2
        move.w  #0xC, d3
        move.w  #9, d4
        bsr.w   InitBackGroundLayer4

        lea     (KING_OF_FIGHTERS_TITLE_BACK_SPRITES).l, a2
        move.w  #0xFFF0, d1
        move.w  #0xFFB0, d2
        move.w  #0x11, d3
        move.w  #3, d4
        bsr.w   InitBackGroundLayer3

        lea     (TITLE_BACKGROUND_SPRITES).l, a2
        move.w  #0, d1
        move.w  #0, d2
        move.w  #0x13, d3
        move.w  #0xD, d4
        bsr.w   InitBackGroundLayer5

        lea     PalGradWrappedObjRoutine, a0
        nop
        move.w  #0x6000, d0			|2148
        jsr     AllocateObjBlock        | params:
                                        |     a0: PActionRoutine
                                        |     d0: level
                                        | ret:
                                        |     a1: newObj
        lea     (FIX_TM_LOGO).l, a0
        jsr     SetFixlayText           

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




PalGradWrappedObjRoutine:             |21e8  

        lea     (PalGradObjInitRoutine).l, a0
        move.w  #0xE800, d0
        jsr     AllocateObjBlock        | params:
                                        |     a0: PActionRoutine
                                        |     d0: level
                                        | ret:
                                        |     a1: newObj
        move.l  #TITLE_FIRE_PAL_GRAD1, PalGradObj.pEntryIndex1(a1)
        move.l  #TITLE_FIRE_PAL_GRAD2, PalGradObj.pEntryIndex2(a1)
        move.w  #1, PalGradObj.GradDDR(a1)
        move.w  #1, PalGradObj.GradDDG(a1)
        move.w  #1, PalGradObj.GradDDB(a1)
        move.b  #3, PalGradObj.CounterResetVal(a1) | grade frequency
        move.b  #5, PalGradObj.MaxGradSteps(a1)
        move.l  a1, Object.EffectChild(a4)
        move.l  #_PalGradWrappedObjRoutine_step2, (a4)

_PalGradWrappedObjRoutine_step2:                                 | DATA XREF: PalGradWrappedObjRoutine+40o
        movea.l Object.EffectChild(a4), a0
        cmpi.b  #0xFF, PalGradObj.CounterResetVal(a0) | grade frequency
        beq.s   _PalGradWrappedObjRoutine_step2end
        rts
| ---------------------------------------------------------------------------

_PalGradWrappedObjRoutine_step2end:                              | CODE XREF: PalGradWrappedObjRoutine+50j
        lea     (PalGradObjInitRoutine).l, a0
        move.w  #0xE801, d0
        jsr     AllocateObjBlock        | params:
                                        |     a0: PActionRoutine
                                        |     d0: level
                                        | ret:
                                        |     a1: newObj
        move.l  #TITLE_FIRE_PAL_GRAD2, PalGradObj.pEntryIndex1(a1)
        move.l  #TITLE_FIRE_PAL_GRAD3, PalGradObj.pEntryIndex2(a1)
        move.w  #1, PalGradObj.GradDDR(a1)
        move.w  #1, PalGradObj.GradDDG(a1)
        move.w  #1, PalGradObj.GradDDB(a1)
        move.b  #4, PalGradObj.CounterResetVal(a1) | grade frequency
        move.b  #6, PalGradObj.MaxGradSteps(a1)
        move.l  a1, Object.EffectChild(a4)
        move.l  #_PalGradWrappedObjRoutine_step3, Object(a4)

_PalGradWrappedObjRoutine_step3:                                 | DATA XREF: PalGradWrappedObjRoutine+94o
        movea.l Object.EffectChild(a4), a0
        cmpi.b  #0xFF, PalGradObj.CounterResetVal(a0) | grade frequency
        beq.s   _PalGradWrappedObjRoutine_step3end
        rts
| ---------------------------------------------------------------------------

_PalGradWrappedObjRoutine_step3end:                              | CODE XREF: PalGradWrappedObjRoutine+A4j
        lea     (PalGradObjInitRoutine).l, a0
        move.w  #0xE802, d0
        jsr     AllocateObjBlock        | params:
                                        |     a0: PActionRoutine
                                        |     d0: level
                                        | ret:
                                        |     a1: newObj
        move.l  #TITLE_FIRE_PAL_GRAD3, PalGradObj.pEntryIndex1(a1)
        move.l  #TITLE_FIRE_PAL_GRAD1, PalGradObj.pEntryIndex2(a1)
        move.w  #1, PalGradObj.GradDDR(a1)
        move.w  #1, PalGradObj.GradDDG(a1)
        move.w  #1, PalGradObj.GradDDB(a1)
        move.b  #6, PalGradObj.CounterResetVal(a1) | grade frequency
        move.b  #0xB, PalGradObj.MaxGradSteps(a1)
        move.l  a1, Object.EffectChild(a4)
        move.l  #_PalGradWrappedObjRoutine_step4, Object(a4)

_PalGradWrappedObjRoutine_step4:                                 | DATA XREF: PalGradWrappedObjRoutine+E8o
        movea.l Object.EffectChild(a4), a0
        cmpi.b  #0xFF, PalGradObj.CounterResetVal(a0) | grade frequency
        beq.s   _PalGradWrappedObjRoutine_step4end
        rts
| ---------------------------------------------------------------------------

_PalGradWrappedObjRoutine_step4end:                              | CODE XREF: PalGradWrappedObjRoutine+F8j
        bra.w   PalGradWrappedObjRoutine
| End of function PalGradWrappedObjRoutine



SNK_LOGO:.word 0x7058                   
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

KING_OF_FIGHTERS_TITLE_SPRITES:
		.long 0xC100, 0xA75FC100, 0xA760C100, 0xA761C100, 0xA762C100, 0xA763C100, 0xA764C100, 0xA765C100, 0xA766C100, 0xA767C100, 0xA768C100, 0xA769C100, 0xA76AC100, 0xA76BC100, 0xA76CC100, 0xA76DC100| 0
		.long 0xA76EC100, 0xA76FC100, 0xA770C100, 0xA771C100, 0xA772C100, 0xA773C100, 0xA774C100, 0xA775C100, 0xA776C100, 0xA777C100, 0xA778C100, 0xA779C100, 0xA77AC100, 0xA77BC100, 0xA77CC100, 0xA77DC100| 16
        .long 0xA77EC100, 0xA77FC100, 0xA780C100, 0xA781C100, 0xC100, 0xA782C100, 0xA783C100, 0xA784C100, 0xC100, 0xA785C100, 0xA786C100, 0xA787C100, 0xC100, 0xA788C100, 0xA789C100, 0xA78AC100| 32
        .long 0xC100, 0xA78BC100, 0xA78CC100, 0xA78DC100| 48

TITLE_FIRE_LOGO_SPRITES:
		.long 0xE400, 0xE400, 0xE400, 0xE400, 0xE400, 0xE400, 0xE400, 0xA892E400, 0xE400, 0xE400, 0xE400, 0xE400, 0xE400, 0xE400, 0xE400, 0xE400| 0
        .long 0xE400, 0xA893E400, 0xA894E400, 0xE400, 0xE400, 0xE400, 0xE400, 0xE400, 0xE400, 0xE400, 0xE400, 0xA895E400, 0xA896E400, 0xE400, 0xE400, 0xA897E400| 16
        .long 0xA898E400, 0xE400, 0xE400, 0xE400, 0xE400, 0xA899E400, 0xA89AE400, 0xA89BE400, 0xE400, 0xA89CE400, 0xA89DE400, 0xE400, 0xE400, 0xE400, 0xA89EE400, 0xA89FE400| 32
        .long 0xA8A0E400, 0xA8A1E400, 0xA8A2E400, 0xA8A3E400, 0xA8A4E400, 0xE400, 0xE400, 0xE400, 0xA8A5E400, 0xA8A6E400, 0xA8A7E400, 0xA8A8E400, 0xA8A9E400, 0xA8AAE400, 0xA8ABE400, 0xA8ACE400| 48
        .long 0xA8ADE400, 0xA8AEE400, 0xA8AFE400, 0xA8B0E400, 0xA8B1E400, 0xA8B2E400, 0xA8B3E400, 0xA8B4E400, 0xA8B5E400, 0xA8B6E400, 0xA8B7E400, 0xA8B8E400, 0xA8B9E400, 0xA8BAE400, 0xA8BBE400, 0xA8BCE400| 64
        .long 0xA8BDE400, 0xA8BEE400, 0xA8BFE400, 0xA8C0E400, 0xA8C1E400, 0xA8C2E400, 0xA8C3E400, 0xA8C4E400, 0xA8C5E400, 0xA8C6E400, 0xE400, 0xA8C7E400, 0xA8C8E400, 0xA8C9E400, 0xA8CAE400, 0xA8CBE400| 80
        .long 0xA8CCE400, 0xA8CDE400, 0xA8CEE400, 0xA8CFE400, 0xE400, 0xA8D0E400, 0xA8D1E400, 0xA8D2E400, 0xA8D3E400, 0xA8D4E400, 0xA8D5E400, 0xA8D6E400, 0xA8D7E400, 0xE400, 0xE400, 0xE400| 96
        .long 0xE400, 0xA8D8E400, 0xA8D9E400, 0xA8DAE400, 0xA8DBE400, 0xA8DCE400, 0xE400, 0xE400, 0xE400, 0xE400, 0xE400, 0xE400, 0xE400, 0xE400, 0xA8DDE400, 0xA8DEE400| 112
        .long 0xE400, 0xE400            | 128

KING_OF_FIGHTERS_TITLE_BACK_SPRITES:
		.long 0xC000, 0xC000, 0xA6DCC000, 0xA6DDC000, 0xA6DEC000, 0xA6DFC000, 0xA6E0C000, 0xA6E1C000, 0xA6E2C000, 0xA6E3C000, 0xA6E4C000, 0xA6E5C000, 0xA6E2C000, 0xA6E3C000, 0xA6E6C000, 0xA6E7C000| 0
        .long 0xA6E2C000, 0xA6E3C000, 0xA6E6C000, 0xA6E8C000, 0xA6E2C000, 0xA6E3C000, 0xA6E6C000, 0xA6E9C000, 0xA6E2C000, 0xA6E3C000, 0xA6EAC000, 0xA6EBC000, 0xA6ECC000, 0xA6E3C000, 0xA6EDC000, 0xA6EEC000| 16
        .long 0xA6EFC000, 0xA6F0C000, 0xA6F1C000, 0xA6F2C000, 0xA6F3C000, 0xA6F4C000, 0xA6E6C000, 0xA6E9C000, 0xC000, 0xA6F5C000, 0xA6E6C000, 0xA6E9C000, 0xC000, 0xA6F6C000, 0xA6E6C000, 0xA6F7C000| 32
        .long 0xC000, 0xA6F8C000, 0xA6E6C000, 0xA6F9C000, 0xC000, 0xA6FAC000, 0xA6FBC000, 0xA6FCC000, 0xC000, 0xA6FDC000, 0xA6FEC000, 0xA6FFC000, 0xC000, 0xA700C000, 0xA701C000, 0xA702C000| 48
        .long 0xC000, 0xA703C000, 0xA704C000, 0xA705C000, 0xC000, 0xA706C000, 0xA707C000, 0xC000| 64

TITLE_BACKGROUND_SPRITES:
		.long 0xA8DFE700, 0xA8E0E700, 0xA8E1E700, 0xA8E2E700, 0xA8E3E700, 0xA8E4E700, 0xA8E5E700, 0xA8E6E700, 0xA8E7E700, 0xA8E8E700, 0xA8E9E700, 0xA8EAE700, 0xA8EBE700, 0xA8ECE700, 0xA8EDE700, 0xA8EEE700| 0
        .long 0xA8EFE700, 0xA8F0E700, 0xA8F1E700, 0xA8F2E700, 0xA8F3E700, 0xA8F4E700, 0xA8F5E700, 0xA8F6E700, 0xA8F7E700, 0xA8F8E700, 0xA8F9E700, 0xA8FAE700, 0xA8FBE700, 0xA8FCE700, 0xA8FDE700, 0xA8FEE700| 16
        .long 0xA8FFE700, 0xA900E700, 0xA901E700, 0xA902E700, 0xA903E700, 0xA904E700, 0xA905E700, 0xA906E700, 0xA907E700, 0xA908E700, 0xA909E700, 0xA90AE700, 0xA90BE700, 0xA90CE700, 0xA90DE700, 0xA90EE700| 32
        .long 0xA90FE700, 0xA910E700, 0xA911E700, 0xA912E700, 0xA913E700, 0xA914E700, 0xA915E700, 0xA916E700, 0xA917E700, 0xA918E700, 0xA919E700, 0xA91AE700, 0xA91BE700, 0xA91CE700, 0xA91DE700, 0xA91EE700| 48
        .long 0xA91FE700, 0xA920E700, 0xA921E700, 0xA922E700, 0xA923E700, 0xA924E700, 0xA925E700, 0xA926E700, 0xA927E700, 0xA928E700, 0xA929E700, 0xA92AE700, 0xA92BE700, 0xA92CE700, 0xA92DE700, 0xA92EE700| 64
        .long 0xA92FE700, 0xA930E700, 0xA931E700, 0xA932E700, 0xA933E700, 0xA934E700, 0xA935E700, 0xA936E700, 0xA937E700, 0xA938E700, 0xA939E700, 0xA93AE700, 0xA93BE700, 0xA93CE700, 0xA93DE700, 0xA93EE700| 80
        .long 0xA93FE700, 0xA940E700, 0xA941E700, 0xA942E700, 0xA943E700, 0xA944E700, 0xA945E700, 0xA946E700, 0xA947E700, 0xA948E700, 0xA949E700, 0xA94AE700, 0xA94BE700, 0xA94CE700, 0xA94DE700, 0xA94EE700| 96
        .long 0xA94FE700, 0xA950E700, 0xA951E700, 0xA952E700, 0xA953E700, 0xA954E700, 0xA955E700, 0xA956E700, 0xA957E700, 0xA958E700, 0xA959E700, 0xA95AE700, 0xA95BE700, 0xA95CE700, 0xA95DE700, 0xA95EE700| 112
        .long 0xA95FE700, 0xA960E700, 0xA961E700, 0xA962E700, 0xA963E700, 0xA964E700, 0xA965E700, 0xA966E700, 0xA967E700, 0xA968E700, 0xA969E700, 0xA96AE700, 0xA96BE700, 0xA96CE700, 0xA96DE700, 0xA96EE700| 128
        .long 0xA96FE700, 0xA970E700, 0xA971E700, 0xA972E700, 0xA973E700, 0xA974E700, 0xA975E700, 0xA976E700, 0xA977E700, 0xA978E700, 0xA979E700, 0xA97AE700, 0xA97BE700, 0xA97CE700, 0xA97DE700, 0xA97EE700| 144
        .long 0xA97FE700, 0xA980E700, 0xA981E700, 0xA982E700, 0xA983E700, 0xA984E700, 0xA985E700, 0xA986E700, 0xA987E700, 0xA988E700, 0xA989E700, 0xA98AE700, 0xA98BE700, 0xA98CE700, 0xA98DE700, 0xA98EE700| 160
        .long 0xA98FE700, 0xA990E700, 0xA991E700, 0xA992E700, 0xA993E700, 0xA994E700, 0xA995E700, 0xA996E700, 0xA997E700, 0xA998E700, 0xA999E700, 0xA99AE700, 0xA99BE700, 0xA99CE700, 0xA99DE700, 0xA99EE700| 176
        .long 0xA99FE700, 0xA9A0E700, 0xA9A1E700, 0xA9A2E700, 0xA9A3E700, 0xA9A4E700, 0xA9A5E700, 0xA9A6E700, 0xA9A7E700, 0xA9A8E700, 0xA9A9E700, 0xA9AAE700, 0xA9ABE700, 0xA9ACE700, 0xA9ADE700, 0xA9AEE700| 192
        .long 0xA9AFE700, 0xA9B0E700, 0xA9B1E700, 0xA9B2E700, 0xA9B3E700, 0xA9B4E700, 0xA9B5E700, 0xA9B6E700, 0xA9B7E700, 0xA9B8E700, 0xA9B9E700, 0xA9BAE700, 0xA9BBE700, 0xA9BCE700, 0xA9BDE700, 0xA9BEE700| 208
        .long 0xA9BFE700, 0xA9C0E700, 0xA9C1E700, 0xA9C2E700, 0xA9C3E700, 0xA9C4E700, 0xA9C5E700, 0xA9C6E700, 0xA9C7E700, 0xA9C8E700, 0xA9C9E700, 0xA9CAE700, 0xA9CBE700, 0xA9CCE700, 0xA9CDE700, 0xA9CEE700| 224
        .long 0xA9CFE700, 0xA9D0E700, 0xA9D1E700, 0xA9D2E700, 0xA9D3E700, 0xA9D4E700, 0xA9D5E700, 0xA9D6E700, 0xA9D7E700, 0xA9D8E700, 0xA9D9E700, 0xA9DAE700, 0xA9DBE700, 0xA9DCE700, 0xA9DDE700, 0xA9DEE700| 240
        .long 0xA9DFE700, 0xA9E0E700, 0xA9E1E700, 0xA9E2E700, 0xA9E3E700, 0xA9E4E700, 0xA9E5E700, 0xA9E6E700, 0xA9E7E700, 0xA9E8E700, 0xA9E9E700, 0xA9EAE700, 0xA9EBE700, 0xA9ECE700, 0xA9EDE700, 0xA9EEE700| 256
        .long 0xA9EFE700, 0xA9F0E700, 0xA9F1E700, 0xA9F2E700, 0xA9F3E700, 0xA9F4E700, 0xA9F5E700, 0xA9F6E700| 272

TITLE_FIRE_PAL_GRAD1:
		.word 0x12C4                                             
        .word 0xE4
        .word 0xFFFF
TITLE_FIRE_PAL_GRAD2:
		.word 0x12C5                                               
        .word 0xE4
        .word 0xFFFF
TITLE_FIRE_PAL_GRAD3:
		.word 0x12C6                                               
        .word 0xE4
        .word 0xFFFF

FIX_TM_LOGO:
		.word 0x7492               
        .byte    5
        .byte 0x86  
        .byte 0x87  
        .byte  0xD
        .byte  0xA
        .byte 0x96  
        .byte 0x97  
        .byte  0xD
        .byte  0xA
        .byte 0xFF
