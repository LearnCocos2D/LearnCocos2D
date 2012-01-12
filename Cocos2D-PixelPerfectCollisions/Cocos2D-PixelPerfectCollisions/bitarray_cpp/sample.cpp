/***************************************************************************
*                       Bit Array Class Usage Sample
*
*   File    : sample.cpp
*   Purpose : Demonstrates usage of bit array class.
*   Author  : Michael Dipperstein
*   Date    : July 23, 2004
*
****************************************************************************
*   HISTORY
*
*   $Id: sample.cpp,v 1.6 2010/02/04 03:31:43 michael Exp $
*   $Log: sample.cpp,v $
*   Revision 1.6  2010/02/04 03:31:43  michael
*   Replaced vector<unsigned char> with an array of unsigned char.
*
*   Made updates for GCC 4.4.
*
*   Revision 1.4  2007/08/06 05:21:00  michael
*   Updated for LGPL Version 3.
*   Verifies new >> and << functions.
*   Corrects printed comment for setting bits by array index.
*
*   Revision 1.2  2004/08/05 22:17:31  michael
*   Test new methods.
*
*   Revision 1.1.1.1  2004/08/04 13:28:20  michael
*   bit_array_c
*
****************************************************************************
*
* Sample: A bit array class sample usage program
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

#include <iostream>
#include <cstdlib>
#include <climits>
#include "bitarray.h"

using namespace std;

/***************************************************************************
*                                 MACROS
***************************************************************************/
#define NUM_BITS 128        /* size of bit array */

/***************************************************************************
*                                FUNCTIONS
***************************************************************************/

/***************************************************************************
*   Function   : ShowArray
*   Description: This is a wrapper for bit_array_t::Dump that shows the
*                array name as well as its contents.
*   Parameters : name - name of array
*                ba - pointer to bit array
*   Effects    : Writes array to stdout.
*   Returned   : None
***************************************************************************/
void ShowArray(const char *name, bit_array_c *ba)
{
    cout << name << ": ";
    ba->Dump(cout);
    cout << endl;
}

/***************************************************************************
*   Function   : main
*   Description: This function demonstrates the usage of each of the bit
*                array method.
*   Parameters : argc - the number command line arguements (not used)
*   Parameters : argv - array of command line arguements (not used)
*   Effects    : Writes results of bit operations to stdout.
*   Returned   : EXIT_SUCCESS
***************************************************************************/
int main(int argc, char *argv[])
{
    bit_array_c ba1(NUM_BITS), ba2(NUM_BITS);
    int i;

    cout << "ba1 has " << ba1.Size() << " bits" << endl;
    cout << "ba2 has " << ba2.Size() << " bits" << endl << endl;

    cout << "set all bits in ba1" << endl;
    ba1.SetAll();
    ShowArray("ba1", &ba1);

    cout << endl << "clear all bits in ba1" << endl;
    ba1.ClearAll();
    ShowArray("ba1", &ba1);

    cout << endl << "set 8 bits on each end of ba1 from the outside in" << endl;
    for (i = 0; i < 8; i++)
    {
        ba1.SetBit(i);
        ba1.SetBit(NUM_BITS - i - 1);
        ShowArray("ba1", &ba1);
    }

    cout << endl << "ba2 = ba1" << endl;
    ba2 = ba1;
    ShowArray("ba2", &ba2);

    cout << endl << "ba2 = ~(ba2)" << endl;
    ba2.Not();
    ShowArray("ba2", &ba2);

    cout << endl << "ba2 |= ba1" << endl;
    ba2 |= ba1;
    ShowArray("ba2", &ba2);

    cout << endl << "ba2 ^= ba1" << endl;
    ba2 ^= ba1;
    ShowArray("ba2", &ba2);

    cout << endl << "ba2 &= ba1" << endl;
    ba2 &= ba1;
    ShowArray("ba2", &ba2);

    cout << endl << "testing some bits in ba1" << endl;
    for (; i > 6; i--)
    {
        if(ba1[i])
        {
            cout << "ba1 bit " << i << " is set." << endl;
        }
        else
        {
            cout << "ba1 bit " << i << " is clear." << endl;
        }

        if(ba1[NUM_BITS - i - 1])
        {
            cout << "ba1 bit " << NUM_BITS - i - 1 << " is set." << endl;
        }
        else
        {
            cout << "ba1 bit " << NUM_BITS - i - 1 << " is clear." << endl;
        }
    }

    cout << endl << "clear 8 bits on each end of ba1 from the outside in" << endl;
    for (i = 0; i < 8; i++)
    {
        ba1.ClearBit(i);
        ba1.ClearBit(NUM_BITS - i - 1);
        ShowArray("ba1", &ba1);
    }

    cout << endl << "set all bits in ba1 and shift right by 20" << endl;
    ba1.SetAll();
    ba1 >>= 20;
    ShowArray("ba1", &ba1);

    cout << endl << "shift ba1 left by 20" << endl;
    ba1 <<= 20;
    ShowArray("ba1", &ba1);

    cout << endl << "set all bits in ba1 and increment" << endl;
    ba1.SetAll();
    ++ba1;
    ShowArray("ba1", &ba1);

    cout << endl << "increment ba1" << endl;
    ba1++;
    ShowArray("ba1", &ba1);

    cout << endl << "increment ba1" << endl;
    ++ba1;
    ShowArray("ba1", &ba1);

    cout << endl << "decrement ba1" << endl;
    --ba1;
    ShowArray("ba1", &ba1);

    cout << endl << "decrement ba1" << endl;
    ba1--;
    ShowArray("ba1", &ba1);

    cout << endl << "decrement ba1" << endl;
    --ba1;
    ShowArray("ba1", &ba1);

    /* == */
    cout << endl << "check ba1 == ba1" << endl;
    if (ba1 == ba1)
    {
        cout << "ba1 == ba1" << endl;
    }
    else
    {
        cout << "ba1 != ba1" << endl;
    }

    cout << endl << "check ba1 == ba2" << endl;
    if (ba1 == ba2)
    {
        cout << "ba1 == ba2" << endl;
    }
    else
    {
        cout << "ba1 != ba2" << endl;
    }

    /* != */
    cout << endl << "check ba1 != ba1" << endl;
    if (ba1 != ba1)
    {
        cout << "ba1 != ba1" << endl;
    }
    else
    {
        cout << "ba1 == ba1" << endl;
    }

    cout << endl << "check ba1 != ba2" << endl;
    if (ba1 != ba2)
    {
        cout << "ba1 != ba2" << endl;
    }
    else
    {
        cout << "Comparison error." << endl;
    }

    /* < */
    cout << endl << "check ba1 < ba1" << endl;
    if (ba1 < ba1)
    {
        cout << "ba1 < ba1" << endl;
    }
    else
    {
        cout << "ba1 >= ba1" << endl;
    }

    cout << endl << "check ba1 < ba2" << endl;
    if (ba1 < ba2)
    {
        cout << "ba1 < ba2" << endl;
    }
    else
    {
        cout << "ba1 >= ba2" << endl;
    }

    cout << endl << "check ba2 < ba1" << endl;
    if (ba2 < ba1)
    {
        cout << "ba2 < ba1" << endl;
    }
    else
    {
        cout << "ba2 >= ba1" << endl;
    }

    /* <= */
    cout << endl << "check ba1 <= ba1" << endl;
    if (ba1 <= ba1)
    {
        cout << "ba1 <= ba1" << endl;
    }
    else
    {
        cout << "ba1 > ba1" << endl;
    }

    cout << endl << "check ba1 <= ba2" << endl;
    if (ba1 <= ba2)
    {
        cout << "ba1 <= ba2" << endl;
    }
    else
    {
        cout << "ba1 > ba2" << endl;
    }

    cout << endl << "check ba2 <= ba1" << endl;
    if (ba2 < ba1)
    {
        cout << "ba2 <= ba1" << endl;
    }
    else
    {
        cout << "ba2 > ba1" << endl;
    }

    /* > */
    cout << endl << "check ba1 > ba1" << endl;
    if (ba1 > ba1)
    {
        cout << "ba1 > ba1" << endl;
    }
    else
    {
        cout << "ba1 <= ba1" << endl;
    }

    cout << endl << "check ba1 > ba2" << endl;
    if (ba1 > ba2)
    {
        cout << "ba1 > ba2" << endl;
    }
    else
    {
        cout << "ba1 <= ba2" << endl;
    }

    cout << endl << "check ba2 > ba1" << endl;
    if (ba2 > ba1)
    {
        cout << "ba2 > ba1" << endl;
    }
    else
    {
        cout << "ba2 <= ba1" << endl;
    }

    /* >= */
    cout << endl << "check ba1 >= ba1" << endl;
    if (ba1 >= ba1)
    {
        cout << "ba1 >= ba1" << endl;
    }
    else
    {
        cout << "ba1 < ba1" << endl;
    }

    cout << endl << "check ba1 >= ba2" << endl;
    if (ba1 >= ba2)
    {
        cout << "ba1 >= ba2" << endl;
    }
    else
    {
        cout << "ba1 < ba2" << endl;
    }

    cout << endl << "check ba2 >= ba1" << endl;
    if (ba2 >= ba1)
    {
        cout << "ba2 >= ba1" << endl;
    }
    else
    {
        cout << "ba2 < ba1" << endl;
    }

    /* test construction from existing: create an array, fill it with values */
    unsigned char* vect;
    vect = new unsigned char[(NUM_BITS / CHAR_BIT)];

    vect[0] = 0x00;
    for (i = 1; i < NUM_BITS / CHAR_BIT; i++)
    {
        vect[i] = vect[i -1] + 0x11;
    }

    cout << endl << "construct a bit array from existing array" << endl;
    bit_array_c ba3(vect, NUM_BITS);
    ShowArray("ba3", &ba3);

    cout << endl << "ba3 = ~(ba3)" << endl;
    ba3 = ~ba3;
    ShowArray("ba3", &ba3);

    ba1.SetAll();
    for (i = 0; i < NUM_BITS; i += 2)
    {
        ba2.SetBit(i);

        if (i < NUM_BITS - 1)
        {
            ba2.ClearBit(i + 1);
        }
    }

    cout << endl;
    ShowArray("ba1", &ba1);
    ShowArray("ba2", &ba2);

    cout << endl << "ba3 = ba1 | ba2" << endl;
    ba3 = ba1 | ba2;
    ShowArray("ba3", &ba3);

    cout << endl << "ba3 = ba1 ^ ba2" << endl;
    ba3 = ba1 ^ ba2;
    ShowArray("ba3", &ba3);

    cout << endl << "ba3 = ba1 & ba2" << endl;
    ba3 = ba1 & ba2;
    ShowArray("ba3", &ba3);

    cout << endl << "ba3 = ba2 >> 1" << endl;
    ba3 = ba2 >> 1;
    ShowArray("ba3", &ba3);

    cout << endl << "ba3 = ba1 << 1" << endl;
    ba3 = ba1 << 1;
    ShowArray("ba3", &ba3);

    cout << endl << "ba3(0) .. ba3(7) = false" << endl;
    for(i = 0; i < 8; i++)
    {
        ba3(i) = false;
        ShowArray("ba3", &ba3);
    }

    return(EXIT_SUCCESS);
}
