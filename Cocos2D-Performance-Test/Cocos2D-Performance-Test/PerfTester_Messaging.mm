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
#import <pthread.h>

@interface StubObject : NSObject
{
@private
    NSUInteger privateVariable;
	NSUInteger privateVariableAtomic;
@public
	NSUInteger publicVariable;
}
@property (nonatomic) NSUInteger privateVariable;
@property (atomic) NSUInteger privateVariableAtomic;
@end

@implementation StubObject
@synthesize privateVariable, privateVariableAtomic;
@end

@implementation PerfTester (Messaging)

-(void) testSetterWithMutexLock
{
	CGPoint p = CGPointMake(123, 456);
	pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
    BEGIN( k10MMIterationTestCount )
	pthread_mutex_lock(&mutex);
	CGFloat temp = p.x;
	p.x = p.y;
	p.y = temp;
	pthread_mutex_unlock(&mutex);
    END()
	pthread_mutex_destroy(&mutex);
}

-(void) testSetterWithDispatchSyncLock
{
	dispatch_queue_t queue = dispatch_queue_create("q", nil);

	__block CGPoint p = CGPointMake(123, 456);
	
    BEGIN( k10MMIterationTestCount )
	dispatch_sync(queue, ^{
		CGFloat temp = p.x;
		p.x = p.y;
		p.y = temp;
	});
    END()
	
	dispatch_release(queue);
}

-(void) testSendMessageToNilObject
{
	PerfTester* target = nil;
    BEGIN( k100MMIterationTestCount )
	[target setPointNotSynchronized:CGPointMake(100, 100)];
    END()
}

-(void) testSendMessageToNilObjectWithNilTest
{
	PerfTester* target = nil;
    BEGIN( k100MMIterationTestCount )
	if (target)
	{
		[target setPointNotSynchronized:CGPointMake(100, 100)];
	}
    END()
}

-(void) testSendMessageToNilObjectWithReturnValue
{
	PerfTester* target = nil;
    BEGIN( k100MMIterationTestCount )
	[target description];
    END()
}

-(void) testSendMessageToNilObjectWithReturnValueWithNilTest
{
	PerfTester* target = nil;
    BEGIN( k100MMIterationTestCount )
	if (target)
	{
		[target description];
	}
    END()
}

-(void) testRespondsToSelectorSucceeds
{
    BEGIN( k10MMIterationTestCount )
	[self respondsToSelector:@selector(setPointNotSynchronized:)];
    END()
}

-(void) testRespondsToSelectorFails
{
    BEGIN( k10MMIterationTestCount )
	[self respondsToSelector:@selector(setWindow:)];
    END()
}

-(void) testConformsToProctolSucceeds
{
    BEGIN( k1MMIterationTestCount )
	[self conformsToProtocol:@protocol(PointSynchronizedProtocol)];
    END()
}

-(void) testConformsToProtocolFails
{
    BEGIN( k1MMIterationTestCount )
	[self conformsToProtocol:@protocol(NotImplementedProtocol)];
    END()
}

-(void) testSetterWithoutRespondsToSelectorCheck
{
	CGPoint p = CGPointMake(123.45, 67.89);
    BEGIN( k100MMIterationTestCount )
	[self setPointNotSynchronized:p];
    END()
}

-(void) testSetterWithRespondsToSelectorCheck
{
	CGPoint p = CGPointMake(123.45, 67.89);
    BEGIN( k10MMIterationTestCount )
	if ([self respondsToSelector:@selector(setPointNotSynchronized:)])
	{
		[self setPointNotSynchronized:p];
	}
    END()
}

-(void) testSetterWithCachedSelectorRespondsToSelectorCheck
{
	CGPoint p = CGPointMake(123.45, 67.89);
	SEL selector = @selector(setPointNotSynchronized:);
	int32_t respondsTo = [self respondsToSelector:selector];
	
    BEGIN( k100MMIterationTestCount )
	if (respondsTo)
	{
		[self setPointNotSynchronized:p];
	}
    END()
}

-(void) testSetterNotSynchronized
{
	CGPoint p = CGPointMake(123.45, 67.89);
    BEGIN( k100MMIterationTestCount )
	[self setPointNotSynchronized:p];
    END()
}

-(void) testSetterSynchronized
{
	CGPoint p = CGPointMake(987.65, 4.321);
    BEGIN( k10MMIterationTestCount )
	[self setPointSynchronized:p];
    END()
}

-(void) testPrivateVariableReadWrite
{
	StubObject* stub = [[StubObject alloc] init];
	
	/*
	SEL aSelector = @selector(init);
	IMP imp1 = [self methodForSelector:aSelector];
	IMP imp2 = [stub methodForSelector:aSelector];
	*/
	
    BEGIN( k100MMIterationTestCount )
	NSUInteger var = [stub privateVariable] + 1;
	[stub setPrivateVariable:var];
    END()
	
	[stub release];
}

-(void) testPrivateVariableReadWriteProperty
{
	StubObject* stub = [[StubObject alloc] init];
	
    BEGIN( k100MMIterationTestCount )
	NSUInteger var = stub.privateVariable + 1;
	stub.privateVariable = var;
    END()
	
	[stub release];
}

-(void) testPrivateVariableReadWriteAtomic
{
	StubObject* stub = [[StubObject alloc] init];
	
    BEGIN( k100MMIterationTestCount )
	NSUInteger var = [stub privateVariableAtomic] + 1;
	[stub setPrivateVariableAtomic:var];
    END()
	
	[stub release];
}

-(void) testPrivateVariableReadWriteAtomicProperty
{
	StubObject* stub = [[StubObject alloc] init];
	
    BEGIN( k100MMIterationTestCount )
	NSUInteger var = stub.privateVariableAtomic + 1;
	stub.privateVariableAtomic = var;
    END()
	
	[stub release];
}

-(void) testPublicVariableReadWrite
{
	StubObject* stub = [[StubObject alloc] init];
	
    BEGIN( k100MMIterationTestCount )
	NSUInteger var = stub->publicVariable + 1;
	stub->publicVariable = var;
    END()
	
	[stub release];
}

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

/* (same as uncached)
static SEL kCachedSelector = @selector(_stubMethod);
- (void)testMessagingPerformSelectorCached
{
    BEGIN( k100MMIterationTestCount )
	[self performSelector:kCachedSelector];
    END()
}
*/

-(void) testMessagingArrayUsingBlock
{
	int numItems = 1000;
	NSMutableArray* arr = [[NSMutableArray alloc] initWithCapacity:numItems];
	for (int i = 0; i < numItems; i++)
	{
		[arr addObject:self];
	}
	
    BEGIN( k10MMIterationTestCount / numItems )
	[arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) 
	 {
		 [obj _stubMethod];
	 }];
    END()
	
	[arr release];
}

-(void) testMessagingArrayUsingBlockConcurrent
{
	int numItems = 1000;
	NSMutableArray* arr = [[NSMutableArray alloc] initWithCapacity:numItems];
	for (int i = 0; i < numItems; i++)
	{
		[arr addObject:self];
	}
	
    BEGIN( k10MMIterationTestCount / numItems )
	[arr enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) 
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
	
    BEGIN( k10MMIterationTestCount / numItems )
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
	
    BEGIN( k10MMIterationTestCount / numItems )
	[arr makeObjectsPerformSelector:@selector(_stubMethod)];
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
	
    BEGIN( k10MMIterationTestCount / numItems )
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
	
    BEGIN( k10MMIterationTestCount / numItems )
	[arr makeObjectsPerformSelector:@selector(_stubMethod)];
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
