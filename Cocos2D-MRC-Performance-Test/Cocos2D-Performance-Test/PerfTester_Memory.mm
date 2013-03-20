//
//  PerfTester
//
//  Copyright 2007-2008 Mike Ash
//					http://mikeash.com/pyblog/performance-comparisons-of-common-operations.html
//					http://mikeash.com/pyblog/performance-comparisons-of-common-operations-leopard-edition.html
//					http://mikeash.com/pyblog/performance-comparisons-of-common-operations-iphone-edition.html
//	Copyright 2010 Manomio / Stuart Carnie  (iOS port)
//					http://aussiebloke.blogspot.com/2010/01/micro-benchmarking-2nd-3rd-gen-iphones.html
//	Copyright 2011 Steffen Itterheim (Improvements, Cocos2D Tests)
//					http://www.learn-cocos2d.com/blog
//


#import "PerfTester.h"

@implementation PerfTester (Memory)

- (void)testSmallMallocFree
{
    BEGIN( k10MMIterationTestCount )
	free( malloc( 16 ) );
    END()
}

- (void)testLargeMallocFree
{
    BEGIN( k1MMIterationTestCount )
	free( malloc( 1 << 24 ) );
    END()
}

- (void)_testMemcpySize: (int)size count: (int)count
{
    void *src = malloc( size );
    void *dst = malloc( size );
    BEGIN( count )
	memcpy( dst, src, size );
    END()
    free( src );
    free( dst );
}

- (void)testSmallMemcpy
{
    [self _testMemcpySize: 16 count: k100MMIterationTestCount];
}

- (void)testLargeMemcpy
{
    [self _testMemcpySize: 1 << 20 count: k10KIterationTestCount];
}

@end
