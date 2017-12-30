.include	"def.inc"
.globl		HelpRoutine

HelpRoutine:                            | DATA XREF: PLAYER_START+110o
        clr.w   A5Seg.BGM_CODE(a5)
        bsr.w   HelpInit
|        andi.b  #0xFC, A5Seg.TileUpdateFlag(a5) | bit0: 1, vert pos need update for buf_main
|                                        | bit1: 1, vert pos need update for buf_sub
|                                        | bit6: 1, mask update SCB3
|                                        | bit7: 1, mask update SCB3
|        clr.l   A5Seg+0x2796(a5)
|        clr.l   A5Seg+0x6BE6(a5)
        jsr     InitObjectPool
        jsr     ClearFixlay
        move.l  #_HelpRoutine_step2, A5Seg.MainNextRoutine(a5)
        rts
| End of function HelpRoutine


| =============== S U B R O U T I N E =======================================


_HelpRoutine_step2:  
        moveq   #1, d0
        jsr     LoadAnimationAndPal     | params:
                                        |     d0: index
        jsr     InitObjectPool
        jsr     SetBackgroundNoUse
        jsr     ClearFixlay
        jsr     0xC004C8                | BIOS_CLEAR_SPRITES
        bsr.w   HelpInitDataForSprites 

        move.l  #_HelpRoutine_step3, A5Seg.MainNextRoutine(a5)

_HelpRoutine_step3:                                 
        lea     InitFixlayHowToPlay, a0
        nop
        move.w  #0x5000, d0
        jsr     AllocateObjBlock    

        moveq   #0, d0
        lea     (BackGroundLayerRoutine).l, a0
        jsr     InitBackGroundLayer     | params:
                                        |     d0: back layer index
                                        |     a0: proc routine
                                        | ret
                                        |     a1: screen obj
        move.w  #0x580, ScreenObj.VRamBaseOffset(a1) | 16 * 40
        move.l  #HELP_BKGRD_LAYER1, ScreenObj.pDataFromParam(a1)
        move.w  #0, ScreenObj.XfromParam(a1)
        move.w  #0, ScreenObj.YfromParam(a1)
        move.w  #0x13, ScreenObj.BackgroundSpriteWidthFromParam(a1) | width - 1
        move.w  #0xD, ScreenObj.BackgroundSpriteHeightFromParam(a1) | height - 1

        moveq   #1, d0
        lea     (BackGroundLayerRoutine).l, a0
        jsr     InitBackGroundLayer     | params:
                                        |     d0: back layer index
                                        |     a0: proc routine
                                        | ret
                                        |     a1: screen obj
        move.w  #0x40, ScreenObj.VRamBaseOffset(a1)
        move.l  #HELP_BKGRD_LAYER0, ScreenObj.pDataFromParam(a1)
        move.w  #0, ScreenObj.XfromParam(a1)
        move.w  #0, ScreenObj.YfromParam(a1)
        move.w  #0x13, ScreenObj.BackgroundSpriteWidthFromParam(a1) | width - 1
        move.w  #0xD, ScreenObj.BackgroundSpriteHeightFromParam(a1) | height - 1

        move.l  #_HelpRoutine_step4, A5Seg.MainNextRoutine(a5)
_HelpRoutine_step4:                   
		rts         
		


HelpInit:                               
        
        clr.l   A5Seg.ScreenLeftX(a5)   | 显示区域最左端横坐标, 像素单位 0-1C0
        clr.l   A5Seg.ScreenTopY(a5)    | 像素单位, 根据场景不同起点不同
                                        | 顶层背景
        jsr     SetBackgroundNoUse
|        clr.b   A5Seg.PersonSelBlock1(a5) | if at sel mode, set this byte to 1
|        clr.b   A5Seg.PersonSelBlock2(a5)
|        move.b  #0, A5Seg.SelectedP1PID(a5) | 选人表
|        move.b  #8, A5Seg.SelectedP2PID(a5)
|        clr.b   A5Seg.ColorFlags1(a5)   | 选人时决定的颜色, 主颜色0, 副颜色1
|        clr.b   A5Seg.ColorFlags1+1(a5) | 选人时决定的颜色, 主颜色0, 副颜色1
|        clr.b   A5Seg.ColorFlags1+2(a5) | 选人时决定的颜色, 主颜色0, 副颜色1
|        clr.b   A5Seg.ColorFlags2(a5)
|        clr.b   A5Seg.ColorFlags2+1(a5)
|        clr.b   A5Seg.ColorFlags2+2(a5)
|        clr.b   A5Seg.field_6C36(a5)
|        move.b  #0xFF, A5Seg.field_6C39(a5)
|        clr.b   A5Seg.field_6C38(a5)
        jsr     0xC004C8                | Clear sprites
 |       lea     (word_A34E8).l, a0
 |       move.w  #0xA, d1
 |       jsr     LoadPalArrayEntries     | params:
 |                                       |     a0: ptr to idx in rom
 |                                       |     d1: des start idx
        rts
| End of function HelpInit


HelpInitDataForSprites:                 
        move.w  #0x1F80, A5Seg.BackUpTileOffsetInSCB1_Main(a5) | 7e * 40 = 1f80
        move.w  #0x3600, A5Seg.TileOffsetInSCB1_Main(a5) | d8 * 40 = 3600
        move.w  #0x5A, A5Seg.ObjTotalSpriteNumbers_Main(a5) | 7e + 5a = d8
|        move.w  #0x1180, A5Seg.BackUpTileOffsetInSCB1_Sub(a5) | 46 * 40 = 1180
|        move.w  #0x1580, A5Seg.TileOffsetInSCB1_Sub(a5)
|        move.w  #0x10, A5Seg.ObjTotalSpriteNumbers_Sub(a5)
        move.b  #3, A5Seg.TileUpdateFlag(a5) | bit0: 1, vert pos need update for buf_main
                                        | bit1: 1, vert pos need update for buf_sub
                                        | bit6: 1, mask update SCB3
                                        | bit7: 1, mask update SCB3
        clr.w   A5Seg.PalGradDeltaR(a5)
        clr.w   A5Seg.PalGradDeltaG(a5)
        clr.w   A5Seg.PalGradDeltaB(a5)
        move.w  #0x1050, d1
        move.w  #0x90, d2
        move.w  #0x3F, d3
        jsr     LoadPalBlockEntries     | params:
                                        |     d1: pal entry index
                                        |     d2: des index
                                        |     d3: entry nums - 1
|        lea     (PAL_FOR_FIX).l, a0
|        lea     (PAL_FOR_FIX).l, a1
|        jsr     LoadPalDoubleArrayEntries | params:
                                        |     a0: ptr to idx in rom
                                        |     a1: ptr to des idx
        clr.l   A5Seg.ScreenLeftX(a5)   | 显示区域最左端横坐标, 像素单位 0-1C0
        clr.l   A5Seg.ScreenTopY(a5)    | 像素单位, 根据场景不同起点不同
                                        | 顶层背景
|        move.w  #0xFF00, A5Seg.SomeGlobalHoriShrinking(a5) | always ff00
|        move.w  #0xFF00, A5Seg.SomeGlobalVertShrinking(a5) | always ff00
|        andi.b  #0xFD, A5Seg.PaletteUpdateFlag(a5) | bit0: 0: use bank Index 1; 1: use bank Index 0
                                        | bit1: 1, mask flush screen
                                        | bit6: 1, mask palette update
                                        | bit7: 1, only update current palette bank
|        clr.w   A5Seg.BackDoorColor(a5)
        rts
| End of function HelpInitDataForSprites


InitFixlayHowToPlay:           
        move.w  #0xF0, Object.selfBuf1(a4)
        move.l  #_InitFixlayHowToPlay_step2, Object(a4)

_InitFixlayHowToPlay_step2:                                 | DATA XREF: InitFixlayHowToPlay+6o
        subi.w  #1, Object.selfBuf1(a4)
        bmi.s   _InitFixlayHowToPlay_destroy
        move.b  -0x7F65(a5), d3         | 10009B counter low byte
        btst    #3, d3
        beq.s   ClearFixlayHowToPlay
        lea     (String_HOW_TO_PLAY).l, a0
        jsr     SetFixlayText           | params:
                                        |     a0: ptr to fixlay output struct
        rts

ClearFixlayHowToPlay:                   | CODE XREF: InitFixlayHowToPlay+1Cj
                                        | InitFixlayHowToPlay:loc_7231Ep
        move.w  #0xA, d0
        move.w  #0x10, d1
        move.w  #0x13, d2
        move.w  #1, d3
        jsr     FixlayVRAMClear         | params:
                                        |     d0: x
                                        |     d1: y
                                        |     d2: width
                                        |     d3: height
        rts
| End of function ClearFixlayHowToPlay		

_InitFixlayHowToPlay_destroy:                              | CODE XREF: InitFixlayHowToPlay+12j
        bsr.s   ClearFixlayHowToPlay
        jmp     FreeObjBlock            | params:
| END OF FUNCTION CHUNK FOR InitFixlayHowToPlay |     a4: Obj        

String_HOW_TO_PLAY:.word 0x7152         
        .byte 0xA4  
        .byte 0x80
        .byte 0x81  
        .byte 0x82  
        .byte 0x83  
        .byte 0x84  
        .byte 0x85  
        .byte 0x86  
        .byte 0x87  
        .byte 0x88  
        .byte 0x89  
        .byte 0x8A  
        .byte 0x8B  
        .byte 0x8C  
        .byte 0x8D  
        .byte 0x8E  
        .byte 0x8F  
        .byte 0xAC  
        .byte 0xAD  
        .byte 0xAE  
        .byte 0xAF  
        .byte  0xD
        .byte  0xA
        .byte 0x90  
        .byte 0x91  
        .byte 0x92  
        .byte 0x93  
        .byte 0x94  
        .byte 0x95  
        .byte 0x96  
        .byte 0x97  
        .byte 0x98  
        .byte 0x99  
        .byte 0x9A  
        .byte 0x9B  
        .byte 0x9C  
        .byte 0x9D  
        .byte 0x9E  
        .byte 0x9F  
        .byte 0xBC  
        .byte 0xBD  
        .byte 0xBE  
        .byte 0xBF  
        .byte 0xFF

HELP_BKGRD_LAYER1:
		.long 0x948B5200, 0x948C5200, 0x948D5200, 0x948E5200, 0x948F5200| 0
        .long 0x94905000, 0x94915000, 0x94925000, 0x94935000, 0x94945000| 5
        .long 0x94955000, 0x94965000, 0x94975000, 0x94985000, 0x94995200| 10
        .long 0x949A6100, 0x949B6100, 0x949C6100, 0x949D5200, 0x949E5000| 15
        .long 0x949F5000, 0x94A05000, 0x94A15000, 0x94A25000, 0x94A35000| 20
        .long 0x94A45000, 0x94A55000, 0x94A65000, 0x94A75200, 0x94A86100| 25
        .long 0x94A96100, 0x94AA6100, 0x94AB5200, 0x94AC5000, 0x94AD5000| 30
        .long 0x94AE5000, 0x94AF5000, 0x94B05000, 0x94B15000, 0x94B25000| 35
        .long 0x94B35000, 0x94B45000, 0x94B55200, 0x94B66100, 0x94B76100| 40
        .long 0x94B86100, 0x94B95200, 0x94BA5000, 0x94BB5000, 0x94BC5000| 45
        .long 0x94BD5000, 0x94BE5000, 0x94BF5000, 0x94C05000, 0x94C15000| 50
        .long 0x94C25000, 0x94C35200, 0x94C46100, 0x94C56100, 0x94C66100| 55
        .long 0x94C75200, 0x94C85000, 0x94C95000, 0x94CA5000, 0x94CB5000| 60
        .long 0x94CC5000, 0x94CD5000, 0x94CE5000, 0x94CF5000, 0x94D05000| 65
        .long 0x94D15200, 0x94D26100, 0x94D36100, 0x94D46100, 0x94D55200| 70
        .long 0x94D65000, 0x94D75000, 0x94D85000, 0x94D95000, 0x94DA5000| 75
        .long 0x94DB5000, 0x94DC5000, 0x94DD5000, 0x94DE5000, 0x94DF5200| 80
        .long 0x94E06100, 0x94E16100, 0x94E26100, 0x94E35200, 0x94E45000| 85
        .long 0x94E55000, 0x94E65000, 0x94E75000, 0x94E85000, 0x94E95000| 90
        .long 0x94EA5000, 0x94EB5000, 0x94EC5000, 0x94ED5200, 0x94EE6100| 95
        .long 0x94EF6100, 0x94F06100, 0x94F15200, 0x94F25000, 0x94F35000| 100
        .long 0x94F45000, 0x94F55000, 0x94F65000, 0x94F75000, 0x94F85000| 105
        .long 0x94F95000, 0x94FA5000, 0x94FB5200, 0x94FC6100, 0x94FD6100| 110
        .long 0x94FE6100, 0x94FF5200, 0x95005000, 0x95015000, 0x95025000| 115
        .long 0x95035000, 0x95045000, 0x95055000, 0x95065000, 0x95075000| 120
        .long 0x95085000, 0x95095200, 0x950A6100, 0x950B6100, 0x950C6100| 125
        .long 0x950D5200, 0x950E5000, 0x950F5000, 0x95105000, 0x95115000| 130
        .long 0x95125000, 0x95135000, 0x95145000, 0x95155000, 0x95165000| 135
        .long 0x95175600, 0x95186200, 0x95196200, 0x951A6200, 0x951B5600| 140
        .long 0x951C5400, 0x951D5400, 0x951E5400, 0x951F5400, 0x95205400| 145
        .long 0x95215400, 0x95225400, 0x95235400, 0x95245400, 0x95255600| 150
        .long 0x95266200, 0x95276200, 0x95286200, 0x95295600, 0x952A5400| 155
        .long 0x952B5400, 0x952C5400, 0x952D5400, 0x952E5400, 0x952F5400| 160
        .long 0x95305400, 0x95315400, 0x95325400, 0x95335600, 0x95346200| 165
        .long 0x95356200, 0x95366200, 0x95375600, 0x95385400, 0x95395400| 170
        .long 0x953A5400, 0x953B5400, 0x953C5400, 0x953D5400, 0x953E5400| 175
        .long 0x953F5400, 0x95405400, 0x95415600, 0x95426200, 0x95436200| 180
        .long 0x95446200, 0x95455600, 0x95465400, 0x95475400, 0x95485400| 185
        .long 0x95495400, 0x954A5400, 0x954B5400, 0x954C5400, 0x954D5400| 190
        .long 0x954E5400, 0x954F5600, 0x95506200, 0x95516200, 0x95526200| 195
        .long 0x95535600, 0x95545400, 0x95555400, 0x95565400, 0x95575400| 200
        .long 0x95585400, 0x95595400, 0x955A5400, 0x955B5400, 0x955C5400| 205
        .long 0x955D5600, 0x955E6200, 0x955F6200, 0x95606200, 0x95615600| 210
        .long 0x95625400, 0x95635400, 0x95645400, 0x95655400, 0x95665400| 215
        .long 0x95675400, 0x95685400, 0x95695400, 0x956A5400, 0x956B5600| 220
        .long 0x956C6200, 0x956D6200, 0x956E6200, 0x956F5600, 0x95705400| 225
        .long 0x95715400, 0x95725400, 0x95735400, 0x95745400, 0x95755400| 230
        .long 0x95765400, 0x95775400, 0x95785400, 0x95795600, 0x957A6200| 235
        .long 0x957B6200, 0x957C6200, 0x957D5600, 0x957E5400, 0x957F5400| 240
        .long 0x95805400, 0x95815400, 0x95825400, 0x95835400, 0x95845400| 245
        .long 0x95855400, 0x95865400, 0x95875600, 0x95886200, 0x95896200| 250
        .long 0x958A6200, 0x958B5600, 0x958C5400, 0x958D5400, 0x958E5400| 255
        .long 0x958F5400, 0x95905400, 0x95915400, 0x95925400, 0x95935400| 260
        .long 0x95945400, 0x95955600, 0x95965600, 0x95975600, 0x95985600| 265
        .long 0x95995600, 0x959A5400, 0x959B5400, 0x959C5400, 0x959D5400| 270
        .long 0x959E5400, 0x959F5400, 0x95A05400, 0x95A15400, 0x95A25400| 275
HELP_BKGRD_LAYER0:
		.long 0x95B56300, 0x95B56300, 0x95B56300, 0x95B56300, 0x95B56300| 0
        .long 0x95B56300, 0x95B56300, 0x95B56300, 0x95B56300, 0x95B56300| 5
        .long 0x95B56300, 0x95B56300, 0x95B56300, 0x95B56300, 0x95B66300| 10
        .long 0x95B66300, 0x95B66300, 0x95B66300, 0x95B66300, 0x95B66300| 15
        .long 0x95B66300, 0x95B66300, 0x95B66300, 0x95B66300, 0x95B66300| 20
        .long 0x95B66300, 0x95B66300, 0x95B66300, 0x95B76300, 0x95B76300| 25
        .long 0x95B76300, 0x95B76300, 0x95B76300, 0x95B76300, 0x95B76300| 30
        .long 0x95B76300, 0x95B76300, 0x95B76300, 0x95B76300, 0x95B76300| 35
        .long 0x95B76300, 0x95B76300, 0x95B86300, 0x95B86300, 0x95B86300| 40
        .long 0x95B86300, 0x95B86300, 0x95B86300, 0x95B86300, 0x95B86300| 45
        .long 0x95B86300, 0x95B86300, 0x95B86300, 0x95B86300, 0x95B86300| 50
        .long 0x95B86300, 0x95B96300, 0x95B96300, 0x95B96300, 0x95B96300| 55
        .long 0x95B96300, 0x95B96300, 0x95B96300, 0x95B96300, 0x95B96300| 60
        .long 0x95B96300, 0x95B96300, 0x95B96300, 0x95B96300, 0x95B96300| 65
        .long 0x95BA6300, 0x95BA6300, 0x95BA6300, 0x95BA6300, 0x95BA6300| 70
        .long 0x95BA6300, 0x95BA6300, 0x95BA6300, 0x95BA6300, 0x95BA6300| 75
        .long 0x95BA6300, 0x95BA6300, 0x95BA6300, 0x95BA6300, 0x95BB6300| 80
        .long 0x95BB6300, 0x95BB6300, 0x95BB6300, 0x95BB6300, 0x95BB6300| 85
        .long 0x95BB6300, 0x95BB6300, 0x95BB6300, 0x95BB6300, 0x95BB6300| 90
        .long 0x95BB6300, 0x95BB6300, 0x95BB6300, 0x95BC6300, 0x95BC6300| 95
        .long 0x95BC6300, 0x95BC6300, 0x95BC6300, 0x95BC6300, 0x95BC6300| 100
        .long 0x95BC6300, 0x95BC6300, 0x95BC6300, 0x95BC6300, 0x95BC6300| 105
        .long 0x95BC6300, 0x95BC6300, 0x95BD6300, 0x95BD6300, 0x95BD6300| 110
        .long 0x95BD6300, 0x95BD6300, 0x95BD6300, 0x95BD6300, 0x95BD6300| 115
        .long 0x95BD6300, 0x95BD6300, 0x95BD6300, 0x95BD6300, 0x95BD6300| 120
        .long 0x95BD6300, 0x95BE6300, 0x95BE6300, 0x95BE6300, 0x95BE6300| 125
        .long 0x95BE6300, 0x95BE6300, 0x95BE6300, 0x95BE6300, 0x95BE6300| 130
        .long 0x95BE6300, 0x95BE6300, 0x95BE6300, 0x95BE6300, 0x95BE6300| 135
        .long 0x95BE6501, 0x95BE6501, 0x95BE6501, 0x95BE6501, 0x95BE6501| 140
        .long 0x95BE6501, 0x95BE6501, 0x95BE6501, 0x95BE6501, 0x95BE6501| 145
        .long 0x95BE6501, 0x95BE6501, 0x95BE6501, 0x95BE6501, 0x95BD6501| 150
        .long 0x95BD6501, 0x95BD6501, 0x95BD6501, 0x95BD6501, 0x95BD6501| 155
        .long 0x95BD6501, 0x95BD6501, 0x95BD6501, 0x95BD6501, 0x95BD6501| 160
        .long 0x95BD6501, 0x95BD6501, 0x95BD6501, 0x95BC6501, 0x95BC6501| 165
        .long 0x95BC6501, 0x95BC6501, 0x95BC6501, 0x95BC6501, 0x95BC6501| 170
        .long 0x95BC6501, 0x95BC6501, 0x95BC6501, 0x95BC6501, 0x95BC6501| 175
        .long 0x95BC6501, 0x95BC6501, 0x95BB6501, 0x95BB6501, 0x95BB6501| 180
        .long 0x95BB6501, 0x95BB6501, 0x95BB6501, 0x95BB6501, 0x95BB6501| 185
        .long 0x95BB6501, 0x95BB6501, 0x95BB6501, 0x95BB6501, 0x95BB6501| 190
        .long 0x95BB6501, 0x95BA6501, 0x95BA6501, 0x95BA6501, 0x95BA6501| 195
        .long 0x95BA6501, 0x95BA6501, 0x95BA6501, 0x95BA6501, 0x95BA6501| 200
        .long 0x95BA6501, 0x95BA6501, 0x95BA6501, 0x95BA6501, 0x95BA6501| 205
        .long 0x95B96501, 0x95B96501, 0x95B96501, 0x95B96501, 0x95B96501| 210
        .long 0x95B96501, 0x95B96501, 0x95B96501, 0x95B96501, 0x95B96501| 215
        .long 0x95B96501, 0x95B96501, 0x95B96501, 0x95B96501, 0x95B86501| 220
        .long 0x95B86501, 0x95B86501, 0x95B86501, 0x95B86501, 0x95B86501| 225
        .long 0x95B86501, 0x95B86501, 0x95B86501, 0x95B86501, 0x95B86501| 230
        .long 0x95B86501, 0x95B86501, 0x95B86501, 0x95B76501, 0x95B76501| 235
        .long 0x95B76501, 0x95B76501, 0x95B76501, 0x95B76501, 0x95B76501| 240
        .long 0x95B76501, 0x95B76501, 0x95B76501, 0x95B76501, 0x95B76501| 245
        .long 0x95B76501, 0x95B76501, 0x95B66501, 0x95B66501, 0x95B66501| 250
        .long 0x95B66501, 0x95B66501, 0x95B66501, 0x95B66501, 0x95B66501| 255
        .long 0x95B66501, 0x95B66501, 0x95B66501, 0x95B66501, 0x95B66501| 260
        .long 0x95B66501, 0x95B56501, 0x95B56501, 0x95B56501, 0x95B56501| 265
        .long 0x95B56501, 0x95B56501, 0x95B56501, 0x95B56501, 0x95B56501| 270
        .long 0x95B56501, 0x95B56501, 0x95B56501, 0x95B56501, 0x95B56501| 275
