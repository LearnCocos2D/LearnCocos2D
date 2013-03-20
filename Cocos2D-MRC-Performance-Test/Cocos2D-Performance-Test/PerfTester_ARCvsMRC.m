//
//  PerfTester_ARCvsMRC.m
//  Cocos2D-ARC-Performance-Test
//
//  Created by Steffen Itterheim on 20.03.13.
//
//

#import "PerfTester.h"
#import "MRCTests.h"


@implementation PerfTester (ARCvsMRC)

#pragma mark Messaging

-(void) testMessageSendObject
{
	BEGIN ( k100MMIterationTestCount )
	[mrcTest messageThatDoesNothing];
	END()
}


#pragma mark Object Creation

-(void) testInternalCreateAutoreleaseObject
{
	BEGIN ( k1MMIterationTestCount )
	[mrcTest createAutoreleaseObject];
	END()
}
-(void) testInternalCreateAllocInitObject
{
	BEGIN ( k1MMIterationTestCount )
	[mrcTest createAllocInitObject];
	END()
}

#pragma mark Object Return/Retain

-(void) testCreateAndReturnAutoreleaseObject
{
	BEGIN ( k1MMIterationTestCount )
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	CCNode* test = [mrcTest createAndReturnAutoreleaseObject];
	test = nil;
	[pool release];
	END()
}


@end
