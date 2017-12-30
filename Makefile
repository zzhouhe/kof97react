#######################################
# Base dir of your m68k gcc toolchain #
#######################################

BASEDIR = $(NEODEV)
AS = as
OBJC = objcopy
LD = gcc

#######################################
# Path to libraries and include files #
#######################################

INCDIR = src/
TMPDIR = $(BASEDIR)/tmp

###################################
# Output: {cart, cd} *lower case* #
###################################
OUTPUT = cart

############################
# Settings for cart output #
############################
ROMSIZE = 0x100000
PADBYTE = 0xff

##############################
# Object Files and Libraries #
##############################

OBJS = $(TMPDIR)/main.o $(TMPDIR)/Palette.o $(TMPDIR)/Sound.o $(TMPDIR)/FixLay.o \
		$(TMPDIR)/Sprites.o $(TMPDIR)/Object.o $(TMPDIR)/Title.o $(TMPDIR)/Backgroud.o \
		$(TMPDIR)/Help.o

#####################
# Compilation Flags #
#####################

ASFLAGS = -m68000 --register-prefix-optional
LDFLAGS = -Wl,-Tneocart.x
CCFLAGS = -m68000 -O3 -Wall -fomit-frame-pointer -ffast-math -fno-builtin -nostartfiles -nodefaultlibs

##############
# Make rules #
##############


out.bin : test.o
	$(OBJC) --gap-fill=$(PADBYTE) --pad-to=$(ROMSIZE) -R .data -O binary $< $@

test.o : $(OBJS)
	$(LD) $(CCFLAGS) $(LDFLAGS) $(OBJS) -o $@

$(TMPDIR)/%.o: src/%.s
	$(AS) -I$(INCDIR) $(ASFLAGS) $< -o $@

clean:
	rm -f $(TMPDIR)/*.*


