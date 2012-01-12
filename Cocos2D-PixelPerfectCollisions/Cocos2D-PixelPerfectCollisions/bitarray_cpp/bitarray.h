/***************************************************************************
*                         Arrays of Arbitrary Bit Length
*
*   File    : bitarray.h
*   Purpose : Header file for class supporting the creation and
*             manipulation of arbitrary length arrays of bits.
*   Author  : Michael Dipperstein
*   Date    : July 23, 2004
*
****************************************************************************
*   HISTORY
*
*   $Id: bitarray.h,v 1.5 2010/02/04 03:31:43 michael Exp $
*   $Log: bitarray.h,v $
*   Revision 1.5  2010/02/04 03:31:43  michael
*   Replaced vector<unsigned char> with an array of unsigned char.
*
*   Made updates for GCC 4.4.
*
*   Revision 1.4  2007/08/06 05:23:12  michael
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
*   Revision 1.2  2004/08/05 22:17:04  michael
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
#ifndef BIT_ARRAY_H
#define BIT_ARRAY_H

/***************************************************************************
*                             INCLUDED FILES
***************************************************************************/
#include <ostream>

/***************************************************************************
*                            TYPE DEFINITIONS
***************************************************************************/
class bit_array_c;

class bit_array_index_c
{
    public:
        bit_array_index_c(bit_array_c *array, const unsigned int index);

        /* assignment */
        void operator=(const bool src);

    private:
        bit_array_c *m_BitArray;        /* array index applies to */
        unsigned int m_Index;           /* index of bit in array */
};

class bit_array_c
{
    public:
        bit_array_c(const int numBits);
        bit_array_c(unsigned char *array, const int numBits);

        virtual ~bit_array_c(void);

        void Dump(std::ostream &outStream);

        const unsigned int Size() { return m_NumBits; };

        /* set/clear functions */
        void SetAll(void);
        void ClearAll(void);
        void SetBit(const unsigned int bit);
        void ClearBit(const unsigned int bit);

        bit_array_index_c operator()(const unsigned int bit);

        /* boolean operator */
        bool operator[](const unsigned int bit) const;
        bool operator==(const bit_array_c &other) const;
        bool operator!=(const bit_array_c &other) const;
        bool operator<(const bit_array_c &other) const;
        bool operator<=(const bit_array_c &other) const;
        bool operator>(const bit_array_c &other) const;
        bool operator>=(const bit_array_c &other) const;

        /* bitwise operators */
        bit_array_c operator&(const bit_array_c &other) const;
        bit_array_c operator^(const bit_array_c &other) const;
        bit_array_c operator|(const bit_array_c &other) const;
        bit_array_c operator~(void) const;

        bit_array_c operator<<(const unsigned int count) const;
        bit_array_c operator>>(const unsigned int count) const;

        /* increment/decrement */
        bit_array_c& operator++(void);          /* prefix */
        bit_array_c& operator++(int dummy);     /* postfix */
        bit_array_c& operator--(void);          /* prefix */
        bit_array_c& operator--(int dummy);     /* postfix */

        /* assignments */
        bit_array_c& operator=(const bit_array_c &src);

        bit_array_c& operator&=(const bit_array_c &src);
        bit_array_c& operator^=(const bit_array_c &src);
        bit_array_c& operator|=(const bit_array_c &src);
        bit_array_c& Not(void);                 /* negate (~=) */

        bit_array_c& operator<<=(unsigned const int shifts);
        bit_array_c& operator>>=(unsigned const int shifts);

    protected:
        unsigned int m_NumBits;                 /* number of bits in the array */
        unsigned char *m_Array;                 /* vector of characters */
};

#endif  /* ndef BIT_ARRAY_H */
