ifndef CROSS_COMPILE
	CROSS_COMPILE = mips-linux-gnu-
endif

CC = $(CROSS_COMPILE)as
LD = $(CROSS_COMPILE)ld
#DIFF
OBJCP = $(CROSS_COMPILE)objcopy
OBJDUMP = $(CROSS_COMPILE)objdump

OBJECTS = inst_rom.o

export CROSS_COMPILE

#
#	Ruler of compilation
#

all: inst_rom.om inst_rom.bin inst_rom.asm inst_rom.data

%.o: %.S
	$(CC) -mips32 $< -o $@
inst_rom.om: ram.ld $(OBJECTS)
	$(LD) -T ram.ld $(OBJECTS) -o $@
inst_rom.bin: inst_rom.om #DIFF
	$(OBJCP) -O binary $<  $@
inst_rom.asm: inst_rom.om
	$(OBJDUMP) -D $< > $@
inst_rom.data: inst_rom.bin
	./Bin2Mem -f $< -o $@
clean:
	rm -f *.o *.om *.bin *.data *.mif *.asm
