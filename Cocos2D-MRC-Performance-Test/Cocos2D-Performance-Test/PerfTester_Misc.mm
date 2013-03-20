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


#import <pthread.h>

#import "PerfTester.h"

@implementation PerfTester (Misc)

static void *stub_pthread( void * )
{
	return 0;
}

- (void)testSpawnThread
{
    BEGIN( k100KIterationTestCount )
        pthread_t pt;
        pthread_create( &pt, NULL, stub_pthread, NULL );
        pthread_join( pt, NULL );
    END()
}

- (void)_delayedPerform
{
    if( mIterations++ < k100KIterationTestCount )
        [self performSelector: @selector( _delayedPerform ) withObject: nil afterDelay: 0.0];
    else
        CFRunLoopStop( CFRunLoopGetCurrent() );
}

- (void)testDelayedPerform
{
    [self beginTest];
    [self performSelector: @selector( _delayedPerform ) withObject: nil afterDelay: 0.0];
    CFRunLoopRun();
    [self endTestWithIterations: k100KIterationTestCount];
}

/*
-(void) testObjectIsMemberOfClass
{
	NSObject* obj = [[[NSObject alloc] init] autorelease];
	
    BEGIN( k100KIterationTestCount )
	[obj isMemberOfClass:[NSObject class]];
    END()
}

-(void) testObjectIsMemberOfClassOptimized
{
	NSObject* obj = [[[NSObject alloc] init] autorelease];
	Class objectClass = [NSObject class];
	
    BEGIN( k100KIterationTestCount )
	[obj isMemberOfClass:objectClass];
    END()
}

-(void) testObjectIsKindOfClass
{
	NSObject* obj = [[[NSObject alloc] init] autorelease];
	
    BEGIN( k100KIterationTestCount )
	[obj isKindOfClass:[NSObject class]];
    END()
}

-(void) testObjectIsKindOfClassOptimized
{
	NSObject* obj = [[[NSObject alloc] init] autorelease];
	Class objectClass = [NSObject class];
	
    BEGIN( k100KIterationTestCount )
	[obj isKindOfClass:objectClass];
    END()
}



-(void) testObjectIsMemberOfClassFail
{
	NSObject* obj = [[[NSObject alloc] init] autorelease];
	
    BEGIN( k100KIterationTestCount )
	[obj isMemberOfClass:[UIResponder class]];
    END()
}

-(void) testObjectIsMemberOfClassOptimizedFail
{
	NSObject* obj = [[[NSObject alloc] init] autorelease];
	Class objectClass = [UIResponder class];
	
    BEGIN( k100KIterationTestCount )
	[obj isMemberOfClass:objectClass];
    END()
}

-(void) testObjectIsKindOfClassFail
{
	NSObject* obj = [[[NSObject alloc] init] autorelease];
	
    BEGIN( k100KIterationTestCount )
	[obj isKindOfClass:[UIResponder class]];
    END()
}

-(void) testObjectIsKindOfClassOptimizedFail
{
	NSObject* obj = [[[NSObject alloc] init] autorelease];
	Class objectClass = [UIResponder class];
	
    BEGIN( k100KIterationTestCount )
	[obj isKindOfClass:objectClass];
    END()
}

-(void) testStringCompareIsEqual
{
	NSString* string = @"SomeClass";
	
    BEGIN( k100KIterationTestCount )
	[string isEqual:@"SomeClass"];
    END()
}

-(void) testStringCompareIsEqualFail
{
	NSString* string = @"MyClass";
	
    BEGIN( k100KIterationTestCount )
	[string isEqual:@"SomeClass"];
    END()
}

-(void) testStringCompareIsEqualToString
{
	NSString* string = @"SomeClass";
	
    BEGIN( k100KIterationTestCount )
	[string isEqualToString:@"SomeClass"];
    END()
}

-(void) testStringCompareIsEqualToStringFail
{
	NSString* string = @"MyClass";
	
    BEGIN( k100KIterationTestCount )
	[string isEqualToString:@"SomeClass"];
    END()
}
*/

@end
