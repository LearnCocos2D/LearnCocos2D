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

@implementation PerfTester (Messaging)

- (void)testNothing
{
    BEGIN( mIterations )
	;
    END()
}

class StubClass
{
public:
	virtual void stub() { }
};

- (void)testCPPVirtualCall
{
    class StubClass *obj = new StubClass;
    BEGIN( k100MMIterationTestCount )
	obj->stub();
    END()
}

- (void)testCPPCachedVirtualCall {
    class StubClass *obj = new StubClass;
	void (StubClass::*fn)() = &StubClass::stub;
    BEGIN( k100MMIterationTestCount )
	(obj->*fn)();
    END()
	
}

- (void)_stubMethod
{
}

- (void)testMessaging
{
    BEGIN( k100MMIterationTestCount )
	[self _stubMethod];
    END()
}

- (void)testMessagingPerformSelector
{
    BEGIN( k100MMIterationTestCount )
	[self performSelector:@selector(_stubMethod)];
    END()
}

static SEL kCachedSelector = @selector(_stubMethod);
- (void)testMessagingPerformSelectorCached
{
    BEGIN( k100MMIterationTestCount )
	[self performSelector:kCachedSelector];
    END()
}

-(void) testMessagingArrayUsingBlock
{
	int numItems = 1000;
	NSMutableArray* arr = [[NSMutableArray alloc] initWithCapacity:numItems];
	for (int i = 0; i < numItems; i++)
	{
		[arr addObject:self];
	}
	
    BEGIN( k100MMIterationTestCount / numItems )
	[arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) 
	 {
		 [obj _stubMethod];
	 }];
    END()
	
	[arr release];
}


-(void) testMessagingArray
{
	int numItems = 1000;
	NSMutableArray* arr = [[NSMutableArray alloc] initWithCapacity:numItems];
	for (int i = 0; i < numItems; i++)
	{
		[arr addObject:self];
	}
	
    BEGIN( k100MMIterationTestCount / numItems )
	for (id item in arr)
	{
		[item _stubMethod];
	}
    END()
	
	[arr release];
}

-(void) testMessagingArrayMakeObjectsPerformSelector
{
	int numItems = 1000;
	NSMutableArray* arr = [[NSMutableArray alloc] initWithCapacity:numItems];
	for (int i = 0; i < numItems; i++)
	{
		[arr addObject:self];
	}
	
    BEGIN( k100MMIterationTestCount / numItems )
	[arr makeObjectsPerformSelector:kCachedSelector];
    END()
	
	[arr release];
}

-(void) testMessagingCCArray
{
	int numItems = 1000;
	CCArray* arr = [[CCArray alloc] initWithCapacity:numItems];
	for (int i = 0; i < numItems; i++)
	{
		[arr addObject:self];
	}
	
    BEGIN( k100MMIterationTestCount / numItems )
	for (id item in arr)
	{
		[item _stubMethod];
	}
    END()
	
	[arr release];
}

-(void) testMessagingCCArrayMakeObjectsPerformSelector
{
	int numItems = 1000;
	CCArray* arr = [[CCArray alloc] initWithCapacity:numItems];
	for (int i = 0; i < numItems; i++)
	{
		[arr addObject:self];
	}
	
    BEGIN( k100MMIterationTestCount / numItems )
	[arr makeObjectsPerformSelector:kCachedSelector];
    END()
	
	[arr release];
}

- (void)testIMPCachedMessaging
{
    void (*imp)(id, SEL) = (void (*)(id, SEL))[self methodForSelector: @selector( _stubMethod )];
    BEGIN( k100MMIterationTestCount )
	imp( self, @selector( _stubMethod ) );
    END()
}

- (void)testNSInvocation
{
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature: [self methodSignatureForSelector: @selector( _stubMethod )]];
    [invocation setSelector: @selector( _stubMethod )];
    [invocation setTarget: self];
    
    BEGIN( k10MMIterationTestCount )
	[invocation invoke];
    END()
}

@end
