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

@implementation PerfTester (ObjectCompare)

-(void) testObjectIsMemberOfClass
{
	NSObject* obj = [[NSObject alloc] init];
	
    BEGIN( k10MMIterationTestCount )
	[obj isMemberOfClass:[NSObject class]];
    END()
	
	[obj release];
}

-(void) testObjectIsMemberOfClassOptimized
{
	NSObject* obj = [[NSObject alloc] init];
	Class objectClass = [NSObject class];
	
    BEGIN( k10MMIterationTestCount )
	[obj isMemberOfClass:objectClass];
    END()

	[obj release];
}

-(void) testObjectIsKindOfClass
{
	NSObject* obj = [[NSObject alloc] init];
	
    BEGIN( k10MMIterationTestCount )
	[obj isKindOfClass:[NSObject class]];
    END()

	[obj release];
}

-(void) testObjectIsKindOfClassOptimized
{
	NSObject* obj = [[NSObject alloc] init];
	Class objectClass = [NSObject class];
	
    BEGIN( k10MMIterationTestCount )
	[obj isKindOfClass:objectClass];
    END()

	[obj release];
}



-(void) testObjectIsMemberOfClassFail
{
	NSObject* obj = [[NSObject alloc] init];
	
    BEGIN( k10MMIterationTestCount )
	[obj isMemberOfClass:[UIResponder class]];
    END()

	[obj release];
}

-(void) testObjectIsMemberOfClassOptimizedFail
{
	NSObject* obj = [[NSObject alloc] init];
	Class objectClass = [UIResponder class];
	
    BEGIN( k10MMIterationTestCount )
	[obj isMemberOfClass:objectClass];
    END()

	[obj release];
}

-(void) testObjectIsKindOfClassFail
{
	NSObject* obj = [[NSObject alloc] init];
	
    BEGIN( k10MMIterationTestCount )
	[obj isKindOfClass:[UIResponder class]];
    END()

	[obj release];
}

-(void) testObjectIsKindOfClassOptimizedFail
{
	NSObject* obj = [[NSObject alloc] init];
	Class objectClass = [UIResponder class];
	
    BEGIN( k10MMIterationTestCount )
	[obj isKindOfClass:objectClass];
    END()

	[obj release];
}


-(void) testPointerIsEqual
{
	NSObject* obj = [[NSObject alloc] init];
	NSObject* obj2 = obj;
	
    BEGIN( k100MMIterationTestCount )
	[obj isEqual:obj2];
    END()

	[obj release];
}
-(void) testPointerIsEqualFail
{
	NSObject* obj = [[NSObject alloc] init];
	NSObject* obj2 = [[NSObject alloc] init];
	
    BEGIN( k100MMIterationTestCount )
	[obj isEqual:obj2];
    END()

	[obj release];
	[obj2 release];
}


-(void) testStringCompareIsEqual
{
	NSString* string = @"SomeClass";
	
    BEGIN( k100MMIterationTestCount )
	[string isEqual:@"SomeClass"];
    END()
}

-(void) testStringCompareIsEqualFail
{
	NSString* string = @"MyClass";
	
    BEGIN( k10MMIterationTestCount )
	[string isEqual:@"SomeClass"];
    END()
}

-(void) testStringCompareIsEqualToString
{
	NSString* string = @"SomeClass";
	
    BEGIN( k100MMIterationTestCount )
	[string isEqualToString:@"SomeClass"];
    END()
}

-(void) testStringCompareIsEqualToStringFail
{
	NSString* string = @"MyClass";
	
    BEGIN( k10MMIterationTestCount )
	[string isEqualToString:@"SomeClass"];
    END()
}



-(void) testObjectHash
{
	NSObject* obj = [[NSObject alloc] init];
	
    BEGIN( k100MMIterationTestCount )
	[obj hash];
    END()

	[obj release];
}
-(void) testStringHash
{
	NSString* string = @"SomeClass";
	
    BEGIN( k100MMIterationTestCount )
	[string hash];
    END()
}

@end
