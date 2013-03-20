//
//  MRCTests.m
//  Cocos2D-ARC-Performance-Test
//
//  Created by Steffen Itterheim on 20.03.13.
//
//

#import "cocos2d.h"
#import "MRCTests.h"

@implementation MRCTests

+(id) mrcTests
{
	return [[[self alloc] init] autorelease];
}

-(void) dealloc
{
	//NSLog(@"MRC Test dealloc");
	[super dealloc]; // this line is illegal under ARC
}

-(void) createAutoreleaseObject
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	CCNode* test = [CCNode node];
	test = nil;
	
	[pool release];
}

-(void) createAllocInitObject
{
	CCNode* test = [[CCNode alloc] init];
	[test release];
	test = nil;
}

-(CCNode*) createAndReturnAutoreleaseObject
{
	return [CCNode node];
}

-(void) messageThatDoesNothing
{
}

@end
