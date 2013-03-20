//
//  PerfTester_ARCvsMRC.m
//  Cocos2D-ARC-Performance-Test
//
//  Created by Steffen Itterheim on 20.03.13.
//
//

#import "PerfTester.h"
#import "ARCTests.h"
#import "MRCTests.h"

@implementation PerfTester (ARCvsMRC)

#pragma mark algorithms

-(void) testGeneticAlgorithmARC
{
	BEGIN ( 50 )
	[arcTest runGeneticAlgorithm];
	NSLog(@"%i out of %i complete", i, iters);
	END()
}
-(void) testGeneticAlgorithmMRC
{
	BEGIN ( 50 )
	[mrcTest runGeneticAlgorithm];
	NSLog(@"%i out of %i complete", i, iters);
	END()
}

-(void) testUnoptimizedContainsStringAlgorithmARC
{
	const char* string = "ein string, zwei string, drei string, vier string, fünf string, sechs string, sieben string, acht string\0";
	NSData* data = [NSData dataWithBytes:string length:strlen(string)];
	
	BEGIN ( k10KIterationTestCount )
	[arcTest data:data containsCString:"sieben string"];
	END()
}

-(void) testUnoptimizedContainsStringAlgorithmMRC
{
	const char* string = "ein string, zwei string, drei string, vier string, fünf string, sechs string, sieben string, acht string\0";
	NSData* data = [NSData dataWithBytes:string length:strlen(string)];
	
	BEGIN ( k10KIterationTestCount )
	[mrcTest data:data containsCString:"sieben string"];
	END()
}

#pragma mark Messaging

-(void) testMessageSendObjectARC
{
	BEGIN ( k100MMIterationTestCount )
	[arcTest messageThatDoesNothing];
	END()
}
-(void) testMessageSendObjectMRC
{
	BEGIN ( k100MMIterationTestCount )
	[mrcTest messageThatDoesNothing];
	END()
}


#pragma mark Object Creation

-(void) testInternalCreateAutoreleaseObjectARC
{
	BEGIN ( k1MMIterationTestCount )
	[arcTest createAutoreleaseObject];
	END()
}
-(void) testInternalCreateAutoreleaseObjectMRC
{
	BEGIN ( k1MMIterationTestCount )
	[mrcTest createAutoreleaseObject];
	END()
}
-(void) testInternalCreateAllocInitObjectARC
{
	BEGIN ( k1MMIterationTestCount )
	[arcTest createAllocInitObject];
	END()
}
-(void) testInternalCreateAllocInitObjectMRC
{
	BEGIN ( k1MMIterationTestCount )
	[mrcTest createAllocInitObject];
	END()
}

#pragma mark Object Return/Retain

-(void) testCreateAndReturnAutoreleaseObjectARC
{
	BEGIN ( k1MMIterationTestCount )
	@autoreleasepool
	{
		CCNode* test = [arcTest createAndReturnAutoreleaseObject];
		test = nil;
	}
	END()
}
-(void) testCreateAndReturnAutoreleaseObjectMRC
{
	BEGIN ( k1MMIterationTestCount )
	@autoreleasepool
	{
		CCNode* test = [mrcTest createAndReturnAutoreleaseObject];
		test = nil;
	}
	END()
}

#pragma mark Properties

-(void) testAssignCopyPropertyARC
{
	BEGIN ( k10MMIterationTestCount )
	arcTest.string = @"strapped on string strangulation";
	arcTest.string = nil;
	END()
}
-(void) testAssignCopyPropertyMRC
{
	BEGIN ( k10MMIterationTestCount )
	mrcTest.string = @"strapped on string strangulation";
	mrcTest.string = nil;
	END()
}

@end
