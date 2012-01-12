############################################################################
# Makefile for bitarray class library and sample
#
#   $Id: Makefile,v 1.2 2007/07/16 02:00:19 michael Exp $
#   $Log: Makefile,v $
#   Revision 1.2  2007/07/16 02:00:19  michael
#   Use -pedantic option when compiling.
#
#   Revision 1.1.1.1  2004/08/04 13:28:20  michael
#   bit_array_c
#
############################################################################

CPP = g++
LD = g++
CPPFLAGS = -O2 -Wall -pedantic -c
LDFLAGS = -O2 -o

# Treat NT and non-NT windows the same
ifeq ($(OS),Windows_NT)
	OS = Windows
endif

ifeq ($(OS),Windows)
	EXE = .exe
	DEL = del
else	#assume Linux/Unix
	EXE =
	DEL = rm
endif

all:		sample$(EXE)

sample$(EXE):	sample.o bitarray.o
		$(LD) $^ $(LDFLAGS) $@

sample.o:	sample.cpp bitarray.h
		$(CPP) $(CPPFLAGS) $<

bitarray.o:	bitarray.cpp bitarray.h
		$(CPP) $(CPPFLAGS) $<

clean:
		$(DEL) *.o
		$(DEL) sample$(EXE)
