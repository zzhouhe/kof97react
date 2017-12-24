Backup_Start = 0x100000
Backup_Size  = 0x100
BIOS_SYSTEM_MODE = 0x10FD80
BIOS_USER_REQUEST = 0x10FDAE
BIOS_USER_MODE = 0x10FDAF

PAL_START = 0x2cfff0

REG_VRAMADDR = 0x3C0000
REG_VRAMRW = 0x3C0002
REG_VRAMMOD = 0x3c0004

REG_WATCHDOG = 0x3C0001
REG_IRQACK = 0x3C000C
REG_SOUND   =   0x320000

COINS_SOUND = 0x0010009E

A5Seg.DebugDips = -0x8000
A5Seg.COINS_SOUND = -0x7f62
A5Seg.VBlankCounter = -0x7f68

OBJ_LIST_HEAD = 0x100100

ScreenObj = 0x0
ScreenObj.Flag = 0x90

Object = 0x0
Object.PNext = 0x4
Object.PPrev = 0x8



A5Seg.MainNextRoutine = 0x500
A5Seg.SpritePoolBaseTable = 0x2700
A5Seg.ObjPoolStackIndex = 0x2780
A5Seg.VBlankSpinEvent = 0x2785
A5Seg.TileUpdateFlag = 0x2789
|A5Seg.PaletteUpdateFlag = 0x278a
A5Seg.IsPlayerExist = 0x27f2

A5Seg.ObjZBuf = 0x286a
A5Seg.NumInObjZBuf = 0x2e6c
A5Seg.TileVertPositionsBuff_Main = 0x2e6e
A5Seg.BackUpTileOffsetInSCB1_Main = 0x306e
A5Seg.TileOffsetInSCB1_Main = 0x3070
A5Seg.ObjTotalSpriteNumbers_Main = 0x3072
A5Seg.SpriteAlreadyUsed_Main = 0x3076
A5Seg.BackGroundObjLayer0 = 0x30b2
A5Seg.BackGroundObjLayer1 = 0x31b2
A5Seg.BackGroundObjLayer2 = 0x32b2
A5Seg.BackGroundObjLayer3 = 0x33b2
A5Seg.BackGroundObjLayer4 = 0x34b2
A5Seg.BackGroundObjLayer5 = 0x35b2
A5Seg.BackGroundObjLayer6 = 0x36b2
A5Seg.BackGroundObjLayer7 = 0x37b2
A5Seg.PendingNumOfBackgroundLayerToUpdate = 0x38b2

PaletteTempQueueStart = 0x108000 + 0x4022	|0x10c022
A5Seg.PaletteTempQueueStart = 0x4022
A5Seg.PAL_IN_POINT = 0x5924
A5Seg.SD_IN_POINT = 0x5936
A5Seg.SD_OUT_POINT = 0x5937
A5Seg.BGM_CODE      = 0x5938
A5Seg.SOUND_CODE_W  = 0x593a
A5Seg.SOUND_BUFFER = 0x593e     |size: 0x100

A5Seg.FirstObjIndexInZBuf = 0x64d2
A5Seg.pGhostBuf = 0x64d6
A5Seg.TextOutputOffset = 0x64f6
A5Seg.TextOutputEntryHigh = 0x64f8
A5Seg.TextOutputDefaultPalIndex = 0x64fa
A5Seg.PaletteSubGroupIndex = 0x66be



