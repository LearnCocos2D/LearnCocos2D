/***************************************************************************
*                         Arrays of Arbitrary Bit Length
*
*   File    : bitarray.cpp
*   Purpose : Provides object with methods for creation and manipulation of
*             arbitrary length arrays of bits.
*
*             Bit arrays are implemented as vectors of unsigned chars.  Bit
*             0 is the MSB of char 0, and the last bit is the least
*             significant (non-spare) bit of the last unsigned char.
*
*             Example: array of 20 bits (0 through 19) with 8 bit unsigned
*                      chars requires 3 unsigned chars (0 through 2) to
*                      store all the bits.
*
*                        char       0       1         2
*                               +--------+--------+--------+
*                               |        |        |        |
*                               +--------+--------+--------+
*                        bit     01234567 8911111111111XXXX
*                                           012345 6789
*
*   Author  : Michael Dipperstein
*   Date    : July 23, 2004
*
****************************************************************************
*   HISTORY
*
*   $Id: bitarray.cpp,v 1.7 2010/02/04 03:31:43 michael Exp $
*   $Log: bitarray.cpp,v $
*   Revision 1.7  2010/02/04 03:31:43  michael
*   Replaced vector<unsigned char> with an array of unsigned char.
*
*   Made updates for GCC 4.4.
*
*   Revision 1.5  2007/08/06 05:23:29  michael
*   Updated for LGPL Version 3.
*
*   All methods that don't modify object have been made
*   const to increase functionality of const bit_array_c.
*
*   All assignment operators return a reference to the object being assigned a value so that operator chaining will work.
*
*   Added >> and << operators.
*
*   Revision 1.3  2006/04/30 23:34:07  michael
*   Improved performance by incorporating Benjamin Schindler's
*   <bschindler@student.ethz.ch> changes to pass arguments as a reference.
*
*   Revision 1.2  2004/08/05 22:16:49  michael
*   Add overloads for bitwise operators returning values.
*   Add a more natural looking way to set bit values.
*
*   Revision 1.1.1.1  2004/08/04 13:28:20  michael
*   bit_array_c
*
****************************************************************************
*
* Bitarray: An ANSI C++ class for manipulating arbitrary length bit arrays
* Copyright (C) 2004, 2006-2007, 2010 by
*       Michael Dipperstein (mdipper@alumni.engr.ucsb.edu)
*
* This file is part of the bit array library.
*
* The bit array library is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public License as
* published by the Free Software Foundation; either version 3 of the
* License, or (at your option) any later version.
*
* The bit array library is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
* General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>.
*
***************************************************************************/

/***************************************************************************
*                             INCLUDED FILES
***************************************************************************/
#include <iostream>
#include <climits>
#include "bitarray.h"

using namespace std;

/***************************************************************************
*                                 MACROS
***************************************************************************/

/* make CHAR_BIT 8 if it's not defined in limits.h */
#ifndef CHAR_BIT
#warning CHAR_BIT not defined.  Assuming 8 bits.
#define CHAR_BIT 8
#endif

/* position of bit within character */
#define BIT_CHAR(bit)         ((bit) / CHAR_BIT)

/* array index for character containing bit */
#define BIT_IN_CHAR(bit)      (1 << (CHAR_BIT - 1 - ((bit)  % CHAR_BIT)))

/* number of characters required to contain number of bits */
#define BITS_TO_CHARS(bits)   ((((bits) - 1) / CHAR_BIT) + 1)

/* most significant bit in a character */
#define MS_BIT                (1 << (CHAR_BIT - 1))

/***************************************************************************
*                                 METHODS
***************************************************************************/

/***************************************************************************
*   Method     : bit_array_c - constructor
*   Description: This is the bit_array_c constructor.  It reserves memory
*                for the vector storing the array.
*   Parameters : numBits - number of bits in the array
*   Effects    : Allocates vectory for array bits
*   Returned   : None
***************************************************************************/
bit_array_c::bit_array_c(const int numBits):
    m_NumBits(numBits)
{
    int numBytes;

    numBytes = BITS_TO_CHARS(numBits);

    /* allocate space for bit array */
    m_Array = new unsigned char[numBytes];

    /* set all bits to 0 */
    fill_n(m_Array, numBytes, 0);
}

/***************************************************************************
*   Method     : bit_array_c - constructor
*   Description: This is the bit_array_c constructor.  It copies the
*                for contents of a vector of unsigned char into the
*                bitarray.
*   Parameters : vect - vector to be copied
*                numBits - number of bits in the array
*   Effects    : Allocates vectory for array bits
*   Returned   : None
***************************************************************************/
bit_array_c::bit_array_c(unsigned char *array, const int numBits):
    m_NumBits(numBits),
    m_Array(array)
{
}

/***************************************************************************
*   Method     : ~bit_array_c - destructor
*   Description: This is the bit_array_c destructor.  At this point it's
*                just a place holder.
*   Parameters : None
*   Effects    : None
*   Returned   : None
***************************************************************************/
bit_array_c::~bit_array_c(void)
{
    delete[] m_Array;
}

/***************************************************************************
*   Method     : Dump
*   Description: This method dumps the conents of a bit array to stdout.
*                The format of the dump is a series of bytes represented in
*                hexadecimal.
*   Parameters : outStream - stream to write to
*   Effects    : Array contents are dumped to stdout
*   Returned   : None
***************************************************************************/
void bit_array_c::Dump(std::ostream &outStream)
{
    int size;

    size = BITS_TO_CHARS(m_NumBits);

    outStream.width(2);
    outStream.fill('0');
    outStream << uppercase << hex << (int)(m_Array[0]);  /* first byte */

    for (int i = 1; i < size; i++)
    {
        /* remaining bytes with a leading space */
        outStream << " ";
        outStream.width(2);
        outStream.fill('0');
        outStream << (int)(m_Array[i]);
    }

    outStream << dec;
}

/***************************************************************************
*   Method     : SetAll
*   Description: This method sets every bit in the bit array to 1.  This
*                method uses UCHAR_MAX to determine what it means to set
*                all bits in an unsigned char, so it is crucial that the
*                machine implementation of unsigned char utilizes all of
*                the bits in the memory allocated for an unsigned char.
*   Parameters : None
*   Effects    : Each of the bits used in the bit array are set to 1.
*                Unused (spare) bits are set to 0.
*   Returned   : None
***************************************************************************/
void bit_array_c::SetAll(void)
{
    int bits, size;
    unsigned char mask;

    size = BITS_TO_CHARS(m_NumBits);

    /* set bits in all bytes to 1 */
    fill_n(m_Array, size, UCHAR_MAX);

    /* zero any spare bits so increment and decrement are consistent */
    bits = m_NumBits % CHAR_BIT;
    if (bits != 0)
    {
        mask = UCHAR_MAX << (CHAR_BIT - bits);
        m_Array[BIT_CHAR(m_NumBits - 1)] = mask;
    }
}

/***************************************************************************
*   Method     : ClearAll
*   Description: This method sets every bit in the bit array to 0.
*   Parameters : None
*   Effects    : Each of the bits in the bit array are set to 0.
*   Returned   : None
***************************************************************************/
void bit_array_c::ClearAll(void)
{
    int size;

    size = BITS_TO_CHARS(m_NumBits);

    /* set bits in all bytes to 0 */
    fill_n(m_Array, size, 0);
}

/***************************************************************************
*   Method     : SetBit
*   Description: This method sets a bit in the bit array to 1.
*   Parameters : bit - the number of the bit to set
*   Effects    : The specified bit will be set to 1.
*   Returned   : None
***************************************************************************/
void bit_array_c::SetBit(const unsigned int bit)
{
    if (m_NumBits <= bit)
    {
        return;         /* bit out of range */
    }

    m_Array[BIT_CHAR(bit)] |= BIT_IN_CHAR(bit);
}

/***************************************************************************
*   Method     : ClearBit
*   Description: This method sets a bit in the bit array to 0.
*   Parameters : bit - the number of the bit to clear
*   Effects    : The specified bit will be set to 0.
*   Returned   : None
***************************************************************************/
void bit_array_c::ClearBit(const unsigned int bit)
{
    unsigned char mask;

    if (m_NumBits <= bit)
    {
        return;         /* bit out of range */
    }

    /* create a mask to zero out desired bit */
    mask =  BIT_IN_CHAR(bit);
    mask = ~mask;

    m_Array[BIT_CHAR(bit)] &= mask;
}

/***************************************************************************
*   Method     : operator()
*   Description: Overload of the () operator.  This method approximates
*                array indices used for assignment.  It returns a
*                bit_array_index_c which includes an = method used to
*                set bit values.
*   Parameters : bit - index of array bit
*   Effects    : None
*   Returned   : bit_array_index_c (pointer to bit)
***************************************************************************/
bit_array_index_c bit_array_c::operator()(const unsigned int bit)
{
    bit_array_index_c result(this, bit);

    return result;
}

/***************************************************************************
*   Method     : operator[]
*   Description: Overload of the [] operator.  This method returns the
*                value of a bit in the bit array.
*   Parameters : bit - index of array bit
*   Effects    : None
*   Returned   : The value of the specified bit.
***************************************************************************/
bool bit_array_c::operator[](const unsigned int bit) const
{
    return((m_Array[BIT_CHAR(bit)] & BIT_IN_CHAR(bit)) != 0);
}

/***************************************************************************
*   Method     : operator==
*   Description: overload of the == operator
*   Parameters : other - bit array to compare
*   Effects    : None
*   Returned   : True if this == other.  Otherwise false.
***************************************************************************/
bool bit_array_c::operator==(const bit_array_c &other) const
{
    if (m_NumBits != other.m_NumBits)
    {
        /* unequal sizes */
        return false;
    }

    return (this->m_Array == other.m_Array);
}

/***************************************************************************
*   Method     : operator!=
*   Description: overload of the != operator
*   Parameters : other - bit array to compare
*   Effects    : None
*   Returned   : True if this != other.  Otherwise false.
***************************************************************************/
bool bit_array_c::operator!=(const bit_array_c &other) const
{
    if (m_NumBits != other.m_NumBits)
    {
        /* unequal sizes */
        return true;
    }

    return (this->m_Array != other.m_Array);
}

/***************************************************************************
*   Method     : operator<
*   Description: overload of the < operator
*   Parameters : other - bit array to compare
*   Effects    : None
*   Returned   : True if this < other.  Otherwise false.
***************************************************************************/
bool bit_array_c::operator<(const bit_array_c &other) const
{
    if (m_NumBits != other.m_NumBits)
    {
        /* unequal sizes */
        return false;
    }

    return (this->m_Array < other.m_Array);
}

/***************************************************************************
*   Method     : operator<=
*   Description: overload of the <= operator
*   Parameters : other - bit array to compare
*   Effects    : None
*   Returned   : True if this <= other.  Otherwise false.
***************************************************************************/
bool bit_array_c::operator<=(const bit_array_c &other) const
{
    if (m_NumBits != other.m_NumBits)
    {
        /* unequal sizes */
        return false;
    }

    return (this->m_Array <= other.m_Array);
}

/***************************************************************************
*   Method     : operator>
*   Description: overload of the > operator
*   Parameters : other - bit array to compare
*   Effects    : None
*   Returned   : True if this > other.  Otherwise false.
***************************************************************************/
bool bit_array_c::operator>(const bit_array_c &other) const
{
    if (m_NumBits != other.m_NumBits)
    {
        /* unequal sizes */
        return false;
    }

    return (this->m_Array > other.m_Array);
}

/***************************************************************************
*   Method     : operator>=
*   Description: overload of the >= operator
*   Parameters : other - bit array to compare
*   Effects    : None
*   Returned   : True if this >= other.  Otherwise false.
***************************************************************************/
bool bit_array_c::operator>=(const bit_array_c &other) const
{
    if (m_NumBits != other.m_NumBits)
    {
        /* unequal sizes */
        return false;
    }

    return (this->m_Array >= other.m_Array);
}

/***************************************************************************
*   Method     : operator~
*   Description: overload of the ~ operator.  Negates all non-spare bits in
*                bit array
*   Parameters : None
*   Effects    : None
*   Returned   : value of this after bitwise not
***************************************************************************/
bit_array_c bit_array_c::operator~(void) const
{
    bit_array_c result(this->m_NumBits);
    result = *this;
    result.Not();

    return result;
}

/***************************************************************************
*   Method     : operator&
*   Description: overload of the & operator.  Performs a bitwise and
*                between the source array and this bit array.
*   Parameters : other - bit array on righthand side of &
*   Effects    : None
*   Returned   : value of bitwise and of this and other.
***************************************************************************/
bit_array_c bit_array_c::operator&(const bit_array_c &other) const
{
    bit_array_c result(this->m_NumBits);
    result = *this;
    result &= other;

    return result;
}


/***************************************************************************
*   Method     : operator^
*   Description: overload of the ^ operator.  Performs a bitwise xor
*                between the source array and this bit array.
*   Parameters : other - bit array on righthand side of ^
*   Effects    : None
*   Returned   : value of bitwise xor of this and other.
***************************************************************************/
bit_array_c bit_array_c::operator^(const bit_array_c &other) const
{
    bit_array_c result(this->m_NumBits);
    result = *this;
    result ^= other;

    return result;
}

/***************************************************************************
*   Method     : operator|
*   Description: overload of the | operator.  Performs a bitwise or
*                between the source array and this bit array.
*   Parameters : other - bit array on righthand side of |
*   Effects    : None
*   Returned   : value of bitwise or of this and other.
***************************************************************************/
bit_array_c bit_array_c::operator|(const bit_array_c &other) const
{
    bit_array_c result(this->m_NumBits);
    result = *this;
    result |= other;

    return result;
}

/***************************************************************************
*   Method     : operator<<
*   Description: overload of the << operator.  Performs a bitwise left
*                shift of this bit array.
*   Parameters : count - the number of bits to shift left
*   Effects    : None
*   Returned   : result of bitwise left shift
***************************************************************************/
bit_array_c bit_array_c::operator<<(const unsigned int count) const
{
    bit_array_c result(this->m_NumBits);
    result = *this;
    result <<= count;

    return result;
}

/***************************************************************************
*   Method     : operator>>
*   Description: overload of the >> operator.  Performs a bitwise right
*                shift of this bit array.
*   Parameters : count - the number of bits to shift right
*   Effects    : None
*   Returned   : result of bitwise right shift
***************************************************************************/
bit_array_c bit_array_c::operator>>(const unsigned int count) const
{
    bit_array_c result(this->m_NumBits);
    result = *this;
    result >>= count;

    return result;
}

/***************************************************************************
*   Method     : operator++ (prefix)
*   Description: overload of the ++ operator.  Increments the contents of
*                a bit array.  Overflows cause rollover.
*   Parameters : None
*   Effects    : Bit array contents are incremented
*   Returned   : Reference to this array after increment
***************************************************************************/
bit_array_c& bit_array_c::operator++(void)
{
    int i;
    unsigned char maxValue;     /* maximum value for current char */
    unsigned char one;          /* least significant bit in current char */

    if (m_NumBits == 0)
    {
        return *this;           /* nothing to increment */
    }

    /* handle arrays that don't use every bit in the last character */
    i = (m_NumBits % CHAR_BIT);
    if (i != 0)
    {
        maxValue = UCHAR_MAX << (CHAR_BIT - i);
        one = 1 << (CHAR_BIT - i);
    }
    else
    {
        maxValue = UCHAR_MAX;
        one = 1;
    }

    for (i = BIT_CHAR(m_NumBits - 1); i >= 0; i--)
    {
        if (m_Array[i] != maxValue)
        {
            m_Array[i] = m_Array[i] + one;
            return *this;
        }
        else
        {
            /* need to carry to next byte */
            m_Array[i] = 0;

            /* remaining characters must use all bits */
            maxValue = UCHAR_MAX;
            one = 1;
        }
    }

    return *this;
}

/***************************************************************************
*   Method     : operator++ (postfix)
*   Description: overload of the ++ operator.  Increments the contents of
*                a bit array.  Overflows cause rollover.
*   Parameters : dumy - needed for postfix increment
*   Effects    : Bit array contents are incremented
*   Returned   : Reference to this array after increment
***************************************************************************/
bit_array_c& bit_array_c::operator++(int dummy)
{
    ++(*this);
    return *this;
}

/***************************************************************************
*   Method     : operator-- (prefix)
*   Description: overload of the -- operator.  Decrements the contents of
*                a bit array.  Underflows cause rollover.
*   Parameters : None
*   Effects    : Bit array contents are decremented
*   Returned   : None
***************************************************************************/
bit_array_c& bit_array_c::operator--(void)
{
    int i;
    unsigned char maxValue;     /* maximum value for current char */
    unsigned char one;          /* least significant bit in current char */

    if (m_NumBits == 0)
    {
        return *this;           /* nothing to decrement */
    }

    /* handle arrays that don't use every bit in the last character */
    i = (m_NumBits % CHAR_BIT);
    if (i != 0)
    {
        maxValue = UCHAR_MAX << (CHAR_BIT - i);
        one = 1 << (CHAR_BIT - i);
    }
    else
    {
        maxValue = UCHAR_MAX;
        one = 1;
    }

    for (i = BIT_CHAR(m_NumBits - 1); i >= 0; i--)
    {
        if (m_Array[i] >= one)
        {
            m_Array[i] = m_Array[i] - one;
            return *this;
        }
        else
        {
            /* need to borrow from the next byte */
            m_Array[i] = maxValue;

            /* remaining characters must use all bits */
            maxValue = UCHAR_MAX;
            one = 1;
        }
    }

    return *this;
}

/***************************************************************************
*   Method     : operator-- (postfix)
*   Description: overload of the -- operator.  Decrements the contents of
*                a bit array.  Underflows cause rollover.
*   Parameters : dumy - needed for postfix decrement
*   Effects    : Bit array contents are decremented
*   Returned   : None
***************************************************************************/
bit_array_c& bit_array_c::operator--(int dummy)
{
    --(*this);
    return *this;
}

/***************************************************************************
*   Method     : operator=
*   Description: overload of the = operator.  Copies source contents into
*                this bit array.
*   Parameters : src - Source bit array
*   Effects    : Source bit array contents are copied into this array
*   Returned   : Reference to this array after copy
***************************************************************************/
bit_array_c& bit_array_c::operator=(const bit_array_c &src)
{
    if (*this == src)
    {
        /* don't do anything for a self assignment */
        return *this;
    }

    if (m_NumBits != src.m_NumBits)
    {
        /* don't do assignment with different array sizes */
        return *this;
    }

    if ((m_NumBits == 0) || (src.m_NumBits == 0))
    {
        /* don't do assignment with unallocated array */
        return *this;
    }

    /* copy bits from source */
    int size;
    size = BITS_TO_CHARS(m_NumBits);

    copy(src.m_Array, &src.m_Array[size], this->m_Array);
    return *this;
}

/***************************************************************************
*   Method     : operator&=
*   Description: overload of the &= operator.  Performs a bitwise and
*                between the source array and this bit array.  This bit
*                array will contain the result.
*   Parameters : src - Source bit array
*   Effects    : Results of bitwise and are stored in this array
*   Returned   : Reference to this array after and
***************************************************************************/
bit_array_c& bit_array_c::operator&=(const bit_array_c &src)
{
    int size;

    size = BITS_TO_CHARS(m_NumBits);

    if (m_NumBits != src.m_NumBits)
    {
        /* don't do assignment with different array sizes */
        return *this;
    }

    /* AND array one unsigned char at a time */
    for(int i = 0; i < size; i++)
    {
        m_Array[i] = m_Array[i] & src.m_Array[i];
    }

    return *this;
}

/***************************************************************************
*   Method     : operator^=
*   Description: overload of the ^= operator.  Performs a bitwise xor
*                between the source array and this bit array.  This bit
*                array will contain the result.
*   Parameters : src - Source bit array
*   Effects    : Results of bitwise xor are stored in this array
*   Returned   : Reference to this array after xor
***************************************************************************/
bit_array_c& bit_array_c::operator^=(const bit_array_c &src)
{
    int size;

    size = BITS_TO_CHARS(m_NumBits);

    if (m_NumBits != src.m_NumBits)
    {
        /* don't do assignment with different array sizes */
        return *this;
    }

    /* XOR array one unsigned char at a time */
    for(int i = 0; i < size; i++)
    {
        m_Array[i] = m_Array[i] ^ src.m_Array[i];
    }

    return *this;
}

/***************************************************************************
*   Method     : operator|=
*   Description: overload of the |= operator.  Performs a bitwise or
*                between the source array and this bit array.  This bit
*                array will contain the result.
*   Parameters : src - Source bit array
*   Effects    : Results of bitwise or are stored in this array
*   Returned   : Reference to this array after or
***************************************************************************/
bit_array_c& bit_array_c::operator|=(const bit_array_c &src)
{
    int size;

    size = BITS_TO_CHARS(m_NumBits);

    if (m_NumBits != src.m_NumBits)
    {
        /* don't do assignment with different array sizes */
        return *this;
    }

    /* OR array one unsigned char at a time */
    for(int i = 0; i < size; i++)
    {
        m_Array[i] = m_Array[i] | src.m_Array[i];
    }

    return *this;
}

/***************************************************************************
*   Method     : Not
*   Description: Negates all non-spare bits in bit array.
*   Parameters : None
*   Effects    : Contents of bit array are negated.  Any spare bits are
*                left at 0.
*   Returned   : Reference to this array after not
***************************************************************************/
bit_array_c& bit_array_c::Not(void)
{
    int bits;
    unsigned char mask;
    int size;

    size = BITS_TO_CHARS(m_NumBits);

    if (m_NumBits == 0)
    {
        /* don't do not with unallocated array */
        return *this;
    }

    /* NOT array one unsigned char at a time */
    for(int i = 0; i < size; i++)
    {
        m_Array[i] = ~m_Array[i];
    }

    /* zero any spare bits so increment and decrement are consistent */
    bits = m_NumBits % CHAR_BIT;
    if (bits != 0)
    {
        mask = UCHAR_MAX << (CHAR_BIT - bits);
        m_Array[BIT_CHAR(m_NumBits - 1)] &= mask;
    }

    return *this;
}

/***************************************************************************
*   Method     : operator<<=
*   Description: overload of the <<= operator.  Performs a left shift on
*                this bit array.  This bit array will contain the result.
*   Parameters : shifts - number of bit positions to shift
*   Effects    : Results of the shifts are stored in this array
*   Returned   : Reference to this array after shift
***************************************************************************/
bit_array_c& bit_array_c::operator<<=(const unsigned int shifts)
{
    int i;
    int chars = shifts / CHAR_BIT; /* number of whole byte shifts */

    if (shifts >= m_NumBits)
    {
        /* all bits have been shifted off */
        this->ClearAll();
        return *this;
    }

    /* first handle big jumps of bytes */
    if (chars > 0)
    {
        int size;

        size = BITS_TO_CHARS(m_NumBits);

        for (i = 0; (i + chars) < size; i++)
        {
            m_Array[i] = m_Array[i + chars];
        }

        /* now zero out new bytes on the right */
        for (i = size; chars > 0; chars--)
        {
            m_Array[i - chars] = 0;
        }
    }

    /* now we have at most CHAR_BIT - 1 bit shifts across the whole array */
    for (i = 0; i < (int)(shifts % CHAR_BIT); i++)
    {
        for (unsigned int j = 0; j < BIT_CHAR(m_NumBits - 1); j++)
        {
            m_Array[j] <<= 1;

            /* handle shifts across byte bounds */
            if (m_Array[j + 1] & MS_BIT)
            {
                m_Array[j] |= 0x01;
            }
        }

        m_Array[BIT_CHAR(m_NumBits - 1)] <<= 1;
    }

    return *this;
}

/***************************************************************************
*   Method     : operator>>=
*   Description: overload of the >>= operator.  Performs a right shift on
*                this bit array.  This bit array will contain the result.
*   Parameters : shifts - number of bit positions to shift
*   Effects    : Results of the shifts are stored in this array
*   Returned   : Reference to this array after shift
***************************************************************************/
bit_array_c& bit_array_c::operator>>=(const unsigned int shifts)
{
    int i;
    char mask;
    int chars = shifts / CHAR_BIT;  /* number of whole byte shifts */

    if (shifts >= m_NumBits)
    {
        /* all bits have been shifted off */
        this->ClearAll();
        return *this;
    }

    /* first handle big jumps of bytes */
    if (chars > 0)
    {
        for (i = BIT_CHAR(m_NumBits - 1); (i - chars) >= 0; i--)
        {
            m_Array[i] = m_Array[i - chars];
        }

        /* now zero out new bytes on the right */
        for (; chars > 0; chars--)
        {
            m_Array[chars - 1] = 0;
        }
    }

    /* now we have at most CHAR_BIT - 1 bit shifts across the whole array */
    for (i = 0; i < (int)(shifts % CHAR_BIT); i++)
    {
        for (unsigned int j = BIT_CHAR(m_NumBits - 1); j > 0; j--)
        {
            m_Array[j] >>= 1;

            /* handle shifts across byte bounds */
            if (m_Array[j - 1] & 0x01)
            {
                m_Array[j] |= MS_BIT;
            }
        }

        m_Array[0] >>= 1;
    }

    /***********************************************************************
    * zero any spare bits that are shifted beyond the end of the bit array
    * so that increment and decrement are consistent.
    ***********************************************************************/
    i = m_NumBits % CHAR_BIT;
    if (i != 0)
    {
        mask = UCHAR_MAX << (CHAR_BIT - i);
        m_Array[BIT_CHAR(m_NumBits - 1)] &= mask;
    }

    return *this;
}

/***************************************************************************
*   Method     : bit_array_index_c - constructor
*   Description: This is the bit_array_index_c constructor.  It stores a
*                pointer to the bit array and the bit index.
*   Parameters : array - pointer to bit array
*                index - index of bit in array
*   Effects    : Pointer to bit array and bit index are stored.
*   Returned   : None
***************************************************************************/
bit_array_index_c::bit_array_index_c(bit_array_c *array,
    const unsigned int index)
{
    m_BitArray = array;
    m_Index = index;
}

/***************************************************************************
*   Method     : operator=
*   Description: overload of the = operator.  Sets the bit array bit to
*                the value of src.
*   Parameters : src - bit value
*   Effects    : Bit pointed to by this object is set to the value of
*                source.
*   Returned   : None
***************************************************************************/
void bit_array_index_c::operator=(const bool src)
{
    if (m_BitArray == NULL)
    {
        return;     /* no array */
    }

    if (m_BitArray->Size() <= m_Index)
    {
        return;     /* index is out of bounds */
    }

    if (src)
    {
        m_BitArray->SetBit(m_Index);
    }
    else
    {
        m_BitArray->ClearBit(m_Index);
    }
}
