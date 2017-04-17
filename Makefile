CASM = nasm
CC   = gcc
CFLAGS   = -c -m32
NFLAGS   = -w-all
INCLUDE  = 
TARGET   = sandbox.exe
SOURCES_ASM = $(wildcard *.asm)
SOURCES_C   = $(wildcard *.c)
OBJECTS_ASM = $(SOURCES_ASM:.asm=.obj)
OBJECTS_C   = $(SOURCES_C:.c=.obj)
OBJECTS  = $(OBJECTS_ASM) $(OBJECTS_C)
DEPENDS  = $(OBJECTS_C:.obj=.d) $(OBJECTS_ASM:.obj=.d)

ifeq ($(OS),Windows_NT)
    REMOVE = rm
    NFLAGS += -fwin32 
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),MINGW32_NT-10)
		REMOVE = rm
	endif
else
    REMOVE = rm -f
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Linux)
        NFLAGS += -felf32 
    endif
    ifeq ($(UNAME_S),Darwin)
        NFLAGS += -fmacho32 --PREFIX _
    endif
    
endif

$(TARGET): $(OBJECTS)
	$(CC) -m32 -o $@ $^ 

%.obj: %.c
	$(CC) $(CFLAGS) $(INCLUDE) -o $@ $<

%.obj: %.asm
	$(CASM) $(NFLAGS) -o $@ $<


all: clean $(TARGET)

clean:
	$(REMOVE) $(OBJECTS) $(TARGET)
	
test:
	echo $(OBJECTS)
	
