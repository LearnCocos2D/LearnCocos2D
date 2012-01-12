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

@implementation PerfTester (Misc)


// don't use > 100 K iterations for add/insert tests because NSMutableArray changes runtime behavior
// if its size is very large, and thus gets a bit slower adding/inserting new objects
// hardly any cocos2d user will store > 10k objects in an array

- (void)testCCArrayAddObject {
	id obj = [[[NSObject alloc] init] autorelease];
	CCArray* test = [CCArray array];
	BEGIN ( k10MMIterationTestCount )
	[test addObject:obj];
	END()
	
	[test removeAllObjects];
}

- (void)testNSMutableArrayAddObject {
	id obj = [[[NSObject alloc] init] autorelease];
	NSMutableArray* test = [NSMutableArray array];
	BEGIN ( k10MMIterationTestCount )
	[test addObject:obj];
	END()
	
	[test removeAllObjects];
}

- (void)testCCArrayWithCapacityAddObject {
	id obj = [[[NSObject alloc] init] autorelease];
	int testCount = k10MMIterationTestCount;
	CCArray* test = [CCArray arrayWithCapacity:testCount];
	BEGIN ( testCount )
	[test addObject:obj];
	END()
	
	[test removeAllObjects];
}

- (void)testNSMutableArrayWithCapacityAddObject {
	id obj = [[[NSObject alloc] init] autorelease];
	int testCount = k10MMIterationTestCount;
	NSMutableArray* test = [NSMutableArray arrayWithCapacity:testCount];
	BEGIN ( testCount )
	[test addObject:obj];
	END()
	
	[test removeAllObjects];
}


// insert at index 0 is the weak spot of CCArray, it's been improved but still several factors slower than NSMutableArray for insert
- (void)testCCArrayWithCapacityInsertObjectAtIndex0 {
	id obj = [[[NSObject alloc] init] autorelease];
	int testCount = k10KIterationTestCount;
	CCArray* test = [CCArray arrayWithCapacity:testCount];
	BEGIN ( testCount )
	[test insertObject:obj atIndex:0];
	END()
	
	[test removeAllObjects];
}

- (void)testNSMutableArrayWithCapacityInsertObjectAtIndex0 {
	id obj = [[[NSObject alloc] init] autorelease];
	int testCount = k10KIterationTestCount;
	NSMutableArray* test = [NSMutableArray arrayWithCapacity:testCount];
	BEGIN ( testCount )
	[test insertObject:obj atIndex:0];
	END()
	
	[test removeAllObjects];
}

- (void)testCCArrayWithCapacityInsertObjectAtIndexHalfCount {
	id obj = [[[NSObject alloc] init] autorelease];
	int testCount = k10KIterationTestCount;
	int index = 0;
	srandom(1234567890);
	CCArray* test = [CCArray arrayWithCapacity:testCount];
	BEGIN ( testCount )
	[test insertObject:obj atIndex:index];
	index = [test count] * CCRANDOM_0_1();
	END()
	
	[test removeAllObjects];
}

- (void)testNSMutableArrayWithCapacityInsertObjectAtIndexHalfCount {
	id obj = [[[NSObject alloc] init] autorelease];
	int testCount = k10KIterationTestCount;
	int index = 0;
	srandom(1234567890);
	NSMutableArray* test = [NSMutableArray arrayWithCapacity:testCount];
	BEGIN ( testCount )
	[test insertObject:obj atIndex:index];
	index = [test count] * CCRANDOM_0_1();
	END()
	
	[test removeAllObjects];
}


- (void)testCCArrayObjectAtIndex {
	NSArray* arr = [NSArray arrayWithObjects:@"one", @"two", @"three", @"one", @"two", @"three", @"one", @"two", @"three", @"one", @"two", @"three", nil];
	CCArray* test = [CCArray arrayWithNSArray:arr];
	BEGIN ( k100MMIterationTestCount )
	id obj = [test objectAtIndex:8];
	END()
}

- (void)testObjCObjectAtIndex {
	NSMutableArray* test = [NSMutableArray arrayWithObjects:@"one", @"two", @"three", @"one", @"two", @"three", @"one", @"two", @"three", @"one", @"two", @"three", nil];
	BEGIN ( k100MMIterationTestCount )
	id obj = [test objectAtIndex:8];
	END()
}

- (void)testCFObjectAtIndex {
	NSArray* test = [NSArray arrayWithObjects:@"one", @"two", @"three", @"one", @"two", @"three", @"one", @"two", @"three", @"one", @"two", @"three", nil];
	BEGIN ( k100MMIterationTestCount )
	id obj = (id)CFArrayGetValueAtIndex((CFArrayRef)test, 8);
	END()
}


- (void)testCCArrayEnumeration {
	id obj = [[[NSObject alloc] init] autorelease];
	NSMutableArray* test = [NSMutableArray array];
	for (int i = 0; i < 1000; i++) 
	{
		[test addObject:obj];
	}
	
	CCArray* array = [CCArray arrayWithNSArray:test];
	int count = [array count];
	
	BEGIN ( k100KIterationTestCount )
	for (int i = 0; i < count; i++) 
	{
		obj = [array objectAtIndex:i];
	}
	END()
}

- (void)testCCArrayFastEnumeration {
	id obj = [[[NSObject alloc] init] autorelease];
	NSMutableArray* test = [NSMutableArray array];
	for (int i = 0; i < 1000; i++) 
	{
		[test addObject:obj];
	}

	CCArray* array = [CCArray arrayWithNSArray:test];
	
	BEGIN ( k100KIterationTestCount )
	CCARRAY_FOREACH(array, obj)
	{
	}
	END()
}

- (void)testNSMutableArrayEnumeration {
	id obj = [[[NSObject alloc] init] autorelease];
	NSMutableArray* array = [NSMutableArray array];
	for (int i = 0; i < 1000; i++) 
	{
		[array addObject:obj];
	}
	
	int count = [array count];
	
	BEGIN ( k100KIterationTestCount )
	for (int i = 0; i < count; i++) 
	{
		obj = [array objectAtIndex:i];
	}
	END()
}

- (void)testNSMutableArrayFastEnumeration {
	id obj = [[[NSObject alloc] init] autorelease];
	NSMutableArray* array = [NSMutableArray array];
	for (int i = 0; i < 1000; i++) 
	{
		[array addObject:obj];
	}
	
	BEGIN ( k100KIterationTestCount )
	for (id obj in array)
	{
	}
	END()
}


- (void)testCCArrayRemoveObjectAtIndexAndAdd {
	id obj = [[[NSObject alloc] init] autorelease];
	NSMutableArray* test = [NSMutableArray array];
	for (int i = 0; i < 1000; i++)
	{
		[test addObject:obj];
	}
	
	CCArray* array = [CCArray arrayWithNSArray:test];
	int index = [array count] / 2;
	
	BEGIN ( k1MMIterationTestCount )
	[array removeObjectAtIndex:index];
	[array addObject:obj];
	END()
}

- (void)testNSMutableArrayRemoveObjectAtIndexAndAdd {
	id obj = [[[NSObject alloc] init] autorelease];
	NSMutableArray* array = [NSMutableArray array];
	for (int i = 0; i < 1000; i++)
	{
		[array addObject:obj];
	}
	
	int index = [array count] / 2;
	
	BEGIN ( k1MMIterationTestCount )
	[array removeObjectAtIndex:index];
	[array addObject:obj];
	END()
}


- (void)testCCArrayRemoveLastObjectAndAdd {
	id obj = [[[NSObject alloc] init] autorelease];
	NSMutableArray* test = [NSMutableArray array];
	for (int i = 0; i < 1000; i++)
	{
		[test addObject:obj];
	}
	
	CCArray* array = [CCArray arrayWithNSArray:test];
	
	BEGIN ( k1MMIterationTestCount )
	[array removeLastObject];
	[array addObject:obj];
	END()
}

- (void)testNSMutableArrayRemoveLastObjectAndAdd {
	id obj = [[[NSObject alloc] init] autorelease];
	NSMutableArray* array = [NSMutableArray array];
	for (int i = 0; i < 1000; i++)
	{
		[array addObject:obj];
	}
	
	BEGIN ( k1MMIterationTestCount )
	[array removeLastObject];
	[array addObject:obj];
	END()
}


- (void)testCCArrayRemoveAndAddObjectsFromArray {
	id obj = [[[NSObject alloc] init] autorelease];
	NSMutableArray* test = [NSMutableArray array];
	for (int i = 0; i < 1000; i++)
	{
		[test addObject:obj];
	}

	NSMutableArray* test2 = [NSMutableArray array];
	for (int i = 0; i < 100; i++)
	{
		[test2 addObject:[[[NSObject alloc] init] autorelease]];
	}

	CCArray* array = [CCArray arrayWithNSArray:test];
	CCArray* removeArray = [CCArray arrayWithNSArray:test2];
	
	BEGIN ( k10KIterationTestCount )
	[array addObjectsFromArray:removeArray];
	[array removeObjectsInArray:removeArray];
	END()
}

- (void)testNSMutableArrayRemoveAndAddObjectsFromArray {
	id obj = [[[NSObject alloc] init] autorelease];
	NSMutableArray* array = [NSMutableArray array];
	for (int i = 0; i < 1000; i++)
	{
		[array addObject:obj];
	}

	NSMutableArray* removeArray = [NSMutableArray array];
	for (int i = 0; i < 100; i++)
	{
		[removeArray addObject:[[[NSObject alloc] init] autorelease]];
	}

	BEGIN ( k10KIterationTestCount )
	[array addObjectsFromArray:removeArray];
	[array removeObjectsInArray:removeArray];
	END()
}



- (void)testCCArrayMakeObjectsPerformSelector {
	id obj = [[[NSObject alloc] init] autorelease];
	NSMutableArray* test = [NSMutableArray array];
	for (int i = 0; i < 1000; i++)
	{
		[test addObject:obj];
	}
	
	CCArray* array = [CCArray arrayWithNSArray:test];
	
	BEGIN ( k10KIterationTestCount )
	[array makeObjectsPerformSelector:@selector(isProxy)];
	END()
}

- (void)testNSMutableArrayMakeObjectsPerformSelector {
	id obj = [[[NSObject alloc] init] autorelease];
	NSMutableArray* array = [NSMutableArray array];
	for (int i = 0; i < 1000; i++)
	{
		[array addObject:obj];
	}
	
	BEGIN ( k10KIterationTestCount )
	[array makeObjectsPerformSelector:@selector(isProxy)];
	END()
}

- (void)testCCArrayMakeObjectsPerformSelectorWithObject {
	id obj = [[[NSObject alloc] init] autorelease];
	NSMutableArray* test = [NSMutableArray array];
	for (int i = 0; i < 1000; i++)
	{
		[test addObject:obj];
	}
	
	CCArray* array = [CCArray arrayWithNSArray:test];
	
	BEGIN ( k10KIterationTestCount )
	[array makeObjectsPerformSelector:@selector(isEqual:) withObject:obj];
	END()
}

- (void)testNSMutableArrayMakeObjectsPerformSelectorWithObject {
	id obj = [[[NSObject alloc] init] autorelease];
	NSMutableArray* array = [NSMutableArray array];
	for (int i = 0; i < 1000; i++)
	{
		[array addObject:obj];
	}
	
	BEGIN ( k10KIterationTestCount )
	[array makeObjectsPerformSelector:@selector(isEqual:) withObject:obj];
	END()
}



- (void)testCCArrayIndexOfObject {
	id obj = [[[NSObject alloc] init] autorelease];
	id specialObj = [[[NSObject alloc] init] autorelease];
	NSMutableArray* test = [NSMutableArray array];
	for (int i = 0; i < 1000; i++)
	{
		if (i == 666) {
			[test addObject:specialObj];
		} else {
			[test addObject:obj];
		}
	}
	
	CCArray* array = [CCArray arrayWithNSArray:test];
	
	BEGIN ( k100KIterationTestCount )
	[array indexOfObject:specialObj];
	END()
}

- (void)testNSMutableArrayIndexOfObject {
	id obj = [[[NSObject alloc] init] autorelease];
	id specialObj = [[[NSObject alloc] init] autorelease];
	NSMutableArray* array = [NSMutableArray array];
	for (int i = 0; i < 1000; i++)
	{
		if (i == 666) {
			[array addObject:specialObj];
		} else {
			[array addObject:obj];
		}
	}
	
	BEGIN ( k100KIterationTestCount )
	[array indexOfObject:specialObj];
	END()
}


- (void)testCCArrayContainsObject {
	id obj = [[[NSObject alloc] init] autorelease];
	id specialObj = [[[NSObject alloc] init] autorelease];
	NSMutableArray* test = [NSMutableArray array];
	for (int i = 0; i < 1000; i++)
	{
		if (i == 666) {
			[test addObject:specialObj];
		} else {
			[test addObject:obj];
		}
	}
	
	CCArray* array = [CCArray arrayWithNSArray:test];
	
	BEGIN ( k100KIterationTestCount )
	[array containsObject:specialObj];
	END()
}

- (void)testNSMutableArrayContainsObject {
	id obj = [[[NSObject alloc] init] autorelease];
	id specialObj = [[[NSObject alloc] init] autorelease];
	NSMutableArray* array = [NSMutableArray array];
	for (int i = 0; i < 1000; i++)
	{
		if (i == 666) {
			[array addObject:specialObj];
		} else {
			[array addObject:obj];
		}
	}
	
	BEGIN ( k100KIterationTestCount )
	[array containsObject:specialObj];
	END()
}



- (void)testCCArrayExchangeObjectAtIndex {
	id obj = [[[NSObject alloc] init] autorelease];
	NSMutableArray* test = [NSMutableArray array];
	for (int i = 0; i < 1000; i++)
	{
		[test addObject:obj];
	}
	
	CCArray* array = [CCArray arrayWithNSArray:test];
	
	BEGIN ( k10MMIterationTestCount )
	[array exchangeObjectAtIndex:333 withObjectAtIndex:666];
	[array exchangeObjectAtIndex:678 withObjectAtIndex:321];
	END()
}

- (void)testNSMutableArrayExchangeObjectAtIndex {
	id obj = [[[NSObject alloc] init] autorelease];
	NSMutableArray* array = [NSMutableArray array];
	for (int i = 0; i < 1000; i++)
	{
		[array addObject:obj];
	}
	
	BEGIN ( k10MMIterationTestCount )
	[array exchangeObjectAtIndex:333 withObjectAtIndex:666];
	[array exchangeObjectAtIndex:678 withObjectAtIndex:321];
	END()
}


@end
