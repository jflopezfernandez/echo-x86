
vpath %.asm src
vpath %.inc include

OBJS     = echo.o
LSTS     = $(patsubst %.o,%.lst,$(OBJS))

AS       = nasm
ASFLAGS  = -f elf

LD       = ld
LDFLAGS  = -m elf_i386

TARGET   = echo-x86

all: $(TARGET)

$(TARGET): $(OBJS)
	$(LD) $(LDFLAGS) -o $@ $^

%.o: %.asm
	$(AS) $(ASFLAGS) -o $@ $^

listings: $(LSTS)

%.lst: %.asm
	$(AS) $(ASFLAGS) -l $@ $^

.PHONY: clean
clean:
	$(RM) $(OBJS) $(LSTS) $(TARGET)

