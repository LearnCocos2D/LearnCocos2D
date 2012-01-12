############################################################################
# Makefile for bitarray library and sample
#
#   $Id: Makefile,v 1.2 2007/07/16 01:55:50 michael Exp $
#   $Log: Makefile,v $
#   Revision 1.2  2007/07/16 01:55:50  michael
#   Use -pedantic when compiling.
#
#   Revision 1.1.1.1  2004/02/09 04:15:45  michael
#   Initial release
#
#
############################################################################

CC = gcc
LD = gcc
CFLAGS = -O2 -Wall -pedantic -ansi -c
LDFLAGS = -O2 -o

# Treat NT and non-NT windows the same
ifeq ($(OS),Windows_NT)
	OS = Windows
endif

ifeq ($(OS),Windows)
	EXE = .exe
	DEL = del
else    #assume Linux/Unix
	EXE =
	DEL = rm
endif

all:	sample$(EXE)

sample$(EXE):	sample.o bitarray.o
	$(LD) $^ $(LDFLAGS) $@

sample.o:	sample.c bitarray.h
	$(CC) $(CFLAGS) $<

bitarray.o:	bitarray.c bitarray.h
	$(CC) $(CFLAGS) $<

clean:
	$(DEL) *.o
	$(DEL) sample$(EXE)
