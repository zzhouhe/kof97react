.include	"def.inc"
.globl      IntVBlankRoutine
.globl      _start

VECTOR_START:
	    .long 0x10F300                  | 0  Reset:Initial SSP
	    .long 0xC00402                  | SV+6*0      1  Reset:Initial PC
	    .long 0xC00408                  | SV+6*1      2  Bus Error=monitor entry
	    .long 0xC0040E                  | SV+6*2      3  Address Error
	    .long 0xC00414                  | SV+6*3      4  Illegal Instruction
	    .long dymmy_RTE
	    .long dymmy_RTE
	    .long dymmy_RTE
	    .long 0xC0041A                  | SV+6*4      8  Privilege Violation
	    .long 0xC00420                  | SV+6*5      9  Trace
	    .long dymmy_RTE
	    .long dymmy_RTE
	    .long 0xC00426                  | SV+6*6      12 Unassigned
	    .long 0xC00426
	    .long 0xC00426
	    .long 0xC0042C                  | SV+6*7      15 Uninitialized interrupt
	    .long 0xC00426
	    .long 0xC00426
	    .long 0xC00426
	    .long 0xC00426
	    .long 0xC00426
	    .long 0xC00426
	    .long 0xC00426
	    .long 0xC00426
	    .long 0xC00432                  | 24 Spurious Interrupt
	    .long IntVBlankRoutine          | 25 Interrupt 1 (v-blanking)
	    .long IntTimer
	    .long dymmy_RTE
	    .long dymmy_RTE
	    .long dymmy_RTE
	    .long dymmy_RTE
	    .long 0xC00402                  | 31 INT7 NMI

.org 0x100						 | *** GAME-ID SECTOR ***

         .ascii "NEO-GEO"                   | cassette ID + system version
         .byte 0x10
         .word 0x232                        | game code
         .long 0x400000                     | p-rom size
         .long Backup_Start                 | backup start
         .word Backup_Size                  | backup size
         .byte    0                         | Eye-catcher animation flag. 0=Done by BIOS, 1=Done by game, 2=Nothing
         .byte 1                            | Sprite bank number (upper 8 bits of tile number) for the eye-catcher logo, if done by BIOS
         .long EUROPE_DATA                  | "K.O.F. '97      "
         .long EUROPE_DATA                  | "K.O.F.'97       "
         .long EUROPE_DATA                  | "K.O.F.'97       "

            jmp     USER                    | user request
    | ---------------------------------------------------------------------------
            jmp     PLAYER_START            | user player start
    | ---------------------------------------------------------------------------
            jmp     DEMO_END                | chage game
    | ---------------------------------------------------------------------------
            jmp     COIN_SOUND              | coin sound request
.org 0x182
	.long _security
	.long 0
	.long 1
	.long EUROPE_DATA

.align 4
_security:
        moveq	#0,d3
        tst.w	0xa14(a5)
        bne		l2a53a
        movea.l	0xa04(a5),a0
        move.w	0xa08(a5),d7

l2a508:
        move.b	d0,0x300001
        move.w	(a0),d1
        cmpi.b	#0xff,d1
        beq.s	l2a530
        move.w	2(a0),d0
        cmp.b	0xace(a5),d0
        bne.s	l2a530
        move.w	4(a0),d0
        cmp.b	0xacf(a5),d0
        bne.s	l2a530
        cmp.b	0xad0(a5),d1
        beq.s	l2a538

l2a530:
        addq.l	#8,a0
        dbf		d7,l2a508
        move.w	d7,d3
l2a538:
        rts

l2a53a:
        movea.l	0xa04(a5),a0
        move.w	0xa08(a5),d7
l2a542:
        move.w	(a0),d1
        lsr.w	#8,d1
        cmpi.b	#0xff,d1
        beq.s	l2a566
        move.w	(a0),d0
        cmp.b	0xace(a5),d0
        bne.s	l2a566
        move.w	2(a0),d0
        lsr.w	#8,d0
        cmp.b	0xacf(a5),d0
        bne.s	l2a566
        cmp.b	0xad0(a5),d1
        beq.s	l2a56e
l2a566:
        addq.l	#4,a0
        dbf		d7,l2a542
        move.w	d7,d3
l2a56e:
        rts
         .align 4

dymmy_RTE:
		rte

PLAYER_START:		|212
		rts
USER:
		lea     (0x108000).l, a5         | set the a5 for the user mode
		bclr    #7, (BIOS_SYSTEM_MODE).l | $10FD80 BIOS_SYSTEM_MODE
		                                 | Current software mode status:
		                                 | bit 7 = 0 system mode
		                                 | 1 game mode
		                                 | The system is not triggered by the game-start button and game-selection
		                                 | button while it is in the system mode. (Therefore, PLAYER-START
		                                 | would not be called.) During the interrupt-handler routine of the game
		                                 | program (such as during game initialization), and when PLAYEiR-START
		                                 | cannot be called, the system m be in the system mode temporarily, but
		                                 | will return to the game mode as soon as possible.
		moveq   #0, d0
		move.b  (BIOS_USER_REQUEST).l, d0 | $10FDAE BIOS_USER_REQUEST
		                                  | Request for the USER subroutine.
		                                  | 0:Init,
		                                  | 1:Boot animation,
		                                  | 2:Demo,
		                                  | 3:Title
		add.w   d0, d0
		add.w   d0, d0
		movea.l REQUEST_TABLE(pc,d0.w), a0
		jmp     (a0)
        rts

REQUEST_TABLE:
	.long INIT_CASSETTE             | On the MVS, this command is called only once:
                                        | when the cassette is inserted into the main board for the first time.
        .long EYE_CATCHER               | Eye-catcher
                                        | A request is made only when the address 114H is 1. The call is not made
                                        | at any other time, nor with the MVS. Only one request is to be made right
                                        | after the home system is turned on.
        .long DEMO
        .long UserTitleRoutine          | Title

INIT_CASSETTE:
EYE_CATCHER:
		rts
DEMO:
_start:
UserTitleRoutine:	|0x248
		bclr    #7, (BIOS_SYSTEM_MODE).l
		
		bsr.w   InitSystem
		bsr.w   InitScreenAndObjectPool 
_title_PalsubIndexLoop:                      
        move.l  #PaletteTempQueueStart, A5Seg.PAL_IN_POINT(a5)
        moveq   #0, d0
        move.b  A5Seg.PaletteSubGroupIndex(a5), d0
        jsr     (Append32PaletteToTail).l     | params:
                                              |     d0: sub group index, (0x20 pals per group)
        move.b  #0, A5Seg.VBlankSpinEvent(a5) | 0: cpu tell the veo-sys need to update one frame
                                              | 1: veo-sys tell cpu that update done

_title_spinLoop:                              
        tst.b   A5Seg.VBlankSpinEvent(a5) | 0: cpu tell the veo-sys need to update one frame
                                          | 1: veo-sys tell cpu that update done
        beq.s   _title_spinLoop
        subq.b  #1, A5Seg.PaletteSubGroupIndex(a5)
        bpl.s   _title_PalsubIndexLoop

	move.b  #1, (BIOS_USER_MODE).l  | $10FDAF BIOS_USER_MODE
	                                | Set the current status of the game program with the game software.
	                                | 0 = Start-up initialization, eye-catcher
	                                | 1 = Title, game demo
	                                | 2 = Game in progress
	                                | Game selection is enabled only when the mode is " 1" for the MVS. Make
	                                | sure to change the mode to "2" when the game starts after the demo.
	move.l  #GameTitle, A5Seg.MainNextRoutine(a5)
	bra.w   GameLogicMainLoopEntry  | in here and will never come out 
	rts
		
DEMO_END:
        rts
COIN_SOUND:
        addq.w  #1, (COINS_SOUND).l
        rts

IntTimer:
        move.w  #2, (0x3C000C).l
        rte

EUROPE_DATA:
        .ascii "K.O.F."<0x27>"97       "
        .byte 0xFF
        .byte 0xFF
        .byte 0xFF
        .byte 0xFF
        .byte 0xFF
        .byte 0xFF
        .byte 0x25
        .byte 0x12
        .byte    2
        .byte    2
        .byte 0x38
        .byte 0x14
        .byte 0x12
        .byte 0x12
        .byte    2
        .byte    3
        .ascii "PLAY TIME   "
        .ascii "SLOW       "
        .ascii " LITTLE SLOW "
        .ascii "NORMAL      "
        .ascii "LITTLE FAST "
        .ascii "FAST        "
        .ascii "CONTINUE    "
        .ascii "OFF         "
        .ascii "ON          "
        .ascii "DEMO SOUND  "
        .ascii "ON          "
        .ascii "OFF         "
        .ascii "PLAY MANUAL "
        .ascii "ON          "
        .ascii "OFF         "
        .ascii "DIFFICULTY  "
        .ascii "LEVEL 1     "
        .ascii "LEVEL 2     "
        .ascii "LEVEL 3     "
        .ascii "LEVEL 4     "
        .ascii "LEVEL 5     "
        .ascii "LEVEL 6     "
        .ascii "LEVEL 7     "
        .ascii "LEVEL 8     "
        .ascii "CREDIT/LEVELOFF/OFF     "
        .ascii "ON/OFF      "
        .ascii "OFF/ON      "
        .ascii "ON/ON       "
        .ascii "GAME "
        .ascii "MODE   "
        .ascii "SINGLE "
        .ascii "PLAY "
        .ascii "TEAM "
        .ascii "PLAY   "
        .ascii "NEXT "
        .ascii "PAGE                           "
        .ascii "BLOOD COLOR "
        .ascii "ON          "
        .ascii "OFF         "
        .ascii "LANGUAGE    "
        .ascii "ENGLISH     "
        .ascii "SPANISH     "
        .ascii "PORTUGUESE  "

IntVBlankRoutine:             |0x4bc          
        tst.b   (BIOS_SYSTEM_MODE).l    | $10FD80 BIOS_SYSTEM_MODE
                                        | Current software mode status:
                                        | bit 7 = 0 system mode
                                        | 1 game mode
                                        | The system is not triggered by the game-start button and game-selection
                                        | button while it is in the system mode. (Therefore, PLAYER-START
                                        | would not be called.) During the interrupt-handler routine of the game
                                        | program (such as during game initialization), and when PLAYEiR-START
                                        | cannot be called, the system m be in the system mode temporarily, but
                                        | will return to the game mode as soon as possible.
        bmi.s   _notPassToBios          
        jmp     0xC00438                | SYSTEM INT1
| ---------------------------------------------------------------------------

_notPassToBios:                         
	ori     #0x700, sr              | disable all 3 ints 
        movem.l d0-a6, -(sp)            
        lea     (0x108000).l, a5     
        move.b  d0, (REG_WATCHDOG).l    | REG_DIPSW
                                        | Kick watchdog
        move.w  #4, (REG_IRQACK).l      | REG_IRQACK 
|        move.b  A5Seg_IsPlayerExist(a5), d0 | bit0: p1 exist
|                                        | bit1: p2 exist
|        beq.s   loc_9ED6
|        move.b  d0, A5Seg.IsPlayerExistCopy(a5) | bit0: p1 exist
|                                        | bit1: p2 exist
|
|loc_9ED6:                              
|        btst    #1, A5Seg.PaletteUpdateFlag(a5) | bit0: 0: use bank Index 1; 1: use bank Index 0
|                                        | bit1: 1, mask flush screen
|                                        | bit6: 1, mask palette update
|                                        | bit7: 1, only update current palette bank
|        bne.s   loc_9EEA
|        jsr     TestCallFlashRoutine  
|        move.w  A5Seg.BackDoorColor(a5), (0x401FFE).l | the color of the backmost "layer" on the screen
|
|loc_9EEA:                               
        tst.b   A5Seg.VBlankSpinEvent(a5) | 0: cpu tell the veo-sys need to update one frame
                                          | 1: veo-sys tell cpu that update done
        bne.s   _toRet
        addq.l  #1, A5Seg.VBlankCounter(a5)         | 100098, FrameCounter

		|btst    #6, A5Seg.PaletteUpdateFlag(a5) | bit0: 0: use bank Index 1; 1: use bank Index 0
        |                                | bit1: 1, mask flush screen
        |                                | bit6: 1, mask palette update
        |                                | bit7: 1, only update current palette bank
        |bne.s   loc_9F16
        bsr.w   FlushUpdatePalette      | params:
                                        |     void

|loc_9F16:                              
                                
        move.b  A5Seg.TileUpdateFlag(a5), d0 | bit0: 1, vert pos need update for buf_main
                                             | bit1: 1, vert pos need update for buf_sub
                                             | bit6: 1, mask update SCB3
                                             | bit7: 1, mask update SCB3
        andi.b  #0xC0, d0
        bne.s   loc_9F24
        bsr.w   UpdateSCB3               
|                                       
|
loc_9F24:                              
        bsr.w   UpdateSCB2              | updeate shirnk vals
                                      
        bsr.w   UpdateBackgroundSCB3_4        | 只更新 SCB3, SCB4 部分
|        tst.b   A5Seg.InGameHUDFlag(a5) | bit0 & bit1: draw game
|                                        | bit2:
|                                        | bit3: 1, 必杀不闪屏
|                                        | bit4: 1, disable screen scroll
|                                        | bit7: 0, show HUD (fixed layer)
|        bmi.s   @toRet
|        bsr.w   UpdateP1P2LifeBar
|
_toRet:                                 
|                                      
         jsr     (SOUND_SEND).l
|        bsr.w   UpdateKeyStartState
        jsr     0xC0044A                 | Should be called at the end of the VBlank interrupt routine.
|                                        | Reads coin and game select inputs, jumps to COIN_SOUND,
|                                        | PLAYER_START or DEMO_END accordingly.
        lea     (0x108000).l, a5
|        jsr     PalDebugRoutine
        move.b  #1, A5Seg.VBlankSpinEvent(a5) | 0: cpu tell the veo-sys need to update one frame
                                        | 1: veo-sys tell cpu that update done
        movem.l (sp)+, d0-a6            
        rte                            

InitSystem:                             | 0x4ca
                                        
        jsr     (ZeroUserWorkRAM).l     | zero range:
                                        | 100100 ~ 10f2c0-1
        jsr     (INIT_SOUND).l
        move.w  #2, d0
_switchLoop:                          
        move.w  d0, (0x2FFFFE).l        | switch to bank 2
        cmp.w   (0x200000).l, d0
        bne.s   _switchLoop             | switch to bank 2
        
        clr.l   A5Seg.DebugDips(a5)             | clear Debug DIPs     
        rts
| End of function InitSystem


ZeroUserWorkRAM:                        
        lea     (OBJ_LIST_HEAD).l, a0
        move.w  #0xF1B, d0              | f1c * 0x10 = f1c0
_ZeroUserWorkRAM_dbfLoop:            
        clr.l   (a0)+
        clr.l   (a0)+
        clr.l   (a0)+
        clr.l   (a0)+
        dbf     d0, _ZeroUserWorkRAM_dbfLoop
        rts

InitScreenAndObjectPool:           |568 
        move.b  #1, A5Seg.VBlankSpinEvent(a5) | 0: cpu tell the veo-sys need to update one frame
                                              | 1: veo-sys tell cpu that update done
        jsr     ClearFixlay
        jsr     0xC004C8                | LSP_1ST ($C004C8): Clear sprites
        |bsr.w   TestAndInitLowsetMem
        jsr     InitObjectPool
        jsr     SetBackgroundNoUse
        |clr.b   A5Seg.PaletteUpdateFlag(a5) | bit0: 0: use bank Index 1; 1: use bank Index 0
        |                                | bit1: 1, mask flush screen
        |                                | bit6: 1, mask palette update
        |                                | bit7: 1, only update current palette bank
        |ori.b   #0x80, A5Seg.PaletteUpdateFlag(a5) | bit0: 0: use bank Index 1; 1: use bank Index 0
        |                                | bit1: 1, mask flush screen
        |                                | bit6: 1, mask palette update
        |                                | bit7: 1, only update current palette bank
        move.b  #7, A5Seg.PaletteSubGroupIndex(a5)
        andi    #0xF8FF, sr             | enable iterrupt
        ori.b   #0x80, (BIOS_SYSTEM_MODE).l | $10FD80 BIOS_SYSTEM_MODE
                                        | Current software mode status:
                                        | bit 7 = 0 system mode
                                        | 1 game mode
                                        | The system is not triggered by the game-start button and game-selection
                                        | button while it is in the system mode. (Therefore, PLAYER-START
                                        | would not be called.) During the interrupt-handler routine of the game
                                        | program (such as during game initialization), and when PLAYEiR-START
                                        | cannot be called, the system m be in the system mode temporarily, but
                                        | will return to the game mode as soon as possible.
        rts
| End of function InitScreenAndObjectPool

SetBackgroundNoUse:                     
                                        
        andi.b  #0x7F, A5Seg.BackGroundObjLayer0+0x90(a5) | top layer obj     
        andi.b  #0x7F, A5Seg.BackGroundObjLayer1+0x90(a5) 
        andi.b  #0x7F, A5Seg.BackGroundObjLayer2+0x90(a5) 
        andi.b  #0x7F, A5Seg.BackGroundObjLayer3+0x90(a5) 
        andi.b  #0x7F, A5Seg.BackGroundObjLayer4+0x90(a5) 
        andi.b  #0x7F, A5Seg.BackGroundObjLayer5+0x90(a5) 
        andi.b  #0x7F, A5Seg.BackGroundObjLayer6+0x90(a5) 
        andi.b  #0x7F, A5Seg.BackGroundObjLayer7+0x90(a5) 
        rts
| End of function SetBackgroundNoUse


GameLogicMainLoopEntry:           |0x5cc      
_MainLoopStart:                         
        move.b  #0, A5Seg.VBlankSpinEvent(a5) 
        andi.b  #0x7F, A5Seg.TileUpdateFlag(a5) | bit0: 1, vert pos need update for buf_main
                                        | bit1: 1, vert pos need update for buf_sub
                                        | bit6: 1, mask update SCB3
                                        | bit7: 1, mask update SCB3

_mainloop_spinLoop:                              
        tst.b   A5Seg.VBlankSpinEvent(a5) | 0: cpu tell the veo-sys need to update one frame
                                        | 1: veo-sys tell cpu that update done
        beq.s   _mainloop_spinLoop
        ori.b   #0x80, A5Seg.TileUpdateFlag(a5) | bit0: 1, vert pos need update for buf_main
                                        | bit1: 1, vert pos need update for buf_sub
                                        | bit6: 1, mask update SCB3
                                        | bit7: 1, SCB3 not changed
        |bsr.w   UpdateP1P2KeyState
                         

        bsr.w   CallObjRoutine

        jsr     (ShowPressStartButton).l
        |jsr     DisplayZbuf             | 把 Zbuf 中的 obj 逐个更新到 VRAM 中
                          
        jsr     ShowCoin
        
        tst.w   A5Seg.COINS_SOUND(a5)             | $10009E COINS
        beq.s   _next_loop
        movem.l d0-d1/a0, -(sp)
        move.w  #0xA, d0
        jsr     SET_SOUND               | params:
                                        |     d0: sound index
        movem.l (sp)+, d0-d1/a0
        subq.w  #1, A5Seg.COINS_SOUND(a5)

_next_loop:                               
        bra.w   _MainLoopStart
| End of function GameLogicMainLoopEntry

ShowCoin:     
        lea     (0xD00034).l, a1        | "Internal" credit counters for player 1 and player 2 (BCD)       
        move.w  #0x73BD, d2             | player2 credits position
        swap    d2

        lea     FIX_CRESITS, a2         | 'CREDITS'
        move.b  (a1), d0
        cmpi.b  #2, d0
        bcc.s   loc_9514
        lea     FIX_CRESIT, a2          | 'CREDIT'

loc_9514:                               
        moveq   #5, d7

_ShowCoin_loop:                                  
        move.w  (a2)+, d2
        move.l  d2, (REG_VRAMADDR).l        | REG_VRAMADDR
        addi.l  #0x200000, d2
        dbf     d7, _ShowCoin_loop
        move.b  (a1), d0
        andi.w  #0xFF, d0
        move.w  d0, d1
        lsr.w   #4, d1
        addi.w  #0x3F0, d1
        move.w  d1, d2
        move.l  d2, (0x3C0000).l
        addi.l  #0x200000, d2
        andi.w  #0xF, d0
        addi.w  #0x3F0, d0
        move.w  d0, d2
        move.l  d2, (0x3C0000).l                           
        rts
| End of function ShowCoin

FIX_CRESIT:.byte 3, 0xE6, 3, 0xE7, 3, 0xE8, 3, 0xE9, 3, 0xEA, 3, 0xFF                                         
FIX_CRESITS:.byte 3, 0xE0, 3, 0xE1, 3, 0xE2, 3, 0xE3, 3, 0xE4, 3, 0xE5



ShowPressStartButton:                   
        tst.b   (BIOS_USER_MODE).l      | $10FDAF BIOS_USER_MODE
                                        | Set the current status of the game program with the game 
                                        | 0 = Start-up initialization, eye-catcher
                                        | 1 = Title, game demo
                                        | 2 = Game in progress
                                        | Game selection is enabled only when the mode is " 1" for the MVS. Make
                                        | sure to change the mode to "2" when the game starts after the demo.
        bne.s   loc_19D2
        rts
| ---------------------------------------------------------------------------

loc_19D2:                               
        cmpi.b  #1, (BIOS_USER_MODE).l  | $10FDAF BIOS_USER_MODE
                                        | Set the current status of the game program with the game 
                                        | 0 = Start-up initialization, eye-catcher
                                        | 1 = Title, game demo
                                        | 2 = Game in progress
                                        | Game selection is enabled only when the mode is " 1" for the 
                                        | sure to change the mode to "2" when the game starts after the 
        bne.s   loc_19F0
        lea     (TitlePressButtonStruct).l, a4
        bsr.w   DipPressButtonOnTitle   | params:
                                        |     a4: fix lay struct
        rts
| ---------------------------------------------------------------------------

loc_19F0:                              
        rts
| End of function ShowPressStartButton



| params:
|     a4: fix lay struct

DipPressButtonOnTitle:                  
        move.w  #0xA, FixLayerStruct(a4)

        move.w  #0x13, FixLayerStruct.y(a4)
        move.l  #aPress1pOr2pButton, FixLayerStruct.PCHAR(a4) | "PRESS 1P OR 2P BUTTON"
        bsr.w   IfCreditP2Exist         | ret:
                                        |     d0: 0 not exist, 1 exist
        move.w  d0, -(sp)
                            
        bsr.w   IfCreditP1Exist         |     d0: 0 not exist, 1 exist
        move.w  (sp)+, d2
        move.w  d0, d3

        add.w   d3, d2
        move.l  #aPress1pOr2pButton, FixLayerStruct.PCHAR(a4) | "PRESS 1P OR 2P BUTTON"
        cmpi.b  #2, d2
        bcc.s   loc_1CCE
        move.l  #aPress1pButton, FixLayerStruct.PCHAR(a4) | "  PRESS 1P BUTTON    "
        tst.b   d2
        bne.s   loc_1CCE

        move.l  #aInsertCoin, FixLayerStruct.PCHAR(a4)

loc_1CCE:                                                                       
        move.b  -0x7F65(a5), d0			| frame counter .low byte
        andi.b  #0xF, d0
        bne.s   loc_1CDE
        eori.b  #1, FixLayerStruct.Flag(a4) | bit0: 1, show

loc_1CDE:                               | CODE XREF: DipPressButtonOnTitle+A6j
        btst    #0, FixLayerStruct.Flag(a4) | bit0: 1, show
        beq.s   _DipPressButtonOnTitle_clear
        move.w  FixLayerStruct(a4), d0
        move.w  FixLayerStruct.y(a4), d1
        jsr     (ScreenXYToFixMapVRAMAddr).l | params:
                                        |     d0: x
                                        |     d1: y
                                        | ret:
                                        |     d0.highword: offset in VRAM
        movea.l FixLayerStruct.PCHAR(a4), a0
        move.w  #0x1300, d0
        move.l  #0x200000, d1
        jsr     (LoopFixLayOut).l       | params:
                                        |     a0: pChar
                                        |     d0: addr | pal
                                        |     d1: step
        rts
| ---------------------------------------------------------------------------

_DipPressButtonOnTitle_clear:                                 
        move.w  FixLayerStruct(a4), d0
        move.w  FixLayerStruct.y(a4), d1
        move.w  #0x14, d2
        move.w  #0, d3
        jsr     (FixlayVRAMClear).l     | params:
                                        |     d0: x
                                        |     d1: y
                                        |     d2: width
                                        |     d3: height
        rts
| End of function DipPressButtonOnTitle


| ret:
|     d0: 0 not exist, 1 exist

IfCreditP2Exist:                        
        move.w  #0x100, (BIOS_CREDIT_DEC).l | Credit decrement value for each player when calling
                                        | CREDIT DOWN.
        movem.l d0-a6, -(sp)
        jsr     0xC00450                | CREDIT CHECK
        movem.l (sp)+, d0-a6
        move.w  (BIOS_CREDIT_DEC).l, d0 | Credit decrement value for each player when calling
                                        | CREDIT DOWN.
        lsr.w   #8, d0
        rts
| End of function IfCreditP2Exist

| ret:
|     d0: 0 not exist, 1 exist

IfCreditP1Exist:                        
        move.w  #1, (BIOS_CREDIT_DEC).l | Credit decrement value for each player when calling
                                        | CREDIT DOWN.
        movem.l d0-a6, -(sp)
        jsr     0xC00450                | CREDIT_CHECK
        movem.l (sp)+, d0-a6
        move.w  (BIOS_CREDIT_DEC).l, d0 | Credit decrement value for each player when calling
                                        | CREDIT DOWN.
        rts
| End of function IfCreditP1Exist


aPress1pButton:
		.ascii "  PRESS 1P BUTTON    "
        .byte 0xFF
aPress1pOr2pButton:
		.ascii "PRESS 1P OR 2P BUTTON"
        .byte 0xFF
aInsertCoin:
		.ascii "    INSERT COIN      "
        .byte 0xFF