// C++11 - use assertion macros, observe error reports.

#include "lest_basic.hpp"

using namespace std;

const lest::test specification[] =
{
    CASE( "Empty string has length zero (succeed)" )
    {
        EXPECT( 0 == string(  ).length() );
        EXPECT( 0 == string("").length() );
    },

    CASE( "Text compares lexically (fail)" )
    {
        EXPECT( string("hello") > string("world") );
    },

    CASE( "Unexpected exception is reported" )
    {
        EXPECT( (throw std::runtime_error("surprise!"), true) );
    },

    CASE( "Unspecified expected exception is captured" )
    {
        EXPECT_THROWS( throw std::runtime_error("surprise!") );
    },

    CASE( "Specified expected exception is captured" )
    {
        EXPECT_THROWS_AS( throw std::bad_alloc(), std::bad_alloc );
    },

    CASE( "Expected exception is reported missing" )
    {
        EXPECT_THROWS( true );
    },

    CASE( "Specific expected exception is reported missing" )
    {
        EXPECT_THROWS_AS( true, std::runtime_error );
    },
};

int main()
{
    return lest::run( specification );
}

// cl -nologo -Wall -EHsc -I.. 01-basic.cpp && 01-basic
// g++ -Wall -Wextra -std=c++11 -I.. -o 01-basic.exe 01-basic.cpp && 01-basic

// 01-basic.cpp:17: failed: Text compares lexically (fail): string("hello") > string("world")
// 01-basic.cpp:22: failed: got unexpected exception with message "surprise!": Unexpected exception is reported: (throw std::runtime_error("surprise!"), true)
// 01-basic.cpp:37: failed: didn't get exception: Expected exception is reported missing: true
// 01-basic.cpp:42: failed: didn't get exception of type std::runtime_error: Specific expected exception is reported missing: true
// 4 out of 7 tests failed.
