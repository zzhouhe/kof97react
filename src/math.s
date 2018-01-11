.include	"def.inc"
.globl		GetByteRandVal
.globl		LongLong64BitTest

| ret:
|     d0: rand val, byte

GetByteRandVal:                         | CODE XREF: _HelpRoutine_step2+22p
                                        | _HelpRoutine_step2+36p ...
        add.w   (0x3C0006).l, d0        | REG_LSPCMODE
        lsr.w   #3, d0
        add.w   -0x7F64(a5), d0
        add.w   -0x7F66(a5), d0         | frame counter
        addq.w  #1, -0x7F64(a5)
        lea     (0xC04200).l, a0        | RND_DATA
        andi.l  #0xFF, d0
        move.b  (a0,d0.w), d0
        rts

| params:
|     d0: bit index to test
|     a0: pLong
| ret:
|     d0: 1, set; 0, clear

LongLong64BitTest:                      
        subi.w  #0x20, d0
        bmi.w   _LongLong64BitTest_doTest
        addq.l  #4, a0
        bra.s   LongLong64BitTest       
| ---------------------------------------------------------------------------

_LongLong64BitTest_doTest:                                
        addi.w  #0x20, d0
        move.l  (a0), d1
        btst    d0, d1
        bne.w   _LongLong64BitTest_set
        moveq   #0, d0
        rts
| ---------------------------------------------------------------------------

_LongLong64BitTest_set:                                   
        moveq   #1, d0
        rts
| End of function LongLong64BitTest
