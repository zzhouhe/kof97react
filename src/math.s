.include	"def.inc"
.globl		GetByteRandVal

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
